//
//  PSBarSliderVertical.h
//  PSIos
//
//  Created by liuchao on 2019/11/6.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PSBrushSizeOverlay;

@interface PSBarSliderVertical : UIControl

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float value;
@property (nonatomic) NSUInteger thumbSize;
@property (nonatomic) UIView *parentViewForOverlay;

@property (nonatomic) PSBrushSizeOverlay *overlay;

@end

NS_ASSUME_NONNULL_END
