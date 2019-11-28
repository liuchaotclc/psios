//
//  RightLayerListView.h
//  PSIos
//
//  Created by liuchao on 2019/11/4.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSLayerCell.h"
#import "PSActionSheet.h"

@class PSActionSheet;
@class PSBar;
@class PSBarItem;
@class PSPainting;
@class PSLayerCell;
@class PSColorSlider;
@class PSBlendModePicker;

NS_ASSUME_NONNULL_BEGIN
//创建协议
@protocol RightLayerDelegate <NSObject>
- (void)onDismissClick; //声明协议方法
@end

@interface RightLayerListView : UIView<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
PSActionSheetDelegate, WDLayerCellDelegate>{
   
    
    
    // iPhone
    id                          merge_;
    PSBarItem                   *undo_;
    PSBarItem                   *redo_;
    PSBarItem                   *delete_;
    PSBarItem                   *duplicate_;
    PSBarItem                   *add_;
    UIButton *deletebtn;
    UIButton *addbtn;

    NSMutableArray              *toolbarItems_;
}
@property (strong, nonatomic) UITableView *layerTable;
@property (nonatomic, weak) PSPainting *painting;
@property (nonatomic, weak) PSLayerCell *layerCell;
@property (nonatomic, strong) PSColorSlider *opacitySlider;
@property (nonatomic, strong) UILabel *opacityLabel;
@property (nonatomic, weak) PSBlendModePicker *blendModePicker;
@property (nonatomic, readonly) NSMutableSet *dirtyThumbnails;
@property (nonatomic, weak) id<RightLayerDelegate> delegate;
@property (nonatomic, weak) PSBar *topBar;
@property (nonatomic, weak) PSBar *bottomBar;
@property (nonatomic) PSActionSheet *blendModeSheet;

- (void) selectActiveLayer;
- (void) updateOpacity;
- (void) updateBlendMode;
- (void) enableLayerButtons;

@end

NS_ASSUME_NONNULL_END
