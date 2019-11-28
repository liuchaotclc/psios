//
//  PSBrushesController.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>

@class PSBar;
@class PSBrushCell;
@class PSColorSlider;

@interface PSBrushesController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *toolbarItems_;
}

@property (nonatomic) IBOutlet UITableView *brushTable;
@property (nonatomic) IBOutlet PSBrushCell *brushCell;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) PSBar *topBar;
@property (nonatomic, weak) PSBar *bottomBar;
@property (nonatomic) PSBarSlider *brushSlider;


@end
