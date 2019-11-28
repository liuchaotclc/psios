//
//  PSBezierSegment.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

extern const float kDefaultFlatness;
extern unsigned long long BezierSegmentRecusionCounter;

@class PSBezierNode;
@class PS3DPoint;

@interface PSBezierSegment : NSObject

@property (nonatomic) PS3DPoint *start;
@property (nonatomic) PS3DPoint *outHandle;
@property (nonatomic) PS3DPoint *inHandle;
@property (nonatomic) PS3DPoint *end;

+ (PSBezierSegment *) segmentWithStart:(PSBezierNode *)start end:(PSBezierNode *)end;

- (BOOL) isDegenerate;
- (BOOL) isFlatWithTolerance:(float)tolerance;
- (PS3DPoint *) splitAtT:(float)t left:(PSBezierSegment **)L right:(PSBezierSegment **)R;
- (void) flattenIntoArray:(NSMutableArray *)points;

@end

