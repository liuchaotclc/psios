//
//  PSReorderLayers.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSLayer.h"
#import "PSReorderLayers.h"

@implementation PSReorderLayers

@synthesize layerUUID;
@synthesize destIndex;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
    self.destIndex = [decoder decodeIntegerForKey:@"destIndex"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:layerUUID forKey:@"layer"];
    [coder encodeInteger:destIndex forKey:@"destIndex"];
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    return (layer && (self.destIndex < [painting.layers count]));
}

- (void) endAnimation:(PSPainting *)painting
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    if (layer && (self.destIndex < [painting.layers count])) {
        [painting moveLayer:layer toIndex:self.destIndex];
        [[painting undoManager] setActionName:NSLocalizedString(@"Rearrange Layers", @"Rearrange Layers")];
    }
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ layer:%@ destIndex:%d", [super description], self.layerUUID, self.destIndex];
}

+ (PSReorderLayers *) moveLayer:(PSLayer *)layer toIndex:(int)index
{
    PSReorderLayers *change = [[PSReorderLayers alloc] init];
    change.layerUUID = layer.uuid;
    change.destIndex = index;
    return change;
}

@end
