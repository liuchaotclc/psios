//
//  PS3DPoint.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <Foundation/Foundation.h>

@interface PS3DPoint : NSObject

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float z;
@property (nonatomic) CGPoint CGPoint;

+ (PS3DPoint *) pointWithX:(float)x y:(float)y z:(float)z;
- (float) distanceTo:(PS3DPoint *)pt;
- (PS3DPoint *) add:(PS3DPoint *)pt;
- (PS3DPoint *) subtract:(PS3DPoint *)pt;
- (float) dot:(PS3DPoint *)pt;
- (PS3DPoint *) unitVector;
- (BOOL) isZero;
- (float) magnitude;
- (PS3DPoint *) normalize;
- (PS3DPoint *) abs;
- (PS3DPoint *) multiplyByScalar:(float)scalar;
- (PS3DPoint *) transform:(CGAffineTransform)tX;
- (BOOL) isDegenerate;

@end
