//
//  PSBrushController.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>

@class PSBar;
@class PSBarItem;
@class PSBrush;
@class PSPropertyCell;
@class PSStampPicker;

@interface PSBrushController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
    NSMutableArray      *toolbarItems_;
    PSBarItem           *randomize_;
}

@property (nonatomic) IBOutlet UITableView *propertyTable;
@property (nonatomic) IBOutlet PSPropertyCell *propertyCell;
@property (nonatomic) IBOutlet UIImageView *preview;
@property (nonatomic) IBOutlet PSStampPicker *picker;
@property (nonatomic, weak) PSBar *topBar;
@property (nonatomic, weak) PSBar *bottomBar;
@property (nonatomic, weak) PSBrush *brush;

@end
