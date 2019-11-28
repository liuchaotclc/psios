//
//  PSChangeHueSaturation.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSChangeHueSaturation.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSHueSaturation.h"
#import "PSLayer.h"

@implementation PSChangeHueSaturation

@synthesize hueSaturation;
@synthesize layerUUID;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.hueSaturation = [decoder decodeObjectForKey:@"hsb"];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeObject:self.hueSaturation forKey:@"hsb" deep:deep];
    [coder encodeString:self.layerUUID forKey:@"layer"];
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    return layer != nil;
}

- (void) endAnimation:(PSPainting *)painting
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    if (layer) {
        layer.hueSaturation = self.hueSaturation;
        [layer commitColorAdjustments];
        
        [[painting undoManager] setActionName:NSLocalizedString(@"Hue and Saturation", @"Hue and Saturation")];
    }
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ layer:%@ hue/sat:%@", [super description], self.layerUUID, self.hueSaturation];
}

+ (PSChangeHueSaturation *) changeHueSaturation:(PSHueSaturation *)hueSaturation forLayer:(PSLayer *)layer
{
    PSChangeHueSaturation *change = [[PSChangeHueSaturation alloc] init];
    change.hueSaturation = hueSaturation;
    change.layerUUID = layer.uuid;
    return change;
}

@end
