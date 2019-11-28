//
//  PSHueSaturation.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSHueSaturation.h"

@implementation PSHueSaturation

@synthesize hueShift;
@synthesize saturationShift;
@synthesize brightnessShift;

+ (PSHueSaturation *) hueSaturationWithHue:(float)hueShift saturation:(float)saturationShift brightness:(float)brightnessShift
{
    PSHueSaturation *hueSat = [[PSHueSaturation alloc] init];
    
    hueSat.hueShift = hueShift;
    hueSat.saturationShift = saturationShift;
    hueSat.brightnessShift = brightnessShift;
    
    return hueSat;    
}

- (BOOL) isEqual:(PSHueSaturation *)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return (self.hueShift == object.hueShift && self.saturationShift == object.saturationShift && self.brightnessShift == object.brightnessShift);
}

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep
{
    [coder encodeFloat:self.hueShift forKey:@"hue"];
    [coder encodeFloat:self.saturationShift forKey:@"saturation"];
    [coder encodeFloat:self.brightnessShift forKey:@"brightness"];
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    self.hueShift = [decoder decodeFloatForKey:@"hue"];
    self.saturationShift = [decoder decodeFloatForKey:@"saturation"];
    self.brightnessShift = [decoder decodeFloatForKey:@"brightness"];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: %f; %f; %f", [super description], hueShift, saturationShift, brightnessShift];
}

@end
