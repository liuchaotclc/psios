//
//  PSImageQuad.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@class PSShader;

typedef enum {
    WDShadowSegmentTopLeft = 0,
    WDShadowSegmentTop,
    WDShadowSegmentTopRight,
    WDShadowSegmentRight,
    WDShadowSegmentBottomRight,
    WDShadowSegmentBottom,
    WDShadowSegmentBottomLeft,
    WDShadowSegmentLeft
} WDShadowSegment;

@interface PSShadowQuad : NSObject

@property (nonatomic) UIImage *image;
@property (nonatomic) NSUInteger dimension;
@property (nonatomic) CGRect shadowedRect;
@property (nonatomic) WDShadowSegment segment;

+ (PSShadowQuad *) imageQuadWithImage:(UIImage *)image dimension:(NSUInteger)dimension segment:(WDShadowSegment)segment;

+ (void) configureBlit:(GLfloat *)proj withShader:(PSShader *)shader;
- (void) blitWithScale:(float)scale;

@end
