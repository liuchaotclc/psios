//
//  PSDocument.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSActiveState.h"
#import "PSAddLayer.h"
#import "PSBrush.h"
#import "PSCanvas.h"
#import "PSCodingProgress.h"
#import "PSDataProvider.h"
#import "PSDeferredImage.h"
#import "PSDocument.h"
#import "PSFileData.h"
#import "PSFilePlusData.h"
#import "PSJSONCoder.h"
#import "PSLayer.h"
#import "PSPainting.h"
#import "PSStartEditing.h"
#import "PSSynchronizer.h"
#import "PSTar.h"
#import "PSTypedData.h"
#import "PSUtilities.h"

NSString *kWDBrushesFileType = @"brushes";
NSString *kWDBrushesUnpackedFileType = @"brushes_unpacked";
NSString *kWDBrushesMimeType = @"application/x-brushes";

static NSString *errorDomain = @"WDDocument";
static NSString *paintingFilename = @"painting.json";
static NSString *thumbnailFilename = @"thumbnail.jpg";
static NSString *thumbnailFilenameOld = @"thumbnail.png";
static NSString *historyFilename = @"history.json";
static NSString *previewFilename = @"image.jpg";

@implementation PSDocument {
    BOOL gesture_;
    NSDate *lastAutoSave_;
    NSString *savingFileType_;
    NSMutableArray *changeQueue_;
    PSCodingProgress *progress_;
    PSPainting *preloadedPainting_;
}

@synthesize loadOnlyThumbnail = loadOnlyThumbnail_;
@synthesize painting = painting_;
@synthesize thumbnail = thumbnail_;
@synthesize synchronizer = synchronizer_;

- (id) init
{
    return [self initWithFileURL:nil painting:nil];
}

- (id) initWithFileURL:(NSURL *)url
{
    return [self initWithFileURL:url painting:nil];
}

- (id) initWithFileURL:(NSURL *)url painting:(PSPainting *)painting
{
    self = [super initWithFileURL:url];
    if (!self) {
        return nil;
    }

    synchronizer_ = [[PSSynchronizer alloc] initWithDocument:self];
    changeQueue_ = [[NSMutableArray alloc] init];
    progress_ = [[PSCodingProgress alloc] init];
    preloadedPainting_ = painting;
    
    [self recordChange:[PSStartEditing startEditing]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(codingProgress:) name:WDCodingProgressNotification object:progress_];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gestureBegan:) name:WDGestureBeganNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gestureEnded:) name:WDGestureEndedNotification object:nil];

    return self;
}

- (void) dealloc
{
    WDLog(@"Document deallocated: %@", self.displayName);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.undoManager = nil;
}

- (void) setPainting:(PSPainting *)painting
{
    if (painting_) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:WDDocumentChangedNotification object:painting_];
    }

    painting_ = painting;
    self.undoManager = painting.undoManager;
    
    if (painting_) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentChanged:) name:WDDocumentChangedNotification object:painting_];
    }
}

- (void) recordChange:(id<PSDocumentChange>)change
{
    PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:nil];
    [coder encodeObject:change forKey:nil deep:YES];
    @synchronized(changeQueue_) {
        [changeQueue_ addObject:[coder jsonData]];
    }
    if (!lastAutoSave_ || -[lastAutoSave_ timeIntervalSinceNow] > 30.0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self autosaveWithCompletionHandler:nil];
        });
    }
}

- (void) documentChanged:(NSNotification *)notification
{
    id<PSDocumentChange> change = (notification.userInfo)[@"change"];
    [self recordChange:change];
}

- (void) codingProgress:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:WDCodingProgressNotification
                                                            object:self
                                                          userInfo:@{@"progress": progress_}];
    });
}

- (void) gestureBegan:(NSNotification *)notification
{
    gesture_ = YES;
}

- (void) gestureEnded:(NSNotification *)notification
{
    gesture_ = NO;
}

- (void) setSavingFileType:(NSString *)typeName
{
    savingFileType_ = typeName;
}

- (NSString *) savingFileType
{   
    if (savingFileType_) {
        return savingFileType_;
    } else {
        return [self fileType];
    }
}

