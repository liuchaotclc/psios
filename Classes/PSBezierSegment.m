//
//  PSBezierSegment.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PS3DPoint.h"
#import "PSBezierSegment.h"
#import "PSBezierNode.h"
#import <Crashlytics/Crashlytics.h>
#import "PSActiveState.h"
#import "PSBrush.h"
#import "PSTool.h"

const float kDefaultFlatness = 1;
unsigned long long BezierSegmentRecusionCounter;

@implementation PSBezierSegment

@synthesize start;
@synthesize outHandle;
@synthesize inHandle;
@synthesize end;

+ (PSBezierSegment *) segmentWithStart:(PSBezierNode *)start end:(PSBezierNode *)end
{
    PSBezierSegment *segment = [[PSBezierSegment alloc] init];
    
    segment.start = start.anchorPoint;
    segment.outHandle = start.outPoint;
    segment.inHandle = end.inPoint;
    segment.end = end.anchorPoint;
    
    return segment;
}

- (BOOL) isDegenerate
{
    return ([start isDegenerate] || [outHandle isDegenerate] || [inHandle isDegenerate] || [end isDegenerate]) ? YES : NO;
}

- (BOOL) isFlatWithTolerance:(float)tolerance
{
    if ([start isEqual:outHandle] && [inHandle isEqual:end]) {
        return YES;
    }
    
    PS3DPoint *delta = [end subtract:start];
    
    float dx = delta.x;
    float dy = delta.y;
    
    float d2 = fabs((outHandle.x - end.x) * dy - (outHandle.y - end.y) * dx);
    float d3 = fabs((inHandle.x - end.x) * dy - (inHandle.y - end.y) * dx);
    
    if ((d2 + d3) * (d2 + d3) <= tolerance * (dx * dx + dy * dy)) {
        return YES;
    }
    
    return NO;
}

- (PS3DPoint *) splitAtT:(float)t left:(PSBezierSegment **)L right:(PSBezierSegment **)R
{
    PS3DPoint *A, *B, *C, *D, *E, *F;
    
    A = [start add:[[outHandle subtract:start] multiplyByScalar:t]];
    B = [outHandle add:[[inHandle subtract:outHandle] multiplyByScalar:t]];
    C = [inHandle add:[[end subtract:inHandle] multiplyByScalar:t]];
    
    D = [A add:[[B subtract:A] multiplyByScalar:t]];
    E = [B add:[[C subtract:B] multiplyByScalar:t]];
    F = [D add:[[E subtract:D] multiplyByScalar:t]];
    
    if (L) {
        (*L).start = start;
        (*L).outHandle = A;
        (*L).inHandle = D;
        (*L).end = F;
    }
    
    if (R) {
        (*R).start = F;
        (*R).outHandle = E;
        (*R).inHandle = C;
        (*R).end = end;
    }
    
    if ((L || R) && [start isEqual:outHandle] && [inHandle isEqual:end]) {
        // no curves
        if (L) {
            (*L).inHandle = (*L).end;
        }
        if (R) {
            (*R).outHandle = (*R).start;
        }
    }
    
    return F;
}

- (void) flattenIntoArray:(NSMutableArray *)points
{
    // Debug comming up
    
    if (BezierSegmentRecusionCounter > 100)
        CLSNSLog(@"BezierSegmentRecusionCounter > 100");
    
    if (BezierSegmentRecusionCounter > 200)
        CLSNSLog(@"BezierSegmentRecusionCounter > 200");
    
    if (BezierSegmentRecusionCounter > 300)
        CLSNSLog(@"BezierSegmentRecusionCounter > 300");
    
    if (BezierSegmentRecusionCounter > 400)
        CLSNSLog(@"BezierSegmentRecusionCounter > 400");
    
    if (BezierSegmentRecusionCounter > 500)
    {
        CLSNSLog(@"BezierSegmentRecusionCounter > 500 - bailing out of flattenIntoArray:");
        CLSNSLog(@"Brushes count: %lu", (unsigned long)[PSActiveState sharedInstance].brushesCount);
        CLSNSLog(@"Brush data: %@", [[PSActiveState sharedInstance].brush allProperties]);
        CLSNSLog(@"Active tool (icon name): %@", [PSActiveState sharedInstance].activeTool.iconName);
        CLSNSLog(@"Paint color: %@", [PSActiveState sharedInstance].paintColor);
        return;
    }
    
    BezierSegmentRecusionCounter++;
    
    if ([self isFlatWithTolerance:kDefaultFlatness]) {
        if (points.count == 0) {
            [points addObject:self.start];
        }
        [points addObject:self.end];
    } else {
        // recursive case
        PSBezierSegment *L = [[PSBezierSegment alloc] init];
        PSBezierSegment *R = [[PSBezierSegment alloc] init];
        
        [self splitAtT:0.5f left:&L right:&R];
        
        [L flattenIntoArray:points];
        [R flattenIntoArray:points];
    }
}

@end
