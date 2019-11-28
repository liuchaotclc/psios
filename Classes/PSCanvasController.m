//
//  PSCanvasController.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

#import "UIImage+Resize.h"
#import "UIImage+Additions.h"
#import "UIView+Additions.h"
#import "PSActiveState.h"
#import "PSBar.h"
#import "PSBarSlider.h"
#import "PSBezierNode.h"
#import "PSBrush.h"
#import "PSBrushesController.h"
#import "PSCanvas.h"
#import "PSCanvasController.h"
#import "PSCodingProgress.h"
#import "PSColor.h"
#import "PSColorPickerController.h"
#import "PSColorWell.h"
#import "PSDocument.h"
#import "PSFillColor.h"
#import "PSLayer.h"
#import "PSLayerController.h"
#import "PSMenu.h"
#import "PSMenuItem.h"
#import "PSModifyLayer.h"
#import "PSPaintingManager.h"
#import "PSProgressView.h"
#import "PSRedoChange.h"
#import "PSStylusManager.h"
#import "PSToolButton.h"
#import "PSUndoChange.h"
#import "PSUtilities.h"
#import "PSAppDelegate.h"
#import "PSBrowserController.h"
#import "FCCollectionViewCell.h"
#import "FCCollectionHeaderView.h"
#import <IFMMenu/IFMMenu.h>
#import "ZFPopupMenu.h"
#import "ZFPopupMenuItem.h"
#import "ScreenTool.h"

#define ALLOW_CAMERA_IMPORT NO
#define contentViewBgColor [UIColor colorWithRed:44.0f/255.0f green:106.0f/255.0f blue:152.0f/255.0 alpha:1]
#define viewBgColor [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:233.0f/255.0 alpha:1]

//屏幕宽和高
#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

#define RESCALE_REPLAY          0
#define kNavBarFixedWidth       20

@implementation PSCanvasController

@synthesize document = document_;
@synthesize canvas = canvas_;
@synthesize colorPickerController = colorPickerController_;
@synthesize brushController = brushController_;
@synthesize shareSheet;
@synthesize gearSheet;
@synthesize hasAppearedBefore;
@synthesize needsToResetInterfaceMode;
@synthesize canvasSettings;
@synthesize replay;
@synthesize topBar;
@synthesize bottomBar;
@synthesize colorPanel;
@synthesize editingTopBarItems;
@synthesize interfaceMode;
@synthesize actionNameView;
@synthesize replayScale;
@synthesize wasPlayingBeforeRotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (!self) {
        return nil;
    }
    
    [self setWantsFullScreenLayout:YES];
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.hasAppearedBefore) {
        // hide the default navbar and toolbar
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
        
        self.interfaceMode = WDInterfaceModeLoading;
        self.hasAppearedBefore = YES;
        
        self.bottomBar.items = [self bottomBarItems];
    } else if (self.needsToResetInterfaceMode) {
        self.bottomBar.items = [self bottomBarItems];
        [self setInterfaceMode:interfaceMode force:YES];
        self.needsToResetInterfaceMode = NO;
    }
        
    [self undoStatusDidChange:nil];
    [self configureForOrientation:self.interfaceOrientation];
    [self enableItems];
    
}

- (void) takeBrushSizeFrom:(PSBarSliderVertical *)sender
{
    [PSActiveState sharedInstance].brush.weight.value = sender.value;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
   
       self.colorPanel.hidden = NO;
       self.colorPanel.delegate = self;
    //滑块高度
    int sliderBarHeight = (Screen_height - [[ScreenTool sharedInstance] getStatusBarHeight] - self.topBar.bounds.size.height - WindowSafeAreaInsets.bottom - self.bottomBar.bounds.size.height - self.colorPanel.bounds.size.height) / 2;
    //颜色选择列表高度
    _colorChooseListHeight = (Screen_height - [[ScreenTool sharedInstance] getStatusBarHeight] - self.topBar.bounds.size.height - WindowSafeAreaInsets.bottom - self.bottomBar.bounds.size.height) * 2 / 3;
    //画笔大小调整
       _brushSizeSlider = [[PSBarSliderVertical alloc] initWithFrame:CGRectMake(0, [[ScreenTool sharedInstance] getStatusBarHeight] + self.topBar.bounds.size.height, 24, sliderBarHeight)];
       _brushSizeSlider.parentViewForOverlay = self.view;
       _brushSizeSlider.value = [PSActiveState sharedInstance].brush.weight.value;
          [_brushSizeSlider addTarget:self action:@selector(takeBrushSizeFrom:) forControlEvents:UIControlEventValueChanged];
       [self.view addSubview:_brushSizeSlider];
    //颜色列表选择
    _colorListbar = [[ColorListChooseView alloc] initWithFrame:CGRectMake(-150, (Screen_height - _colorChooseListHeight) / 2, 150, _colorChooseListHeight)];
          _colorListbar.delegate = self;
          _rightLayerListView =[[RightLayerListView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, (Screen_height - _colorChooseListHeight) / 2, 200, _colorChooseListHeight)];
          [self.view addSubview:_colorListbar];
    //图层列表
          [self.view addSubview:_rightLayerListView];
    
    //颜色透明度调整
    _colorAlphaSlider = [[PSAlphaSliderVertical alloc] initWithFrame:CGRectMake(0, [[ScreenTool sharedInstance] getStatusBarHeight] + self.topBar.bounds.size.height + sliderBarHeight + self.colorPanel.bounds.size.height, 24, sliderBarHeight)];
    _colorAlphaSlider.parentViewForOverlay = self.view;
    _colorAlphaSlider.value = [PSActiveState sharedInstance].brush.weight.value;
     [_colorAlphaSlider addTarget:self action:@selector(takeAlphaFrom:) forControlEvents:UIControlEventValueChanged];
     [self.view addSubview:_colorAlphaSlider];
    //底部菜单弹窗
    _clMenuView = [[CLMenuView alloc] init];//CLMenuView(itemTypes: [.copy,.collect,.reply,.report,.resend,.translate])
    _clMenuView.delegate = self;
    [self.view addSubview:_clMenuView];
}

- (void) takeAlphaFrom:(PSBarSliderVertical *)slider
{
//    float alpha = slider.value;
//    WDColor *usedColor = [WDActiveState sharedInstance].paintColor;
//    
//    WDColor *newColor = [WDColor colorWithHue:[usedColor hue]
//                                   saturation:[usedColor saturation]
//                                   brightness:[usedColor brightness]
//                                        alpha:alpha];
//    [WDActiveState sharedInstance].paintColor = newColor;
}

- (PSPainting *) painting
{
    return self.document.painting;
}

- (BOOL) runningOnPhone
{
    static BOOL isPhone;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? YES : NO;
    });
    
    return isPhone;
}

#pragma mark -
#pragma mark Interface Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    wasPlayingBeforeRotation = (replay && replay.isPlaying);
    if (wasPlayingBeforeRotation) {
        [replay pause];
    }
    
    canvas_.autoresizingMask = UIViewAutoresizingNone;
}

