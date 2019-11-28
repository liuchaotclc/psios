//
//  PSToolButton.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSTool.h"
#import "PSToolButton.h"
#import "PSActiveState.h"

#define kCornerRadius   6
#define kTopInset       2.0

@implementation PSToolButton

@synthesize tool = tool_;

- (UIImage *) selectedImage
{
    CGRect rect = CGRectMake(0, 0, 30, 30);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
        
    CGContextSaveGState(ctx);
        
    // clip
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 1, kTopInset)
                                                    cornerRadius:kCornerRadius];
    [path addClip];
    
    [[UIColor colorWithRed:(32.0f / 255.0f) green:(105.0f / 255.0f) blue:(221.0f / 255.0f) alpha:0.05] set];
    //[[UIColor colorWithWhite:0.0f alpha:0.05f] set];
    CGContextFillRect(ctx, rect);
        
    // draw donut to create inner shadow
    [[UIColor blackColor] set];
    CGContextAddRect(ctx, CGRectInset(rect, -20, -20));
    path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kCornerRadius];
    CGContextSetShadowWithColor(ctx, CGSizeZero, 7, [UIColor colorWithWhite:0.0 alpha:0.15].CGColor);
    path.usesEvenOddFillRule = YES;
    [path fill];
        
    CGContextRestoreGState(ctx);
        
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 0.5f, kTopInset - 0.5f) cornerRadius:kCornerRadius];
    [[UIColor colorWithWhite:1.0f alpha:1.0f] set];
    [path stroke];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CALayer *layer = self.layer;
    layer.shadowRadius = 1;
    layer.shadowOpacity = 0.9f;
    layer.shadowOffset = CGSizeZero;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    UIImage *bgImage = [[self selectedImage] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    [self setBackgroundImage:bgImage forState:UIControlStateSelected];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeToolChanged:) name:WDActiveToolDidChange object:nil];
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) activeToolChanged:(NSNotification *)aNotification
{
    self.selected = ([PSActiveState sharedInstance].activeTool == self.tool) ? YES : NO;
}

- (void) setTool:(PSTool *)tool
{
    tool_ = tool;
    
    [self setImage:tool.icon forState:UIControlStateNormal];
}


@end
