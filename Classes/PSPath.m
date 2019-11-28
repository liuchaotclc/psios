//
//  PSPath.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "NSData+Base64.h"

#import "PS3DPoint.h"
#import "PSActiveState.h"
#import "PSBezierNode.h"
#import "PSBezierSegment.h"
#import "PSBrush.h"
#import "PSColor.h"
#import "PSDecoder.h"
#import "PSPath.h"
#import "PSRandom.h"
#import "PSUtilities.h"
#import "PSCoder.h"

#define kMiterLimit     10

const float circleFactor = 0.5522847498307936;

NSString *WDNodesKey = @"cnodes";
NSString *WDNodesKeyV1 = @"nodes";
NSString *WDNodesKeyV2 = @"path";
NSString *WDNodesKeyV3 = @"coords";
NSString *WDColorKey = @"color";
NSString *WDBrushIDKey = @"brush-id";
NSString *WDScaleKey = @"scale";


/**************************
 * WDPath
 *************************/
@implementation PSPath

@synthesize closed = closed_;
@synthesize nodes = nodes_;
@synthesize brush = brush_;
@synthesize color = color_;
@synthesize limitBrushSize;
@synthesize remainder = remainder_;
@synthesize action;
@synthesize scale = scale_;

- (id) init
{
    self = [super init];
    
    nodes_ = [[NSMutableArray alloc] init];
    
    if (!self) {
        return nil;
    }
    
    boundsDirty_ = YES;
    scale_ = 1.f;
    
    return self;
}

- (id) initWithNode:(PSBezierNode *)node
{
    self = [super init];
    
    nodes_ = [[NSMutableArray alloc] initWithObjects:node, nil];
    
    if (!self) {
        return nil;
    }

    boundsDirty_ = YES;
    scale_ = 1.f;
    
    return self;
}

- (void) dealloc
{
    CGPathRelease(pathRef_);
}