- (BOOL) loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    [progress_ reset];
    @try {
        PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:progress_];
        NSDictionary *dict = [coder decodeRoot:paintingFilename from:contents];
        self.painting = dict[@"painting"];
        self.thumbnail = [UIImage imageWithData:[dict[@"thumbnail"] data]];
        if (!self.thumbnail) {
            self.thumbnail = painting_.thumbnailImage;
        }
        return YES;
    } @catch (NSException *exception) {
        WDLog(@"Exception in loadFromContents: %@", exception);
        *outError = [NSError errorWithDomain:@"WDDocument" code:1 userInfo:@{@"exception": exception}];
        self.painting = [[PSPainting alloc] initWithSize:CGSizeMake(100.f, 100.f)];
        self.thumbnail = painting_.thumbnailImage;
        return NO;
    } @finally {
        [progress_ complete];
    }
}

- (NSString *) mimeType 
{
    return [self mimeTypeForContentType:self.fileType];
}

- (NSString *) mimeTypeForContentType:(NSString *)typeName
{
    // TODO "Brushes" -> typeName conversion should happen in import/export UI
    if ([typeName hasSuffix:kWDBrushesFileType] || [typeName isEqualToString:@"Brushes"]) {
        return kWDBrushesMimeType;
    } else {
        return [NSString stringWithFormat:@"image/%@", [self fileNameExtensionForType:typeName saveOperation:UIDocumentSaveForCreating]];
    }
}

- (NSString *) historyFile
{
    return [[self.fileURL path] stringByAppendingPathComponent:historyFilename];
}

- (id<PSDataProvider>) historyData
{
    @synchronized(changeQueue_) {
        NSMutableData *history = [NSMutableData data];
        for (NSData *data in changeQueue_) {
            [history appendBytes:"\n" length:1];
            [history appendData:data];
            [history appendBytes:"\n\0" length:2];
        }
        return [PSFilePlusData withPath:[self historyFile] data:history mediaType:@"application/json"];
    }
}

- (NSArray *) history
{
    [self.painting.brushes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [[PSActiveState sharedInstance] addTemporaryBrush:obj];
    }];
    [self.painting.undoneBrushes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [[PSActiveState sharedInstance] addTemporaryBrush:obj];
    }];
    
    NSData *historyData = self.historyData.data;
    uint8_t *bytes = (uint8_t *) historyData.bytes;
    int start = 0;
    int length = 0;
    NSMutableArray *history = [NSMutableArray array];
    while (start + length < historyData.length) {
        while (start + length < historyData.length && bytes[start + length]) {
            ++length;
        }
        NSData *json = [NSData dataWithBytes:(bytes + start) length:length];
        start += (length + 1);
        length = 0;
        [history addObject:json];
    }
    return history;
}

// this method exists because PSD files are so huge, there's no way to hold a large 10-layer one in memory
- (BOOL) writeTemp:(NSString *)path type:(NSString *)typeName error:(NSError **)outError
{
    if ([[path pathExtension] isEqualToString:kWDBrushesUnpackedFileType]) {
        WDLog(@"ERROR: writeTemp does not handle unpacked files!");
        if (outError) {
            *outError = [NSError errorWithDomain:errorDomain code:3 userInfo:@{@"message": @"writeTemp does not handle unpacked files"}];
        }
        return NO;
    } else {

        id contents = [self contentsForType:typeName error:outError];
        if (contents) {
            [[NSFileManager defaultManager] createFileAtPath:path contents:contents attributes:nil];
            return YES;
        } else {
            return NO;
        }
    }
}

