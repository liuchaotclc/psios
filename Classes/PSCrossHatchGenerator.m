//
//  PSCrossHatchGenerator.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSBrush.h"
#import "PSCrossHatchGenerator.h"
#import "PSRandom.h"

@implementation PSCrossHatchGenerator

- (void) buildProperties
{
    PSProperty *density = [PSProperty property];
    density.title = NSLocalizedString(@"Density", @"Density");
    density.minimumValue = 1;
    density.maximumValue = 15;
    density.conversionFactor = 1;
    density.delegate = self;
    (self.rawProperties)[@"density"] = density;
    
    PSProperty *deviation = [PSProperty property];
    deviation.title = NSLocalizedString(@"Deviation", @"Deviation");
    deviation.minimumValue = 0.0;
    deviation.maximumValue = 1.0;
    deviation.percentage = YES;
    deviation.delegate = self;
    (self.rawProperties)[@"deviation"] = deviation;
}

- (PSProperty *) density
{
    return (self.rawProperties)[@"density"];
}

- (PSProperty *) deviation
{
    return (self.rawProperties)[@"deviation"];
}

- (void) renderStamp:(CGContextRef)ctx randomizer:(PSRandom *)randomizer
{
    size_t  width = self.baseDimension;
    
    int hatches = self.density.value;
    float step = (float) width / (hatches + 1);
    float dev = 0;
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    for (float x = 1; x <= hatches; x++) {
        CGContextSetLineWidth(ctx, 5.0f + [randomizer nextFloat] * 5.0f);
        CGContextSetGrayStrokeColor(ctx, MAX(0.5, [randomizer nextFloat]), 1.0f);
        
        dev = (step / 2) * [randomizer nextFloat] * self.deviation.value;
        CGContextMoveToPoint(ctx, x*step + dev, 6);
        
        dev = (step / 2) * [randomizer nextFloat] * self.deviation.value;
        CGContextAddLineToPoint(ctx, x*step + dev, width - 6);
        CGContextStrokePath(ctx);
    }
    
    for (float y = 1; y <= hatches; y++) {
        CGContextSetLineWidth(ctx, 5.0f + [randomizer nextFloat] * 5.0f);
        CGContextSetGrayStrokeColor(ctx, MAX(0.5, [randomizer nextFloat]), 1.0f);
        
        dev = (step / 2) * [randomizer nextFloat] * self.deviation.value;
        CGContextMoveToPoint(ctx, 6, y*step + dev);
        
        dev = (step / 2) * [randomizer nextFloat] * self.deviation.value;
        CGContextAddLineToPoint(ctx, width - 6, y*step + dev);
        CGContextStrokePath(ctx);
    }
}

- (void) configureBrush:(PSBrush *)brush
{
    brush.intensity.value = 0.3f;
    brush.angle.value = 0.0f;
    brush.spacing.value = 0.02;
    brush.rotationalScatter.value = 0.0f;
    brush.positionalScatter.value = 0.5f;
    brush.angleDynamics.value = 1.0f;
    brush.weightDynamics.value = 0.0f;
    brush.intensityDynamics.value = 1.0f;
}

@end