- (NSMutableArray *) decodeLegacyNodesA:(NSArray *)nodeList v1:(BOOL)v1
{
    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:(nodeList.count / 9)];
    for (NSUInteger i = 0; i < nodeList.count; i += 9) {
        float ix, iy, ip, ax, ay, ap, ox, oy, op;
        ix = [nodeList[(i + 0)] floatValue];
        iy = [nodeList[(i + 1)] floatValue];
        ip = [nodeList[(i + 2)] floatValue];
        ax = [nodeList[(i + 3)] floatValue];
        ay = [nodeList[(i + 4)] floatValue];
        ap = [nodeList[(i + 5)] floatValue];
        ox = [nodeList[(i + 6)] floatValue];
        oy = [nodeList[(i + 7)] floatValue];
        op = [nodeList[(i + 8)] floatValue];
        if (v1) {
            ax += ix; ay += iy; ap += ip;
            ox += ix; oy += iy; op += ip;
        }
        PSBezierNode *node = [PSBezierNode bezierNodeWithInPoint:[PS3DPoint pointWithX:ix y:iy z:ip]
                                                     anchorPoint:[PS3DPoint pointWithX:ax y:ay z:ap]
                                                        outPoint:[PS3DPoint pointWithX:ox y:oy z:op]];
        [nodes addObject:node];
    }
    return nodes;
}
- (NSMutableArray *) decodeLegacyNodesB:(NSArray *)nodeList
{
    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:(nodeList.count / 9)];
    for (NSUInteger i = 0; i < nodeList.count; i += 9) {
        float ix, iy, ip, ax, ay, ap, ox, oy, op;
        ix = [nodeList[(i + 0)] intValue] / 100.f;
        iy = [nodeList[(i + 1)] intValue] / 100.f;
        ip = [nodeList[(i + 2)] intValue] / 1000.f;
        ax = [nodeList[(i + 3)] intValue] / 100.f;
        ay = [nodeList[(i + 4)] intValue] / 100.f;
        ap = [nodeList[(i + 5)] intValue] / 1000.f;
        ox = [nodeList[(i + 6)] intValue] / 100.f;
        oy = [nodeList[(i + 7)] intValue] / 100.f;
        op = [nodeList[(i + 8)] intValue] / 1000.f;
        PSBezierNode *node = [PSBezierNode bezierNodeWithInPoint:[PS3DPoint pointWithX:ix y:iy z:ip]
                                                     anchorPoint:[PS3DPoint pointWithX:ax y:ay z:ap]
                                                        outPoint:[PS3DPoint pointWithX:ox y:oy z:op]];
        [nodes addObject:node];
    }
    return nodes;
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    self.color = [decoder decodeObjectForKey:WDColorKey];
    NSString *brushID = [decoder decodeObjectForKey:WDBrushIDKey];
    self.brush = [[PSActiveState sharedInstance] brushWithID:brushID];
    self.scale = [decoder decodeFloatForKey:WDScaleKey defaultTo:1.f];
    
    NSString *cnodes = [decoder decodeStringForKey:WDNodesKey];
    if (!cnodes) {
        // handle legacy formats
        NSArray *nodeList = nil;
        nodeList = [decoder decodeArrayForKey:WDNodesKeyV1];
        if (nodeList) {
            self.nodes = [self decodeLegacyNodesA:nodeList v1:YES];
        } else {
            nodeList = [decoder decodeArrayForKey:WDNodesKeyV2];
            if (nodeList) {
                self.nodes = [self decodeLegacyNodesA:nodeList v1:NO];
            } else {
                nodeList = [decoder decodeArrayForKey:WDNodesKeyV3];
                self.nodes = [self decodeLegacyNodesB:nodeList];
            }
        }
    } else {
        NSData *binaryNodes = [NSData dataFromBase64String:cnodes];
        NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:(binaryNodes.length / (9 * sizeof(CFSwappedFloat32)))];
        for (int i = 0; i < binaryNodes.length; i += 9 * sizeof(CFSwappedFloat32)) {
            CFSwappedFloat32 f;
            [binaryNodes getBytes:&f range:NSMakeRange(i + 0 * sizeof(f), sizeof(f))];
            float ix = CFConvertFloat32SwappedToHost(f);
            [binaryNodes getBytes:&f range:NSMakeRange(i + 1 * sizeof(f), sizeof(f))];
            float iy = CFConvertFloat32SwappedToHost(f);
            [binaryNodes getBytes:&f range:NSMakeRange(i + 2 * sizeof(f), sizeof(f))];
            float ip = CFConvertFloat32SwappedToHost(f);
            [binaryNodes getBytes:&f range:NSMakeRange(i + 3 * sizeof(f), sizeof(f))];
            float ax = CFConvertFloat32SwappedToHost(f);
            [binaryNodes getBytes:&f range:NSMakeRange(i + 4 * sizeof(f), sizeof(f))];
            float ay = CFConvertFloat32SwappedToHost(f);
            [binaryNodes getBytes:&f range:NSMakeRange(i + 5 * sizeof(f), sizeof(f))];
            float ap = CFConvertFloat32SwappedToHost(f);
            [binaryNodes getBytes:&f range:NSMakeRange(i + 6 * sizeof(f), sizeof(f))];
            float ox = CFConvertFloat32SwappedToHost(f);
            [binaryNodes getBytes:&f range:NSMakeRange(i + 7 * sizeof(f), sizeof(f))];
            float oy = CFConvertFloat32SwappedToHost(f);
            [binaryNodes getBytes:&f range:NSMakeRange(i + 8 * sizeof(f), sizeof(f))];
            float op = CFConvertFloat32SwappedToHost(f);
            PSBezierNode *node = [PSBezierNode bezierNodeWithInPoint:[PS3DPoint pointWithX:ix y:iy z:ip]
                                                         anchorPoint:[PS3DPoint pointWithX:ax y:ay z:ap]
                                                            outPoint:[PS3DPoint pointWithX:ox y:oy z:op]];
            [nodes addObject:node];
        }
        self.nodes = nodes;
    }

    boundsDirty_ = YES;
}

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep
{
    [coder encodeObject:self.color forKey:WDColorKey deep:deep];
    [coder encodeString:self.brush.uuid forKey:WDBrushIDKey];
    if (self.scale != 1.f) {
        [coder encodeFloat:self.scale forKey:WDScaleKey];
    }
    
    NSMutableData *binaryNodes = [NSMutableData dataWithCapacity:self.nodes.count * 9 * sizeof(CFSwappedFloat32)];
    for (PSBezierNode *node in self.nodes) {
        CFSwappedFloat32 f;
        f = CFConvertFloat32HostToSwapped(node.inPoint.x);
        [binaryNodes appendBytes:&f length:sizeof(f)];
        f = CFConvertFloat32HostToSwapped(node.inPoint.y);
        [binaryNodes appendBytes:&f length:sizeof(f)];
        f = CFConvertFloat32HostToSwapped(node.inPressure);
        [binaryNodes appendBytes:&f length:sizeof(f)];
        f = CFConvertFloat32HostToSwapped(node.anchorPoint.x);
        [binaryNodes appendBytes:&f length:sizeof(f)];
        f = CFConvertFloat32HostToSwapped(node.anchorPoint.y);
        [binaryNodes appendBytes:&f length:sizeof(f)];
        f = CFConvertFloat32HostToSwapped(node.anchorPressure);
        [binaryNodes appendBytes:&f length:sizeof(f)];
        f = CFConvertFloat32HostToSwapped(node.outPoint.x);
        [binaryNodes appendBytes:&f length:sizeof(f)];
        f = CFConvertFloat32HostToSwapped(node.outPoint.y);
        [binaryNodes appendBytes:&f length:sizeof(f)];
        f = CFConvertFloat32HostToSwapped(node.outPressure);
        [binaryNodes appendBytes:&f length:sizeof(f)];
    }
    [coder encodeString:[[binaryNodes base64EncodedString] stringByReplacingOccurrencesOfString:@"\n" withString:@""]forKey:WDNodesKey];
}

