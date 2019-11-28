//
//  PSDeleteLayer
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSCanvas.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSDeleteLayer.h"
#import "PSLayer.h"

@implementation PSDeleteLayer {
    float startOpacity_;
}

@synthesize layerUUID;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:self.layerUUID forKey:@"layer"];
}

- (int) animationSteps:(PSPainting *)painting
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    return layer.visible ? layer.opacity / 0.03f : 0;
}

- (void) beginAnimation:(PSPainting *)painting
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    startOpacity_ = layer.opacity;
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    float progress = 1.0f * step / steps;
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    if (layer) {
        layer.opacity = startOpacity_ * (1.0f - progress);
        return YES;
    } else {
        return NO;
    }
}

- (void) endAnimation:(PSPainting *)painting
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    if (layer) {
        [painting activateLayerAtIndex:[painting.layers indexOfObject:layer]];
        [painting deleteActiveLayer];
        [[painting undoManager] setActionName:NSLocalizedString(@"Delete Layer", @"Delete Layer")];
    }
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ layer:%@", [super description], self.layerUUID];
}

+ (PSDeleteLayer *) deleteLayer:(PSLayer *)layer 
{
    PSDeleteLayer *notification = [[PSDeleteLayer alloc] init];
    notification.layerUUID = layer.uuid;
    return notification;
}

@end
