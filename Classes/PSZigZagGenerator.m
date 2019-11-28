//
//  PSZigZagGenerator.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSBrush.h"
#import "PSZigZagGenerator.h"

@implementation PSZigZagGenerator

- (BOOL) canRandomize
{
    return NO;
}

- (void) buildProperties
{
    PSProperty *density = [PSProperty property];
    density.title = NSLocalizedString(@"Density", @"Density");
    density.minimumValue = 2;
    density.maximumValue = 20;
    density.conversionFactor = 1;
    density.delegate = self;
    (self.rawProperties)[@"density"] = density;
}

- (PSProperty *) density
{
    return (self.rawProperties)[@"density"];
}

- (void) renderStamp:(CGContextRef)ctx randomizer:(PSRandom *)randomizer
{
    int num = self.density.value;
    float step = self.baseDimension / (num + 1);
    
    NSMutableArray *oddPoints = [NSMutableArray array];
    NSMutableArray *evenPoints = [NSMutableArray array];
    
    for (int x = 1; x <= num; x++) {
        [oddPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x * step, step)]];
    }
    for (int y = 2; y <= num; y++) {
        [oddPoints addObject:[NSValue valueWithCGPoint:CGPointMake(step * num, y * step)]];
    }
    
    for (int y = 2; y <= num; y++) {
        [evenPoints addObject:[NSValue valueWithCGPoint:CGPointMake(step, y * step)]];
    }
    for (int x = 2; x <= num; x++) {
        [evenPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x * step, step * num)]];
    }
    
    NSEnumerator *oddEnum = [oddPoints objectEnumerator];
    NSEnumerator *evenEnum = [evenPoints objectEnumerator];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPoint a = [[oddEnum nextObject] CGPointValue];
    CGPathMoveToPoint(pathRef, NULL, a.x, a.y);
    
    NSValue *oddValue, *evenValue;
    while (oddValue = [oddEnum nextObject]) {
        evenValue = [evenEnum nextObject];
        
        a = [evenValue CGPointValue];
        CGPathAddLineToPoint(pathRef, NULL, a.x, a.y);
        
        a = [oddValue CGPointValue];
        CGPathAddLineToPoint(pathRef, NULL, a.x, a.y);
    }
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, self.baseBounds, [self radialFadeWithHardness:0.25]);
    
    CGContextAddPath(ctx, pathRef);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, step / 5);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetGrayStrokeColor(ctx, 1.0f, 1.0f);
    
    CGContextStrokePath(ctx);
    CGPathRelease(pathRef);
    CGContextRestoreGState(ctx);
}

- (void) configureBrush:(PSBrush *)brush
{
    brush.intensity.value = 0.25f;
    brush.angle.value = 0.0f;
    brush.spacing.value = 0.1f;
    brush.rotationalScatter.value = 1.0f;
    brush.positionalScatter.value = 0.0f;
    brush.angleDynamics.value = 0.0f;
    brush.weightDynamics.value = 0.0f;
    brush.intensityDynamics.value = 0.0f;
}

@end
