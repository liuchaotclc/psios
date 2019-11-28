//
//  PSColor.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <UIKit/UIKit.h>
#import "PSCoding.h"

@interface PSColor : NSObject <PSCoding, NSCopying> {
    CGFloat   hue_;
    CGFloat   saturation_;
    CGFloat   brightness_;
    CGFloat   alpha_;
}

@property (nonatomic, readonly) CGFloat hue;
@property (nonatomic, readonly) CGFloat saturation;
@property (nonatomic, readonly) CGFloat brightness;
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) float red;
@property (nonatomic, readonly) float green;
@property (nonatomic, readonly) float blue;

+ (PSColor *) randomColor;
+ (PSColor *) colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (PSColor *) colorWithWhite:(float)white alpha:(CGFloat)alpha;
+ (PSColor *) colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(CGFloat)alpha;
- (PSColor *) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;

+ (PSColor *) colorWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) dictionary;

+ (PSColor *) colorWithData:(NSData *)data;
- (NSData *) colorData;

- (UIColor *) UIColor;
- (UIColor *) opaqueUIColor;

- (CGColorRef) CGColor;
- (CGColorRef) opaqueCGColor;

- (void) set;

- (PSColor *) adjustColor:(PSColor * (^)(PSColor *color))adjustment;
- (PSColor *) colorBalanceRed:(float)rShift green:(float)gShift blue:(float)bShift;
- (PSColor *) adjustHue:(float)hShift saturation:(float)sShift brightness:(float)bShift;
- (PSColor *) inverted;
- (PSColor *) desaturated;
- (PSColor *) colorWithAlphaComponent:(float)alpha;

+ (PSColor *) blackColor;
+ (PSColor *) grayColor;
+ (PSColor *) whiteColor;
+ (PSColor *) cyanColor;
+ (PSColor *) redColor;
+ (PSColor *) magentaColor;
+ (PSColor *) greenColor;
+ (PSColor *) yellowColor;
+ (PSColor *) blueColor;

- (NSString *) hexValue;

- (PSColor *) complement;
- (PSColor *) blendedColorWithFraction:(float)fraction ofColor:(PSColor *)color;

- (void) drawEyedropperSwatchInRect:(CGRect)rect;

@end
