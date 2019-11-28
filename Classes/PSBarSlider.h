//
//  PSBarSlider.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@class PSBrushSizeOverlay;

@interface PSBarSlider : UIControl

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float value;
@property (nonatomic) NSUInteger thumbSize;
@property (nonatomic) UIView *parentViewForOverlay;

@property (nonatomic) PSBrushSizeOverlay *overlay;

@end
