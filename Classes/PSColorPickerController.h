//
//  PSColorPickerController.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>
#import "PSSwatches.h"

@class PSBar;
@class PSColor;
@class PSColorComparator;
@class PSColorSquare;
@class PSColorWheel;
@class PSColorSlider;
@class PSMatrix;

@interface PSColorPickerController : UIViewController <PSSwatchesDelegate>

@property (nonatomic) PSColor *color;
@property (nonatomic) IBOutlet PSColorComparator *colorComparator;
@property (nonatomic) IBOutlet PSColorWheel *colorWheel;
@property (nonatomic) IBOutlet PSColorSquare *colorSquare;
@property (nonatomic) IBOutlet PSSwatches *swatches;
@property (nonatomic) IBOutlet PSColorSlider *alphaSlider;

// iPhone
@property (nonatomic) PSMatrix *matrix;
@property (nonatomic) IBOutlet UIView *firstCell;
@property (nonatomic) IBOutlet UIView *secondCell;

@property (nonatomic, weak) PSBar *bottomBar;

@property (nonatomic, weak) id delegate;

- (IBAction)dismiss:(id)sender;
- (void) setInitialColor:(PSColor *)color;

@end