- (void) configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.topBar setOrientation:toInterfaceOrientation];
    [self.bottomBar setOrientation:toInterfaceOrientation];
    
    [layer_ setImage:[self layerImage]];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self hidePopovers];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // restore the proper canvas frame
    canvas_.frame = canvas_.superview.bounds;
    canvas_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (wasPlayingBeforeRotation) {
        [replay play];
    }
}

- (void)onCollectionClick:(NSInteger)section rowNum:(NSInteger)row
{
    switch (section) {
        case 0:
            [PSActiveState sharedInstance].paintColor = [[PSActiveState sharedInstance].historyColors objectAtIndex:row];
            break;
            case 1:
                       [PSActiveState sharedInstance].paintColor = [[PSActiveState sharedInstance].commonColors objectAtIndex:row];
                       break;
            case 2:
                       [PSActiveState sharedInstance].paintColor = [[PSActiveState sharedInstance].collectColors objectAtIndex:row];
                       break;
            
        default:
            break;
    }
    [UIView animateWithDuration:0.2 animations:^{
        
           [self.colorListbar setFrame:CGRectMake(-150, (Screen_height - _colorChooseListHeight) / 2, 150, _colorChooseListHeight)];
       } completion:^(BOOL finished) {
           
       }];
}

- (BOOL) shouldDismissPopoverForClassController:(Class)controllerClass insideNavController:(BOOL)insideNav
{
    if (!popoverController_) {
        return NO;
    }
    
    if (insideNav && [popoverController_.contentViewController isKindOfClass:[UINavigationController class]]) {
        NSArray *viewControllers = [(UINavigationController *)popoverController_.contentViewController viewControllers];
        
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:controllerClass]) {
                return YES;
            }
        }
    } else if ([popoverController_.contentViewController isKindOfClass:controllerClass]) {
        return YES;
    }
    
    return NO;
}

- (void) showPhotoBrowser:(id)sender
{
    if ([self shouldDismissPopoverForClassController:[UIImagePickerController class] insideNavController:NO]) {
        [self hidePopovers];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    [self showController:picker fromBarButtonItem:sender animated:YES];
}

#pragma mark -
#pragma mark Image Placement

- (void) dismissImagePicker:(UIImagePickerController *)picker
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
   
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissImagePicker:picker];
    
    CGSize imageSize = image.size;
    if (imageSize.width > imageSize.height) {
        if (imageSize.width > 2048) {
            imageSize.height = (imageSize.height / imageSize.width) * 2048;
            imageSize.width = 2048;
        }
    } else {
        if (imageSize.height > 2048) {
            imageSize.width = (imageSize.width / imageSize.height) * 2048;
            imageSize.height = 2048;
        }
    }
    
    image = [image resizedImage:imageSize interpolationQuality:kCGInterpolationHigh];
    [canvas_ beginPhotoPlacement:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImagePicker:picker];
}

#pragma mark -
#pragma mark Actions

- (void) duplicateLayer:(id)sender
{
    [self.painting duplicateActiveLayer];
}

- (void) transformLayer:(id)sender
{
    [canvas_ beginLayerTransformation];
}

- (void) clearLayer:(id)sender
{
    changeDocument(self.painting, [PSModifyLayer modifyLayer:self.painting.activeLayer withOperation:WDClearLayer]);
}

- (void) fillLayer:(id)sender
{
    changeDocument(self.painting, [PSFillColor fillColor:[PSActiveState sharedInstance].paintColor inLayer:self.painting.activeLayer]);
}

- (void) desaturateLayer:(id)sender
{
    changeDocument(self.painting, [PSModifyLayer modifyLayer:self.painting.activeLayer withOperation:WDDesaturateLayer]);
}

- (void) invertLayer:(id)sender
{
    changeDocument(self.painting, [PSModifyLayer modifyLayer:self.painting.activeLayer withOperation:WDInvertLayerColor]);
}

- (void) flipHorizontally:(id)sender
{
    changeDocument(self.painting, [PSModifyLayer modifyLayer:self.painting.activeLayer withOperation:WDFlipLayerHorizontal]);
}

- (void) flipVertically:(id)sender
{
    changeDocument(self.painting, [PSModifyLayer modifyLayer:self.painting.activeLayer withOperation:WDFlipLayerVertical]);
}

#pragma mark - Sheets

- (void) actionSheetDismissed:(PSActionSheet *)actionSheet
{
    if (actionSheet == gearSheet) {
        self.gearSheet = nil;
    } else if (actionSheet == shareSheet) {
        self.shareSheet = nil;
    }
}

- (void) showActionSheet:(id)sender
{
    self.shareSheet = [PSActionSheet sheet];
    
    __unsafe_unretained PSCanvasController *canvasController = self;
    
    [shareSheet addButtonWithTitle:NSLocalizedString(@"Add to Photos", @"Add to Photos")
                            action:^(id sender) { [canvasController addToPhotoAlbum:sender]; }];
     
    [shareSheet addButtonWithTitle:NSLocalizedString(@"Copy to Pasteboard", @"Copy to Pasteboard")
                             action:^(id sender) { [canvasController copyPainting:sender]; }];
    
    if (self.document) {
        [shareSheet addButtonWithTitle:NSLocalizedString(@"Duplicate", @"Duplicate")
                                action:^(id sender) { [canvasController duplicatePainting:sender]; }];
    }
    /*
    if (NSClassFromString(@"SLComposeViewController")) { // if we can facebook
        [shareSheet addButtonWithTitle:NSLocalizedString(@"Post on Facebook", @"Post on Facebook")
                                action:^(id sender) { [canvasController postOnFacebook:sender]; }];
    }
    
    // could check this with [TWTweetComposeViewController canSendTweet], but the behavior seems okay without the check
    [shareSheet addButtonWithTitle:NSLocalizedString(@"Tweet", @"Tweet")
                             action:^(id sender) { [canvasController tweetPainting:sender]; }];
    
    if (self.document && [MFMailComposeViewController canSendMail]) {
        [shareSheet addButtonWithTitle:NSLocalizedString(@"Email", @"Email")
                                 action:^(id sender) { [canvasController emailPNG:sender]; }];
    }
     */
    
    [shareSheet addCancelButton];
    
    shareSheet.delegate = self;
    [shareSheet.sheet showInView:self.view];
}

