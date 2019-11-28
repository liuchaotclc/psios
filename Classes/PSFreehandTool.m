//
//  PSFreehandTool.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PS3DPoint.h"
#import "PSActiveState.h"
#import "PSAddPath.h"
#import "PSBezierNode.h"
#import "PSBristleGenerator.h"
#import "PSBrush.h"
#import "PSCanvas.h"
#import "PSColor.h"
#import "PSFreehandTool.h"
#import "PSLayer.h"
#import "PSPath.h"
#import "PSPanGestureRecognizer.h"
#import "PSRandom.h"
#import "PSUtilities.h"
#import "PSStylusManager.h"

#define kMaxError                   10.0f
#define kSpeedFactor                3
#define kBezierInterpolationSteps   5

@implementation PSFreehandTool {
    PSRandom *randomizer_;
    BOOL supportsPreciseLocation;
    BOOL supportsCoalescedTouches;
    BOOL supportsStylusTouchType;
    float _lastAltitudeAngle;
    float _brushSize;
}

@synthesize  eraseMode;
@synthesize realPressure;

- (id) init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    accumulatedStrokePoints_ = [[NSMutableArray alloc] init];
    
    supportsPreciseLocation = [[UITouch new] respondsToSelector:@selector(preciseLocationInView:)];
    supportsCoalescedTouches = [[UIEvent new] respondsToSelector:@selector(coalescedTouchesForTouch:)];
    supportsStylusTouchType = [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9, 1, 0}];
    
    return self;
}

- (NSString *) iconName
{
    return @"brush.png";
}

- (CGPoint) documentLocationFromRecognizer:(PSPanGestureRecognizer *)recognizer withTouch: (UITouch*) touch
{
    PSCanvas *canvas = (PSCanvas *)recognizer.view;
    CGPoint point;
    
    if (supportsPreciseLocation){
        point = [touch preciseLocationInView:recognizer.view];
    }else{
        point = [touch locationInView:recognizer.view];
    }
    
    return [canvas convertPointToDocument:point];
}

- (void) averagePointsFrom:(NSUInteger)startIx to:(NSUInteger)endIx
{
    for (NSUInteger i = startIx; i < endIx; i++) {
        PS3DPoint *current = [pointsToFit_[i].anchorPoint multiplyByScalar:0.5];
        PS3DPoint *prev = [pointsToFit_[i-1].anchorPoint multiplyByScalar:0.25];
        PS3DPoint *next = [pointsToFit_[i+1].anchorPoint multiplyByScalar:0.25];
        
        pointsToFit_[i].anchorPoint = [current add:[prev add:next]];
    }
}

- (void) paintFittedPoints:(PSCanvas *)canvas
{
    BOOL    touchEnding = (pointsIndex_ != 5) ? YES : NO;
    int     loopBound = touchEnding ? pointsIndex_ - 1 : 4;
    int     drawBound = touchEnding ? pointsIndex_ - 1 : 2;
    
    [self averagePointsFrom:2 to:loopBound];
    
    for (int i = 1; i < loopBound; i++) {
        PS3DPoint *current = pointsToFit_[i].anchorPoint;
        PS3DPoint *prev = pointsToFit_[i-1].anchorPoint;
        PS3DPoint *next = pointsToFit_[i+1].anchorPoint;
        
        PS3DPoint *delta = [next subtract:prev];
        delta = [delta normalize];
        
        float inMagnitude = [prev distanceTo:current] / 3.0f;
        float outMagnitude = [next distanceTo:current] / 3.0f;

        PS3DPoint *in = [current subtract:[delta multiplyByScalar:inMagnitude]];
        PS3DPoint *out = [current add:[delta multiplyByScalar:outMagnitude]];
        
        pointsToFit_[i].inPoint = in;
        pointsToFit_[i].outPoint = out;
    }
    
    NSMutableArray *nodes = [NSMutableArray array];
    for (int i = 0; i <= drawBound; i++) {
        [nodes addObject:pointsToFit_[i]];
        
        if (i == 0 && accumulatedStrokePoints_.count) {
            [accumulatedStrokePoints_ removeLastObject];
        }
        [accumulatedStrokePoints_ addObject:pointsToFit_[i]];
    }
    PSPath *path = [[PSPath alloc] init];
    path.nodes = nodes;
    
    [self paintPath:path inCanvas:canvas];
    
    if (!touchEnding) {
        for (int i = 0; i < 3; i++) {
            pointsToFit_[i] = pointsToFit_[i+2];
        }
        pointsIndex_ = 3;
    }
}

