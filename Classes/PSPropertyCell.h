//
//  PSPropertyCell.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@class PSProperty;

@interface PSPropertyCell : UITableViewCell

@property (nonatomic) IBOutlet UISlider *slider;
@property (nonatomic) IBOutlet UILabel *title;
@property (nonatomic) IBOutlet UILabel *value;
@property (nonatomic) IBOutlet UIButton *decrement;
@property (nonatomic) IBOutlet UIButton *increment;

@property (nonatomic) PSProperty *property;

- (IBAction) takeValueFrom:(id)sender;
- (IBAction) decrement:(id)sender;
- (IBAction) increment:(id)sender;

@end