- (NSMutableArray *) reversedNodes
{
    NSMutableArray  *reversed = [NSMutableArray array];
    
    for (PSBezierNode *node in [nodes_ reverseObjectEnumerator]) {
        [reversed addObject:[node flippedNode]];
    }
    
    return reversed;
}

- (CGPathRef) pathRef
{
    if (nodes_.count == 0) {
        return NULL;
    }
    
    if (!pathRef_) {
        // construct the path ref from the node list
        
        PSBezierNode                *prevNode = nil;
        BOOL                        firstTime = YES;
        NSArray                     *nodes = nodes_;
        
        pathRef_ = CGPathCreateMutable();
        
        for (PSBezierNode *node in nodes) {
            if (firstTime) {
                CGPathMoveToPoint(pathRef_, NULL, node.anchorPoint.x, node.anchorPoint.y);
                firstTime = NO;
            } else if ([prevNode hasOutPoint] || [node hasInPoint]) {
                CGPathAddCurveToPoint(pathRef_, NULL, prevNode.outPoint.x, prevNode.outPoint.y,
                                      node.inPoint.x, node.inPoint.y, node.anchorPoint.x, node.anchorPoint.y);
            } else {
                CGPathAddLineToPoint(pathRef_, NULL, node.anchorPoint.x, node.anchorPoint.y);
            }
            prevNode = node;
        }
        
        if (closed_ && prevNode) {
            PSBezierNode *node = nodes[0];
            CGPathAddCurveToPoint(pathRef_, NULL, prevNode.outPoint.x, prevNode.outPoint.y,
                                  node.inPoint.x, node.inPoint.y, node.anchorPoint.x, node.anchorPoint.y);
            
            CGPathCloseSubpath(pathRef_);
        }
    }
    
    return pathRef_;
}

