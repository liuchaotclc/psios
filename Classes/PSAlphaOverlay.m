//
//  PSAlphaOverlay.m
//  PSIos
//
//  Created by liuchao on 2019/11/6.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import "PSAlphaOverlay.h"
#import "PSColorComparator.h"
#import "PSActiveState.h"

@implementation PSAlphaOverlay
@synthesize title;
@synthesize value;
- (CGRect) squareBounds
{
    CGRect square = self.bounds;
    square.size.height = square.size.width;
    
    return square;
}

- (void) configureTitle
{
    CGRect square = [self squareBounds];
    CGRect frame = square;
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = nil;
    label.opaque = NO;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text = @"512 px";
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, 1);

    [label sizeToFit];
    frame = label.frame;
    frame.size.width = CGRectGetWidth(square);
    frame.origin.y = 10;
    label.frame = frame;
    
    [self addSubview:label];
    self.title = label;
}

- (void) setColor:(PSColor *)color
{
    CGRect square = [self squareBounds];
  
    if (!_colorInfoview) {
        _colorInfoview = [[PSColorInfoView alloc] initWithFrame:CGRectInset(square, 60, 60)];
//        _colorComparator.frame = CGRectInset(square, 60, 60);
//        [_colorComparator.layer setMinificationFilter:kCAFilterTrilinear];

        [self addSubview:_colorInfoview];
    }
    [_colorInfoview setColor:[color UIColor]];
    
}


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.opaque = NO;
    self.backgroundColor = nil;
    
    [self configureTitle];
    
    [self setColor:[PSActiveState sharedInstance].paintColor];
    
    return self;
}

- (void) setValue:(float)inValue
{
    value = inValue;
    
    title.text = [NSString stringWithFormat:NSLocalizedString(@"%d", @"%d"), (int)value];
    
    float percentage = 0.05f + (value / 100.0f) * 0.95;
    PSColor *usedColor = [PSActiveState sharedInstance].paintColor;
    
    PSColor *newColor = [PSColor colorWithHue:[usedColor hue]
                                      saturation:[usedColor saturation]
                                      brightness:[usedColor brightness]
                                           alpha:percentage];
    [_colorInfoview setColor:[newColor UIColor]];
    [PSActiveState sharedInstance].paintColor = newColor;
   
}


- (void)drawRect:(CGRect)rect
{
    CGRect square = [self squareBounds];
    float heightDelta = CGRectGetHeight(self.bounds) - CGRectGetHeight(square);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:square cornerRadius:11];
    
    if (heightDelta > 0.0f) {
        float dimension = heightDelta / M_SQRT2 * 2;
        UIBezierPath *point = [UIBezierPath bezierPathWithRect:CGRectMake(-dimension / 2, -dimension / 2, dimension, dimension)];
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, CGRectGetMidX(self.bounds), CGRectGetHeight(square));
        transform = CGAffineTransformRotate(transform, M_PI_4);
        [point applyTransform:transform];
                              
        [roundedRect appendPath:point];
    }
    
    [[UIColor colorWithWhite:0.0f alpha:0.5f] set];
    [roundedRect fill];
}


@end
