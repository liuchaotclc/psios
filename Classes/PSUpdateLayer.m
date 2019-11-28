//
//  PSUpdateLayer
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
#import "PSJSONCoder.h"
#import "PSLayer.h"
#import "PSUpdateLayer.h"


@implementation PSUpdateLayer

@synthesize layer;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.layer = [decoder decodeObjectForKey:@"layer"];
}

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeObject:self.layer forKey:@"layer" deep:NO];
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    PSLayer *layer2 = [painting layerWithUUID:self.layer.uuid];
    return (layer2 != nil && self.layer != nil);
}

- (void) endAnimation:(PSPainting *)painting
{
    PSLayer *layer2 = [painting layerWithUUID:self.layer.uuid];
    if (layer2 && self.layer) {
        PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:nil];
        [coder update:layer2 with:self.layer];
    }
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ layer:%@", [super description], self.layer];
}

+ (PSUpdateLayer *) updateLayer:(PSLayer *)layer
{
    PSUpdateLayer *change = [[PSUpdateLayer alloc] init];
    change.layer = layer;
    return change;
}

@end
