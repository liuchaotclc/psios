//
//  PSSquareBristleGenerator.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
#import "PSBrush.h"
#import "PSSquareBristleGenerator.h"
#import "PSRandom.h"

@implementation PSSquareBristleGenerator

- (void) buildProperties
{
    PSProperty *bristleDensity = [PSProperty property];
    bristleDensity.title = NSLocalizedString(@"Bristle Density", @"Bristle Density");
    bristleDensity.minimumValue = 2;
    bristleDensity.maximumValue = 30;
    bristleDensity.conversionFactor = 1;
    bristleDensity.delegate = self;
    [self.rawProperties setValue:bristleDensity forKey:@"bristleDensity"];
}

- (PSProperty *) bristleDensity
{
    return (self.rawProperties)[@"bristleDensity"];
}

- (void) renderStamp:(CGContextRef)ctx randomizer:(PSRandom *)randomizer
{
    size_t  width = self.baseDimension;
    
    int steps = self.bristleDensity.value;
    float dim = (float) width / steps;
    CGRect box = CGRectMake(0, 0, dim, dim);
    
    for (float y = 0; y < steps; y++) {
        for (float x = 0; x < steps; x++) {
            box.origin = CGPointMake(x * dim, y * dim);
            float inset = [randomizer nextFloat] * 0.25 * dim;
            
            CGContextSetGrayFillColor(ctx, [randomizer nextFloat], 1.0f);
            CGContextFillEllipseInRect(ctx, CGRectInset(box, inset, inset));
        }
    }
}

- (void) configureBrush:(PSBrush *)brush
{
    brush.intensity.value = 0.2f;
    brush.angle.value = 0.0f;
    brush.spacing.value = 0.02;
    brush.rotationalScatter.value = 0.0f;
    brush.positionalScatter.value = 0.5f;
    brush.angleDynamics.value = 1.0f;
    brush.weightDynamics.value = 0.0f;
    brush.intensityDynamics.value = 1.0f;
}

@end
