//
//  PSProperty.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSCoder.h"
#import "PSCoding.h"
#import "PSDecoder.h"
#import "PSProperty.h"
#import "PSUtilities.h"

NSString *WDPropertyChangedNotification = @"WDPropertyChangedNotification";

static NSString *WDPercentageKey = @"pct";
static NSString *WDConversionFactorKey = @"conversion";
static NSString *WDTitleKey = @"title";
static NSString *WDMinimumValueKey = @"min";
static NSString *WDMaximumValueKey = @"max";
static NSString *WDValueKey = @"value";

@implementation PSProperty

@synthesize title;
@synthesize percentage;
@synthesize conversionFactor;
@synthesize minimumValue;
@synthesize maximumValue;
@synthesize value;
@synthesize delegate;

+ (PSProperty *) property
{
    return [[PSProperty alloc] init];
}

- (id) init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }

    self.minimumValue = 0.0f;
    self.maximumValue = 1.0f;
    self.conversionFactor = 100.0f;

    return self;
}


- (id) copyWithZone:(NSZone *)zone
{
    PSProperty *copy = [[PSProperty alloc] init];
    
    copy.title = self.title;
    copy.percentage = self.percentage;
    copy.conversionFactor = self.conversionFactor;
    copy.minimumValue = self.minimumValue;
    copy.maximumValue = self.maximumValue;
    copy.value = self.value;
    
    return copy;
}

- (BOOL) isEqual:(PSProperty *)object
{
    if (!object) {
        return NO;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return (self.conversionFactor == object.conversionFactor &&
            self.percentage == object.percentage &&
            self.minimumValue == object.minimumValue &&
            self.maximumValue == object.maximumValue &&
            self.value == object.value &&
            [self.title isEqualToString:object.title]);
}

- (void) setValue:(float)aValue
{
    float clamped = WDClamp(self.minimumValue, self.maximumValue, aValue);
    
    if (clamped != value) {
        value = clamped;
        [delegate propertyChanged:self];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WDPropertyChangedNotification object:self];
    }
}

- (BOOL) canIncrement
{
    return value < maximumValue;
}

- (BOOL) canDecrement
{
    return value > minimumValue;
}

- (void) increment
{
    self.value = (roundf(value * conversionFactor) + 1) / conversionFactor;
}

- (void) decrement
{
    self.value = (roundf(value * conversionFactor) - 1) / conversionFactor;
}

- (void) randomize
{
    float   r = PSRandomFloat() * (self.maximumValue - self.minimumValue) + self.minimumValue;
    self.value = roundf(r * conversionFactor) / conversionFactor;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: %@; value: %f; range: [%f,%f]", [super description],
            title, value, minimumValue, maximumValue];
}


#pragma mark -
#pragma mark WDCoding

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep
{
    [coder encodeBoolean:self.percentage forKey:WDPercentageKey];
    [coder encodeFloat:self.conversionFactor forKey:WDConversionFactorKey];
    [coder encodeString:self.title forKey:WDTitleKey];
    [coder encodeFloat:self.minimumValue forKey:WDMinimumValueKey];
    [coder encodeFloat:self.maximumValue forKey:WDMaximumValueKey];
    [coder encodeFloat:self.value forKey:WDValueKey];
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    self.percentage = [decoder decodeBooleanForKey:WDPercentageKey];
    self.conversionFactor = [decoder decodeFloatForKey:WDConversionFactorKey];
    self.title = [decoder decodeStringForKey:WDTitleKey];
    self.minimumValue = [decoder decodeFloatForKey:WDMinimumValueKey];
    self.maximumValue = [decoder decodeFloatForKey:WDMaximumValueKey];
    self.value = [decoder decodeFloatForKey:WDValueKey];
}

@end
