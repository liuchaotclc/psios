//
//  PSBar.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

typedef enum {
    WDBarTypeView,
    WDBarTypeFlexible,
    WDBarTypeFixed
} WDBarItemType;

@interface PSBarItem : NSObject 
    
@property (nonatomic) UIView *view;
@property (nonatomic) UIView *landscapeView;
@property (nonatomic, readonly) UIView *activeView;
@property (nonatomic) WDBarItemType type;
@property (nonatomic) NSUInteger width;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL flexibleContent;

+ (PSBarItem *) barItemWithView:(UIView *)view;
+ (PSBarItem *) barItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (PSBarItem *) flexibleItem;
+ (PSBarItem *) fixedItemWithWidth:(NSUInteger)width;
+ (PSBarItem *) backButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

- (void) setImage:(UIImage *)image;

@end

typedef enum {
    WDBarTypeBottom,
    WDBarTypeTop,
    WDBarTypeLeft,
    WDBarTypeRight
} WDBarType;

@interface PSBar : UIView

@property (nonatomic) NSArray *items;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) BOOL ignoreTouches;
@property (nonatomic) BOOL animateAfterLayout;
@property (nonatomic) WDBarType barType;
@property (nonatomic) float defaultFlexibleSpacing;
@property (nonatomic) BOOL tightHitTest;

+ (PSBar *) bottomBar;
+ (PSBar *) topBar;

- (void) setTitle:(NSString *)title;
- (void) setItems:(NSArray *)items animated:(BOOL)animated;
- (void) addEdge;

- (void) setOrientation:(UIInterfaceOrientation)orientation;

@end
