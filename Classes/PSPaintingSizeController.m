//
//  PSPaintingSizeController.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "NSArray+Additions.h"
#import "UIView+Additions.h"
#import "PSBrowserController.h"
#import "PSPaintingSizeController.h"
#import "PSUtilities.h"
#import "PSPaintingManager.h"


NSString *WDPaintingSizeIndex = @"WDPaintingSizeIndex";
NSString *WDPaintingSizeVersion = @"WDPaintingSizeVersion";
NSString *WDCustomSizeWidth = @"WDCustomSizeWidth";
NSString *WDCustomSizeHeight = @"WDCustomSizeHeight";
NSString *WDPaintingOrientationRotated = @"WDPaintingOrientationRotated";

const NSUInteger WDMinimumDimension = 64;
const NSUInteger WDMaximumDimension = 4096;
const NSUInteger WDPaintingSizeCurrentVersion = 2;

#define kWDEdgeBuffer 25

@implementation PSPaintingSizeController {
}

@synthesize configuration;
@synthesize width;
@synthesize height;
@synthesize browserController;
@synthesize miniCanvases;

+ (void) registerDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *path = PSCanUseHDTextures() ? @"DocSizes.plist" : @"DocSizes_LowRes.plist";
    NSString *settingsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    NSArray *docSizes = [NSArray arrayWithContentsOfFile:settingsPath];
    
    BOOL needToRebuildIndex = NO;
    
    if (![defaults objectForKey:WDPaintingSizeIndex]) {
        needToRebuildIndex = YES;
    } else {
        NSInteger currentIndex = [defaults integerForKey:WDPaintingSizeIndex];        
        needToRebuildIndex = (currentIndex < 0 || currentIndex >= docSizes.count) ? YES : NO;
    }
    
    if (![defaults objectForKey:WDPaintingSizeVersion]) {
        needToRebuildIndex = YES;
        [defaults setObject:@(WDPaintingSizeCurrentVersion) forKey:WDPaintingSizeVersion];
    } else {
        NSInteger version = [defaults integerForKey:WDPaintingSizeVersion];
        if (version != WDPaintingSizeCurrentVersion)
        {
            needToRebuildIndex = YES;
            [defaults setObject:@(WDPaintingSizeCurrentVersion) forKey:WDPaintingSizeVersion];
        }
    }
    
    // set up the default size chooser orientations
    NSArray *landscapes = [defaults objectForKey:WDPaintingOrientationRotated];
    if (!landscapes || landscapes.count != docSizes.count) {
        NSArray *orientations = [NSArray arrayByReplicating:@NO times:docSizes.count];
        [defaults setObject:orientations forKey:WDPaintingOrientationRotated];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.configuration.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    (self.configuration)[currentPage][@"Custom"] ? YES : NO;
    static NSString *CellIdentifier = @"NameIdentifier";
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell == nil){
        cell = [[UITableViewCell  alloc] initWithStyle:(UITableViewCellStyle)UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CGSize size = [self sizeForPage:indexPath.row];
    self.width = size.width;
    self.height = size.height;
    
    NSDictionary *config = (self.configuration)[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;//文字居中
    if(indexPath.row > 1){
        cell.textLabel.text = [(self.configuration)[indexPath.row][@"Name"] stringByAppendingString:[NSString stringWithFormat:@"(%lu × %lu)", (unsigned long)width, (unsigned long)height]];
    }else{
         cell.textLabel.text = (self.configuration)[indexPath.row][@"Name"];
    }
           
        return cell;
}


- (void)alertStyleWithTwoTextField
{
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:@"输入分辨率" preferredStyle:UIAlertControllerStyleAlert];
    [actionSheetController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"宽度";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [actionSheetController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"高度";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    UIAlertAction *determineAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定 is pressed");
        ;
        
        NSUInteger choosewidth = [[[actionSheetController textFields] objectAtIndex:0].text intValue];
        NSUInteger chooseheight = [[[actionSheetController textFields] objectAtIndex:1].text intValue];
        [self.browserController createNewPainting:CGSizeMake(choosewidth, chooseheight)];
        [self dismissModalViewControllerAnimated:YES];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消 is pressed");
        
    }];
    
    [actionSheetController addAction:determineAction];
    [actionSheetController addAction:cancelAction];
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选中了第%li个cell", (long)indexPath.row);
    if(indexPath.row == 0){
        [self alertStyleWithTwoTextField];
        return;
    }else if(indexPath.row == 1){
        [self importFromCamera:tableView];
        return;
    }
    
    CGSize size = [self sizeForPage:indexPath.row];
    NSUInteger choosewidth = size.width;
    NSUInteger chooseheight = size.height;
    [self.browserController createNewPainting:CGSizeMake(choosewidth, chooseheight)];
    [self dismissModalViewControllerAnimated:YES];
}


- (void) importFromCamera:(id)sender
{
    UIImagePickerController *controller = nil;
    
        controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:^{
               NSLog(@"进入相册");
           }];
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //取得所选取的图片,原大小,可编辑等，info是选取的图片的信息字典
    UIImage *selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//    [[WDPaintingManager sharedInstance] createNewPaintingWithImage:selectImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"模态返回") ;
    }];
    [self.browserController createNewPaintingWithImage:selectImage];
     [self dismissViewControllerAnimated:YES completion:^{
     }];
  
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (!self) {
        return nil;
    }
    
    self.title = @"新建绘画";
    self.miniCanvases = [NSMutableArray array];
    
    return self;
}

