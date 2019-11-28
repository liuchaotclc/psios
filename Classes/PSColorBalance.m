//
//  PSColorBalance.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSCoder.h"
#import "PSColorBalance.h"
#import "PSDecoder.h"

@implementation PSColorBalance

@synthesize redShift;
@synthesize greenShift;
@synthesize blueShift;

+ (PSColorBalance *) colorBalanceWithRed:(float)redShift green:(float)greenShift blue:(float)blueShift
{
    PSColorBalance *balance = [[PSColorBalance alloc] init];
    
    redShift /= 2.0;
    greenShift /= 2.0;
    blueShift /= 2.0;
    
    float average = (redShift + greenShift + blueShift) / 3.0f;
    redShift -= average;
    greenShift -= average;
    blueShift -= average;
    
    balance.redShift = redShift;
    balance.greenShift = greenShift;
    balance.blueShift = blueShift;
    
    return balance;
}

- (BOOL) isEqual:(PSColorBalance *)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return (self.redShift == object.redShift && self.blueShift == object.blueShift && self.greenShift == object.greenShift);
}

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep
{
    [coder encodeFloat:self.redShift forKey:@"red"];
    [coder encodeFloat:self.greenShift forKey:@"green"];
    [coder encodeFloat:self.blueShift forKey:@"blue"];
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    self.redShift = [decoder decodeFloatForKey:@"red"];
    self.greenShift = [decoder decodeFloatForKey:@"green"];
    self.blueShift = [decoder decodeFloatForKey:@"blue"];
}


- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: %f; %f; %f", [super description], redShift, blueShift, greenShift];
}

@end