- (id) contentsForType:(NSString *)typeName error:(NSError **)outError
{
    PSBeginTiming();
    
    id contents = nil;
    if ([typeName isEqualToString:@"public.png"]) {
        contents = [self.painting PNGRepresentation];
    } else if ([typeName isEqualToString:@"public.jpeg"]) {
        contents = [self.painting JPEGRepresentation];
    } else if (([[self.fileURL pathExtension] isEqualToString:kWDBrushesUnpackedFileType] && ![typeName isEqualToString:kWDBrushesFileType]) || [typeName isEqualToString:kWDBrushesUnpackedFileType]) {
        [progress_ reset];
        PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:progress_];
        UIImage *rawImage = [painting_ imageWithSize:painting_.dimensions backgroundColor:[UIColor whiteColor]];
        PSDeferredImage *thumbnail = [PSDeferredImage image:rawImage mediaType:@"image/jpeg" size:self.painting.thumbnailSize];
        PSDeferredImage *image = [PSDeferredImage image:rawImage mediaType:@"image/jpeg" size:self.painting.dimensions];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        self.painting, @"painting", 
                                        thumbnail, @"thumbnail",
                                        image, @"image", 
                                        [self historyData], @"history",
                                        nil];
        [coder encodeDictionary:dict forKey:nil];
        contents = [coder dataWithRootNamed:paintingFilename];
        [progress_ complete];
    } else if ([[self.fileURL pathExtension] isEqualToString:kWDBrushesFileType] || [typeName isEqualToString:kWDBrushesFileType]) {
        NSDictionary *unpacked = [self contentsForType:kWDBrushesUnpackedFileType error:outError];
        if (unpacked) {
            NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
            [stream open];
            PSTar *tar = [[PSTar alloc] init];
            [tar writeTarToStream:stream withFiles:unpacked baseURL:self.fileURL order:@[thumbnailFilename, paintingFilename]];
            [stream close];
            contents = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        }
    } else {
        *outError = [NSError errorWithDomain:errorDomain code:1 userInfo:@{@"type": typeName}];
    }
    
    PSEndTiming([NSString stringWithFormat:@"Contents for type %@ (%@)", typeName, outError ? *outError : nil]);
    return contents;
}

- (BOOL) writeFileData:(NSDictionary *)files toURL:(NSURL *)url alreadySaved:(NSMutableSet *)savedData error:(NSError **)outError
{
    NSFileManager *fm = [NSFileManager defaultManager];
    PSDeferredImage *thumbnail = files[thumbnailFilename];
    if (thumbnail) {
        self.thumbnail = thumbnail.scaledImage;
    }
    for (NSString *name in files) {
        NSString *path = [[url path] stringByAppendingPathComponent:name];
        id<PSDataProvider> datap = files[name];
        if (datap.isSaved == kWDSaveStatusSaved) {
            [savedData addObject:name];
        } else if (![fm createFileAtPath:path contents:[datap data] attributes:nil]) {
            if (outError) {
                *outError = [NSError errorWithDomain:errorDomain code:1 userInfo:@{@"path": path}];
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL) writeContents:(id)contents toURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation originalContentsURL:(NSURL *)originalContentsURL error:(NSError **)outError
{
#ifdef WD_DEBUG
    NSDate *start = [NSDate date];
#endif
    
    if ([[url pathExtension] isEqualToString:kWDBrushesUnpackedFileType]) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:[url path]] 
            || [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:outError]) {
            NSDictionary *dict = contents;
            NSMutableSet *savedData = [NSMutableSet set];
            [self writeFileData:dict toURL:url alreadySaved:savedData error:outError];
            if (*outError == nil) {
                // successfully saved all changed files, now copy unchanged ones
                for (NSString *name in savedData) {
                    NSURL *originalData = [originalContentsURL URLByAppendingPathComponent:name];
                    NSURL *newData = [url URLByAppendingPathComponent:name];
                    if (![[NSFileManager defaultManager] copyItemAtURL:originalData toURL:newData error:outError]) {
                        break;
                    }
                }
            }
            if (*outError == nil) {
                WDLog(@"Write contents (%@) to: %@: %gs", self.savingFileType, url, -[start timeIntervalSinceNow]);
                return YES;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    } else {
        BOOL result = [super writeContents:contents toURL:url forSaveOperation:saveOperation originalContentsURL:originalContentsURL error:outError];
        WDLog(@"Write contents (%@) to: %@: %gs", self.savingFileType, url, -[start timeIntervalSinceNow]);
        return result;
    }
}

- (void) saveCoordinated:(id)contents toURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL))completionHandler token:(id)token
{
    NSError *coordinateError = nil;
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
    [coordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForReplacing error:&coordinateError byAccessor:^(NSURL *newURL) {
        if (self.hasUnsavedChanges || saveOperation == UIDocumentSaveForCreating) {
            NSError *writeError = nil;
            NSDictionary *attributes = [self fileAttributesToWriteToURL:newURL forSaveOperation:saveOperation error:&writeError];
            if (writeError == nil) {
                [self writeContents:contents andAttributes:attributes safelyToURL:newURL forSaveOperation:saveOperation error:&writeError];
            }
            if (writeError == nil) {
                [self updateChangeCountWithToken:token forSaveOperation:saveOperation];
            } else {
                [self handleError:writeError userInteractionPermitted:NO];
            }
            if (completionHandler) {
                completionHandler(writeError == nil);
            }
        } else {
            WDLog(@"Save operation skipped: appears to have been completed by another queue");
        }
    }];
    if (coordinateError != nil) {
        [self handleError:coordinateError userInteractionPermitted:NO];
        if (completionHandler != nil) {
            completionHandler(NO);
        }
    }
}

