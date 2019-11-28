//
//  PSFreehandTool.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSTool.h"

@class PSBrush;
@class PSPath;
@class PSBezierNode;
@class PSPanGestureRecognizer;

@interface PSFreehandTool : PSTool {
    BOOL                    firstEver_;
    CGPoint                 lastLocation_;
    float                   lastRemainder_;
    
    BOOL                    clearBuffer_;
    CGRect                  strokeBounds_;
    
    NSMutableArray          *accumulatedStrokePoints_;
    PSBezierNode            *pointsToFit_[5];
    int                     pointsIndex_;
}

@property (nonatomic) BOOL eraseMode;
@property (nonatomic) BOOL realPressure;

- (void) paintPath:(PSPath *)path inCanvas:(PSCanvas *)canvas;

- (void) gestureBegan:(PSPanGestureRecognizer *)recognizer;
- (void) gestureMoved:(PSPanGestureRecognizer *)recognizer;
- (void) gestureEnded:(PSPanGestureRecognizer *)recognizer;

@end