- (void) showGearSheet:(UIButton *)sender
{
    
    __unsafe_unretained PSCanvasController *canvasController = self;
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithObjects:
                                     
             [IFMMenuItem itemWithImage:[UIImage imageNamed:@"settings.png"]
                                  title:@"设置"
                                 action:^(IFMMenuItem *item) {
        
                                 }],
             [IFMMenuItem itemWithImage:[UIImage imageNamed:@"settings.png"]
                                  title:@"保存"
                                 action:^(IFMMenuItem *item) {
                                     [canvasController addToPhotoAlbum:sender];
                                
                                 }],
                                 [IFMMenuItem itemWithImage:[UIImage imageNamed:@"settings.png"]
                                   title:@"发布"
                                  action:^(IFMMenuItem *item) {
                                      [canvasController addToPhotoAlbum:sender];
                                 
                                  }],
                                 [IFMMenuItem itemWithImage:[UIImage imageNamed:@"settings.png"]
                                   title:@"帮助"
                                  action:^(IFMMenuItem *item) {
                                 
                                  }],
                                 [IFMMenuItem itemWithImage:[UIImage imageNamed:@"settings.png"]
                                  title:@"清空图层"
                                 action:^(IFMMenuItem *item) {
                                    [canvasController clearLayer:sender];
                                 }],
                                 [IFMMenuItem itemWithImage:[UIImage imageNamed:@"settings.png"]
                                  title:@"前景色填充图层"
                                 action:^(IFMMenuItem *item) {
                                    [canvasController fillLayer:sender];
                                 }],
                                 [IFMMenuItem itemWithImage:[UIImage imageNamed:@"settings.png"]
                                  title:@"反色"
                                 action:^(IFMMenuItem *item) {
                                    [canvasController fillLayer:sender];
                                 }],nil];
    
        
    IFMMenu *menu = [[IFMMenu alloc] initWithItems:menuItems];

    [menu showFromRect:sender.frame inView:self.view];
    
    
//
//    self.gearSheet = [WDActionSheet sheet];
//
//    __unsafe_unretained WDCanvasController *canvasController = self;
//
//    [gearSheet addButtonWithTitle:@"设置"
//                                    action:^(id sender) { }];
//
//    [gearSheet addButtonWithTitle:@"保存"
//                                 action:^(id sender) { [canvasController addToPhotoAlbum:sender];}];
//    [gearSheet addButtonWithTitle:@"发布"
//                              action:^(id sender) { [canvasController addToPhotoAlbum:sender];}];
//
//    [gearSheet addButtonWithTitle:@"帮助"
//                                 action:^(id sender) { }];
//
//    if (self.painting.canAddLayer) {
//        [gearSheet addButtonWithTitle:@"插入图片"
//                               action:^(id sender) { [canvasController showPhotoBrowser:sender]; }];
//    }
//
//
//
//    if (self.painting.activeLayer.editable) {
//        [gearSheet addButtonWithTitle:@"清空图层"
//                               action:^(id sender) { [canvasController clearLayer:sender]; }];
//
//        [gearSheet addButtonWithTitle:@"前景色填充图层"
//                               action:^(id sender) { [canvasController fillLayer:sender]; }];
//
//        [gearSheet addButtonWithTitle:@"反色"
//                               action:^(id sender) { [canvasController invertLayer:sender]; }];
//
//        [gearSheet addButtonWithTitle:@"变换图层"
//                          action:^(id sender) { [canvasController transformLayer:sender]; }];
//    }
//
//    [gearSheet addCancelButton];
//
//    gearSheet.delegate = self;
//    [gearSheet.sheet showInView:self.view];
}

#pragma mark -
#pragma mark Menus

- (void) showActionMenu:(id)sender
{
    if (popoverController_ && (popoverController_.contentViewController.view == actionMenu_)) {
        [self hidePopovers];
        return;
    }
    
    if (!actionMenu_) {
        NSMutableArray  *menus = [NSMutableArray array];
        PSMenuItem      *item;
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Add to Photos", @"Add to Photos")
                                  action:@selector(addToPhotoAlbum:) target:self];
        [menus addObject:item];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Copy to Pasteboard", @"Copy to Pasteboard")
                                  action:@selector(copyPainting:) target:self];
        [menus addObject:item];
        
        [menus addObject:[PSMenuItem separatorItem]];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Duplicate", @"Duplicate")
                                  action:@selector(duplicatePainting:) target:self];
        [menus addObject:item];
        
        /*
        [menus addObject:[WDMenuItem separatorItem]];
        
        if (NSClassFromString(@"SLComposeViewController")) {
            item = [WDMenuItem itemWithTitle:NSLocalizedString(@"Post on Facebook", @"Post on Facebook")
                                      action:@selector(postOnFacebook:) target:self];
            [menus addObject:item];
        }
        
        item = [WDMenuItem itemWithTitle:NSLocalizedString(@"Tweet", @"Tweet")
                                  action:@selector(tweetPainting:) target:self];
        [menus addObject:item];
        
        
        [menus addObject:[WDMenuItem separatorItem]];
        
        item = [WDMenuItem itemWithTitle:NSLocalizedString(@"Email JPEG", @"Email JPEG")
                                  action:@selector(emailJPEG:) target:self];
        [menus addObject:item];
        
        item = [WDMenuItem itemWithTitle:NSLocalizedString(@"Email PNG", @"Email PNG")
                                  action:@selector(emailPNG:) target:self];
        [menus addObject:item];
         */
        
        actionMenu_ = [[PSMenu alloc] initWithItems:menus];
        actionMenu_.delegate = self;
    }
    
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view = actionMenu_;
    
    if ([controller respondsToSelector:@selector(setPreferredContentSize:)])
        controller.preferredContentSize = actionMenu_.frame.size;
    else
        controller.contentSizeForViewInPopover = actionMenu_.frame.size;
    
    visibleMenu_ = actionMenu_;
    [self validateVisibleMenuItems];
    
    actionMenu_.popover = [self runPopoverWithController:controller from:sender];
}

- (void) showGearMenu:(id)sender
{
    if (popoverController_ && (popoverController_.contentViewController.view == gearMenu_)) {
        [self hidePopovers];
        return;
    }
    
    if (!gearMenu_) {
        NSMutableArray  *menus = [NSMutableArray array];
        PSMenuItem      *item;
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Clear Layer", @"Clear Layer")
                                  action:@selector(clearLayer:) target:self];
        [menus addObject:item];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Fill Layer", @"Fill Layer")
                                  action:@selector(fillLayer:) target:self];
        [menus addObject:item];
        
        [menus addObject:[PSMenuItem separatorItem]];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Desaturate", @"Desaturate") action:@selector(desaturateLayer:) target:self];
        [menus addObject:item];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Invert Color", @"Invert Color")
                                  action:@selector(invertLayer:) target:self];
        [menus addObject:item];
        
        [menus addObject:[PSMenuItem separatorItem]];
        
        [menus addObject:[PSMenuItem separatorItem]];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Flip Horizontally", @"Flip Horizontally")
                                  action:@selector(flipHorizontally:) target:self];
        [menus addObject:item];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Flip Vertically", @"Flip Vertically")
                                  action:@selector(flipVertically:) target:self];
        [menus addObject:item];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Transform", @"Transform")
                                  action:@selector(transformLayer:) target:self];
        [menus addObject:item];
        
        [menus addObject:[PSMenuItem separatorItem]];
        
        item = [PSMenuItem itemWithTitle:NSLocalizedString(@"Paste Image", @"Paste Image")
                                  action:@selector(pasteImage:) target:self];
        [menus addObject:item];
        
        gearMenu_ = [[PSMenu alloc] initWithItems:menus];
        gearMenu_.delegate = self;
    }
    
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view = gearMenu_;
    controller.contentSizeForViewInPopover = gearMenu_.frame.size;
    controller.preferredContentSize = gearMenu_.frame.size;
    
    visibleMenu_ = gearMenu_;
    [self validateVisibleMenuItems];
    
    gearMenu_.popover = [self runPopoverWithController:controller from:sender];
}

