//
//  PSBlendModes.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSBlendModes.h"

NSArray * PSBlendModes()
{
    static NSArray *modes = nil;
    
    if (!modes) {
        modes = @[@(PSBlendModeNormal),
                 @(PSBlendModeMultiply),
                 @(PSBlendModeScreen),
                 @(PSBlendModeExclusion)];
    }
    
    return modes;
}

NSArray * WDBlendModeDisplayNames()
{
    static NSArray *displayNames = nil;
    
    if (!displayNames) {
        displayNames = @[NSLocalizedString(@"Normal", @"Normal blending mode"),
                        NSLocalizedString(@"Multiply", @"Multiply blending mode"),
                        NSLocalizedString(@"Screen", @"Screen blending mode"),
                        NSLocalizedString(@"Exclude", @"Exclusion blending mode")];
    }
    
    return displayNames;
}

NSString * WDDisplayNameForBlendMode(PSBlendMode blendMode)
{
    static NSDictionary *map = nil;
    
    if (!map) {
        map = [NSDictionary dictionaryWithObjects:WDBlendModeDisplayNames() forKeys:PSBlendModes()];
    }
    
    return map[@(blendMode)];
}

PSBlendMode WDValidateBlendMode(PSBlendMode blendMode)
{
    NSNumber *test = @(blendMode);
    
    NSUInteger oldBlendModes[] = {
        PSBlendModeNormal,
        PSBlendModeMultiply,
        PSBlendModeScreen,
        PSBlendModeNormal, // old lighten mode
        PSBlendModeExclusion,
        PSBlendModeNormal, // old add mode
        PSBlendModeNormal // old subtract mode
    };
    
    if ([PSBlendModes() containsObject:test]) {
        return blendMode;
    } else if (blendMode < 7) {
        return (PSBlendMode) oldBlendModes[blendMode];
    } else {
        return PSBlendModeNormal;
    }
}