- (void) gestureBegan:(PSPanGestureRecognizer *)recognizer
{    
    [super gestureBegan:recognizer];
    
    firstEver_ = YES;
    
    strokeBounds_ = CGRectZero;
    [accumulatedStrokePoints_ removeAllObjects];
    
    CGPoint location = [self documentLocationFromRecognizer:recognizer withTouch:[recognizer.touches anyObject]];
    
    // capture first point
    lastLocation_ = location;
    float pressure = 1.0f;
    
    // see if we've got real pressure
    self.realPressure = NO;
    if ([recognizer isKindOfClass:[PSPanGestureRecognizer class]]) {
        UITouch *touch = [recognizer.touches anyObject];
        pressure = [[PSStylusManager sharedStylusManager] pressureForTouch:touch realPressue:&realPressure];
    }
    
    PSBezierNode *node = [PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:location.x y:location.y z:pressure]];
    pointsToFit_[0] = node;
    pointsIndex_ = 1;
    
    _brushSize = [PSActiveState sharedInstance].brush.weight.value;
    
    clearBuffer_ = YES;
}

- (void) gestureMoved:(PSPanGestureRecognizer *)recognizer
{
    [super gestureMoved:recognizer];
    
    PSCanvas    *canvas = (PSCanvas *)recognizer.view;
    UITouch     *_touch = [recognizer.touches anyObject];
    NSMutableArray<UITouch*> * touches = [NSMutableArray new];
    
    if (supportsCoalescedTouches){
        [touches addObjectsFromArray:[recognizer.event coalescedTouchesForTouch:_touch]];
    }else{
        [touches addObject:_touch];
    }
    
    for(UITouch * touch in touches)
    {
        CGPoint     location = [self documentLocationFromRecognizer:recognizer withTouch:touch];
        float       distanceMoved = WDDistance(location, lastLocation_);
        
        if (distanceMoved < 3.0 / canvas.scale) {
            // haven't moved far enough
            return;
        }
        
        float pressure = 1.0f;
        
        if (!self.realPressure || (supportsStylusTouchType && _touch.type != UITouchTypeStylus)) {
            if ([recognizer respondsToSelector:@selector(velocityInView:)]) {
                CGPoint velocity = [(UIPanGestureRecognizer *) recognizer velocityInView:recognizer.view];
                float   speed = PSMagnitude(velocity) / 1000.0f; // pixels/millisecond
                
                // account for view scale
                //speed /= canvas.scale;
                
                // convert speed into "pressure"
                pressure = PSSineCurve(1.0f - MIN(kSpeedFactor, speed) / kSpeedFactor);
                pressure = 1.0f - pressure;
            }
        } else {
            pressure = [[PSStylusManager sharedStylusManager] pressureForTouch:_touch realPressue:nil];
            
            float altitudeAngle = 1/MIN([touch altitudeAngle], 1);
            
            if (altitudeAngle != _lastAltitudeAngle){
                [PSActiveState sharedInstance].brush.weight.value = _brushSize * altitudeAngle;
                [[NSNotificationCenter defaultCenter] postNotificationName:WDActiveBrushDidChange object:nil];
                
                _lastAltitudeAngle = altitudeAngle;
            }
        }
        
        if (firstEver_) {
            pointsToFit_[0].inPressure = pressure;
            pointsToFit_[0].anchorPressure = pressure;
            pointsToFit_[0].outPressure = pressure;
            firstEver_ = NO;
        } else if (pointsIndex_ != 0) {
            // average out the pressures
            pressure = (pressure + pointsToFit_[pointsIndex_ - 1].anchorPressure) / 2;
        }
        
        pointsToFit_[pointsIndex_++] = [PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:location.x y:location.y z:pressure]];
        
        // special case: otherwise the 2nd overall point never gets averaged
        if (pointsIndex_ == 3) { // since we just incrementred pointsIndex (it was really just 2)
            [self averagePointsFrom:1 to:2];
        }
        
        if (pointsIndex_ == 5) {
            [self paintFittedPoints:canvas];
        }
        
        // save data for the next iteration
        lastLocation_ = location;
    }
}

