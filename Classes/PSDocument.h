//
//  PSDocument.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "PSDocumentChange.h"

extern NSString *kWDBrushesFileType;
extern NSString *kWDBrushesUnpackedFileType;
extern NSString *kWDBrushesMimeType;

@class PSCanvas;
@class PSPainting;
@class PSSynchronizer;

@interface PSDocument : UIDocument

@property (nonatomic, strong, readonly) PSPainting *painting;
@property (nonatomic) UIImage *thumbnail;
@property (weak, nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) PSSynchronizer *synchronizer;
@property (nonatomic, assign) BOOL loadOnlyThumbnail;

- (id) initWithFileURL:(NSURL *)url painting:(PSPainting *)painting;
- (BOOL) writeTemp:(NSString *)path type:(NSString *)contentType error:(NSError **)outError;
- (NSString *) mimeType;
- (NSString *) mimeTypeForContentType:(NSString *)typeName;
- (void) recordChange:(id<PSDocumentChange>)change;
- (void) setSavingFileType:(NSString *)typeName;
- (NSArray *) history;

+ (NSString *) contentTypeForFormat:(NSString *)name;

@end
