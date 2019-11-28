//
//  PSColorWell.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSColor.h"
#import "PSColorWell.h"
#import "PSUtilities.h"

const float kWDColorWellShadowOpacity = 0.8f;

@implementation PSColorWell

@synthesize color;
@synthesize shape;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    [self buildShape];
    
    self.opaque = NO;
    self.backgroundColor = nil;
    
    return self;
}

- (void) buildShape
{
    float inset =  8;
    float cornerRadius = 33;
    
    CGRect box = CGRectInset(self.bounds, inset, inset);
    
    box = CGRectOffset(box, 0, 1);
    self.shape = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(box, 0.5, 0.5) byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    self.shape.lineWidth = 1;
    
    CALayer *layer = self.layer;
    layer.shadowRadius = 1;
    layer.shadowOpacity = kWDColorWellShadowOpacity;
    layer.shadowOffset = CGSizeZero;
    layer.shadowPath = [self shape].CGPath;
}

- (void) setColor:(PSColor *)inColor
{
    color = inColor;
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
    if (color.alpha < 1.0) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        [self.shape addClip];
        PSDrawTransparencyDiamondInRect(ctx, self.shape.bounds);
        CGContextRestoreGState(ctx);
    }
    
    [self.color set];
    [self.shape fill];
    
    [[UIColor whiteColor] set];
    [self.shape stroke];
}

@end
