//
//  PSColorInfoView.m
//  PSIos
//
//  Created by liuchao on 2019/11/6.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import "PSColorInfoView.h"


const CGFloat kHRColorInfoViewLabelHeight = 18.;
const CGFloat kHRColorInfoViewCornerRadius = 3.;

@interface PSColorInfoView () {
    UIColor *_color;
}
@end

@implementation PSColorInfoView {
    UILabel *_hexColorLabel;
    CALayer *_borderLayer;
}

@synthesize color = _color;

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    self.backgroundColor = [UIColor clearColor];
    _hexColorLabel = [[UILabel alloc] init];
    _hexColorLabel.backgroundColor = [UIColor clearColor];
    _hexColorLabel.font = [UIFont systemFontOfSize:12];
    _hexColorLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1];
    _hexColorLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:_hexColorLabel];

    _borderLayer = [[CALayer alloc] initWithLayer:self.layer];
    _borderLayer.cornerRadius = kHRColorInfoViewCornerRadius;
    _borderLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    _borderLayer.borderWidth = 1.f / [[UIScreen mainScreen] scale];
    [self.layer addSublayer:_borderLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _hexColorLabel.frame = CGRectMake(
            0,
            CGRectGetHeight(self.frame) - kHRColorInfoViewLabelHeight,
            CGRectGetWidth(self.frame),
            kHRColorInfoViewLabelHeight);

    _borderLayer.frame = (CGRect) {.origin = CGPointZero, .size = self.frame.size};
}

- (void)setColor:(UIColor *)color {
    _color = color;
    CGFloat r, g, b, a;
    [_color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int) (r * 255.0f)<<16 | (int) (g * 255.0f)<<8 | (int) (b * 255.0f)<<0;
    _hexColorLabel.text = [NSString stringWithFormat:@"#%06x", rgb];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect colorRect = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect) - kHRColorInfoViewLabelHeight);

    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRoundedRect:colorRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(4, 4)];
    [rectanglePath closePath];
    [self.color setFill];
    [rectanglePath fill];
}

- (UIView *)viewForBaselineLayout {
    return _hexColorLabel;
}

@end

