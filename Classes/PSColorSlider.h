//
//  PSColorSlider.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@class PSColorIndicator;
@class PSColor;

typedef enum {
    WDColorSliderModeHue,
    WDColorSliderModeSaturation,
    WDColorSliderModeBrightness,
    WDColorSliderModeRed,
    WDColorSliderModeGreen,
    WDColorSliderModeBlue,
    WDColorSliderModeAlpha,
    WDColorSliderModeRedBalance,
    WDColorSliderModeGreenBalance,
    WDColorSliderModeBlueBalance
} WDColorSliderMode;

@interface PSColorSlider : UIControl {
    CGImageRef          hueImage_;
    PSColor             *color_;
    float               value_;
    CGShadingRef        shadingRef_;
    WDColorSliderMode   mode_;
    BOOL                reversed_;
}

@property (nonatomic, assign) WDColorSliderMode mode;
@property (nonatomic, readonly) float floatValue;
@property (nonatomic) PSColor *color;
@property (nonatomic, assign) BOOL reversed;
@property (nonatomic, readonly) PSColorIndicator *indicator;

@end
