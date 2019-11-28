//
//  PSDragChip.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import "PSColor.h"
#import "PSDragChip.h"
#import "PSUtilities.h"

@implementation PSDragChip

@synthesize color = color_;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }

    self.opaque = NO;
    self.backgroundColor = nil;

    // shadow
    self.layer.shadowOffset = CGSizeMake(0,2);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.25;
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = CGRectInset(self.bounds, 1, 1);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:5];
    
    if (self.color.alpha < 1.0) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        [path addClip];
        PSDrawTransparencyDiamondInRect(ctx, self.bounds);
        CGContextRestoreGState(ctx);
    }
    
    [self.color set];
    [path fill];
    
    [[UIColor whiteColor] set];
    path.lineWidth = 2;
    [path stroke];
}

@end
