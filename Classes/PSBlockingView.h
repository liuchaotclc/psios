//
//  PSBlockingView.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <UIKit/UIKit.h>

@interface PSBlockingView : UIView {
    NSArray     *passthroughViews_;
    BOOL        sendAction_;
}

@property (nonatomic, assign) SEL action;
@property (nonatomic, weak) id target;
@property (nonatomic) NSArray *passthroughViews;

- (void) setShadowCenter:(CGPoint)center radius:(float)radius;

@end
