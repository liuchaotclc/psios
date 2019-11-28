//
//  ScreenTool.h
//  PsIos
//
//  Created by liuchao on 2019/11/12.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
 
#define ViewSafeAreaInsets(view) [ScreenToolSharedInstance getViewSafeAreaInsets:view]
 
#define WindowSafeAreaInsets [ScreenToolSharedInstance getWindowSafeAreaInsets]
 
#define Screen_height [[UIScreen mainScreen] bounds].size.height
#define Screen_width [[UIScreen mainScreen] bounds].size.width
 
#define ScreenToolSharedInstance [ScreenTool sharedInstance]
 
#define NavAndStatusBarHeight [ScreenToolSharedInstance getNavAndStatusBarHeight] //获取导航栏和状态的高度
#define TabBarAndVirtualHomeHeight [ScreenToolSharedInstance getTabBarAndVirtualHomeHeight]//获取tabbar和底部的高度
 
#define StatusBarHeight [ScreenToolSharedInstance getStatusBarHeight]
#define NavContentHeight [ScreenToolSharedInstance getNavContentHeight]
#define TabBarContentHeight [ScreenToolSharedInstance getTabBarContentHeight]
 
#define ScrollViewContentInsetAdjustmentBehavior(scrollView) [ScreenToolSharedInstance setScrollViewContentInsetAdjustmentBehavior:scrollView]
 
typedef NS_ENUM(NSUInteger, DeviceScreenType) {//设备屏幕类型
    DeviceTypeIphone4Screen,
    DeviceTypeIphone5Screen,
    DeviceTypeIphone6Screen,
    DeviceTypeIphone6PlusScreen,
    DeviceTypeIphoneXScreen,
    DeviceTypeOtherScreen
};
 
typedef NS_ENUM(NSUInteger, DeviceOrientationType) {//屏幕方向类型
    DeviceOrientationTypeHorizontalScreen,
    DeviceOrientationTypeVerticalScreen,
    DeviceOrientationTypeOther
};

NS_ASSUME_NONNULL_BEGIN

@interface ScreenTool : NSObject
@property(nonatomic,unsafe_unretained)BOOL isAccordingToSafeArea;
-(void)setScrollViewContentInsetAdjustmentBehavior:(UIScrollView *)scrollView;
 
+(ScreenTool *)sharedInstance;
+(BOOL)isSmallScreen;
 
-(UIEdgeInsets)getWindowSafeAreaInsets;
-(UIEdgeInsets)getViewSafeAreaInsets:(UIView *)view;
 
-(NSString *)getDevice;
-(DeviceScreenType)getDeviceType;
-(DeviceOrientationType)getDeviceOrientationType;
 
-(CGFloat)getNavAndStatusBarHeight;
-(CGFloat)getTabBarAndVirtualHomeHeight;
 
-(CGFloat)getTabBarContentHeight;
-(CGFloat)getNavContentHeight;
-(CGFloat)getStatusBarHeight;

@end

NS_ASSUME_NONNULL_END
