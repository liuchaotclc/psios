//
//  PSColorSourceView.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <UIKit/UIKit.h>

@class PSDragChip;
@class PSColor;

@interface PSColorSourceView : UIView {
    CGPoint     initialTap_;
}

@property (nonatomic, strong) PSDragChip *dragChip;
@property (nonatomic, strong) id lastTarget;
@property (nonatomic, readonly) BOOL moved;

- (void) dragEnded;
- (PSColor *) color;

@end
