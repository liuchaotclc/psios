//
//  PSHueShifter.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <Foundation/Foundation.h>

@class PSHueIndicator;
@class PSColor;

@interface WDHueIndicatorOverlay : UIView
@property (nonatomic, weak) PSHueIndicator *indicator;
@end

@interface PSHueIndicator : UIView

@property (nonatomic, strong) PSColor *color;

- (CGRect) colorRect;

@end

@interface PSHueShifter : UIControl {
    CGImageRef      offsetHueImage_;
    CGImageRef      hueImage_;
    float           value_;
    float           initialValue_;
    CGPoint         initialPt_;
    
    PSHueIndicator  *indicator_;
    
}

@property (nonatomic, assign) float floatValue;

@end
