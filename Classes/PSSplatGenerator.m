//
//  PSSplatGenerator.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 

#import "PSPath.h"
#import "PSSplatGenerator.h"
#import "PSRandom.h"

@implementation PSSplatGenerator

- (void) buildProperties
{
    PSProperty *splotchiness = [PSProperty property];
    splotchiness.title = NSLocalizedString(@"Splotchiness", @"Splotchiness");
    splotchiness.minimumValue = 0;
    splotchiness.maximumValue = 25;
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
    // draw base splat
    CGContextSetGrayFillColor(ctx, 1, 1);
    PSPath *path = [self splatInRect:self.baseBounds maxDeviation:0.1 randomizer:randomizer];
    CGContextAddPath(ctx, [path pathRef]);
    CGContextFillPath(ctx);
    
    // draw holes
    for (int i = 0; i < self.splotchiness.value; i++) {
        path = [self splatInRect:[self randomRect:randomizer minPercentage:0.3f maxPercentage:0.6f] maxDeviation:0.1 randomizer:randomizer];
        CGContextAddPath(ctx, [path pathRef]);
        CGContextSetGrayFillColor(ctx, 0, 1);
        CGContextFillPath(ctx);
    }
}

@end