+ (PSPath *) pathWithRect:(CGRect)rect
{
    PSPath *path = [[PSPath alloc] initWithRect:rect];
    return path;
}

+ (PSPath *) pathWithOvalInRect:(CGRect)rect
{
    PSPath *path = [[PSPath alloc] initWithOvalInRect:rect];
    return path;
}

+ (PSPath *) pathWithStart:(CGPoint)start end:(CGPoint)end
{
    PSPath *path = [[PSPath alloc] initWithStart:start end:end];
    return path;
}

- (id) initWithRect:(CGRect)rect
{
    self = [self init];
    
    if (!self) {
        return nil;
    }
    
    // instantiate nodes for each corner
    
    [nodes_ addObject:[PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:CGRectGetMinX(rect) y:CGRectGetMinY(rect) z:1.0f]]];
    [nodes_ addObject:[PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:CGRectGetMaxX(rect) y:CGRectGetMinY(rect) z:1.0f]]];
    [nodes_ addObject:[PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:CGRectGetMaxX(rect) y:CGRectGetMaxY(rect) z:1.0f]]];
    [nodes_ addObject:[PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:CGRectGetMinX(rect) y:CGRectGetMaxY(rect) z:1.0f]]];
    
    self.closed = YES;
    bounds_ = rect;
    
    return self;
}

- (id) initWithOvalInRect:(CGRect)rect
{
    self = [self init];
    
    if (!self) {
        return nil;
    }
    
    // instantiate nodes for each corner
    float minX = CGRectGetMinX(rect);
    float midX = CGRectGetMidX(rect);
    float maxX = CGRectGetMaxX(rect);
    
    float minY = CGRectGetMinY(rect);
    float midY = CGRectGetMidY(rect);
    float maxY = CGRectGetMaxY(rect);
    
    PS3DPoint *xDelta = [PS3DPoint pointWithX:(maxX - midX) * circleFactor y:0 z:1];
    PS3DPoint *yDelta = [PS3DPoint pointWithX:0 y:(maxY - midY) * circleFactor z:1];
    
    PS3DPoint *anchor = [PS3DPoint pointWithX:minX y:midY z:1.0];
    PSBezierNode *node = [PSBezierNode bezierNodeWithInPoint:[anchor add:yDelta]
                                                 anchorPoint:anchor
                                                    outPoint:[anchor subtract:yDelta]];
    [nodes_ addObject:node];
      
    anchor = [PS3DPoint pointWithX:midX y:minY z:1.0];
    node = [PSBezierNode bezierNodeWithInPoint:[anchor subtract:xDelta]
                                   anchorPoint:anchor
                                      outPoint:[anchor add:xDelta]];
    [nodes_ addObject:node];
    
    anchor = [PS3DPoint pointWithX:maxX y:midY z:1.0];
    node = [PSBezierNode bezierNodeWithInPoint:[anchor subtract:yDelta]
                                   anchorPoint:anchor
                                      outPoint:[anchor add:yDelta]];
    [nodes_ addObject:node];
    
    anchor = [PS3DPoint pointWithX:midX y:maxY z:1.0];
    node = [PSBezierNode bezierNodeWithInPoint:[anchor add:xDelta]
                                   anchorPoint:anchor
                                      outPoint:[anchor subtract:xDelta]];
    [nodes_ addObject:node];
    
    self.closed = YES;
    bounds_ = rect;
    
    return self;
}

- (id) initWithStart:(CGPoint)start end:(CGPoint)end
{
    self = [self init];
    
    if (!self) {
        return nil;
    }
    
    [nodes_ addObject:[PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:start.x y:start.y z:1.0]]];
    [nodes_ addObject:[PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:end.x y:end.y z:1.0]]];
    
    boundsDirty_ = YES;
    
    return self;
}