- (void) postOnFacebook:(id)sender
{
    SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [facebookSheet addImage:[canvas_.painting imageForCurrentState]];
    [facebookSheet setInitialText:NSLocalizedString(@"Check out my Brushes painting! http://brushesapp.com",
                                                    @"Check out my Brushes painting! http://brushesapp.com")];
    
    [self presentModalViewController:facebookSheet animated:YES];
}

- (void) tweetPainting:(id)sender
{
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    
    [tweetSheet addImage:[canvas_.painting imageForCurrentState]];
    [tweetSheet setInitialText:NSLocalizedString(@"Check out my Brushes #painting! @brushesapp",
                                                 @"Check out my Brushes #painting! @brushesapp")];
    
    [self presentModalViewController:tweetSheet animated:YES];
}

- (void) validateMenuItem:(PSMenuItem *)item
{
    // ACTION
    if (item.action == @selector(emailPNG:) ||
        item.action == @selector(emailJPEG:))
    {
        item.enabled = [MFMailComposeViewController canSendMail];
    }
    else if (item.action == @selector(duplicatePainting:))
             {
        item.enabled = (self.document != nil);
    }
    
    // LAYER
    else if (item.action == @selector(pasteImage:)) {
        item.enabled = [self canPasteImage];
    }
    else if (item.action == @selector(duplicateLayer:)) {
        item.enabled = [self.painting canAddLayer];
    }
    else if (item.action == @selector(clearLayer:) ||
             item.action == @selector(fillLayer:) ||
             item.action == @selector(invertLayer:) ||
             item.action == @selector(desaturateLayer:) ||
             item.action == @selector(flipHorizontally:) ||
             item.action == @selector(flipVertically:) ||
             item.action == @selector(transformLayer:))
    {
        PSLayer *activeLayer = self.painting.activeLayer;
        item.enabled = !(activeLayer.locked || !activeLayer.visible);
    }
    
    // GENERIC CASE
    else {
        item.enabled = [self respondsToSelector:item.action];
    }
}

- (void) validateVisibleMenuItems
{
    if (!visibleMenu_) {
        return;
    }
    
    for (PSMenuItem *item in visibleMenu_.items) {
        [self validateMenuItem:item];
    }
}

#pragma mark -
#pragma mark Inspectors

- (void) showBrushPanel:(id)sender
{
    if ([self shouldDismissPopoverForClassController:[PSBrushesController class] insideNavController:YES]) {
        [self hidePopovers];
        return;
    }
    
    if (!self.brushController) {
        PSBrushesController *brushController = [[PSBrushesController alloc] initWithNibName:@"Brushes" bundle:nil];
        brushController.delegate = self;

        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:brushController];
        self.brushController = navController;
    }
    
    [self showController:self.brushController fromBarButtonItem:sender animated:YES];
}

- (void)onColorSliderToEnd:(id)sender
{
    if ([self shouldDismissPopoverForClassController:[PSColorPickerController class] insideNavController:NO]) {
        [self hidePopovers];
        return;
    }

    if (!self.colorPickerController) {
        if (PSDeviceIs4InchPhone()) {
            self.colorPickerController = [[PSColorPickerController alloc] initWithNibName:@"ColorPicker~iphone5" bundle:nil];
        } else {
            self.colorPickerController = [[PSColorPickerController alloc] initWithNibName:@"ColorPicker" bundle:nil];
        }
        
        self.colorPickerController.delegate = self;
    }
    
    [self.colorPickerController setInitialColor:[PSActiveState sharedInstance].paintColor];
    
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.colorPickerController];
        [self showController:navController fromBarButtonItem:sender animated:NO];
  
}

- (void)onColorSliderSingleClick:(id)sender
{
    [self.colorListbar reloadCollectionData];
    [UIView animateWithDuration:0.2 animations:^{
        [self.colorListbar setFrame:CGRectMake(0, (Screen_height - _colorChooseListHeight) / 2, 150, _colorChooseListHeight)];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void) dismissViewController:(UIViewController *)viewController
{
    if (popoverController_) {
        [self hidePopovers];
    } else {
        [viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onDismissClick
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.rightLayerListView setFrame:CGRectMake(SCREEN_WIDTH , (Screen_height - _colorChooseListHeight) / 2, 200, _colorChooseListHeight)];
    } completion:^(BOOL finished) {
        
    }];
}

- (void) showLayers:(id)sender
{

    self.rightLayerListView.painting = self.painting;
    [self.rightLayerListView enableLayerButtons];
    self.rightLayerListView.delegate = self;
    
    [UIView animateWithDuration:0.2 animations:^{
        
              [self.rightLayerListView setFrame:CGRectMake(SCREEN_WIDTH - 200, (Screen_height - _colorChooseListHeight) / 2, 200, _colorChooseListHeight)];
          } completion:^(BOOL finished) {
              
          }];
    
//    if ([self shouldDismissPopoverForClassController:[WDLayerController class] insideNavController:YES]) {
//        [self hidePopovers];
//        return;
//    }
//
//    if (!layerController_) {
//        layerController_ = [[WDLayerController alloc] initWithNibName:@"Layers" bundle:nil];
//        layerController_.painting = self.painting;
//        layerController_.delegate = self;
//        layerController_.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    }
//
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:layerController_];
//    [self showController:navController fromBarButtonItem:sender animated:YES];
}


#pragma mark -
#pragma mark Popover Management

- (void) showController:(UIViewController *)controller fromBarButtonItem:(UIBarButtonItem *)barButton animated:(BOOL)animated
{
    [self presentViewController:controller animated:animated completion:nil];
}

- (UIPopoverController *) runPopoverWithController:(UIViewController *)controller from:(id)sender
{
    [self hidePopovers];
    
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:controller];
	popoverController_.delegate = self;
    
    NSMutableArray *passthroughs = [NSMutableArray arrayWithObjects:self.topBar, self.bottomBar, nil];
    if (self.isEditing) {
        [passthroughs addObject:self.canvas];
    }
    popoverController_.passthroughViews = passthroughs;
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [popoverController_ presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
    } else {
        
        [popoverController_ presentPopoverFromRect:CGRectInset(((UIView *) sender).bounds, 10, 10)
                                            inView:sender
                          permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown)
                                          animated:YES];
    }
    
    return popoverController_;
}

