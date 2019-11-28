//
//  PSColor.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import "PSCoder.h"
#import "PSColor.h"
#import "PSDecoder.h"
#import "PSUtilities.h"

static NSString *WDHueKey = @"h";
static NSString *WDSaturationKey = @"s";
static NSString *WDBrightnessKey = @"b";
static NSString *WDAlphaKey = @"a";

@implementation PSColor

@synthesize hue = hue_;
@synthesize saturation = saturation_;
@synthesize brightness = brightness_;
@synthesize alpha = alpha_;

+ (PSColor *) randomColor
{
   float components[4];
    
    for (int i = 0; i < 4; i++) {
        components[i] = PSRandomFloat();
    }
    
    components[3] = 0.5 + (components[3] * 0.5);
    
    PSColor *color = [(PSColor *)[PSColor alloc] initWithHue:components[0] saturation:components[1] brightness:components[2] alpha:components[3]];
    
    return color;
}

+ (PSColor *)colorWithWhite:(float)white alpha:(CGFloat)alpha
{
    PSColor *color = [(PSColor *)[PSColor alloc] initWithHue:0 saturation:0 brightness:white alpha:alpha];
    
    return color;
}

+ (PSColor *)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(CGFloat)alpha
{
    float hue, saturation, brightness;
    
    RGBtoHSV(red, green, blue, &hue, &saturation, &brightness);
    
    PSColor *color = [(PSColor *)[PSColor alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    
    return color;
}
    
+ (PSColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    PSColor *color = [(PSColor *)[PSColor alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    
    return color;
}

- (PSColor *) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    hue_ = WDClamp(0.0f, 1.0f, hue);
    saturation_ = WDClamp(0.0f, 1.0f, saturation);
    brightness_ = WDClamp(0.0f, 1.0f, brightness);
    alpha_ = WDClamp(0.0f, 1.0f, alpha);
    
    return self;
}

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep
{
    [coder encodeFloat:hue_ forKey:WDHueKey];
    [coder encodeFloat:saturation_ forKey:WDSaturationKey];
    [coder encodeFloat:brightness_ forKey:WDBrightnessKey];
    [coder encodeFloat:alpha_ forKey:WDAlphaKey];
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    hue_ =  WDClamp(0.0f, 1.0f, [decoder decodeFloatForKey:WDHueKey]);
    saturation_ = WDClamp(0.0f, 1.0f, [decoder decodeFloatForKey:WDSaturationKey]);
    brightness_ = WDClamp(0.0f, 1.0f, [decoder decodeFloatForKey:WDBrightnessKey]);
    alpha_ = WDClamp(0.0f, 1.0f, [decoder decodeFloatForKey:WDAlphaKey]);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: H: %f, S: %f, V:%f, A: %f", [super description], hue_, saturation_, brightness_, alpha_];
}

- (BOOL) isEqual:(PSColor *)color
{
    if (color == self) {
        return YES;
    }
    
    if (![color isKindOfClass:[PSColor class]]) {
        return NO;
    }
    
    return (hue_ == color.hue &&
            saturation_ == color.saturation &&
            brightness_ == color.brightness &&
            alpha_ == color.alpha);
}

- (NSUInteger) hash
{
    int h = 256.f * hue_;
    int s = 256.f * saturation_;
    int b = 256.f * brightness_;
    int a = 256.f * alpha_;
    return (h << 24) | (s << 16) | (b << 8) | (a);
}

+ (PSColor *) colorWithDictionary:(NSDictionary *)dict
{
    float hue = [dict[@"hue"] floatValue];
    float saturation = [dict[@"saturation"] floatValue];
    float brightness = [dict[@"brightness"] floatValue];
    float alpha = [dict[@"alpha"] floatValue];
    
    return [PSColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (NSDictionary *) dictionary
{
    NSNumber *hue = @(hue_);
    NSNumber *saturation = @(saturation_);
    NSNumber *brightness = @(brightness_);
    NSNumber *alpha = @(alpha_);

    return @{@"hue": hue, @"saturation": saturation, @"brightness": brightness, @"alpha": alpha};
}

+ (PSColor *) colorWithData:(NSData *)data
{
    UInt16  *values = (UInt16 *) [data bytes];
    float   components[4];
    
    for (int i = 0; i < 4; i++) {
        components[i] = CFSwapInt16LittleToHost(values[i]);
        components[i] /= USHRT_MAX;
    }
    
    return [PSColor colorWithHue:components[0] saturation:components[1] brightness:components[2] alpha:components[3]];
}
    
- (NSData *) colorData
{
    UInt16 data[4];
    
    data[0] = hue_ * USHRT_MAX;
    data[1] = saturation_ * USHRT_MAX;
    data[2] = brightness_ * USHRT_MAX;
    data[3] = alpha_ * USHRT_MAX;
    
    for (int i = 0; i < 4; i++) {
        data[i] = CFSwapInt16HostToLittle(data[i]);
    }
    
    return [NSData dataWithBytes:data length:8];
}

- (void) set {
    [[self UIColor] set];
}

- (UIColor *) UIColor {
    return [UIColor colorWithHue:hue_ saturation:saturation_ brightness:brightness_ alpha:alpha_];
}

- (UIColor *) opaqueUIColor {
    return [UIColor colorWithHue:hue_ saturation:saturation_ brightness:brightness_ alpha:1.0];
}

- (CGColorRef) CGColor
{
    return [[self UIColor] CGColor];
}

- (CGColorRef) opaqueCGColor
{
    return [[self opaqueUIColor] CGColor];
}

- (PSColor *) colorWithAlphaComponent:(float)alpha
{
    return [PSColor colorWithHue:hue_ saturation:saturation_ brightness:brightness_ alpha:alpha];
}

- (PSColor *) adjustColor:(PSColor * (^)(PSColor *color))adjustment
{
    return adjustment(self);
}

- (float) red
{
    float   r, g, b;
    
    HSVtoRGB(hue_, saturation_, brightness_, &r, &g, &b);
    
    return r;
}

- (float) green
{
    float   r, g, b;
    
    HSVtoRGB(hue_, saturation_, brightness_, &r, &g, &b);
    
    return g;
}

- (float) blue
{
    float   r, g, b;
    
    HSVtoRGB(hue_, saturation_, brightness_, &r, &g, &b);
    
    return b;
}

- (PSColor *) colorBalanceRed:(float)rShift green:(float)gShift blue:(float)bShift
{
    float   r, g, b;
    float   h, s, v;
    
    HSVtoRGB(hue_, saturation_, brightness_, &r, &g, &b);
    
    r = WDClamp(0, 1, r + rShift);
    g = WDClamp(0, 1, g + gShift);
    b = WDClamp(0, 1, b + bShift);
    
    RGBtoHSV(r, g, b, &h, &s, &v);
    return [PSColor colorWithHue:h saturation:s brightness:v alpha:alpha_];
}

- (PSColor *) adjustHue:(float)hShift saturation:(float)sShift brightness:(float)bShift
{
    float h = hue_ + hShift;
    BOOL negative = (h < 0);
    h = fmodf(fabs(h), 1.0f);
    if (negative) {
        h = 1.0f - h;
    }
    
    sShift = 1 + sShift;
    bShift = 1 + bShift;
    float s = WDClamp(0, 1, saturation_ * sShift);
    float b = WDClamp(0, 1, brightness_ * bShift);
    
    return [PSColor colorWithHue:h saturation:s brightness:b alpha:alpha_];
}

- (PSColor *) inverted
{
    float   r, g, b;
    
    HSVtoRGB(hue_, saturation_, brightness_, &r, &g, &b);
    
    return [PSColor colorWithRed:(1.0f - r) green:(1.0f - g) blue:(1.0f - b) alpha:alpha_];
}

- (PSColor *) desaturated
{
    return [PSColor colorWithHue:hue_ saturation:0 brightness:brightness_ alpha:alpha_];
}

+ (PSColor *) blackColor
{
    return [PSColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:1.0f];
}

+ (PSColor *) grayColor
{
    return [PSColor colorWithHue:0.0f saturation:0.0f brightness:0.25f alpha:1.0f];
}

+ (PSColor *) whiteColor
{
    return [PSColor colorWithHue:0.0f saturation:0.0f brightness:1.0f alpha:1.0f];
}

+ (PSColor *) cyanColor
{
    return [PSColor colorWithRed:0 green:1 blue:1 alpha:1];
}

+ (PSColor *) redColor
{
    return [PSColor colorWithRed:1 green:0 blue:0 alpha:1];
}

+ (PSColor *) magentaColor
{
    return [PSColor colorWithRed:1 green:0 blue:1 alpha:1];
}

+ (PSColor *) greenColor
{
    return [PSColor colorWithRed:0 green:1 blue:0 alpha:1];
}

+ (PSColor *) yellowColor
{
    return [PSColor colorWithRed:1 green:1 blue:0 alpha:1];
}

+ (PSColor *) blueColor
{
    return [PSColor colorWithRed:0 green:0 blue:1 alpha:1];
}

- (PSColor *) complement
{
    float r = 1.0 - self.red;
    float g = 1.0 - self.green;
    float b = 1.0 - self.blue;
    float a = self.alpha;
    
    return [PSColor colorWithRed:r green:g blue:b alpha:a];
}

- (PSColor *) blendedColorWithFraction:(float)blend ofColor:(PSColor *)color
{
    float       inR, inG, inB;
    float       selfR, selfG, selfB;
    
    HSVtoRGB(color.hue, color.saturation, color.brightness, &inR, &inG, &inB);
    HSVtoRGB(hue_, saturation_, brightness_, &selfR, &selfG, &selfB);
    
    float r = (blend * inR) + (1.0f - blend) * selfR;
    float g = (blend * inG) + (1.0f - blend) * selfG;
    float b = (blend * inB) + (1.0f - blend) * selfB;
    float a = (blend * color.alpha) + (1.0f - blend) * self.alpha;
    
    return [PSColor colorWithRed:r green:g blue:b alpha:a];
}

- (NSString *) hexValue
{   
    float       r, g, b;

    HSVtoRGB(hue_, saturation_, brightness_, &r, &g, &b);
    return [NSString stringWithFormat:@"#%.2x%.2x%.2x", (int) (r*255 + 0.5f), (int) (g*255 + 0.5f), (int) (b*255 + 0.5f)];
}

- (void) drawSwatchInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    PSDrawTransparencyDiamondInRect(ctx, rect);
    
    [self set];
    CGContextFillRect(ctx, rect);
}

- (void) drawEyedropperSwatchInRect:(CGRect)rect
{
    [self drawSwatchInRect:rect];
}

- (BOOL) transformable
{
    return NO;
}

- (BOOL) canPaintStroke
{
    return YES;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

@end
