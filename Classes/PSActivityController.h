//
//  PSActivityController.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>

@class PSActivityManager;

@interface PSActivityController : UIViewController <UITableViewDelegate>

@property (nonatomic) UITableView *table;
@property (nonatomic, weak) PSActivityManager *activityManager;

@end
