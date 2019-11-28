//
//  PSPaintingSizeController.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>

@class PSBrowserController;

@interface PSPaintingSizeController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sizeCoupeListTabView;
@property (nonatomic) NSArray *configuration;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@property (nonatomic, weak) PSBrowserController *browserController;
@property (nonatomic) NSMutableArray *miniCanvases;

+ (void) registerDefaults;

- (IBAction) rotate:(id)sender;

- (BOOL) isCustomSize;

@end
