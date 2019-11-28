//
//  PSAddLayer
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
//

#import "PSAddLayer.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSLayer.h"
#import "PSUtilities.h"

@implementation PSAddLayer

@synthesize index;
@synthesize layerUUID;


- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.index = [decoder decodeIntegerForKey:@"index"];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeInteger:(int)self.index forKey:@"index"];
    [coder encodeString:self.layerUUID forKey:@"layer"];
}

- (void) beginAnimation:(PSPainting *)painting
{
    NSUInteger n = MIN(self.index, painting.layers.count);
    PSLayer *layer = [[PSLayer alloc] initWithUUID:self.layerUUID];
    layer.painting = painting;
    [painting insertLayer:layer atIndex:n];
    [painting activateLayerAtIndex:n];
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    return [painting layerWithUUID:self.layerUUID] != nil;
}

- (void) endAnimation:(PSPainting *)painting
{
    [[painting undoManager] setActionName:NSLocalizedString(@"Add Layer", @"Add Layer")];
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ added:%@ layer:%lu", [super description], self.layerUUID, (unsigned long) self.index];
}

+ (PSAddLayer *) addLayerAtIndex:(NSUInteger)index 
{
    PSAddLayer *notification = [[PSAddLayer alloc] init];
    notification.index = index;
    notification.layerUUID = generateUUID();
    return notification;
}

@end