- (BOOL) popoverVisible
{
    return popoverController_ ? YES : NO;
}

- (void) hidePopovers
{
    if (popoverController_) {
        [popoverController_ dismissPopoverAnimated:NO];
        popoverController_ = nil;
        
        visibleMenu_ = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == popoverController_) {
        popoverController_ = nil;
        
        visibleMenu_ = nil;
    }
}

- (void) stylusConnected:(NSNotification *)aNotification
{
    [self.actionNameView setConnectedDeviceName:(aNotification.userInfo)[@"name"]];
}

- (void) stylusDisconnected:(NSNotification *)aNotification
{
    [self.actionNameView setDisconnectedDeviceName:(aNotification.userInfo)[@"name"]];
}

#pragma mark - Undo/Redo

- (void) primaryStylusButtonPressed:(NSNotification *)aNotification
{
    if (!canvas_.currentlyPainting) {
        [self undo:nil];
    }
}

- (void) secondaryStylusButtonPressed:(NSNotification *)aNotification
{
    if (!canvas_.currentlyPainting) {
        [self redo:nil];
    }
}

- (void) undo:(id)sender
{
    if ([self.painting.undoManager canUndo]) {
        changeDocument(self.painting, [PSUndoChange undoChange]);
    }
}

- (void) redo:(id)sender
{
    if ([self.painting.undoManager canRedo]) {
        changeDocument(self.painting, [PSRedoChange redoChange]);
    }
}

#pragma mark -
#pragma mark Toolbar Stuff

- (void) enableItems
{
    album_.enabled = self.isEditing && self.painting.canAddLayer;
        gear_.enabled = (self.painting.canAddLayer || self.painting.activeLayer.editable);
}

- (UIImage *) layerImage
{
    CGContextRef    ctx;
    UIBezierPath    *path;
    CGRect          layerBox;
    
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(25,30), NO, 0.0f);
        ctx = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(ctx, 0, -2);
        
        // draw background outline
        [[UIColor whiteColor] set];
        layerBox = CGRectMake(0, 5, 19, 19);
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectOffset(layerBox, 1, 1) cornerRadius:3];
        path.lineWidth = 2;
        [path stroke];

        // punch out a hole
        layerBox = CGRectOffset(layerBox, 5, 5);
        path = [UIBezierPath bezierPathWithRoundedRect:layerBox cornerRadius:3];
        CGContextSetBlendMode(ctx, kCGBlendModeClear);
        [path fill];
        path.lineWidth = 5;
        [path stroke];
    
    // fill the foreground lightly
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    [[UIColor colorWithWhite:1.0 alpha:0.1f] set];
    [path fill];
    
    // stroke the foreground
    [[UIColor whiteColor] set];
    path.lineWidth = 2;
    [path stroke];
    
    // draw the layer number
    if (self.painting) {
        NSUInteger index = [self.painting indexOfActiveLayer];
        index = (index == NSNotFound) ? 1 : (index + 1);
        
        NSString *label = [NSString stringWithFormat:@"%lu", (unsigned long)index];
        
        [label drawInRect:CGRectOffset(layerBox, 0, 1)
                 withFont:[UIFont boldSystemFontOfSize:13]
            lineBreakMode:UILineBreakModeClip
                alignment:UITextAlignmentCenter];
    }

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (void) setTitle:(NSString *)title
{
    [super setTitle:title];
    
    if (!self.isEditing) {
        self.topBar.title = title;
    }
}

- (void) goBack:(id)sender
{
    [[PSActiveState sharedInstance] resetActiveTool];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (self.isEditing) {
        if (!self.document && self.replay) {
            [self setUserInteractionEnabled:NO];
            
            PSDocument *document = [[PSPaintingManager sharedInstance] paintingWithName:self.replay.paintingName];
            self.document = document;
            // save off the scale so we can correct for it later
            self.replayScale = @(replay.scale);
            
            [document openWithCompletionHandler:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setInterfaceMode:WDInterfaceModeEdit];
                    [self setUserInteractionEnabled:YES];
                });
            }];
            self.replay = nil;
        } else if (!self.document) {
            [NSException raise:@"No replay or document" format:@"Either replay or document should not be nil"];
        } else {
            [self setInterfaceMode:WDInterfaceModeEdit];
            [self enableItems];
        }
    }
}

//顶部栏
- (PSBar *) topBar
{
    if (!topBar) {
        PSBar *aBar = [PSBar topBar];
        CGRect frame = aBar.frame;
        frame.origin.y = [[ScreenTool sharedInstance] getStatusBarHeight];
        frame.size.width = CGRectGetWidth(self.view.bounds);
        aBar.frame = frame;
        
        [self.view addSubview:aBar];
        self.topBar = aBar;
    }
    
    return topBar;
}

- (void) chooseTool:(id)sender
{
    [PSActiveState sharedInstance].activeTool = ((PSToolButton *)sender).tool;
}

- (void) addToolButtons:(NSArray *)inTools toArray:(NSMutableArray *)items
{
    // build tool buttons
    CGRect buttonRect = CGRectMake(0, 0, 36, 36);
    
    for (id tool in inTools) {
        PSToolButton *button = [PSToolButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = buttonRect;
        [button addTarget:self action:@selector(chooseTool:) forControlEvents:UIControlEventTouchUpInside];
        button.adjustsImageWhenHighlighted = NO;
        
        button.tool = tool;
        if (tool == [PSActiveState sharedInstance].activeTool) {
            button.selected = YES;
        }
        
        PSBarItem *item = [PSBarItem barItemWithView:button];
        [items addObject:item];
    }
}

-(void)startTimer{
    seconds++;
    if(seconds==60){
        minutes++;
        seconds = 0;
    }
    if (minutes == 60) {
        hour++;
        minutes = 0;
    }
    [timePenCount_ setTime:[NSString stringWithFormat:@"%02d:%02d:%02d",hour,minutes,seconds]];
}

- (NSArray *) editingTopBarItems
{
    if (!editingTopBarItems) {
        PSBarItem *fixed = [PSBarItem fixedItemWithWidth:5];
        PSBarItem *backButton = [PSBarItem backButtonWithTitle:@"" target:self action:@selector(goBack:)];
        NSMutableArray *items = [NSMutableArray arrayWithObjects:fixed, backButton, [PSBarItem flexibleItem], nil];
        
        timePenCount_ = [[PSTimePenCountView alloc] initWithFrame:CGRectMake(0, 0, 290, 44)];
        PSBarItem *info = [PSBarItem barItemWithView:timePenCount_];
        
        [items addObject:info];
        [items addObject:[PSBarItem flexibleItem]];
            
            
            layer_ = [PSBarItem barItemWithImage:[self layerImage] target:self action:@selector(showLayers:)];
               
               gear_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"gear.png"]
                                            target:self
                                            action: @selector(showGearSheet:)];
        
            [items addObject:layer_];
            [items addObject:gear_];
            
           
            [items addObject:[PSBarItem fixedItemWithWidth:15]];
            
      
        
        editingTopBarItems = items;
    }
    
    [self enableItems];
    
    return editingTopBarItems;
}

