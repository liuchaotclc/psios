//
//  PSTool.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class PSCanvas;

@interface PSTool : NSObject {
    BOOL        moved_;
}

@property (unsafe_unretained, nonatomic, readonly) id icon;
@property (weak, nonatomic, readonly) NSString *iconName;
@property (nonatomic, readonly) BOOL moved;

+ (PSTool *) tool;
- (void) activated;
- (void) deactivated;

- (void) buttonDoubleTapped;

- (void) gestureBegan:(UIGestureRecognizer *)recognizer;
- (void) gestureMoved:(UIGestureRecognizer *)recognizer;
- (void) gestureEnded:(UIGestureRecognizer *)recognizer;
- (void) gestureCanceled:(UIGestureRecognizer *)recognizer;

@end
