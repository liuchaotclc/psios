//
//  PSCanvasController.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>
#import "PSActionNameView.h"
#import "PSActionSheet.h"
#import "PSBar.h"
#import "ColorPanelSlider.h"
#import "PSDocumentReplay.h"
#import "RightLayerListView.h"
#import "PSTimePenCountView.h"
#import "ColorListChooseView.h"
#import "PSBarSliderVertical.h"
#import "PSAlphaSliderVertical.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "Ps_Ios-Swift.h"
//#import "CLMenuView"
//#import "PsIos-Swift.h"

typedef enum {
    WDInterfaceModeHidden, // all adornments are hidden
    WDInterfaceModeLoading,   // only progress indicator and top bar
    WDInterfaceModePlay, // play button, unlock slider and top bar
    WDInterfaceModeEdit // brush control, bottom bar and top bar
} WDInterfaceMode;

@class PSActionNameView;
@class WDArtStoreController;
@class WDBarColorWell;
@class PSBarSlider;
@class RightLayerListView;
@class PSCanvas;
@class WDColorBalanceController;
@class PSColorPickerController;
@class PSDocument;
@class PSLayerController;
@class WDLobbyController;
@class PSMenu;
@class PSMenuItem;
@class PSPainting;
@class PSProgressView;
@class ColorPanelSlider;

@interface PSCanvasController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                                                    MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate,
                                                PSActionSheetDelegate,PSDocumentReplayDelegate, PSActionNameViewDelegate,
                                        ColorSliderDelegate, CollectionClickDelegate, RightLayerDelegate,ClMenuItemViewDelegate>
{
    PSBarItem           *album_;
    PSBarItem           *undo_;
    PSBarItem           *redo_;
    PSBarItem           *gear_;
    PSBarItem           *layer_;
    PSBarSlider         *brushSlider_;
    PSTimePenCountView  *timePenCount_;
    int seconds;
    int minutes;
    int hour;
    
    PSMenu              *gearMenu_;
    PSMenu              *actionMenu_;
    PSMenu              *visibleMenu_; // pointer to currently active menu
    
    UIPopoverController *popoverController_;
    
    PSLayerController   *layerController_;
    WDLobbyController   *lobbyController_;

}
@property (strong, nonatomic) ColorListChooseView *colorListbar;//容器视图
@property (nonatomic) PSDocument *document;
@property (weak, nonatomic, readonly) PSPainting *painting;
@property (nonatomic) NSDictionary *canvasSettings;

@property (nonatomic, strong) PSDocumentReplay *replay;
@property (nonatomic, readonly) PSCanvas *canvas;

@property (nonatomic) UINavigationController *brushController;
@property (nonatomic, strong) PSColorPickerController *colorPickerController;

@property (nonatomic) PSActionSheet *shareSheet;
@property (nonatomic) PSActionSheet *gearSheet;
@property (nonatomic,strong )NSTimer *timer;

@property (nonatomic) int colorChooseListHeight;
@property (nonatomic, weak) PSBar *topBar;
@property (nonatomic, weak) PSBar *bottomBar;
@property (nonatomic) ColorPanelSlider *colorPanel;
@property (nonatomic) RightLayerListView *rightLayerListView;
@property (nonatomic) NSArray *editingTopBarItems;
@property (nonatomic) BOOL popoverVisible;
@property (nonatomic) CLMenuView *clMenuView;

@property (nonatomic, readonly) BOOL runningOnPhone;
@property (nonatomic) WDInterfaceMode interfaceMode;
@property (nonatomic, readonly) BOOL interfaceHidden;
@property (nonatomic) BOOL hasAppearedBefore;
@property (nonatomic) BOOL needsToResetInterfaceMode;
@property (nonatomic) NSNumber *replayScale;

@property (nonatomic) PSActionNameView *actionNameView;
@property (nonatomic) BOOL wasPlayingBeforeRotation;

@property (nonatomic) WDArtStoreController *artStoreController;
@property (nonatomic) PSBarSliderVertical *brushSizeSlider;
@property (nonatomic) PSAlphaSliderVertical *colorAlphaSlider;

- (void) updateTitle;
- (void) hidePopovers;

- (BOOL) shouldDismissPopoverForClassController:(Class)controllerClass insideNavController:(BOOL)insideNav;
- (void) showController:(UIViewController *)controller fromBarButtonItem:(UIBarButtonItem *)barButton animated:(BOOL)animated;
- (UIPopoverController *) runPopoverWithController:(UIViewController *)controller from:(id)sender;

- (void) validateMenuItem:(PSMenuItem *)item;
- (void) validateVisibleMenuItems;

- (void) undoStatusDidChange:(NSNotification *)aNotification;

- (UIImage *) layerImage;

- (void) showInterface;
- (void) hideInterface;

- (void) oneTap:(UITapGestureRecognizer *)recognizer;

- (void) undo:(id)sender;
- (void) redo:(id)sender;

@end

