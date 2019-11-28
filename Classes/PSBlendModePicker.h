//
//  PSBlendModePicker.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@interface PSBlendModePicker : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic) NSArray *titles;
@property (nonatomic) UIFont *font;
@property (nonatomic) NSMutableArray *buttonBounds;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic) UIImageView *indicatorImageView;

- (void) chooseItemAtIndex:(NSUInteger)index;
- (void) chooseItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void) chooseItemAtIndexSilent:(NSUInteger)index;

@end
