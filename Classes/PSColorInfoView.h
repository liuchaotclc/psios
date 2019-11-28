//
//  PSColorInfoView.h
//  PSIos
//
//  Created by liuchao on 2019/11/6.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PSColorInfoView
@property (nonatomic, strong) UIColor *color;
@end

@interface PSColorInfoView : UIView <PSColorInfoView>
- (void)setColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
