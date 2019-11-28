//
//  PSBrowserController.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "UIView+Additions.h"
#import "PSActiveState.h"
#import "PSActivity.h"
#import "PSActivityController.h"
#import "PSActivityManager.h"
#import "PSAppDelegate.h"
#import "PSBlockingView.h"
#import "PSBrowserController.h"
#import "PSCanvasController.h"
#import "PSDocument.h"
#import "PSMenuItem.h"
#import "PSPaintingManager.h"
#import "PSPaintingSizeController.h"
#import "PSThumbnailView.h"
#import "PSUtilities.h"
#import "PSPaintingIterator.h"
#import "MaterialDesignIcons.h"



@implementation PSBrowserController {
    UIImageView *snapshotBeforeRotation;
    UIImageView *snapshotAfterRotation;
    CGRect frameBeforeRotation;
    CGRect frameAfterRotation;
    NSUInteger centeredIndex;
    NSMutableSet *savingPaintings;
}

@synthesize currentPopoverViewController;
@synthesize activityIndicator;

- (void) buildDefaultNavBar
{
    [self updateTitle];
}

- (UIPopoverController *) runPopoverWithController:(UIViewController *)controller from:(id)sender
{
    [self hidePopovers];
    
    popoverController_ = [[UIPopoverController alloc] initWithContentViewController:controller];
	popoverController_.delegate = self;
    popoverController_.passthroughViews = @[self.navigationController.navigationBar];
    [popoverController_ presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    return popoverController_;
}

- (void) hidePopovers
{
    if (popoverController_) {
        [popoverController_ dismissPopoverAnimated:NO];
        popoverController_ = nil;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (!self) {
        return nil;
    }
    
    selectedPaintings_ = [[NSMutableSet alloc] init];
    filesBeingUploaded_ = [[NSMutableSet alloc] init];
    activities_ = [[PSActivityManager alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paintingAdded:)
                                                 name:WDPaintingAdded
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paintingsDeleted:)
                                                 name:WDPaintingsDeleted
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(activityCountChanged:)
                                                 name:PSActivityAddedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(activityCountChanged:)
                                                 name:PSActivityRemovedNotification
                                               object:nil];
    
    _addNewPaintBtn = [UIButton buttonWithType:
    UIButtonTypeRoundedRect];
    
    [_addNewPaintBtn setFrame:CGRectMake(60, 200, 200, 40)];
    _addNewPaintBtn.center = self.view.center;
    [_addNewPaintBtn setBackgroundColor: [UIColor lightGrayColor]];
    // sets title for the button
    [_addNewPaintBtn setTitle:@"创建" forState:
    UIControlStateNormal];
    [_addNewPaintBtn addTarget:self
              action:@selector(addPainting:)
    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addNewPaintBtn];

    [self buildDefaultNavBar];

    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (NSInteger) thumbnailDimension
{
    return 96; // 148 for big thumbs on the iPhone
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // force initialization
    [PSActiveState sharedInstance];    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void) showOpenFailure:(PSDocument *)document
{
    NSString *title = NSLocalizedString(@"Could Not Open Painting", @"Could Not Open Painting");
    NSString *format = NSLocalizedString(@"There was a problem opening “%@”.", @"There was a problem opening “%@”.");
                              
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:[NSString stringWithFormat:format, document.displayName]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
    [alertView show];
}

// TODO
- (void) openDocument:(PSDocument *)document editing:(BOOL)editing
{
    PSCanvasController *canvasController = [[PSCanvasController alloc] init];
    [self.navigationController pushViewController:canvasController animated:YES];
    // set the document before setting the editing flag
    canvasController.document = document;

    [document openWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                canvasController.editing = editing || ([document.history count] <= 4);
            } else {
                [self showOpenFailure:document];
            }
        });
    }];
}

- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) updateTitle
{
        NSInteger count = [[PSPaintingManager sharedInstance] numberOfPaintings];
        NSString *title = @"Ps-Ios";;
        self.title = title;
}

- (void) tappedOnPainting:(id)sender
{
    if (editingThumbnail_) {
        return;
    }
    
    if (!self.isEditing) {
        NSUInteger index = [(UIView *)sender tag];
        PSDocument *document = [[PSPaintingManager sharedInstance] paintingAtIndex:index];
        [self openDocument:document editing:NO];
    } else {
        PSThumbnailView     *thumbnail = (PSThumbnailView *)sender;
        NSString            *filename = [[PSPaintingManager sharedInstance] fileAtIndex:[thumbnail tag]];
        
        if ([selectedPaintings_ containsObject:filename]) {
            thumbnail.selected = NO;
            [selectedPaintings_ removeObject:filename];
        } else {
            thumbnail.selected = YES;
            [selectedPaintings_ addObject:filename];
        }
        
        [self updateTitle];
        
    }
}

