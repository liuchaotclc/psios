//
//  PSBrowserController.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "PSGridView.h"

@class PSActivityManager;
@class PSLabel;
@class PSPainting;
@class PSThumbnailView;

#define kMaximumThumbnails      18

@class PSBlockingView;
@class PSDocument;
@class PSMenu;

@interface PSBrowserController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>
{
    UIActionSheet           *deleteSheet_;
    
    NSMutableArray          *toolbarItems_;
    NSMutableArray          *editingToolbarItems_;
    
    UIPopoverController     *popoverController_;
    UIBarButtonItem         *selectItem_;
    UIBarButtonItem         *deleteItem_;
    
    NSMutableSet            *selectedPaintings_;
    
    UIImagePickerController *pickerController_;
    NSMutableSet            *filesBeingUploaded_;
    PSActivityManager       *activities_;

    PSBlockingView          *blockingView_;
    PSThumbnailView         *editingThumbnail_;
}

@property (nonatomic, readonly) BOOL runningOnPhone;
@property (nonatomic, readonly) NSInteger thumbnailDimension;
@property (nonatomic, weak) UIViewController *currentPopoverViewController;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UIBarButtonItem *shareItem;
@property (nonatomic) UIButton *addNewPaintBtn;

- (void) openDocument:(PSDocument *)document editing:(BOOL)editing;
- (void) showOpenFailure:(PSDocument *)document;

- (void) createNewPainting:(CGSize)size;
- (void) createNewPaintingWithImage:(UIImage*)image;

- (void) showController:(UIViewController *)controller from:(id)sender;

@end
