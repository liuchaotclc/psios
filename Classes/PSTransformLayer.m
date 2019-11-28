//
//  PSTransformLayer.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSLayer.h"
#import "PSPainting.h"
#import "PSTransformLayer.h"
#import "PSUtilities.h"

static const int steps = 20;

@implementation PSTransformLayer 

@synthesize layerUUID;
@synthesize transform;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
    self.transform = [decoder decodeTransformForKey:@"transform"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:self.layerUUID forKey:@"layer"];
    [coder encodeTransform:self.transform forKey:@"transform"];
}

- (int) animationSteps:(PSPainting *)painting
{
    return steps;
}

- (void) beginAnimation:(PSPainting *)painting
{
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    if (!layer) {
        return NO;
    }

    CGPoint a = CGPointZero; // pivot
    CGPoint b = CGPointMake(1.0f, 0.0f);
    
    a = CGPointApplyAffineTransform(a, self.transform);
    b = CGPointApplyAffineTransform(b, self.transform);
    
    CGPoint delta = PsSubtractPoints(b, a);
    float angle = atan2(delta.y, delta.x);
    float scale = WDDistance(b, a);
    
    // rebuild bigger, stronger and faster
    float progress = PSSineCurve(((float) step) / steps);
    float scalep = 1.0f + (scale - 1.0f) * progress;
    
    CGPoint center = CGPointMake(painting.width / 2.0f, painting.height / 2.0f);
    CGPoint transformedCenter = CGPointApplyAffineTransform(center, self.transform);
    CGPoint movement = PSMultiplyPointScalar(PsSubtractPoints(transformedCenter, center), progress);
    
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, center.x, center.y);
    t = CGAffineTransformTranslate(t, movement.x, movement.y);
    t = CGAffineTransformRotate(t, progress * angle);
    t = CGAffineTransformScale(t, scalep, scalep);
    t = CGAffineTransformTranslate(t, -center.x, -center.y);
    
    layer.clipWhenTransformed = YES;
    layer.transform = t;

    if (step == steps) {
        layer.transform = CGAffineTransformIdentity;
        [layer transform:transform undoBits:undoable];
    }
    
    return YES;
}

- (void) endAnimation:(PSPainting *)painting
{
    [[painting undoManager] setActionName:NSLocalizedString(@"Transform Layer", @"Transform Layer")];
}

- (void) scale:(float)scale
{
    CGAffineTransform t = self.transform;
    self.transform = CGAffineTransformMake(t.a, t.b, t.c, t.d, t.tx * scale, t.ty * scale);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ layer:%@ transform:%@", [super description], self.layerUUID,
            NSStringFromCGAffineTransform(self.transform)];
}

+ (PSTransformLayer *) transformLayer:(PSLayer *)layer transform:(CGAffineTransform)transform
{
    PSTransformLayer *change = [[PSTransformLayer alloc] init];
    change.layerUUID = layer.uuid;
    change.transform = transform;
    return change;
}

@end