- (void) createNewPainting:(CGSize)size
{   
    [self dismissPopoverAnimated:NO];
    
    
    PSCanvasController *canvasController = [[PSCanvasController alloc] init];
    [self.navigationController pushViewController:canvasController animated:YES];

    [[PSPaintingManager sharedInstance] createNewPaintingWithSize:size afterSave:^(PSDocument *document) {

        // set the document before setting the editing flag
        canvasController.document = document;

        [document openWithCompletionHandler:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                canvasController.editing = YES;
            });
        }];
    }];
    centeredIndex = 0;

}

- (void) createNewPaintingWithImage:(UIImage*)image
{
    [self dismissPopoverAnimated:NO];
        
        NSString *imageName = NSLocalizedString(@"Photo", @"Photo");
   
        PSCanvasController *canvasController = [[PSCanvasController alloc] init];
        [self.navigationController pushViewController:canvasController animated:YES];
    [[PSPaintingManager sharedInstance] createNewPaintingWithImage:image imageName:imageName afterSave:^(PSDocument *document) {

            // set the document before setting the editing flag
            canvasController.document = document;

            [document openWithCompletionHandler:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    canvasController.editing = YES;
                });
            }];
        }];
        centeredIndex = 0;
}

- (NSInteger) cellDimension
{
    return 96; // 148 for big thumbs on the iPhone
}

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
}

- (BOOL) thumbnailShouldBeginEditing:(PSThumbnailView *)thumb
{
    if (self.isEditing) {
        return NO;
    }
    
    // can't start editing if we're already editing another thumbnail
    return (editingThumbnail_ ? NO : YES);
}

- (void) blockingViewTapped:(id)sender
{
    [editingThumbnail_ stopEditing];
}

- (void) didEnterBackground:(NSNotification *)aNotification
{
    if (!editingThumbnail_) {
        return;
    }
    
    [editingThumbnail_ stopEditing];
}

- (void) thumbnailDidBeginEditing:(PSThumbnailView *)thumbView
{
    editingThumbnail_ = thumbView;
}

- (void) thumbnailDidEndEditing:(PSThumbnailView *)thumbView
{
    [UIView animateWithDuration:0.2f
                     animations:^{ blockingView_.alpha = 0; }
                     completion:^(BOOL finished) {
                         [blockingView_ removeFromSuperview];
                         blockingView_ = nil;
                     }];
    
    editingThumbnail_ = nil;
}

- (void) keyboardWillShow:(NSNotification *)aNotification
{
    if (!editingThumbnail_ || blockingView_) {
        return;
    }
    
    NSValue     *endFrame = [aNotification userInfo][UIKeyboardFrameEndUserInfoKey];
    
    blockingView_ = [[PSBlockingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    PSAppDelegate *delegate = (PSAppDelegate *) [UIApplication sharedApplication].delegate;
    
    blockingView_.passthroughViews = @[editingThumbnail_.titleField];
    [delegate.window addSubview:blockingView_];
    
    blockingView_.target = self;
    blockingView_.action = @selector(blockingViewTapped:);
}

- (void) paintingAdded:(NSNotification *)aNotification
{
    [self updateTitle];
}


- (void) viewDidUnload
{
}

- (NSString*) appFolderPath
{
    return @"/";
    /*
    NSString* appFolderPath = @"Brushes";
    if (![appFolderPath isAbsolutePath]) {
        appFolderPath = [@"/" stringByAppendingString:appFolderPath];
    }
    
    return appFolderPath;
    */
}

- (void) deleteSelectedPaintings
{
    NSString *format = NSLocalizedString(@"Delete %d Paintings", @"Delete %d Paintings");
    NSString *title = (selectedPaintings_.count) == 1 ? NSLocalizedString(@"Delete Painting", @"Delete Painting") :
    [NSString stringWithFormat:format, selectedPaintings_.count];
    
    NSString *message;
    
    if (selectedPaintings_.count == 1) {
        message = NSLocalizedString(@"Once deleted, this painting cannot be recovered.", @"Alert text when deleting 1 painting");
    } else {
        message = NSLocalizedString(@"Once deleted, these paintings cannot be recovered.", @"Alert text when deleting multiple paintings");
    }
    
    NSString *deleteButtonTitle = NSLocalizedString(@"Delete", @"Title of Delete button");
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Title of Cancel button");

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:deleteButtonTitle, cancelButtonTitle, nil];
    alertView.cancelButtonIndex = 1;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    [[PSPaintingManager sharedInstance] deletePaintings:selectedPaintings_];
    
    [self updateTitle];
}
     
 - (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == deleteSheet_) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self deleteSelectedPaintings];
        }
    }
    
    deleteSheet_ = nil;
}

