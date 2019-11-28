//
//  PSColorSwatch.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import "PSColorSwatch.h"
#import "PSColor.h"

static const float kCornerRadius = 9.0f;

@implementation PSColorSwatch

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
	}
    
    [self setColor:[PSColor whiteColor]];
    
	return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef    ctx = UIGraphicsGetCurrentContext();
    CGRect          bounds = [self bounds];
    
    CGContextSaveGState(ctx);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 0.5, 0.5)
                                               byRoundingCorners:corners_
                                                     cornerRadii:CGSizeMake(kCornerRadius, kCornerRadius)];
    [path addClip];
    [color_ set];
    CGContextFillRect(ctx, bounds);
    CGContextRestoreGState(ctx);
    
    [[UIColor whiteColor] set];
    path.lineWidth = 1.5;
    [path stroke];
}

- (PSColor *) color
{
    return color_;
}

- (void) setColor:(PSColor *)color
{
    color_ = color;
    
    [self setNeedsDisplay];
}

- (void) setRoundedCorners:(UIRectCorner)corners
{
    corners_ = corners;
    [self setNeedsDisplay];
}


@end