- (void) saveToURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL))completionHandler
{
    if (preloadedPainting_) {
        self.painting = preloadedPainting_;
        preloadedPainting_ = nil;
    }

    if (self.painting == nil) {
        // special case for safety's sake; don't clobber a good painting
        WDLog(@"ERROR: saveToURL called on nil painting");
        completionHandler(NO);
        return;
    }

    if (self.hasUnsavedChanges || saveOperation == UIDocumentSaveForCreating) {
        // this is similar to how the base class is documented to behave, except that we write synchronously if the app is not active
        __block NSError *error = nil;
        id token = nil;
        NSArray *changeQueueBackup = nil;
        id contents = nil;
        @synchronized(changeQueue_) {
            token = [self changeCountTokenForSaveOperation:saveOperation];
            contents = [self contentsForType:self.savingFileType error:&error];
            changeQueueBackup = [changeQueue_ copy];
        }
        void (^tweakedCompletionHandler)(BOOL) = ^void (BOOL success) {
            @synchronized(changeQueue_) {
                if (success) {
                    // carefully remove only the objects that were saved
                    [changeQueue_ removeObjectsInArray:changeQueueBackup];
                }
            }
            for (PSLayer *layer in painting_.layers) {
                if (layer.isSaved == kWDSaveStatusTentative) {
                    layer.isSaved = success ? kWDSaveStatusSaved : kWDSaveStatusUnsaved;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler(success);
                }
            });
        };
        if (contents) {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                // write on a background queue
                // if the application backgrounds in the process, we should re-enter this method, take the else branch, and wait for the
                // save to complete in the process of file coordination (in theory)
                [self performAsynchronousFileAccessUsingBlock:^{
                    [self saveCoordinated:contents toURL:url forSaveOperation:saveOperation completionHandler:tweakedCompletionHandler token:token];
                }];
            } else {
                // write synchronously to prevent OpenGL crash -- it's not clear to me what would use OpenGL during the write but it happens
                [self saveCoordinated:contents toURL:url forSaveOperation:saveOperation completionHandler:tweakedCompletionHandler token:token];
            }
        } else {
            if (error) {
                [self handleError:error userInteractionPermitted:NO];
            }
            if (completionHandler) {
                tweakedCompletionHandler(NO);
            }
        }
    } else if (completionHandler) {
        completionHandler(YES);
    }
}

