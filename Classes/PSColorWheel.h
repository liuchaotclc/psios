//
//  PSColorWheel.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@class PSColor;
@class PSColorIndicator;

@interface PSColorWheel : UIControl {
    CGImageRef          wheelImage_;
    PSColorIndicator    *indicator_;
    CGPoint             value_;
}

@property (nonatomic) PSColor *color;
@property (nonatomic, readonly) int radius;
@property (nonatomic, assign) float hue;

@end
