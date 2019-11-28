//
//  PSSplotchGenerator.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSBrush.h"
#import "PSPath.h"
#import "PSSplotchGenerator.h"
#import "PSRandom.h"

@implementation PSSplotchGenerator

- (void) buildProperties
{
    PSProperty *splotchiness = [PSProperty property];
    splotchiness.title = NSLocalizedString(@"Splotchiness", @"Splotchiness");
    splotchiness.minimumValue = 5;
    splotchiness.maximumValue = 50;
    splotchiness.conversionFactor = 1;
    splotchiness.delegate = self;
    (self.rawProperties)[@"splotchiness"] = splotchiness;
    
    self.blurRadius = 10;
}

- (PSProperty *) splotchiness
{
    return (self.rawProperties)[@"splotchiness"];
}

- (void) renderStamp:(CGContextRef)ctx randomizer:(PSRandom *)randomizer
{
    PSPath *path = nil;
    
    // draw splotches
    for (int i = 0; i < self.splotchiness.value; i++) {
        path = [self splatInRect:[self randomRect:randomizer minPercentage:0.2f maxPercentage:1.0f] maxDeviation:0.1 randomizer:randomizer];
        CGContextAddPath(ctx, [path pathRef]);
        CGContextSetGrayFillColor(ctx, [randomizer nextFloatMin:0.5f max:1.0f], 0.5f);
        CGContextFillPath(ctx);
    }
}

- (void) configureBrush:(PSBrush *)brush
{
    brush.intensity.value = 0.25f;
    brush.angle.value = 0.0f;
    brush.spacing.value = 0.1f;
    brush.rotationalScatter.value = 1.0f;
    brush.positionalScatter.value = 0.2f;
    brush.angleDynamics.value = 0.0f;
    brush.weightDynamics.value = 0.0f;
    brush.intensityDynamics.value = 0.75f;
}

@end
