//
//  PSDuplicateLayer.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSDuplicateLayer.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSLayer.h"

@implementation PSDuplicateLayer

@synthesize destinationLayerUUID;
@synthesize sourceLayerUUID;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.destinationLayerUUID = [decoder decodeStringForKey:@"destinationLayerUUID"];
    self.sourceLayerUUID = [decoder decodeStringForKey:@"sourceLayerUUID"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:self.destinationLayerUUID forKey:@"destinationLayerUUID"];
    [coder encodeString:self.sourceLayerUUID forKey:@"sourceLayerUUID"];
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    PSLayer *sourceLayer = [painting layerWithUUID:self.sourceLayerUUID];
    PSLayer *destinationLayer = [painting layerWithUUID:self.destinationLayerUUID];
    return (sourceLayer != nil && destinationLayer != nil);
}

- (void) endAnimation:(PSPainting *)painting
{
    PSLayer *sourceLayer = [painting layerWithUUID:self.sourceLayerUUID];
    PSLayer *destinationLayer = [painting layerWithUUID:self.destinationLayerUUID];
    if (sourceLayer != nil && destinationLayer != nil) {
        [destinationLayer duplicateLayer:sourceLayer copyThumbnail:YES];
        [[painting undoManager] setActionName:NSLocalizedString(@"Duplicate Layer", @"Duplicate Layer")];
    }
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ sourceLayer:%@ destLayer:%@", [super description], self.sourceLayerUUID, self.destinationLayerUUID];
}

+ (PSDuplicateLayer *) duplicateLayer:(PSLayer *)sourceLayer toLayer:(PSLayer *)destinationLayer
{
    PSDuplicateLayer *change = [[PSDuplicateLayer alloc] init];
    change.destinationLayerUUID = destinationLayer.uuid;
    change.sourceLayerUUID = sourceLayer.uuid;
    return change;
}

@end