//底部栏
- (PSBar *) bottomBar
{
    if (!bottomBar) {
        PSBar *aBar = [PSBar bottomBar];
        CGRect frame = aBar.frame;
        frame.origin.y  = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(aBar.frame) - WindowSafeAreaInsets.bottom;
        frame.size.width = CGRectGetWidth(self.view.bounds);
        aBar.frame = frame;
        
        [self.view addSubview:aBar];
        self.bottomBar = aBar;
        
        bottomBar.defaultFlexibleSpacing = 32;
        self.bottomBar.ignoreTouches = NO;
    }
    
    return bottomBar;
}

- (void) decrementBrushSize:(id)sender
{
    [[PSActiveState sharedInstance].brush.weight decrement];
    brushSlider_.value = [PSActiveState sharedInstance].brush.weight.value;
}

- (void) incrementBrushSize:(id)sender
{
    [[PSActiveState sharedInstance].brush.weight increment];
    brushSlider_.value = [PSActiveState sharedInstance].brush.weight.value;
}

//- (void) takeBrushSizeFrom:(WDBarSlider *)sender
//{
//    [WDActiveState sharedInstance].brush.weight.value = roundf(sender.value);
//}

- (void) brushSliderBegan:(id)sender
{
    [self hidePopovers];
}

- (NSArray *) bottomBarItems
{
    undo_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"undo.png"]
                                 target:self action:@selector(undo:)];
    
    redo_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"redo.png"]
                                 target:self action:@selector(redo:)];
    
    PSBarItem *brushItem = [PSBarItem barItemWithImage:[UIImage imageNamed:@"style.png"]
                                                target:self
                                                action:@selector(showBrushPanel:)];
    
    
    
    brushSlider_ = [[PSBarSlider alloc] initWithFrame:CGRectMake(0, 0, 290, 44)];
    PSBarItem *brushSizeItem = [PSBarItem barItemWithView:brushSlider_];
    brushSizeItem.flexibleContent = YES;
    brushSlider_.value = [PSActiveState sharedInstance].brush.weight.value;
    [brushSlider_ addTarget:self action:@selector(brushSliderBegan:) forControlEvents:UIControlEventTouchDown];
    
    NSMutableArray *items;
    items = [NSMutableArray arrayWithObjects:
                 undo_, [PSBarItem flexibleItem],nil
                 ];
    album_ = [PSBarItem barItemWithImage:[UIImage relevantImageNamed:@"album.png"]
                                            target:self
                                            action:@selector(showPhotoBrowser:)];
              
//    //画笔大小调整
//      [items addObject:brushItem];
//    //图片导入
//              [items addObject:album_];
    
    
    //菜单
    PSBarItem *editMore = [PSBarItem barItemWithImage:[UIImage imageNamed:@"bottom_bar_edit"]
                                                 target:self
                                                 action:@selector(showBottomMoreMenu:)];
    [items addObject:editMore];
    
    //画笔和橡皮檫
    [self addToolButtons:[PSActiveState sharedInstance].tools toArray:items];
    [items addObject:[PSBarItem flexibleItem]];
    [items addObject:redo_];
    
    return items;
}

//显示底部菜单
- (void) showBottomMoreMenu:(UIButton *)sender{
    [_clMenuView setTargetRectWithTargetRect:bottomBar.frame];
    [_clMenuView showMenuItemView];
}

- (void)menuItemActionWithItemIndex:(NSInteger)itemIndex sender:(UIButton *)sender{
    switch (itemIndex) {
           case 0:
            [self showPhotoBrowser:sender];
               break;
        case 1:
            [self transformLayer:sender];
            break;
            case 2:
            [self showBrushPanel:sender];
            break;
               
           default:
               break;
       }
       
       [_clMenuView hiddenMenuItemView];
}

#pragma mark -
#pragma mark Notifications
 
- (void) undoStatusDidChange:(NSNotification *)aNotification
{
    undo_.enabled = [self.painting.undoManager canUndo];
    redo_.enabled = [self.painting.undoManager canRedo];
    [timePenCount_ setpenCount:  [NSString stringWithFormat: @"%d", self.painting.strokeCount]];
}

- (void) layerVisibilityChanged:(NSNotification *)aNotification
{
    [canvas_ drawView];
    [self enableItems];
}

- (void) layerAdded:(NSNotification *)aNotification
{
    [self enableItems];
}

- (void) layerDeleted:(NSNotification *)aNotification
{
    [self enableItems];
}

- (void) layerLockedStatusChanged:(NSNotification *)aNotification
{
    [self enableItems];
}

- (void) activeLayerChanged:(NSNotification *)aNotification
{
    [layer_ setImage:[self layerImage]];
}

- (void) colorBalanceChanged:(NSNotification *)aNotification
{
    [canvas_ drawViewAtEndOfRunLoop];
}

- (void) hueSaturationChanged:(NSNotification *)aNotification
{
    [canvas_ drawViewAtEndOfRunLoop];
}

#pragma mark -
#pragma mark View Controller Stuff

- (void) brushChanged:(NSNotification *)aNotification
{
    [self.painting reloadBrush];
    brushSlider_.value = [PSActiveState sharedInstance].brush.weight.value;
}

- (void) paintColorChanged:(NSNotification *)aNotification
{
    NSLog(@"paintColorChanged");
    [colorPanel setColor:[PSActiveState sharedInstance].paintColor];
}

- (void) loadView
{    
    UIView *background = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    background.opaque = YES;
    
    background.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    self.view = background;
    
    //画板添加
    if (self.painting) {
        // background painting view
        canvas_ = [[PSCanvas alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        canvas_.painting = self.painting;
        canvas_.controller = self;
        
        [[PSStylusManager sharedStylusManager].pogoManager registerView:canvas_];
        
        [background addSubview:canvas_];
        
        if (self.canvasSettings) {
            [canvas_ updateFromSettings:self.canvasSettings];
            self.canvasSettings = nil;
        }
    }
}

- (void) viewWillUnload
{
    topBar = nil;
    bottomBar = nil;
    self.needsToResetInterfaceMode = YES;
    
    // cache the canvas zoom and position so that we can restore it
    self.canvasSettings = [canvas_ viewSettings];
}

- (void) sliderUnlocked:(id)sender
{
    [self setEditing:YES animated:YES];
}

- (void) didResign:(NSNotification *)aNotification
{
    [self.replay pause];
    [canvas_ cancelUpdate];
    [self showInterface];
    
    glFinish();
}

- (void) didEnterBackground:(NSNotification *)aNotification
{
    if ([self.document hasUnsavedChanges]) {
        // might get terminated while backgrounded, so save now        
        UIApplication   *app = [UIApplication sharedApplication];
        
        __block UIBackgroundTaskIdentifier task = [app beginBackgroundTaskWithExpirationHandler:^{
            if (task != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:task];
            }
        }];
        
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
               if (task != UIBackgroundTaskInvalid) {
                   [app endBackgroundTask:task];
               }
            });
        }];
    }
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
    // if the document has never saved and we go back to the gallery after a memory warning, the browser will be confused
    // because it reloads its view before the document is normally saved (during -viewWillDisappear:)
    [self.document autosaveWithCompletionHandler:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self hidePopovers];
}

