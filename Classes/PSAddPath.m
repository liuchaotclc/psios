//
//  PSAddPath.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSAddPath.h"
#import "PSCanvas.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSDocumentChangeVisitor.h"
#import "PSLayer.h"
#import "PSPath.h"
#import "PSRandom.h"
#import "PSUtilities.h"

@implementation PSAddPath {
    float lastRemainder_;
    PSRandom *randomizer_;
    NSMutableArray *partitions_;
    CGRect pathBounds_;
    BOOL undoable_;
}

@synthesize erase;
@synthesize changeIndex;
@synthesize layerUUID;
@synthesize path;
@synthesize sourcePainting;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    self.path = [decoder decodeObjectForKey:@"added"];
    self.erase = [decoder decodeBooleanForKey:@"erase"];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
    self.changeIndex = [decoder decodeIntegerForKey:@"index"];
    // sourcePainting is transient
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [coder encodeObject:self.path forKey:@"added" deep:deep];
    if (self.erase) {
        // erase defaults to NO and since we're recording a LOT of these, don't save unless it's YES
        [coder encodeBoolean:self.erase forKey:@"erase"];
    }
    [coder encodeString:self.layerUUID forKey:@"layer"];
    [coder encodeInteger:self.changeIndex forKey:@"index"];
    // sourcePainting is transient
}

- (int) animationSteps:(PSPainting *)painting
{
    return MAX((int) self.path.nodes.count / 8, 1);
}

- (void) partitionPath
{
    PSBezierNode    *previousNode = nil;
    NSMutableArray  *nodes = nil;
    NSUInteger      numberOfPartitions = [self animationSteps:nil]; 
    NSUInteger      partitionSize = self.path.nodes.count / numberOfPartitions;
    NSUInteger      ix = 0;
    
    partitions_ = [NSMutableArray array];
    
    for (PSBezierNode *node in self.path.nodes) {
        // if we're equal to 0 mod the partition size, we need a new array to collect nodes
        // UNLESS we've already created the maximum number of partitions, in which case the
        // remainder can just go in the previously created partition
        
        if ((ix % partitionSize == 0) && partitions_.count < numberOfPartitions) {
            nodes = [NSMutableArray array];
            [partitions_ addObject:nodes];
            
            if (previousNode) {
                // we need to add the end of the previous partition to avoid a gap
                [nodes addObject:previousNode];
            }
        }
        
        [nodes addObject:node];
        previousNode = node;
        ix++;
    }
}

- (void) beginAnimation:(PSPainting *)painting
{
    if (painting != self.sourcePainting) {
        lastRemainder_ = 0.f;
        randomizer_ = [path newRandomizer];
        pathBounds_ = CGRectZero;
        [self partitionPath];
        
        PSLayer *layer = [painting layerWithUUID:self.layerUUID];
        [layer.painting activateLayerAtIndex:[layer.painting.layers indexOfObject:layer]];
    }
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    if (!layer) {
        return NO;
    }
    
    if (painting != self.sourcePainting) {
        PSPath *subpath = [[PSPath alloc] init];
        subpath.brush = self.path.brush;
        subpath.color = self.path.color;
        subpath.scale = self.path.scale; // do before setting nodes to avoid double scaling!
        subpath.nodes = partitions_[(step - 1)];
        subpath.remainder = lastRemainder_;
        subpath.action = self.erase ? WDPathActionErase : WDPathActionPaint;
        
        CGRect bounds = [painting paintStroke:subpath randomizer:randomizer_ clear:(step == 1)];
        
        pathBounds_ = PSUnionRect(pathBounds_, bounds);
        lastRemainder_ = subpath.remainder;
        undoable_ = undoable;
    }
    
    return YES;
}

- (void) endAnimation:(PSPainting *)painting
{
    if (painting != self.sourcePainting) {
        if (pathBounds_.size.width * pathBounds_.size.height > 0) {
            PSLayer *layer = [painting layerWithUUID:self.layerUUID];
            [layer commitStroke:pathBounds_ color:path.color erase:erase undoable:undoable_ path:nil];
        } else if ([path.nodes count] > 0) {
            WDLog(@"Empty path bounds with path of length %d", [path.nodes count]);
        }
        painting.activePath = nil;
    }

    NSString *actionName = self.erase ? NSLocalizedString(@"Eraser", @"Eraser") : NSLocalizedString(@"Brush", @"Brush");
    [[painting undoManager] setActionName:actionName];
    
    [painting recordStroke:self.path];
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ #%d erase:%d added:%@ layer:%@", [super description], self.changeIndex, self.erase, self.path, self.layerUUID];
}

- (void) accept:(id<PSDocumentChangeVisitor>)visitor
{
    [visitor visitAddPath:self];
}

- (void) scale:(float)scale
{
    self.path.scale *= scale;
}

+ (PSAddPath *) addPath:(PSPath *)added erase:(BOOL)erase layer:(PSLayer *)layer sourcePainting:(PSPainting *)painting
{
    PSAddPath *notification = [[PSAddPath alloc] init];
    notification.path = added;
    notification.erase = erase;
    notification.layerUUID = layer.uuid;
    notification.sourcePainting = painting;
    return notification;
}

@end
