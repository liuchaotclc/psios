//
//  PS3DPoint.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PS3DPoint.h"

@implementation PS3DPoint 

@synthesize x, y, z;
@synthesize CGPoint;

+ (PS3DPoint *) pointWithX:(float)x y:(float)y z:(float)z
{
    PS3DPoint *pt = [[PS3DPoint alloc] init];
    
    pt.x = x;
    pt.y = y;
    pt.z = z;
    
    return pt;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: {x: %f, y: %f, z: %f}", [super description], x, y, z];
}

- (id) copyWithZone:(NSZone *)zone
{
    return [PS3DPoint pointWithX:x y:y z:z];
}

- (BOOL) isEqual:(PS3DPoint *)object
{   
    // is it me?
    if (object == self) {
        return YES;
    }
    
    // does it exist?
    if (!object) {
        return NO;
    }
    
    // is it the same class?
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    // finally, check the ivars
    return (x == object.x && y == object.y && z == object.z);
}

- (float) distanceTo:(PS3DPoint *)pt
{
    float xD = x - pt.x;
    float yD = y - pt.y;
    float zD = z - pt.z;
    
    return sqrt (xD*xD + yD*yD + zD*zD);
}

- (PS3DPoint *) add:(PS3DPoint *)pt
{
    float xD = x + pt.x;
    float yD = y + pt.y;
    float zD = z + pt.z;
    
    return [PS3DPoint pointWithX:xD y:yD z:zD];
}

- (PS3DPoint *) subtract:(PS3DPoint *)pt
{
    float xD = x - pt.x;
    float yD = y - pt.y;
    float zD = z - pt.z;
    
    return [PS3DPoint pointWithX:xD y:yD z:zD];
}

- (PS3DPoint *) normalize
{
    return [self multiplyByScalar:1.0f / [self magnitude]];
}

- (PS3DPoint *) multiplyByScalar:(float)scalar
{
    return [PS3DPoint pointWithX:(x * scalar) y:(y * scalar) z:(z * scalar)];
}

- (float) dot:(PS3DPoint *)pt
{
    float xP = x * pt.x;
    float yP = y * pt.y;
    float zP = z * pt.z;
    
    return (xP + yP + zP);
}

- (PS3DPoint *) abs
{
    return [PS3DPoint pointWithX:fabs(x) y:fabs(y) z:fabs(z)];
}

- (PS3DPoint *) unitVector
{
    float magnitude = sqrt(x * x + y * y + z * z);
    return [PS3DPoint pointWithX:(x / magnitude) y:(y / magnitude) z:(z / magnitude)];
}

- (PS3DPoint *) transform:(CGAffineTransform)tX
{
    CGPoint transformed = CGPointApplyAffineTransform(self.CGPoint, tX);
    return [PS3DPoint pointWithX:transformed.x y:transformed.y z:self.z];
}

- (BOOL) isZero
{
    return (x == 0 && y == 0 && z == 0);
}

- (float) magnitude
{
    return sqrt(x * x + y * y + z * z);
}

- (CGPoint) CGPoint
{
    return CGPointMake(x, y);
}

- (void) setCGPoint:(CGPoint)pt
{
    x = pt.x;
    y = pt.y;
}

- (BOOL) isDegenerate
{
    return (isnan(x) || isnan(y) || isnan(z)) ? YES : NO;
}

//- (void) setZ:(float)inZ
//{
//    z = WDClamp(0.0f, 1.0f, inZ);
//}

@end

