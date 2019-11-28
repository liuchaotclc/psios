//
//  PSUnlockSlider.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <UIKit/UIKit.h>
#import "PSColor.h"

@class PSColorWell;
//创建协议
@protocol ColorSliderDelegate <NSObject>
- (void)onColorSliderSingleClick:(id)sender; //单次点击事件
- (void)onColorSliderToEnd:(id)sender; //滑动到底部了
@end

@interface ColorPanelSlider : UIControl <UIGestureRecognizerDelegate>
@property (nonatomic, weak)id<ColorSliderDelegate> delegate; //声明协议变量

+ (ColorPanelSlider *) unlockSlider;
- (void) setColor:(PSColor *)inColor;

@end
