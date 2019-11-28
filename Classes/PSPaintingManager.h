//
//  PSPaintingManager.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@class PSPainting;
@class PSDocument;

@interface PSPaintingManager : NSObject {
    NSMutableArray  *paintingNames_;
}

+ (PSPaintingManager *) sharedInstance;

- (NSString *) documentDirectory;
- (NSString *) paintingPath;
- (NSURL *) urlForName:(NSString *)name;
- (BOOL) paintingExists:(NSString *)painting;

- (void) createNewPaintingWithSize:(CGSize)size afterSave:(void (^)(PSDocument *document))afterSave;
- (BOOL) createNewPaintingWithImage:(UIImage *)image;
- (BOOL) createNewPaintingWithImageAtURL:(NSURL *)imageURL;
- (BOOL) createNewPaintingWithImage:(UIImage *)image imageName:(NSString *)imageName
                          afterSave:(void (^)(PSDocument *document))afterSave;

- (PSDocument *) paintingWithName:(NSString *)name;
- (PSDocument *) paintingAtIndex:(NSUInteger)index;
- (NSData *) packedPainting:(NSString *)name;

- (NSUInteger) numberOfPaintings;
- (NSArray *) paintingNames;

- (NSString *) fileAtIndex:(NSUInteger)ix;

- (PSDocument *) duplicatePainting:(PSDocument *)painting;

- (void) installSamples:(NSArray *)urls;
- (NSString *) installPaintingFromURL:(NSURL *)url error:(NSError **)outError;

- (void) installPainting:(PSPainting *)painting
                        withName:(NSString *)paintingName
                     initializer:(void (^)(PSDocument *document))initializer;

- (void) installPainting:(PSPainting *)painting
                withName:(NSString *)paintingName
             initializer:(void (^)(PSDocument *document))initializer
               afterSave:(void (^)(PSDocument *document))afterSave;

- (void) deletePainting:(PSDocument *)painting;
- (void) deletePaintings:(NSMutableSet *)set;

- (NSString *) uniqueFilenameWithPrefix:(NSString *)prefix;
- (void) renamePainting:(NSString *)painting newName:(NSString *)newName;

- (void) getThumbnail:(NSString *)name withHandler:(void(^)(UIImage *))handler;

@end


extern NSString *WDPaintingFileExtension;

// notifications
extern NSString *WDPaintingsDeleted;
extern NSString *WDPaintingAdded;
extern NSString *WDPaintingRenamed;

extern NSString *WDPaintingOldFilenameKey;
extern NSString *WDPaintingNewFilenameKey;

