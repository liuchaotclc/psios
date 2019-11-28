//
//  PSAlphaSliderVertical.m
//  PSIos
//
//  Created by liuchao on 2019/11/6.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import "PSAlphaSliderVertical.h"
#import "PSActiveState.h"
#import "PSBrush.h"
#import "PSAlphaOverlay.h"
#import "PSUtilities.h"
#import "UIView+Additions.h"

#define kWDOverlayDimension     200
#define kWDOverlayPointerHeight 25
@interface PSAlphaSliderVertical ()
@property (nonatomic) float offset;
@property (nonatomic) BOOL moved;
@end
@implementation PSAlphaSliderVertical

@synthesize minimumValue;
@synthesize maximumValue;
@synthesize value;
@synthesize thumbSize;
@synthesize offset;
@synthesize parentViewForOverlay;
@synthesize moved;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.opaque = NO;
    self.backgroundColor = nil;
    self.contentMode = UIViewContentModeRedraw;
    
    self.thumbSize = 38;
    self.minimumValue = 0;
    self.maximumValue = 100;
    
    
    return self;
}

- (float) percentage
{
    float delta = (maximumValue - minimumValue);
    float v = (value - minimumValue) * (8.0f / delta) + 1.0f;
    v = log(v);
    v /= 2.1972245773362196;
    
    return v;
}

- (void) computeValue:(CGPoint)pt
{
    CGRect  trackRect = CGRectInset(self.bounds, 0, 4);
    float   percentage;
    
    trackRect = CGRectInset(trackRect, 0, self.thumbSize / 2);
    percentage = (pt.y - CGRectGetMinY(trackRect)) / CGRectGetHeight(trackRect);
    percentage = WDClamp(0.0f, 1.0f, percentage);
    
    float delta = (maximumValue - minimumValue);
    self.value = delta * (exp(2.1972245773362196 * percentage) - 1.0f) / 8.0f + minimumValue;
    
    [self setNeedsDisplay];
}

- (CGRect) thumbRect
{
    CGRect  trackRect = CGRectInset(self.bounds, 0, 4);
    float   trackLength = CGRectGetHeight(trackRect) - self.thumbSize;
    float   centerY = (self.thumbSize / 2) + (trackLength * [self percentage]);
    CGRect  thumbRect = CGRectMake(CGRectGetMinX(trackRect), centerY - (thumbSize / 2) + 1, CGRectGetWidth(trackRect)/2, self.thumbSize);
    
    return thumbRect;
}

- (void) drawRect:(CGRect)rect
{
    CGRect bound = self.bounds;
       bound.size.width = bound.size.width/ 2;
    UIBezierPath *path = nil;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    float radius = CGRectGetWidth(self.bounds)/2;
    float lineWidth = 2;
    
    [[UIColor blackColor] set];
    CGRect trackRect = CGRectInset(bound, 0, 4);
    trackRect = CGRectInset(trackRect, 1, 2) ;

    [[UIColor colorWithWhite:0.4 alpha:0.1] set];
    if(moved){
        CGRect topRect = trackRect;
        topRect.size.height = 15;
        path = [UIBezierPath bezierPathWithRoundedRect:topRect cornerRadius:radius];
        [path fill];

        CGRect bottomRect = trackRect;
        bottomRect.origin.y = CGRectGetMaxY(trackRect) - 15;
        bottomRect.size.height = 15;
        path = [UIBezierPath bezierPathWithRoundedRect:bottomRect cornerRadius:radius];
        [path fill];
    
        [[UIColor whiteColor] set];
        
        path = [UIBezierPath bezierPathWithRoundedRect:trackRect cornerRadius:radius];
        path.lineWidth = lineWidth;
        [path stroke];
    }
    
    //画滑块
    CGRect thumbRect = [self thumbRect];
    // knockout a hole
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(thumbRect, -2, -2) byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(radius, radius)];
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    [path fill];
    
    thumbRect = CGRectInset(thumbRect, 1, 1);
    path = [UIBezierPath bezierPathWithRoundedRect:thumbRect byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(radius , radius )];
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    path.lineWidth = lineWidth;
    [[UIColor colorWithRed:0.0  green: 0.0  blue: 0.0  alpha: 0.1] set];
//    [[UIColor colorWithWhite:0.4 alpha:0.1] set];
    [path fill];
     [[UIColor colorWithRed:0.0  green: 0.0  blue: 0.0  alpha: 0.8] set];
//    [[UIColor whiteColor] set];
    [path stroke];
    
  
}

- (void) setValue:(float)inValue
{
    value = WDClamp(minimumValue, maximumValue, inValue);
    [self setNeedsDisplay];
}

- (CGRect) overlayFrame
{
    float   pointerHeight = parentViewForOverlay ? 0 : kWDOverlayPointerHeight;
   
    return CGRectMake(0, 0, kWDOverlayDimension, kWDOverlayDimension + pointerHeight);
}

- (void) showOverlayAtPoint:(CGPoint)pt
{
    if (!self.overlay) {
        PSAlphaOverlay *view = [[PSAlphaOverlay alloc] initWithFrame:[self overlayFrame]];

        if (parentViewForOverlay) {
            view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

            [parentViewForOverlay addSubview:view];
            view.sharpCenter = PSCenterOfRect(parentViewForOverlay.bounds);
        }
        _overlay = view;
    }

    if (!parentViewForOverlay) {
        _overlay.sharpCenter = CGPointMake(pt.x, CGRectGetMinY(self.bounds) - (kWDOverlayDimension + kWDOverlayPointerHeight) / 2.0f + 8);
    }

    [_overlay setValue:self.value];
}

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    offset = pt.y - CGRectGetMidY([self thumbRect]);
    
    moved = NO;
    
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    
    if (!moved) {
        offset = pt.y - CGRectGetMidY([self thumbRect]);
        moved = YES;
    }
    
    pt.y -= offset;
    [self computeValue:pt];
    
    [self showOverlayAtPoint:PSCenterOfRect([self thumbRect])];
    
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!moved) {
        self.value = (offset > 0) ? (value + 1) : (value - 1);
    }
    moved = NO;
    [self setNeedsDisplay];
    [self.overlay removeFromSuperview];
    self.overlay = nil;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) cancelTrackingWithEvent:(UIEvent *)event
{
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}


@end