- (BOOL) readFromURL:(NSURL *)url error:(NSError **)outError
{
    PSBeginTiming();
    
    BOOL result = NO;
    if (self.painting && [self.undoManager canUndo]) {
        // for an existing painting, this happens spontaneously and we want to reject with NO or it will clear the undo manager
        if (outError) {
            *outError = [NSError errorWithDomain:@"WDDocument" code:2 userInfo:nil];
        }
        result = NO;
    } else if (self.painting) {
        // new painting
        result = YES;
    } else if (preloadedPainting_) {
        self.painting = preloadedPainting_;
        preloadedPainting_ = nil;
        result = YES;
    } else if ([[url pathExtension] isEqualToString:kWDBrushesFileType]) {
        if (self.loadOnlyThumbnail) {
            PSTar *tar = [[PSTar alloc] init];
            NSData *thumbnail = [tar readEntry:thumbnailFilename fromTar:url];
            if (thumbnail) {
                self.thumbnail = [UIImage imageWithData:thumbnail];
                result = self.thumbnail != nil;
            } else {
                NSData *thumbnail = [tar readEntry:thumbnailFilenameOld fromTar:url];
                if (thumbnail) {
                    self.thumbnail = [UIImage imageWithData:thumbnail];
                    result = self.thumbnail != nil;
                } else {
                    result = NO;
                }
            }
        } else {
            PSTar *tar = [[PSTar alloc] init];
            NSDictionary *contents = [tar readTar:url error:outError];
            if (contents) {
                result = [self loadFromContents:contents ofType:kWDBrushesFileType error:outError];
            } else {
                result = NO;
            }
        }
    } else if ([[url pathExtension] isEqualToString:kWDBrushesUnpackedFileType]) {
        if (self.loadOnlyThumbnail) {
            self.thumbnail = [UIImage imageWithContentsOfFile:[[url URLByAppendingPathComponent:thumbnailFilename] path]];
            if (self.thumbnail) {
                result = YES;
            } else {
                self.thumbnail = [UIImage imageWithContentsOfFile:[[url URLByAppendingPathComponent:thumbnailFilenameOld] path]];
                if (self.thumbnail) {
                    result = YES;
                    NSData *jpegThumbnail = UIImageJPEGRepresentation(self.thumbnail, 0.9);
                    NSString *thumbnailPath = [[url path] stringByAppendingPathComponent:thumbnailFilename];
                    [[NSFileManager defaultManager] createFileAtPath:thumbnailPath contents:jpegThumbnail attributes:nil];
                } else {
                    result = NO;
                }
            }
        } else {
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:outError];
            NSMutableDictionary *contents = [NSMutableDictionary dictionary];
            for (NSURL *fileUrl in files) {
                PSFileData *data = [PSFileData withPath:[fileUrl path] mediaType:nil];
                [contents setValue:data forKey:[[fileUrl path] lastPathComponent]];
            }
            result = [self loadFromContents:contents ofType:kWDBrushesFileType error:outError];
        }
    } else {
        NSData *contents = [NSData dataWithContentsOfURL:url];
        result = [self loadFromContents:contents ofType:self.fileType error:outError];
    }
    if (!self.loadOnlyThumbnail) {
        PSEndTiming([NSString stringWithFormat:@"Loaded %@ %d:%@", url, result, (outError ? *outError : nil)]);
    }
    if (!result && outError) {
        WDLog(@"ERROR: readFromURL: %@: %@", url, *outError);
    }
    
    lastAutoSave_ = [NSDate date]; // since we have just loaded, we can consider this document saved
    return result;
}

- (void) autosaveWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    lastAutoSave_ = [NSDate date];
    if (![self hasUnsavedChanges]) {
        WDLog(@"Autosave skipped, no changes");
    }
    if (gesture_) {
        WDLog(@"Autosave prevented due to gesture");
    } else {
        WDLog(@"Autosave");
        [super autosaveWithCompletionHandler:completionHandler];
    }
}

- (void) handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted
{
    [super handleError:error userInteractionPermitted:userInteractionPermitted];
    WDLog(@"ERROR: WDDocument: %@", error);
}

- (NSString *) displayName
{
    return [[self.fileURL lastPathComponent] stringByDeletingPathExtension];
}

+ (NSString *) contentTypeForFormat:(NSString *)name
{
    if ([name isEqualToString:@"PNG"]) {
        return @"public.png";
    } else if ([name isEqualToString:@"Photoshop"]) {
        return @"com.adobe.photoshop-image";
    } else if ([name isEqualToString:@"JPEG"]) {
        return @"public.jpeg";
    } else if ([name isEqualToString:@"Brushes"]) {
        return @"brushes";
    } else {
        WDLog(@"Unrecognized format: %@", name);
        return name;
    }
}

@end
