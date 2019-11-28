//
//  PSBrushController.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "NSArray+Additions.h"
#import "PSActiveState.h"
#import "PSBar.h"
#import "PSBrush.h"
#import "PSBrushController.h"
#import "PSPropertyCell.h"
#import "PSStampPicker.h"
#import "PSUtilities.h"

@implementation PSBrushController

@synthesize propertyTable;
@synthesize propertyCell;
@synthesize brush;
@synthesize preview;
@synthesize picker;
@synthesize topBar;
@synthesize bottomBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (!self) {
        return nil;
    }
    
    self.title = @"画笔调整";
    
    UIBarButtonItem *randomizeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(randomize:)];
    self.navigationItem.rightBarButtonItem = randomizeItem;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) enableRandomizeButton
{
    BOOL canRandomize = self.brush.generator.canRandomize;
    
    randomize_.enabled = canRandomize;
    self.navigationItem.rightBarButtonItem.enabled = canRandomize;
}

- (void) updatePreview
{
    [picker setImage:brush.generator.preview forIndex:picker.selectedIndex];
    preview.image = [brush previewImageWithSize:preview.bounds.size];
}

- (void) brushChanged:(NSNotification *)aNotification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePreview) object:nil];
    [self performSelector:@selector(updatePreview) withObject:nil afterDelay:0];
    
    [self enableRandomizeButton];
}

- (void) randomize:(id)sender
{
    [brush.generator resetSeed];
}

- (void) brushGeneratorChanged:(NSNotification *)aNotification
{
    [[PSActiveState sharedInstance] setCanonicalGenerator:[aNotification userInfo][@"generator"]];
    [self brushChanged:aNotification];
}

- (void) brushGeneratorReplaced:(NSNotification *)aNotification
{
    preview.image = [brush previewImageWithSize:preview.bounds.size];
    [propertyTable reloadData];
    
    [self enableRandomizeButton];
}

- (void) setBrush:(PSBrush *)inBrush
{
    brush = inBrush;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushChanged:) name:PSBrushPropertyChanged object:brush];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushGeneratorChanged:) name:PSBrushGeneratorChanged object:brush];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushGeneratorReplaced:) name:PSBrushGeneratorReplaced object:brush];
    
    if (inBrush) {
        [[PSActiveState sharedInstance] setCanonicalGenerator:inBrush.generator];
    }
    
    [picker chooseItemAtIndex:[[PSActiveState sharedInstance] indexForGeneratorClass:[brush.generator class]]];
    
    [self enableRandomizeButton];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) previewDoubleTapped:(id)sender
{
    [brush restoreDefaults];
}

- (void) configurePreview
{
    preview.image = [brush previewImageWithSize:preview.bounds.size];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewDoubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [preview addGestureRecognizer:doubleTap];
    
    preview.userInteractionEnabled = YES;
}

#pragma mark - Table Delegate/Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return PSUseModernAppearance() ? 20 : 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return brush.numberOfPropertyGroups;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [brush propertiesForGroupAtIndex:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PropertyCell";
    
    PSPropertyCell *cell = (PSPropertyCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSString *nibName = PSUseModernAppearance() ? @"PropertyCell~iOS7" : @"PropertyCell";
        [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        cell = propertyCell;
        propertyCell = nil;
    }
    
    cell.property = [brush propertiesForGroupAtIndex:indexPath.section][indexPath.row];
    
    return cell;
}

#pragma mark - View lifecycle

- (void) takeGeneratorFrom:(PSStampPicker *)sender
{
    PSStampGenerator *gen = ([PSActiveState sharedInstance].canonicalGenerators)[sender.selectedIndex];

    brush.generator = [gen copy];
}

- (void) goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (PSBar *) topBar
{
    if (!topBar) {
        PSBar *aBar = [PSBar topBar];
        CGRect frame = aBar.frame;
        frame.size.width = CGRectGetWidth(self.view.bounds);
        aBar.frame = frame;
        
        [self.view addSubview:aBar];
        self.topBar = aBar;
    }
    
    return topBar;
}

- (PSBar *) bottomBar
{
    if (!bottomBar) {
        PSBar *aBar = [PSBar bottomBar];
        CGRect frame = aBar.frame;
        frame.origin.y  = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(aBar.frame);
        frame.size.width = CGRectGetWidth(self.view.bounds);
        aBar.frame = frame;
        
        [self.view addSubview:aBar];
        self.bottomBar = aBar;
    }
    
    return bottomBar;
}

- (NSArray *) barItems
{
    PSBarItem *backButton = [PSBarItem backButtonWithTitle:@""
                                                    target:self
                                                    action:@selector(goBack:)];

    randomize_ = [PSBarItem barItemWithImage:[UIImage imageNamed:@"refresh.png"]
                                      target:self
                                      action:@selector(randomize:)];
    
    return @[[PSBarItem fixedItemWithWidth:4], backButton, [PSBarItem flexibleItem],
            randomize_];
}

- (NSArray *) bottomBarItems
{
    PSBarItem *dismiss = [PSBarItem barItemWithImage:[UIImage imageNamed:@"dismiss.png"]
                                              target:self
                                              action:@selector(done:)];

    return @[[PSBarItem flexibleItem], dismiss];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    propertyTable.rowHeight = PSUseModernAppearance() ? 64 : 60;
    propertyTable.allowsSelection = NO;
    
    if (PSUseModernAppearance()) {
        propertyTable.sectionHeaderHeight = 0;
        propertyTable.sectionFooterHeight = 0;
    }
    
    [propertyTable setBackgroundView:nil];
    [propertyTable setBackgroundView:[[UIView alloc] init]];
    propertyTable.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    [self configurePreview];
    
    NSArray *canon = [PSActiveState sharedInstance].canonicalGenerators;
    NSArray *stamps = [canon map:^id(id obj) {
        return [obj preview];
    }];
    picker.images = stamps;
    
    picker.action = @selector(takeGeneratorFrom:);
    [picker chooseItemAtIndex:[[PSActiveState sharedInstance] indexForGeneratorClass:[brush.generator class]]];
    
    self.preview.contentMode = UIViewContentModeCenter;
    
    if ([self respondsToSelector:@selector(setPreferredContentSize:)])
        self.preferredContentSize = self.view.frame.size;
    else
        self.contentSizeForViewInPopover = self.view.frame.size;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.topBar.ignoreTouches = YES;
        self.topBar.items = [self barItems];
        
        self.bottomBar.items = [self bottomBarItems];
    }
    
    [self enableRandomizeButton];
}

- (void) done:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self configureForOrientation:self.interfaceOrientation];
    }
}

- (void) configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.topBar setOrientation:toInterfaceOrientation];
    [self.bottomBar setOrientation:toInterfaceOrientation];
    
    float barHeight = CGRectGetHeight(bottomBar.frame) - 10;
    propertyTable.contentInset = UIEdgeInsetsMake(0, 0, barHeight, 0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self configureForOrientation:toInterfaceOrientation];
}

- (UIView *) rotatingHeaderView
{
    return self.topBar;
}

- (UIView *) rotatingFooterView
{
    return self.bottomBar;
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

@end