- (void) cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) create:(id)sender
{
    [self.browserController createNewPainting:CGSizeMake(width, height)];
    [self dismissModalViewControllerAnimated:YES];
}

- (NSArray *) configuration
{
    if (!configuration) {
        NSString *docSizes = PSCanUseHDTextures() ? @"DocSizes.plist" : @"DocSizes_LowRes.plist";
        NSString *settingsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:docSizes];
        configuration = [NSArray arrayWithContentsOfFile:settingsPath];
    }
    
    return configuration;
}

- (NSUInteger) maxDimension
{
    return PSCanUseHDTextures() ? WDMaximumDimension : WDMaximumDimension / 2;
}

- (void) handleDoubleTapGesture:(UIGestureRecognizer*)gestureRecognizer
{
    [self create:nil];
}

- (void) handleTapGesture:(UIGestureRecognizer*)gestureRecognizer
{
    [self rotate:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString        *proposed = textField.text;
    NSCharacterSet  *numericSet = [NSCharacterSet decimalDigitCharacterSet];
        
    if (![string isEqualToString:@"\n"]) {
        proposed = [proposed stringByReplacingCharactersInRange:range withString:string];
    }
    
    if (proposed.length == 0) {
        return YES;
    }
    
    for (NSUInteger ix = 0; ix < proposed.length; ix++) {
        unichar c = [proposed characterAtIndex:ix];
        if (![numericSet characterIsMember:c]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *create = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create", @"Create")
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(create:)];
    self.navigationItem.rightBarButtonItem = create;
    
    _sizeCoupeListTabView.dataSource = self;
    _sizeCoupeListTabView.delegate = self;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancel;
    }
    
    self.view.backgroundColor = (PSUseModernAppearance() && !PSDeviceIsPhone()) ? nil : [UIColor colorWithWhite:0.95 alpha:1];
    
    if (PSUseModernAppearance()) {
        // we don't want to go under the nav bar and tool bar
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    UIControlEvents eventFlags = (UIControlEventEditingDidEnd | UIControlEventEditingDidEndOnExit);

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger) maxValidPage
{
    return self.configuration.count;
}

- (CGSize) sizeForPage:(NSUInteger)page
{
    NSNumber    *w, *h;
    BOOL        isScreen = (self.configuration)[page][@"Screen"] ? YES : NO;
    if (isScreen) {
        CGSize screenSize = PSMultiplySizeScalar([UIScreen mainScreen].bounds.size, [UIScreen mainScreen].scale);
        w = @(screenSize.width);
        h = @(screenSize.height);
    } else {
        w = (self.configuration)[page][@"Width"];
        h = (self.configuration)[page][@"Height"];
        
        NSArray *landscapes = [[NSUserDefaults standardUserDefaults] objectForKey:WDPaintingOrientationRotated];
        if ([landscapes[page] boolValue]) {
            // swap
            NSNumber *temp = w;
            w = h;
            h = temp;
        }
    }
    
    return CGSizeMake([w integerValue], [h integerValue]);
}

@end
