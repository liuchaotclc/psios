//
//  ScreenTool.m
//  PsIos
//
//  Created by liuchao on 2019/11/12.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import "ScreenTool.h"

//屏幕宽和高
#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

@implementation ScreenTool
-(instancetype)init{
    if (self = [super init]) {
        self.isAccordingToSafeArea = YES;
    }
    return self;
}
 
+(ScreenTool *)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id screenTool = nil;
    dispatch_once(&pred, ^{
        screenTool = [[self alloc] init];
    });
    return screenTool;
}
 
-(void)setScrollViewContentInsetAdjustmentBehavior:(UIScrollView *)scrollView {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if(@available(iOS 11.0, *)) {
        if ([scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
#endif
}
 
-(UIEdgeInsets)getWindowSafeAreaInsets {
    UIEdgeInsets i = UIEdgeInsetsZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if(@available(iOS 11.0, *)) {
        i = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    }
#endif
    return i;
}
 
-(UIEdgeInsets)getViewSafeAreaInsets:(UIView *)view {
    UIEdgeInsets i = UIEdgeInsetsZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if(@available(iOS 11.0, *)) {
        i = view.safeAreaInsets;
    }
#endif
    return i;
}
 
-(NSString *)getDevice {
    if ((Screen_width == 320 && Screen_height == 480) || (Screen_height == 320 && Screen_width == 480)) {
        return @"4";
    }else if ((Screen_width == 320 && Screen_height == 568) || (Screen_height == 320 && Screen_width == 568)) {
        return @"5";
    }else if ((Screen_width == 375 && Screen_height == 667) || (Screen_height == 375 && Screen_width == 667)) {
        return @"6";
    }else if ((Screen_width == 375 && Screen_height == 812) || (Screen_height == 375 && Screen_width == 812)) {
        return @"x";
    }else if ((Screen_width == 414 && Screen_height == 736) || (Screen_height == 414 && Screen_width == 736)) {
        return @"6p";
    }else {
        return @"";
    }
}
 
-(DeviceScreenType)getDeviceType {
    if ((Screen_width == 320 && Screen_height == 480) || (Screen_height == 320 && Screen_width == 480)) {
        return DeviceTypeIphone4Screen;
    }else if ((Screen_width == 320 && Screen_height == 568) || (Screen_height == 320 && Screen_width == 568)) {
        return DeviceTypeIphone5Screen;
    }else if ((Screen_width == 375 && Screen_height == 667) || (Screen_height == 375 && Screen_width == 667)) {
        return DeviceTypeIphone6Screen;
    }else if ((Screen_width == 375 && Screen_height == 812) || (Screen_height == 375 && Screen_width == 812)) {
        return DeviceTypeIphoneXScreen;
    }else if ((Screen_width == 414 && Screen_height == 736) || (Screen_height == 414 && Screen_width == 736)) {
        return DeviceTypeIphone6PlusScreen;
    }else {
        return DeviceTypeOtherScreen;
    }
}
 
-(DeviceOrientationType)getDeviceOrientationType {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        return DeviceOrientationTypeVerticalScreen;
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return DeviceOrientationTypeHorizontalScreen;
    }else {
        return DeviceOrientationTypeOther;
    }
}
 
+(BOOL)isSmallScreen{
    if (Screen_width >=375 && Screen_height >= 667) {
        return NO;
    }else {
        return YES;
    }
}
 
-(CGFloat)getTabBarContentHeight {
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, WindowSafeAreaInsets)) {
        if ([self getDeviceOrientationType] == DeviceOrientationTypeHorizontalScreen) {
            if (self.isAccordingToSafeArea) {
                return 32;
            }else {
                return 49;
            }
        }else {
            return 49;
        }
    }else {
        return 49;
    }
}
 
-(CGFloat)getNavContentHeight {
    if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, WindowSafeAreaInsets)) {
        if ([self getDeviceOrientationType] == DeviceOrientationTypeHorizontalScreen) {
            if (self.isAccordingToSafeArea) {
                return 32;
            }else {
                return 44;
            }
        }else {
            return 44;
        }
    }else {
        return 44;
    }
}
 
-(CGFloat)getStatusBarHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}
 
-(CGFloat)getNavAndStatusBarHeight {
    return [self getNavContentHeight]+[self getStatusBarHeight];
}
 
-(CGFloat)getTabBarAndVirtualHomeHeight {
    return [self getTabBarContentHeight]+WindowSafeAreaInsets.bottom;
}
@end