- (void) setClosedQuiet:(BOOL)closed
{
    if (closed && nodes_.count < 2) {
        // need at least 2 nodes to close a path
        return;
    }
    
    if (closed) {
        // if the first and last node have the same anchor, one is redundant
        PSBezierNode *first = [self firstNode];
        PSBezierNode *last = [self lastNode];
        if ([first.anchorPoint isEqual:last.anchorPoint]) {
            PSBezierNode *closedNode = [PSBezierNode bezierNodeWithInPoint:last.inPoint anchorPoint:first.anchorPoint outPoint:first.outPoint];
            
            NSMutableArray *newNodes = [NSMutableArray arrayWithArray:nodes_];
            newNodes[0] = closedNode;
            [newNodes removeLastObject];
            
            self.nodes = newNodes;
        }
    }
    
    closed_ = closed;
}

- (void) setClosed:(BOOL)closed
{
    if (closed && nodes_.count < 2) {
        // need at least 2 nodes to close a path
        return;
    }
    
    [self setClosedQuiet:closed];
    
    [self invalidatePath];
}

- (void) addNode:(PSBezierNode *)node
{
    [self.nodes addObject:node];
}

- (PSBezierNode *) firstNode
{
    return nodes_[0];
}

- (PSBezierNode *) lastNode
{
    return (closed_ ? nodes_[0] : [nodes_ lastObject]); 
}

- (void) invalidatePath
{
    CGPathRelease(pathRef_);
    pathRef_ = NULL;
    
    boundsDirty_ = YES;
}

- (void) computeBounds
{
    bounds_ = CGPathGetPathBoundingBox(self.pathRef);
    boundsDirty_ = NO;
}

/* 
 * Bounding box of path geometry.
 */
- (CGRect) bounds
{
    if (boundsDirty_) {
        [self computeBounds];
    }
    
    return bounds_;
}

- (CGRect) controlBounds
{
    PSBezierNode     *initial = [nodes_ lastObject];
    float           minX, maxX, minY, maxY;
    
    minX = maxX = initial.anchorPoint.x;
    minY = maxY = initial.anchorPoint.y;
    
    for (PSBezierNode *node in nodes_) {
        minX = MIN(minX, node.anchorPoint.x);
        maxX = MAX(maxX, node.anchorPoint.x);
        minY = MIN(minY, node.anchorPoint.y);
        maxY = MAX(maxY, node.anchorPoint.y);
        
        minX = MIN(minX, node.inPoint.x);
        maxX = MAX(maxX, node.inPoint.x);
        minY = MIN(minY, node.inPoint.y);
        maxY = MAX(maxY, node.inPoint.y);
        
        minX = MIN(minX, node.outPoint.x);
        maxX = MAX(maxX, node.outPoint.x);
        minY = MIN(minY, node.outPoint.y);
        maxY = MAX(maxY, node.outPoint.y);
    }
      
    CGRect bbox = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    return bbox;
}

- (NSSet *) nodesInRect:(CGRect)rect
{
    NSMutableSet *nodesInRect = [NSMutableSet set];
    
    for (PSBezierNode *node in nodes_) {
        if (CGRectContainsPoint(rect, node.anchorPoint.CGPoint)) {
            [nodesInRect addObject:node];
        }
    }
    
    return nodesInRect;
}

- (void) setNodes:(NSMutableArray *)nodes
{
    if ([nodes_ isEqualToArray:nodes]) {
        return;
    }
    
    nodes_ = nodes;
    
    [self invalidatePath];
}

- (void) transform:(CGAffineTransform)transform
{
    NSMutableArray      *newNodes = [[NSMutableArray alloc] init];
    
    for (PSBezierNode *node in nodes_) {
        [newNodes addObject:[node transform:transform]];
    }
    
    self.nodes = newNodes;
}

