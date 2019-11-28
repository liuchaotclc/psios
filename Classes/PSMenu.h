//
//  PSMenu.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>


@interface PSMenu : UIControl {
    NSMutableArray          *rects_;
    NSMutableArray          *items_;
    BOOL                    visible_;
}

@property (nonatomic, assign) int indexOfSelectedItem;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, weak) UIPopoverController *popover;
@property (nonatomic, weak) id delegate;

- (id) initWithItems:(NSArray *)items;
- (void) dismiss;

@end
