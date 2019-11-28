//
//  PSPath.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  
#import "PSBezierSegment.h"
#import "PSCoding.h"

@class PSBezierNode;
@class PSBrush;
@class PSColor;
@class PSRandom;

typedef enum {
    WDPathActionPaint,
    WDPathActionErase
} WDPathAction;

@interface PSPath : NSObject <PSCoding, NSCopying> {
    NSMutableArray      *nodes_;
    BOOL                closed_;
    CGMutablePathRef    pathRef_;
    CGRect              bounds_;
    BOOL                boundsDirty_;
    
    // rendering assistance
    float               remainder_;
    NSMutableArray      *points_;
    NSMutableArray      *sizes_;
    NSMutableArray      *angles_;
    NSMutableArray      *alphas_;
}

@property (nonatomic, assign) BOOL closed;
@property (nonatomic, strong) NSMutableArray *nodes;
@property (nonatomic, strong) PSBrush *brush;
@property (nonatomic) PSColor *color;
@property (nonatomic, assign) float remainder;
@property (nonatomic) WDPathAction action;
@property (nonatomic, assign) float scale;

@property (nonatomic, assign) BOOL limitBrushSize;

+ (PSPath *) pathWithRect:(CGRect)rect;
+ (PSPath *) pathWithOvalInRect:(CGRect)rect;
+ (PSPath *) pathWithStart:(CGPoint)start end:(CGPoint)end;

- (id) initWithRect:(CGRect)rect;
- (id) initWithOvalInRect:(CGRect)rect;
- (id) initWithStart:(CGPoint)start end:(CGPoint)end;
- (id) initWithNode:(PSBezierNode *)node;

- (void) invalidatePath;

- (void) addNode:(PSBezierNode *)node;
- (void) addAnchors;

- (PSBezierNode *) firstNode;
- (PSBezierNode *) lastNode;

- (CGRect) controlBounds;
- (void) computeBounds;

- (void) setClosedQuiet:(BOOL)closed;

- (CGPathRef) pathRef;

- (NSArray *) flattenedPoints;
- (void) flatten;

- (PSRandom *) newRandomizer;
- (CGRect) paint:(PSRandom *)randomizer;

@end