- (void) addAnchors
{
    NSMutableArray      *newNodes = [NSMutableArray array];
    NSInteger           numNodes = closed_ ? (nodes_.count + 1) : nodes_.count;
    NSInteger           numSegments = (numNodes - 1) * 2;
    NSMutableArray      *segments = [NSMutableArray array];
    PSBezierSegment     *segment;
    PSBezierNode        *prev, *curr, *node;
    NSUInteger          segmentIndex = 0;
    
    prev = nodes_[0];
    for (int i = 1; i < numNodes; i++, segmentIndex += 2) {
        curr = nodes_[(i % nodes_.count)];
        
        segment = [PSBezierSegment segmentWithStart:prev end:curr];
        PSBezierSegment *L = [[PSBezierSegment alloc] init];
        PSBezierSegment *R = [[PSBezierSegment alloc] init];
        
        [segment splitAtT:0.5f left:&L right:&R];
        [segments addObject:L];
        [segments addObject:R];
        
        prev = curr;
    }
    
    PSBezierSegment *lastSegment = (PSBezierSegment *)[segments lastObject];
    // convert the segments back to nodes
    for (int i = 0; i < numSegments; i++) {
        PSBezierSegment *currentSegment = (PSBezierSegment *)segments[i];
        
        if (i == 0) {
            PS3DPoint *inPoint = closed_ ? lastSegment.inHandle : [self firstNode].inPoint;
            node = [PSBezierNode bezierNodeWithInPoint:inPoint anchorPoint:currentSegment.start outPoint:currentSegment.outHandle];
        } else {
            PSBezierSegment *prevSegment = (PSBezierSegment *)segments[i-1];
            node = [PSBezierNode bezierNodeWithInPoint:prevSegment.inHandle anchorPoint:currentSegment.start outPoint:currentSegment.outHandle];
        }
        
        [newNodes addObject:node];
        
        if (i == (numSegments - 1) && !closed_) {
            node = [PSBezierNode bezierNodeWithInPoint:currentSegment.inHandle anchorPoint:currentSegment.end outPoint:[self lastNode].outPoint];
            [newNodes addObject:node];
        }
    }
    
    self.nodes = newNodes;
}

- (NSArray *) flattenedPoints
{
    if (self.nodes.count == 1) {
        PSBezierNode *lonelyNode = [nodes_ lastObject];
        return @[lonelyNode.anchorPoint];
    }
    
    NSMutableArray      *flatNodes = [NSMutableArray array];
    NSInteger           numNodes = closed_ ? nodes_.count : nodes_.count - 1;
    PSBezierSegment     *segment = nil;
    
    BezierSegmentRecusionCounter = 0;
    for (int i = 0; i < numNodes; i++) {
        PSBezierNode *a = nodes_[i];
        PSBezierNode *b = nodes_[(i+1) % nodes_.count];
        
        segment = [PSBezierSegment segmentWithStart:a end:b];

        [segment flattenIntoArray:flatNodes];
    }
    
    return flatNodes;
}

- (void) flatten
{
    NSArray *flattenedPoints = [self flattenedPoints];
    NSMutableArray *newNodes = [NSMutableArray array];
    
    for (PS3DPoint *pt in flattenedPoints) {
        [newNodes addObject:[PSBezierNode bezierNodeWithAnchorPoint:pt]];
    }
    
    self.nodes = newNodes;
}

- (id) copyWithZone:(NSZone *)zone
{       
    PSPath *path = [[PSPath alloc] init];
    
    path->nodes_ = [nodes_ copy];
    path->closed_ = closed_;
    path->boundsDirty_ = YES;

    return path;
}

/*************************/


typedef struct {
    GLfloat     x, y;
    GLfloat     s, t;
    GLfloat     a;
} vertexData;

