//
//  PSLayerController.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>
#import "PSLayerCell.h"

@class PSActionSheet;
@class PSBar;
@class PSBarItem;
@class PSPainting;
@class PSLayerCell;
@class PSColorSlider;
@class PSBlendModePicker;

@interface PSLayerController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
                                                    PSActionSheetDelegate, WDLayerCellDelegate> {
    IBOutlet UITableView        *layerTable_;
    UITextField                 *activeField_;
    
    // iPhone
    id                          merge_;
    PSBarItem                   *undo_;
    PSBarItem                   *redo_;
    PSBarItem                   *delete_;
    PSBarItem                   *duplicate_;
    PSBarItem                   *add_;

    NSMutableArray              *toolbarItems_;
}

@property (nonatomic, weak) PSPainting *painting;
@property (nonatomic, weak) IBOutlet PSLayerCell *layerCell;
@property (nonatomic, weak) IBOutlet PSColorSlider *opacitySlider;
@property (nonatomic, weak) IBOutlet UILabel *opacityLabel;
@property (nonatomic, weak) IBOutlet PSBlendModePicker *blendModePicker;
@property (nonatomic, readonly) NSMutableSet *dirtyThumbnails;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) PSBar *topBar;
@property (nonatomic, weak) PSBar *bottomBar;
@property (nonatomic) PSActionSheet *blendModeSheet;

- (void) selectActiveLayer;
- (void) updateOpacity;
- (void) updateBlendMode;
- (void) enableLayerButtons;

@end
