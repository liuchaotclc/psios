//
//  PSColorWheel.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSColorWheel.h"
#import "PSColor.h"
#import "PSColorIndicator.h"
#import "PSUtilities.h"
#import "UIView+Additions.h"

@interface PSColorWheel (Private)
- (CGImageRef) p_wheelImage;
- (void) p_buildWheelImage;
@end

@implementation PSColorWheel

@synthesize color = color_;
@synthesize radius = radius_;
@synthesize hue = hue_;

- (int) wheelWidth 
{
    return 35;
}

- (CGPoint) hueConstrainPoint:(CGPoint)pt
{
    CGPoint center = PSCenterOfRect([self bounds]);
    CGPoint delta = PsSubtractPoints(pt, center);
    
    delta = PSNormalizePoint(delta);
    delta = PSMultiplyPointScalar(delta, [self radius] - (self.wheelWidth / 2.0f + 1));
    
    return PSAddPoints(center, delta);
}

- (void) awakeFromNib
{
    CGRect frame = [self frame];
    
    // compute radius
    float width = CGRectGetWidth(frame);
    float height = CGRectGetHeight(frame);
    float diameter = MIN(width, height);
    radius_ = floor(diameter / 2.0f);
    
    indicator_ = [[PSColorIndicator alloc] initWithFrame:CGRectMake(0,0,24,24)];
    indicator_.sharpCenter = [self hueConstrainPoint:CGPointMake(0,1)];
    indicator_.opaque = NO;
    indicator_.color = nil;
    [self addSubview:indicator_];
}

- (void)drawRect:(CGRect)rect
{ 
	CGRect				bounds = CGRectInset(self.bounds, 1, 1);
	CGContextRef		ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    CGContextAddEllipseInRect(ctx, bounds);
    CGContextAddEllipseInRect(ctx, CGRectInset(bounds, self.wheelWidth, self.wheelWidth));
    CGContextEOClip(ctx);
	CGContextDrawImage(ctx, self.bounds, [UIImage imageNamed:@"color_wheel.png"].CGImage);
    
    CGContextSetShadow(ctx, CGSizeMake(0,4), 8);
    CGContextAddRect(ctx, CGRectInset(bounds, -20, -20));
    CGContextAddEllipseInRect(ctx, CGRectInset(bounds, -1, -1));
    CGContextAddEllipseInRect(ctx, CGRectInset(bounds, self.wheelWidth + 1, self.wheelWidth + 1));
    CGContextEOFillPath(ctx);
    
    CGContextRestoreGState(ctx);
    
    // stroke oval
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(ctx, 1.5f);
    CGContextStrokeEllipseInRect(ctx, bounds);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(bounds, self.wheelWidth, self.wheelWidth));
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    CGPoint center = PSCenterOfRect([self bounds]);
    CGPoint delta = PsSubtractPoints(pt, center);
    float   distance = WDDistance(delta, CGPointZero) / [self radius];
    
    if (distance >= 1.0f) {
        return NO;
    }
    
    value_ = [self hueConstrainPoint:pt];    
    indicator_.sharpCenter = value_;
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    value_ = [self hueConstrainPoint:[touch locationInView:self]];
    
    indicator_.sharpCenter = value_;
    
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)dealloc
{
    CGImageRelease(wheelImage_);
}

- (float) hue
{
    CGPoint center = PSCenterOfRect([self bounds]);
    
    CGPoint delta = PsSubtractPoints(value_, center);
    float angle = -atan2(delta.y, delta.x);
    if (angle < 0.0) {
        angle += 2*M_PI;
    }
    
    angle *= (180.0 / M_PI);
    angle = fmod(angle, 360.0f);
    
    return (angle / 360.0f);
}

- (PSColor *) color
{
    return [PSColor colorWithHue:[self hue] saturation:[color_ saturation] brightness:[color_ brightness] alpha:1.0f];
}

- (void) setColor:(PSColor *)color
{
    CGPoint center = PSCenterOfRect([self bounds]);
    
    float hue = [color hue];
    hue *= -(2 * M_PI);
    
    color_ = color;

    value_.x = cos(hue) * [self radius];
    value_.y = sin(hue) * [self radius];
    value_ = PSAddPoints(center, value_);
    indicator_.sharpCenter = [self hueConstrainPoint:value_];
}

@end

@implementation PSColorWheel (Private)

- (CGImageRef) p_wheelImage
{
    if (!wheelImage_) {
        [self p_buildWheelImage];
    }
    
    return wheelImage_;
}

- (void) p_buildWheelImage
{
    int             x, y;
    int             radius = [self radius];
    CGPoint         currentPt, center = CGPointMake(radius, radius);
    CGPoint         delta;
    float           angle;
    float           r,g,b;
    int             diameter = radius * 2;
    int             bpr = diameter * 4;
    UInt8           *data, *ptr;
    
    ptr = data = calloc(1, sizeof(unsigned char) * diameter * bpr);
    
    for (y = 0; y < diameter; y++) {
        for (x = 0; x < diameter; x++) {
            // compute hue angle
            currentPt = CGPointMake(x,y);
            delta = PsSubtractPoints(currentPt, center);
                
            angle = atan2(delta.y, delta.x);
            if (angle < 0.0) {
                angle += 2 * M_PI;
            }
            angle /= (2.0f * M_PI);
                
            HSVtoRGB(angle, 1.0f, 1.0f, &r, &g, &b);
                      
            ptr[x*4] = 255;
            ptr[x*4+1] = r * 255;
            ptr[x*4+2] = g * 255;
            ptr[x*4+3] = b * 255;
        }
        ptr += bpr;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(data, diameter, diameter, 8, bpr, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    wheelImage_ = CGBitmapContextCreateImage(ctx);
    
    // clean up
    free(data);
    CGContextRelease(ctx);
}

@end