- (CGRect) drawData
{
    vertexData *vertexD = calloc(sizeof(vertexData), points_.count * 4 + (points_.count - 1) * 2);
    CGRect dataBounds = CGRectZero;
    
    int n = 0;
    for (int i = 0; i < points_.count; i++) {
        CGPoint result = [points_[i] CGPointValue];
        float angle = [angles_[i] floatValue];
        float size = [sizes_[i] floatValue] / 2;
        float alpha = [alphas_[i] floatValue];
        
        CGRect rect = CGRectMake(result.x - size, result.y - size, size*2, size*2);
        CGPoint a = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGPoint b = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
        CGPoint c = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGPoint d = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        
        CGAffineTransform t = CGAffineTransformMakeTranslation(PSCenterOfRect(rect).x, PSCenterOfRect(rect).y);
        t = CGAffineTransformRotate(t, angle);
        t = CGAffineTransformTranslate(t, -PSCenterOfRect(rect).x, -PSCenterOfRect(rect).y);
        
        a = CGPointApplyAffineTransform(a, t);
        b = CGPointApplyAffineTransform(b, t);
        c = CGPointApplyAffineTransform(c, t);
        d = CGPointApplyAffineTransform(d, t);
        
        CGRect boxBounds = CGRectApplyAffineTransform(rect, t);
        dataBounds = PSUnionRect(dataBounds, CGRectIntegral(boxBounds));
        
        if (n != 0) {
            // dup 1st vertex
            vertexD[n].x = a.x;
            vertexD[n].y = a.y;
            vertexD[n].s = 0;
            vertexD[n].t = 0;
            vertexD[n].a = alpha;
            n++;
        }
        
        vertexD[n].x = a.x;
        vertexD[n].y = a.y;
        vertexD[n].s = 0;
        vertexD[n].t = 0;
        vertexD[n].a = alpha;
        n++;
        
        vertexD[n].x = b.x;
        vertexD[n].y = b.y;
        vertexD[n].s = 1;
        vertexD[n].t = 0;
        vertexD[n].a = alpha;
        n++;
        
        vertexD[n].x = c.x;
        vertexD[n].y = c.y;
        vertexD[n].s = 0;
        vertexD[n].t = 1;
        vertexD[n].a = alpha;
        n++;
        
        vertexD[n].x = d.x;
        vertexD[n].y = d.y;
        vertexD[n].s = 1;
        vertexD[n].t = 1;
        vertexD[n].a = alpha;
        n++;
        
        if (i != (points_.count - 1)) {
            // dup last vertex
            vertexD[n].x = d.x;
            vertexD[n].y = d.y;
            vertexD[n].s = 1;
            vertexD[n].t = 1;
            vertexD[n].a = alpha;
            n++;
        }
    }
    
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(vertexData), &vertexD[0].x);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_TRUE, sizeof(vertexData), &vertexD[0].s);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 1, GL_FLOAT, GL_TRUE, sizeof(vertexData), &vertexD[0].a);
    glEnableVertexAttribArray(2);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, n);
    free(vertexD);
    WDCheckGLError();
    
    return dataBounds;
}

- (PSRandom *) newRandomizer
{
    return [[PSRandom alloc] initWithSeed:self.brush.generator.seed];
}

- (void) paintStamp:(PSRandom *)randomizer
{
    PSBrush         *brush = self.brush;
    float           weight = scale_ * (self.limitBrushSize ? 50 : brush.weight.value);
        
    CGPoint start = ((PSBezierNode *) [self.nodes lastObject]).anchorPoint.CGPoint;

    float brushSize = weight;
    float rotationalScatter = [randomizer nextFloat] * brush.rotationalScatter.value * M_PI * 2;
    float angleOffset = brush.angle.value * (M_PI / 180.0f);
    float alpha = MAX(0.01, brush.intensity.value);
            
    [points_ addObject:[NSValue valueWithCGPoint:start]];
    [sizes_ addObject:@(brushSize)];
    [angles_ addObject:@(rotationalScatter + angleOffset)];
    [alphas_ addObject:@(alpha)];
}

