//
//  PSBrushCell.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@class PSBrush;

@interface PSBrushCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *preview;
@property (nonatomic) IBOutlet UILabel *size;
@property (nonatomic) IBOutlet UIButton *editButton;

@property (nonatomic) PSBrush *brush;
@property (nonatomic, weak) UITableView *table;

@property (nonatomic) BOOL previewDirty;

- (IBAction)disclose:(id)sender;

@end