#pragma mark -
#pragma mark Import/Export

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Managing View Controllers

- (void) dismissPopoverAnimated:(BOOL)animated
{    
    if (popoverController_) {
        [popoverController_ dismissPopoverAnimated:animated];
        popoverController_ = nil;
        self.currentPopoverViewController = nil;
    }
    
    if (deleteSheet_) {
        [deleteSheet_ dismissWithClickedButtonIndex:deleteSheet_.cancelButtonIndex animated:NO];
        deleteSheet_ = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == popoverController_) {
        self.currentPopoverViewController = nil;
        popoverController_ = nil;
    }
}

- (void) showController:(UIViewController *)controller from:(id)sender
{
    if (!controller) {
        // we're trying to show the currently visible popover, so dismiss it and quit
        [self dismissPopoverAnimated:NO];
        return;
    }
    
    // hide any other popovers
    [self dismissPopoverAnimated:NO];
    
    // embed in a nav controller
    UIViewController *presentedController;
    
    if ([controller isKindOfClass:[UIImagePickerController class]] || [controller isKindOfClass:[UIActivityViewController class]]) {
        presentedController = controller;
    } else {
        presentedController = [[UINavigationController alloc] initWithRootViewController:controller];
    }
    
    [self presentViewController:presentedController animated:YES completion:nil];
   
}

- (void) addPainting:(id)sender
{
    PSPaintingSizeController *controller = nil;
    
    if (![self.currentPopoverViewController isKindOfClass:[PSPaintingSizeController class]]) {
        controller = [[PSPaintingSizeController alloc] initWithNibName:@"SizeChooser" bundle:nil];
        controller.browserController = self;
    }
    
    [self showController:controller from:sender];
}

- (void) activityTapped:(UITapGestureRecognizer *)recognizer
{
    PSActivityController *controller = nil;
    
    if (![self.currentPopoverViewController isKindOfClass:[PSActivityController class]]) {
        controller = [[PSActivityController alloc] initWithNibName:nil bundle:nil];
        controller.activityManager = activities_;
    }
    
    [self showController:controller from:recognizer.view];
}

- (void) createActivityIndicator
{
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhite;
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    self.activityIndicator = activity;
    
    // create a background view to make the indicator more visible
    CGRect frame = CGRectInset(self.activityIndicator.frame, -10, -10);
    UIView *bgView = [[UIView alloc] initWithFrame:frame];
    bgView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.333f];
    bgView.opaque = NO;
    bgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
    // adjust the layer properties to get the appearance that we want
    CALayer *layer = bgView.layer;
    layer.cornerRadius = CGRectGetWidth(frame) / 2;
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.borderWidth = 1;
    
    [bgView addSubview:self.activityIndicator];

    // position the views properly
    self.activityIndicator.sharpCenter = PSCenterOfRect(bgView.bounds);
    CGPoint corner = CGPointMake(0.0f, CGRectGetMaxY(self.view.superview.bounds));
    corner = PSAddPoints(corner, CGPointMake(CGRectGetWidth(frame) * 0.75f, -CGRectGetHeight(frame) * 0.75f));
    bgView.sharpCenter = corner;
    [self.view addSubview:bgView];
    
    // respond to taps
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activityTapped:)];
    [bgView addGestureRecognizer:tapRecognizer];
    
    [self.activityIndicator startAnimating];
}

- (void) activityCountChanged:(NSNotification *)aNotification
{
    NSUInteger numActivities = activities_.count;
    
    if (numActivities) {
        if (!self.activityIndicator) {
            [self createActivityIndicator];
        }
    } else {
        [self.activityIndicator.superview removeFromSuperview];
        self.activityIndicator = nil;
    }
    
    if (numActivities == 0 && [self.currentPopoverViewController isKindOfClass:[PSActivityController class]]) {
        [self dismissPopoverAnimated:YES];
    }
}

- (void)didDismissModalView {
    // Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!snapshotBeforeRotation) {
        return;
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (!snapshotBeforeRotation) {
        return;
    }
    
    [snapshotAfterRotation removeFromSuperview];
    [snapshotBeforeRotation removeFromSuperview];
    snapshotBeforeRotation = nil;
    snapshotAfterRotation = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (editingThumbnail_) {
        [editingThumbnail_ stopEditing];
    }

    return YES;
}




@end

