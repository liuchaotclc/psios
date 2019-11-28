//
//  PSChangeColorBalance.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSChangeColorBalance.h"
#import "PSCoder.h"
#import "PSColorBalance.h"
#import "PSDecoder.h"
#import "PSLayer.h"

@implementation PSChangeColorBalance

@synthesize colorBalance;
@synthesize layerUUID;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.colorBalance = [decoder decodeObjectForKey:@"colorBalance"];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeObject:self.colorBalance forKey:@"colorBalance" deep:deep];
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
        layer.colorBalance = self.colorBalance;
        [layer commitColorAdjustments];
        
        [[painting undoManager] setActionName:NSLocalizedString(@"Color Balance", @"Color Balance")];
    }
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ layer:%@ colorBalance:%@", [super description], self.layerUUID, self.colorBalance];
}

+ (PSChangeColorBalance *) changeColorBalance:(PSColorBalance *)colorBalance forLayer:(PSLayer *)layer
{
    PSChangeColorBalance *change = [[PSChangeColorBalance alloc] init];
    change.colorBalance = colorBalance;
    change.layerUUID = layer.uuid;
    return change;
}

@end
