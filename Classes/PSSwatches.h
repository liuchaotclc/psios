//
//  PSSwatches.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSColorSourceView.h"
#import "PSDragChip.h"

@class PSColor;
@class PSColorPickerController;

@protocol PSSwatchesDelegate <NSObject>
- (void) setColor:(PSColor *)color;
- (void) doubleTapped:(id)sender;
@end

@interface PSSwatches : PSColorSourceView <PSColorDragging>

@property (nonatomic, weak) id<PSSwatchesDelegate> delegate;
@property (nonatomic, assign) NSInteger highlightIndex;
@property (nonatomic, assign) NSInteger initialIndex;
@property (nonatomic, strong) PSColor *highlightColor;
@property (nonatomic, strong) PSColor *tappedColor;
@property (nonatomic) UIImageView *shadowOverlay;

@end
