//
//  PSFillColor.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSCoder.h"
#import "PSColor.h"
#import "PSDecoder.h"
#import "PSFillColor.h"
#import "PSLayer.h"

@implementation PSFillColor

@synthesize color;
@synthesize layerUUID;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
    self.color = [decoder decodeObjectForKey:@"color"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:self.layerUUID forKey:@"layer"];
    [coder encodeObject:self.color forKey:@"color" deep:deep];
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
        [layer fill:self.color];
        [[painting undoManager] setActionName:NSLocalizedString(@"Fill Layer", @"Fill Layer")];
    }
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ layer:%@ color:%@", [super description], self.layerUUID, self.color];
}

+ (PSFillColor *) fillColor:(PSColor *)color inLayer:(PSLayer *)layer
{
    PSFillColor *fill = [[PSFillColor alloc] init];
    fill.color = color;
    fill.layerUUID = layer.uuid;
    return fill;
}

@end
