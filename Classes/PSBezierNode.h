//
//  PSBezierNode.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "PSCoding.h"

@class PS3DPoint;

@interface PSBezierNode : NSObject <PSCoding, NSCopying>

@property (nonatomic) PS3DPoint *inPoint;
@property (nonatomic) PS3DPoint *anchorPoint;
@property (nonatomic) PS3DPoint *outPoint;

@property (nonatomic) float inPressure;
@property (nonatomic) float anchorPressure;
@property (nonatomic) float outPressure;

@property (nonatomic, readonly) BOOL hasInPoint;
@property (nonatomic, readonly) BOOL hasOutPoint;
@property (nonatomic, readonly) BOOL isCorner;

+ (PSBezierNode *) bezierNodeWithAnchorPoint:(PS3DPoint *)pt;
+ (PSBezierNode *) bezierNodeWithInPoint:(PS3DPoint *)inPoint
                             anchorPoint:(PS3DPoint *)pt
                                outPoint:(PS3DPoint *)outPoint;

- (id) initWithAnchorPoint:(PS3DPoint *)pt;
- (id) initWithInPoint:(PS3DPoint *)inPoint
           anchorPoint:(PS3DPoint *)pt
              outPoint:(PS3DPoint *)outPoint;

- (PSBezierNode *) transform:(CGAffineTransform)transform;
- (PSBezierNode *) flippedNode;

@end

