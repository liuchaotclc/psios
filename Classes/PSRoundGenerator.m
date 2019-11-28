//
//  PSRoundGenerator.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSRoundGenerator.h"

@implementation PSRoundGenerator

- (void) buildProperties
{
    PSProperty *hardness = [PSProperty property];
    hardness.title = @"锐度";
    hardness.delegate = self;
    (self.rawProperties)[@"hardness"] = hardness;
}

- (BOOL) canRandomize
{
    return NO;
}

- (PSProperty *) hardness
{
    return (self.rawProperties)[@"hardness"];
}

- (void) renderStamp:(CGContextRef)context randomizer:(PSRandom *)randomizer
{
    CGContextDrawImage(context, self.baseBounds, [self radialFadeWithHardness:self.hardness.value]);
}

@end