- (void) paintFromPoint:(PS3DPoint *)lastLocation toPoint:(PS3DPoint *)location randomizer:(PSRandom *)randomizer
{
    float           pA = lastLocation.z;
    float           pB = location.z;
    float           pDelta = (pB - pA);
	float           f, distance = WDDistance(lastLocation.CGPoint, location.CGPoint);
	CGPoint         vector = PsSubtractPoints(location.CGPoint, lastLocation.CGPoint);
	CGPoint         unitVector = CGPointMake(1.0f, 1.0f);
	float           vectorAngle = atan2(vector.y, vector.x);
	float           step, pressureStep, pressure = pA;
    PSBrush         *brush = self.brush;
    float           weight = scale_ * (self.limitBrushSize ? 50 : brush.weight.value);
    
	if (distance > 0.0f) {
		unitVector = PSMultiplyPointScalar(vector, 1.0f / distance);
	}
    
	CGPoint start = PSAddPoints(lastLocation.CGPoint, PSMultiplyPointScalar(unitVector, remainder_));
    
	// step linearly from last to current, pasting brush image
	for (f = remainder_; f <= distance; f += step, pressure += pressureStep) {
        
        int sign = signbit(brush.weightDynamics.value);
        float p = sign ? pressure : (1.0f - pressure);
        float brushSize = MAX(1, weight - fabs(brush.weightDynamics.value) * p * weight);
        
        float rotationalScatter = [randomizer nextFloat] * brush.rotationalScatter.value * M_PI * 2;
        float angleOffset = brush.angle.value * (M_PI / 180.0f);
        
        float positionalScatter = [randomizer nextFloatMin:-1.0f max:1.0f];
        positionalScatter *= brush.positionalScatter.value;
        CGPoint orthog;
        orthog.x = unitVector.y;
        orthog.y = -unitVector.x;
        orthog = PSMultiplyPointScalar(orthog, weight / 2.0f * positionalScatter);
        CGPoint pos = PSAddPoints(start, orthog);
        
        sign = signbit(brush.intensityDynamics.value);
        p = sign ? pressure : (1.0f - pressure);
        float alpha = MAX(0.01, brush.intensity.value - fabs(brush.intensityDynamics.value) * p * brush.intensity.value);
        
        [points_ addObject:[NSValue valueWithCGPoint:pos]];
        [sizes_ addObject:@(brushSize)];
        [angles_ addObject:@(vectorAngle * brush.angleDynamics.value + rotationalScatter + angleOffset)];
        [alphas_ addObject:@(alpha)];
        
        step = MAX(1.0, brush.spacing.value * brushSize);
        start = PSAddPoints(start, PSMultiplyPointScalar(unitVector, step));
		pressureStep = pDelta / (distance / step);
    }
    
    // how much extra spacing should we add when we paint the next time?
    // this keeps the spacing uniform across move events
    remainder_ = (f - distance);
}

- (CGRect) paint:(PSRandom *)randomizer
{
    if (!points_) {
        points_ = [[NSMutableArray alloc] init];
        angles_ = [[NSMutableArray alloc] init];
        sizes_ = [[NSMutableArray alloc] init];
        alphas_ = [[NSMutableArray alloc] init];
    }
    
    [points_ removeAllObjects];
    [sizes_ removeAllObjects];
    [angles_ removeAllObjects];
    [alphas_ removeAllObjects];
    
    if (self.nodes.count == 1) {
        [self paintStamp:randomizer];
    } else {
        NSArray     *points = [self flattenedPoints];
        NSInteger   numPoints = points.count;
        
        for (NSInteger ix = 0; ix < numPoints - 1; ix++) {
            [self paintFromPoint:points[ix] toPoint:points[ix+1] randomizer:randomizer];
        }
    }
    
    return [self drawData];
}

- (void) setBrush:(PSBrush *)brush
{    
    brush_ = brush;
}

- (void) setColor:(PSColor *)color
{    
    color_ = color;
}

- (void) setScale:(float)scale
{
    [self transform:CGAffineTransformMakeScale(scale / scale_, scale / scale_)];
    scale_ = scale;
}

@end