- (void)sessionStateChanged:(NSNotification *)sessionStateChanged {
    [self updateTitle];
}

//左部滑块
- (ColorPanelSlider *) colorPanel
{
    if (!colorPanel) {
        colorPanel = [ColorPanelSlider unlockSlider];
        [colorPanel addTarget:self action:@selector(sliderUnlocked:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:colorPanel];
        
//        int inset = [UIDevice currentDevice].userInterfaceIdiom ==  UIUserInterfaceIdiomPhone ? 22 : 44;
//        inset += CGRectGetHeight(unlockSlider.bounds) / 2;
//        unlockSlider.sharpCenter = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds) - inset);
    }
    
    return colorPanel;
}

- (void) oneTap:(UITapGestureRecognizer *)recognizer
{
    if (self.replay && !self.replay.paused) {
        [replay pause];
        [self showInterface];
    } else if (self.interfaceMode != WDInterfaceModeHidden) {
        [self hideInterface];
    } else {
        [self showInterface];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (document_.documentState != UIDocumentStateClosed) {
        [document_ closeWithCompletionHandler:nil];
    }
}

#pragma mark -
#pragma mark Miscellaneous

- (void) updateTitle
{
    NSString    *filename = self.document ? self.document.displayName : self.replay.paintingName;


        self.title = filename;
   
}

- (void) registerNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    [nc addObserver:self selector:@selector(didResign:)
               name:UIApplicationWillResignActiveNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(didEnterBackground:)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    
    [nc addObserver:self selector:@selector(paintColorChanged:) name:WDActivePaintColorDidChange object:nil];
    [nc addObserver:self selector:@selector(brushChanged:) name:WDActiveBrushDidChange object:nil];
    
    if (self.document) {
        [nc addObserver:self selector:@selector(loadProgress:) name:WDCodingProgressNotification object:self.document];
        [nc addObserver:self selector:@selector(documentStateChanged:) name:UIDocumentStateChangedNotification object:self.document];
    }
    
    if (self.painting) {
        [nc addObserver:self selector:@selector(layerLockedStatusChanged:) name:WDLayerLockedStatusChanged object:self.painting];
        [nc addObserver:self selector:@selector(layerVisibilityChanged:) name:WDLayerVisibilityChanged object:self.painting];
        
        [nc addObserver:self selector:@selector(activeLayerChanged:) name:WDActiveLayerChangedNotification object:self.painting];
        [nc addObserver:self selector:@selector(layerDeleted:) name:WDLayerDeletedNotification object:self.painting];
        [nc addObserver:self selector:@selector(layerAdded:) name:WDLayerAddedNotification object:self.painting];
        
        [nc addObserver:self selector:@selector(colorBalanceChanged:) name:WDColorBalanceChanged object:self.painting];
        [nc addObserver:self selector:@selector(hueSaturationChanged:) name:WDHueSaturationChanged object:self.painting];
    }

    NSUndoManager *undoManager = self.painting.undoManager;
    [self undoStatusDidChange:nil];
    if (undoManager) {
        [nc addObserver:self selector:@selector(willUndo:)
                   name:NSUndoManagerWillUndoChangeNotification
                 object:undoManager];
        
        [nc addObserver:self selector:@selector(willRedo:)
                   name:NSUndoManagerWillRedoChangeNotification
                 object:undoManager];
        
        
        [nc addObserver:self selector:@selector(undoStatusDidChange:)
                                                     name:NSUndoManagerDidUndoChangeNotification object:undoManager];
        [nc addObserver:self selector:@selector(undoStatusDidChange:)
                                                     name:NSUndoManagerDidRedoChangeNotification object:undoManager];
        [nc addObserver:self selector:@selector(undoStatusDidChange:)
                                                     name:NSUndoManagerWillCloseUndoGroupNotification object:undoManager];
    }
    
    // listen for stylus buttons too
    [nc addObserver:self selector:@selector(primaryStylusButtonPressed:)
               name:WDStylusPrimaryButtonPressedNotification object:nil];
    
    [nc addObserver:self selector:@selector(secondaryStylusButtonPressed:)
               name:WDStylusSecondaryButtonPressedNotification object:nil];
    
    // and stylus connections
    [nc addObserver:self selector:@selector(stylusConnected:)
               name:WDStylusDidConnectNotification object:nil];
    [nc addObserver:self selector:@selector(stylusDisconnected:)
               name:WDStylusDidDisconnectNotification object:nil];
    
}

- (void) fadingOutActionNameView:(PSActionNameView *)inActionNameView
{
    actionNameView = nil;
}

//提示框
- (PSActionNameView *) actionNameView
{
    if (!actionNameView) {
        self.actionNameView = [[PSActionNameView alloc] initWithFrame:CGRectMake(0,0,180,60)];
        [self.view addSubview:actionNameView];
        actionNameView.center = PSCenterOfRect(self.view.bounds);
        actionNameView.delegate = self;
    }
    
    return actionNameView;
}

- (void) willUndo:(NSNotification *)aNotification
{
    NSString *actionName = self.painting.undoManager.undoActionName;
    
    if (actionName && ![actionName isEqualToString:@""]) {
        [self.actionNameView setUndoActionName:actionName];
    } else {
        WDLog(@"Undo with no action name.");
    }
}

- (void) willRedo:(NSNotification *)aNotification
{
    NSString *actionName = self.painting.undoManager.redoActionName;
    
    if (actionName && ![actionName isEqualToString:@""]) {
        [self.actionNameView setRedoActionName:actionName];
    } else {
        WDLog(@"Redo with no action name.");
    }
}

- (void) setDocument:(PSDocument *)document
{
    if (document != self.document) {
        if (document_.documentState != UIDocumentStateClosed) {
            [document_ closeWithCompletionHandler:nil];
        }
        
        if (layerController_) {
            // make sure to clear the old painting or it will show the wrong layers
            layerController_.painting = document.painting;
        }
        
        [self hidePopovers];
    }
    
    document_ = document;
    
    [self documentStateChanged:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
       if (_clMenuView) {
           if([_clMenuView isShow]){
                [_clMenuView hiddenMenuItemView];
           }
       }
}

- (void) loadProgress:(NSNotification *)aNotification
{
}

- (void) documentStateChanged:(NSNotification *)aNotification
{
    if (self.document && self.document.documentState == UIDocumentStateNormal) {
        if (self.painting) {
            if (canvas_) {
                if (replayScale) {
                    [self.canvas adjustForReplayScale:(1.0f / replayScale.floatValue)];
                    self.replayScale = nil;
                }
                canvas_.painting = self.painting;
            } else {
                
//                UIScrollView *scroll11 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [[ScreenTool sharedInstance] getStatusBarHeight] + self.topBar.bounds.size.height, self.view.frame.size.width, self.view.frame.size.height - [[ScreenTool sharedInstance] getStatusBarHeight] - self.bottomBar.bounds.size.height - self.topBar.bounds.size.height - WindowSafeAreaInsets.bottom)];
//
                canvas_ = [[PSCanvas alloc] initWithFrame:CGRectMake(0, [[ScreenTool sharedInstance] getStatusBarHeight] + self.topBar.bounds.size.height, self.view.frame.size.width, self.view.frame.size.height - [[ScreenTool sharedInstance] getStatusBarHeight] - self.bottomBar.bounds.size.height - self.topBar.bounds.size.height - WindowSafeAreaInsets.bottom )];
                canvas_.painting = self.painting;
                canvas_.controller = self;
//                scroll11.contentSize = canvas_.bounds.size;
                [self.view insertSubview:canvas_ atIndex:0];
//                [scroll11 insertSubview:canvas_ atIndex:0];
                
//                canvas_ = [[WDCanvas alloc] initWithFrame:self.view.bounds];
//                canvas_.painting = self.painting;
//                canvas_.controller = self;
//
//                [[WDStylusManager sharedStylusManager].pogoManager registerView:canvas_];
//
//                [self.view insertSubview:canvas_ atIndex:0];
            }
            
            if (!canvas_.hasEverBeenScaledToFit) {
                [canvas_ scaleDocumentToFit:NO];
            }
            
            // display the correct layer index in the nav bar
            [layer_ setImage:[self layerImage]];
        }
        
        [self updateTitle];
    }
    
    [self registerNotifications];
    
    [self enableItems];
    
    [self undoStatusDidChange:nil];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark Action Menu

- (void) addToPhotoAlbum:(id)sender
{
    UIImage *image = [canvas_.painting image];

    // this will write a JPEG
    UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);    

    // this will write a PNG
    //NSData *pngData = UIImagePNGRepresentation(image);
    //UIImage *pngImage = [UIImage imageWithData:pngData];
    //UIImageWriteToSavedPhotosAlbum(pngImage, self, nil, NULL);
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) emailPainting:(id)sender mimeType:(NSString *)mimeType data:(NSData *)data
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSString *subject = NSLocalizedString(@"Brushes Painting: ", @"Brushes Painting: ");
    NSString *filename = self.document ? self.document.displayName : self.replay.paintingName;
    subject = [subject stringByAppendingString:filename];
    [picker setSubject:subject];    
    
    [picker addAttachmentData:data mimeType:mimeType fileName:filename];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (BOOL) canPasteImage
{
    if (!self.isEditing) {
        return NO;
    }
    
    return [UIPasteboard generalPasteboard].image ? YES : NO;
}

- (void) pasteImage:(id)sender
{
    [canvas_ beginPhotoPlacement:[UIPasteboard generalPasteboard].image];
}

- (void) copyPainting:(id)sender
{
    [UIPasteboard generalPasteboard].image = [canvas_.painting image];
}

- (void) setUserInteractionEnabled:(BOOL)enabled
{
    self.canvas.userInteractionEnabled = enabled;
    self.topBar.userInteractionEnabled = enabled;
    self.bottomBar.userInteractionEnabled = enabled;
}

- (void) duplicatePainting:(id)sender
{
    // prevent anything being done to the old document before the new is loaded
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WDCodingProgressNotification object:self.document];
    [self setUserInteractionEnabled:NO];
    [self.document closeWithCompletionHandler:^(BOOL success) {
        if (!success) {
            WDLog(@"ERROR: Duplicate failed in close!");
            return;
        }
        PSDocument *duplicate = [[PSPaintingManager sharedInstance] duplicatePainting:self.document];
        [duplicate openWithCompletionHandler:^(BOOL success) {
            if (!success) {
                WDLog(@"ERROR: Duplicate failed in open!");
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.document = duplicate;
                [self setUserInteractionEnabled:YES];
            });
        }];
    }];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:canvas_ cache:YES];
    [UIView commitAnimations];
}

