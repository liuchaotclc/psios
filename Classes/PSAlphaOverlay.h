//
//  PSAlphaOverlay.h
//  PSIos
//
//  Created by liuchao on 2019/11/6.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSColor.h"
#import "PSColorInfoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSAlphaOverlay : UIView

@property (nonatomic) UILabel *title;
@property (nonatomic, strong) PSColorInfoView *colorInfoview;
@property (nonatomic) float value;
@property (nonatomic) BOOL isSquare;
@end

NS_ASSUME_NONNULL_END
