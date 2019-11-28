//
//  PSPaintingFragment.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@class PSLayer;

@interface PSPaintingFragment : NSObject 

@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic) NSString *cachedFilename;

+ (PSPaintingFragment *) paintingFragmentWithData:(NSData *)data bounds:(CGRect)bounds;

- (id) initWithData:(NSData *)data bounds:(CGRect)bounds;
- (PSPaintingFragment *) inverseFragment:(PSLayer *)layer;
- (void) applyInLayer:(PSLayer *)layer;
- (NSUInteger) bytesUsed;

@end

