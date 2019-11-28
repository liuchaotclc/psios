//
//  PSModifyLayer.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSLayer.h"
#import "PSModifyLayer.h"
#import "PSUtilities.h"

@implementation PSModifyLayer 

@synthesize layerUUID;
@synthesize operation;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
    self.operation = [decoder decodeIntegerForKey:@"operation"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:self.layerUUID forKey:@"layer"];
    [coder encodeInteger:self.operation forKey:@"operation"];
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    return layer != nil;
}

- (void) endAnimation:(PSPainting *)painting
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    NSUndoManager *undoManager = [painting undoManager];
    
    if (layer) {
        switch (self.operation) {
            case WDMergeLayer:
                [painting activateLayerAtIndex:[painting.layers indexOfObject:layer]];
                [painting mergeDown];
                [undoManager setActionName:NSLocalizedString(@"Merge Down", @"Merge Down")];
                return;
            case WDClearLayer:
                [layer clear];
                [undoManager setActionName:NSLocalizedString(@"Clear Layer", @"Clear Layer")];
                return;
            case WDDesaturateLayer:
                [layer desaturate];
                [undoManager setActionName:NSLocalizedString(@"Desaturate", @"Desaturate")];
                return;
            case WDInvertLayerColor:
                [layer invert];
                [undoManager setActionName:NSLocalizedString(@"Invert Color", @"Invert Color")];
                return;
            case WDFlipLayerHorizontal:
                [layer flipHorizontally];
                [undoManager setActionName:NSLocalizedString(@"Flip Horizontally", @"Flip Horizontally")];
                return;
            case WDFlipLayerVertical:
                [layer flipVertically];
                [undoManager setActionName:NSLocalizedString(@"Flip Vertically", @"Flip Vertically")];
                return;
            default:
                WDLog(@"ERROR: unknown layer modification: %d", self.operation);
        }
    }
}

- (NSString *) description 
{
    NSString *operationName;
    switch (self.operation) {
        case WDMergeLayer: operationName = @"merge"; break;
        case WDClearLayer: operationName = @"clear"; break;
        case WDDesaturateLayer: operationName = @"desaturate"; break;
        case WDInvertLayerColor: operationName = @"invert"; break;
        case WDFlipLayerHorizontal: operationName = @"flip horizontal"; break;
        case WDFlipLayerVertical: operationName = @"flip vertical"; break;
        default: operationName = @"unknown"; break;
    }
    return [NSString stringWithFormat:@"%@ layer:%@ operation:%@", [super description], self.layerUUID, operationName];
}

+ (PSModifyLayer *) modifyLayer:(PSLayer *)layer withOperation:(WDLayerOperation)operation
{
    return [PSModifyLayer modifyLayerUUID:layer.uuid withOperation:operation];
}

+ (PSModifyLayer *) modifyLayerUUID:(NSString *)layerUUID withOperation:(WDLayerOperation)operation
{
    PSModifyLayer *change = [[PSModifyLayer alloc] init];
    change.layerUUID = layerUUID;
    change.operation = operation;
    return change;
}

@end