- (void) gestureEnded:(PSPanGestureRecognizer *)recognizer
{
    PSColor     *color = [PSActiveState sharedInstance].paintColor;
    PSBrush     *brush = [PSActiveState sharedInstance].brush;
    PSCanvas    *canvas = (PSCanvas *) recognizer.view;
    PSPainting  *painting = canvas.painting;
    
    CGPoint     location = [recognizer locationInView:recognizer.view];
    location = [canvas convertPointToDocument:location];
    
    if (!self.moved) { // draw a single stamp
        PSBezierNode *node = [PSBezierNode bezierNodeWithAnchorPoint:[PS3DPoint pointWithX:location.x y:location.y z:1.0]];
        PSPath *path = [[PSPath alloc] init];
        [path addNode:node];
        
        [accumulatedStrokePoints_ addObject:node];
        
        [self paintPath:path inCanvas:canvas];
    } else {
        [self paintFittedPoints:canvas];
    }
    
    if (CGRectIntersectsRect(strokeBounds_, painting.bounds)) {
        if (accumulatedStrokePoints_.count > 0) {
            PSPath *accumulatedPath = [[PSPath alloc] init];
            accumulatedPath.nodes = accumulatedStrokePoints_;
            accumulatedPath.color = color;
            accumulatedPath.brush = [brush copy];
            changeDocument(painting, [PSAddPath addPath:accumulatedPath erase:eraseMode layer:painting.activeLayer sourcePainting:painting]);
            [painting.activeLayer commitStroke:strokeBounds_ color:color erase:eraseMode undoable:YES path:accumulatedPath];
        }
    }
    
    if (_brushSize != [PSActiveState sharedInstance].brush.weight.value){
        [PSActiveState sharedInstance].brush.weight.value = _brushSize;
        [[NSNotificationCenter defaultCenter] postNotificationName:WDActiveBrushDidChange object:nil];
    }
    
    painting.activePath = nil;
    
    [super gestureEnded:recognizer];
}

- (void) gestureCanceled:(UIGestureRecognizer *)recognizer
{
    PSCanvas    *canvas = (PSCanvas *) recognizer.view;
    PSPainting  *painting = canvas.painting;
    
    painting.activePath = nil;
    [canvas drawView];
    
    [super gestureCanceled:recognizer];
}

- (void) paintPath:(PSPath *)path inCanvas:(PSCanvas *)canvas
{
    path.brush = [PSActiveState sharedInstance].brush;
    path.color = [PSActiveState sharedInstance].paintColor;
    path.action = eraseMode ? WDPathActionErase : WDPathActionPaint;
    
    if (clearBuffer_) {
        // depends on the path's brush
        randomizer_ = [path newRandomizer];
        lastRemainder_ = 0.f;
    }
    
    path.remainder = lastRemainder_;
    
    CGRect pathBounds = [canvas.painting paintStroke:path randomizer:randomizer_ clear:clearBuffer_];
    strokeBounds_ = PSUnionRect(strokeBounds_, pathBounds);
    lastRemainder_ = path.remainder;
    
    //[canvas drawViewInRect:pathBounds];
    
    clearBuffer_ = NO;
}

@end