- (void) emailPNG:(id)sender
{
    NSData *imageData = [canvas_.painting PNGRepresentationForCurrentState];
    [self emailPainting:sender mimeType:@"image/png" data:imageData];
}

- (void) emailJPEG:(id)sender
{
    NSData *imageData = [canvas_.painting JPEGRepresentationForCurrentState];
    [self emailPainting:sender mimeType:@"image/jpeg" data:imageData];
}

- (void) exportPNG: (id) sender
{
    /*
    NSData *imageData = [canvas_.painting PNGRepresentationForCurrentState];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[imageData] applicationActivities:nil];
    activityViewController.completionHandler = ^(NSString* activityType, BOOL completed) {
        // do whatever you want to do after the activity view controller is finished
    };
    //[self presentViewController:activityViewController animated:YES completion:nil];
    actionMenu_.popover = [self runPopoverWithController:activityViewController from:sender];
     */
    
    PSAppDelegate *delegate = (PSAppDelegate *) [UIApplication sharedApplication].delegate;

    
}

#pragma mark - Interface Visibility

- (void) fadePlayControls
{
  
}

- (void) showInterface
{    
    if (replay && replay.isPlaying) {
        return;
    }
    
    if (canvas_.isZooming) {
        return;
    }
    
    if (!self.document && !self.replay) {
        self.interfaceMode = WDInterfaceModeLoading;
    } else {
        self.interfaceMode = self.isEditing ? WDInterfaceModeEdit : WDInterfaceModePlay;
    }
}

- (void) hideInterface
{
    self.interfaceMode = WDInterfaceModeHidden;
}

- (BOOL) interfaceHidden
{
    return (self.interfaceMode == WDInterfaceModeHidden) ? YES : NO;
}

- (void) setInterfaceMode:(WDInterfaceMode)inInterfaceMode
{
    [self setInterfaceMode:inInterfaceMode force:NO];
}

- (void) setInterfaceMode:(WDInterfaceMode)inInterfaceMode force:(BOOL)force
{
    if (!force && interfaceMode == inInterfaceMode) {
        return;
    }
    
    interfaceMode = inInterfaceMode;
    
    if (interfaceMode == WDInterfaceModeEdit) {
//        [self fadePlayControls];
        
        self.topBar.hidden = NO;
        self.bottomBar.hidden = NO;
        self.topBar.title = nil;
        [self.topBar setItems:[self editingTopBarItems] animated:YES];
        
        [self.painting preloadPaintTexture];
        
    }
}

- (void) showProgress
{
}

- (UIView *) rotatingHeaderView
{
    return self.topBar;
}

- (UIView *) rotatingFooterView
{
    return self.bottomBar;
}

@end
