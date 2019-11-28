//
//  PSBezierNode.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PS3DPoint.h"
#import "PSBezierNode.h"
#import "PSUtilities.h"
#import "PSCoder.h"
#import "PSDecoder.h"

#define kAnchorRadius 3.5
#define kControlPointRadius 3.5

/**************************
 * WDBezierNode
 *************************/

@implementation PSBezierNode

@synthesize inPoint = inPoint_;
@synthesize anchorPoint = anchorPoint_;
@synthesize outPoint = outPoint_;

+ (PSBezierNode *) bezierNodeWithAnchorPoint:(PS3DPoint *)pt
{
    PSBezierNode *node = [[PSBezierNode alloc] initWithAnchorPoint:pt];
    
    return node;
}

+ (PSBezierNode *) bezierNodeWithInPoint:(PS3DPoint *)inPoint anchorPoint:(PS3DPoint *)pt outPoint:(PS3DPoint *)outPoint
{
    PSBezierNode *node = [[PSBezierNode alloc] initWithInPoint:inPoint anchorPoint:pt outPoint:outPoint];
    
    return node;
}

- (id) copyWithZone:(NSZone *)zone
{
    PSBezierNode *node = [[PSBezierNode alloc] init];
    
    node->inPoint_ = [inPoint_ copy];
    node->anchorPoint_ = [anchorPoint_ copy];
    node->outPoint_ = [outPoint_ copy];

    return node;
}

- (id) initWithAnchorPoint:(PS3DPoint *)pt
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    inPoint_ = [pt copy];
    anchorPoint_ = [pt copy];
    outPoint_ = [pt copy];
    
    return self;
}

- (id) initWithInPoint:(PS3DPoint *)inPoint anchorPoint:(PS3DPoint *)pt outPoint:(PS3DPoint *)outPoint
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    inPoint_ = [inPoint copy];
    anchorPoint_ = [pt copy];
    outPoint_ = [outPoint copy];
    
    return self;
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    CGPoint inPt = [decoder decodePointForKey:@"in"];
    CGPoint anchorPt = [decoder decodePointForKey:@"anchor"];
    CGPoint outPt  = [decoder decodePointForKey:@"out"];
    
    float inPressure = [decoder decodeFloatForKey:@"in-pressure"];
    float anchorPressure = [decoder decodeFloatForKey:@"anchor-pressure"];
    float outPressure = [decoder decodeFloatForKey:@"out-pressure"];
    
    inPoint_ = [PS3DPoint pointWithX:inPt.x y:inPt.y z:inPressure];
    anchorPoint_ = [PS3DPoint pointWithX:anchorPt.x y:anchorPt.y z:anchorPressure];
    outPoint_ = [PS3DPoint pointWithX:outPt.x y:outPt.y z:outPressure];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [coder encodePoint:inPoint_.CGPoint forKey:@"in"];
    [coder encodePoint:anchorPoint_.CGPoint forKey:@"anchor"];
    [coder encodePoint:outPoint_.CGPoint forKey:@"out"];
    
    [coder encodeFloat:inPoint_.z forKey:@"in-pressure"];
    [coder encodeFloat:anchorPoint_.z forKey:@"anchor-pressure"];
    [coder encodeFloat:outPoint_.z forKey:@"out-pressure"];
}

- (BOOL) isEqual:(PSBezierNode *)node
{
    if (node == self) {
        return YES;
    }
    
    if (![node isKindOfClass:[PSBezierNode class]]) {
        return NO;
    }
    
    return ([self.inPoint isEqual:node.inPoint] &&
            [self.anchorPoint isEqual:node.anchorPoint] &&
            [self.outPoint isEqual:node.outPoint]);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: (%@) -- [%@] -- (%@)", [super description],
            [inPoint_ description], [anchorPoint_ description], [outPoint_ description]];
}

- (BOOL) hasInPoint
{
    return ![self.anchorPoint isEqual:self.inPoint];
}

- (BOOL) hasOutPoint
{
    return ![self.anchorPoint isEqual:self.outPoint];
}

- (BOOL) isCorner
{
    if (![self hasInPoint] || ![self hasOutPoint]) {
        return YES;
    }
    
    return !PSCollinear(inPoint_.CGPoint, anchorPoint_.CGPoint, outPoint_.CGPoint);
}

- (PSBezierNode *) transform:(CGAffineTransform)transform
{
    PS3DPoint *tXIn = [inPoint_ transform:transform];
    PS3DPoint *tXAnchor = [anchorPoint_ transform:transform];
    PS3DPoint *tXOut = [outPoint_ transform:transform];
    
    return [[PSBezierNode alloc] initWithInPoint:tXIn anchorPoint:tXAnchor outPoint:tXOut];
}

- (PSBezierNode *) flippedNode
{
    return [PSBezierNode bezierNodeWithInPoint:self.outPoint anchorPoint:self.anchorPoint outPoint:self.inPoint];
}

- (float) inPressure
{
    return inPoint_.z;
}

- (float) anchorPressure
{
    return anchorPoint_.z;
}

- (float) outPressure
{
    return outPoint_.z;
}

- (void) setInPressure:(float)inPressure
{
    inPoint_.z = inPressure;
}

- (void) setAnchorPressure:(float)anchorPressure
{
    anchorPoint_.z = anchorPressure;
}

- (void) setOutPressure:(float)outPressure
{
    outPoint_.z = outPressure;
}

@end
