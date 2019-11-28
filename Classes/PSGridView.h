//
//  PSGridView.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <UIKit/UIKit.h>

@protocol WDGridViewDataSource;

@interface PSGridView : UIScrollView
@property (nonatomic) id<WDGridViewDataSource> dataSource;

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSUInteger)index;

// scrolling support
- (NSUInteger) approximateIndexOfCenter;
- (CGRect) centeredFrameForIndex:(NSUInteger)index;
- (void) scrollToBottom;
- (void) centerIndex:(NSUInteger)index;

// returns nil if the cell at index is not visible
- (UIView *) visibleCellForIndex:(NSUInteger)index;
- (NSArray *) visibleCells;

- (void) cellsDeleted;

@end

@protocol WDGridViewDataSource<NSObject>
@required

// assumes square cells
- (NSInteger) cellDimension;

- (NSUInteger) numberOfItemsInGridView:(PSGridView *)gridView;
- (UIView *) gridView:(PSGridView *)gridView cellForIndex:(NSUInteger)index;

@end
