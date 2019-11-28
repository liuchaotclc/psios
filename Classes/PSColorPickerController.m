//
//  PSColorPickerController.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSActiveState.h"
#import "PSBar.h"
#import "PSColor.h"
#import "PSColorComparator.h"
#import "PSColorPickerController.h"
#import "PSColorSlider.h"
#import "PSColorSquare.h"
#import "PSColorWheel.h"
#import "PSMatrix.h"
#import "PSUtilities.h"

//屏幕宽和高
#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

@interface PSColorPickerController()

@property(nonatomic,strong)UIButton *btn;

@end

@implementation PSColorPickerController

@synthesize color = color_;
@synthesize colorComparator = colorComparator_;
@synthesize colorSquare = colorSquare_;
@synthesize colorWheel = colorWheel_;
@synthesize swatches = swatches_;
@synthesize alphaSlider = alphaSlider_;
@synthesize delegate;
@synthesize bottomBar;
@synthesize firstCell;
@synthesize secondCell;
@synthesize matrix;

- (IBAction)dismiss:(id)sender
{
    [[PSActiveState sharedInstance] addHistoryColor:[PSActiveState sharedInstance].paintColor];
    [[PSActiveState sharedInstance] saveHistoryColor];
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

- (void) doubleTapped:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissViewController:)]) {
        [self.delegate performSelector:@selector(dismissViewController:) withObject:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    if ([self respondsToSelector:@selector(setPreferredContentSize:)])
        self.preferredContentSize = self.view.frame.size;
    else
        self.contentSizeForViewInPopover = self.view.frame.size;
    
    // set up color comparator
    self.colorComparator.target = self;
    self.colorComparator.action = @selector(takeColorFromComparator:);
    
    // set up color wheel
    UIControlEvents dragEvents = (UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragOutside);
    self.colorWheel.backgroundColor = nil;
    [self.colorWheel addTarget:self action:@selector(takeHueFrom:) forControlEvents:dragEvents];
    
    // set up color square
    [self.colorSquare addTarget:self action:@selector(takeBrightnessAndSaturationFrom:) forControlEvents:dragEvents];
    
    // set up swatches
    self.swatches.delegate = self;
    
    self.alphaSlider.mode = WDColorSliderModeAlpha;
    [alphaSlider_ addTarget:self action:@selector(takeAlphaFrom:) forControlEvents:dragEvents];
    
    self.initialColor = [PSActiveState sharedInstance].paintColor;
    
    if (PSDeviceIsPhone()) {
        self.bottomBar.items = [self bottomBarItems];
        [self.bottomBar setOrientation:self.interfaceOrientation];
        
        CGRect matrixFrame = PSDeviceIs4InchPhone() ? self.view.frame : CGRectInset(self.view.frame, 10, 10);
        matrix = [[PSMatrix alloc] initWithFrame:matrixFrame];
        matrix.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:matrix atIndex:0];
        matrix.columns = 1;
        matrix.rows = 2;
        
        self.secondCell.backgroundColor = nil;
        self.secondCell.opaque = NO;
        
        self.alphaSlider.superview.backgroundColor = nil;
        
        [matrix setCellViews:@[self.firstCell, self.secondCell]];
    }
    
    //添加收藏按钮
    [self.view addSubview:self.btn];
}

- (UIButton *)btn{
    if (!_btn) {
        _btn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT/ 2, 80, 25)];
        [_btn setTitle:@"收藏" forState:UIControlStateNormal];
        UIImage *iconCollect = [UIImage imageNamed:@"swatch_add.png"];
        [_btn setImage:iconCollect forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(pressCollect:)  forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (void) pressCollect:(id)sender
{
        [[PSActiveState sharedInstance] addCollectColor:[PSActiveState sharedInstance].paintColor];
}

- (void) takeColorFromComparator:(id)sender
{
    [self setColor:(PSColor *) [sender color]];
}

- (void) takeHueFrom:(id)sender
{
    float hue = [(PSColorWheel *)sender hue];
    PSColor *newColor = [PSColor colorWithHue:hue
                                   saturation:[color_ saturation]
                                   brightness:[color_ brightness]
                                        alpha:[color_ alpha]];
    
    [self setColor:newColor];
}

- (void) takeBrightnessAndSaturationFrom:(id)sender
{
    float saturation = [(PSColorSquare *)sender saturation];
    float brightness = [(PSColorSquare *)sender brightness];
    
    PSColor *newColor = [PSColor colorWithHue:[color_ hue]
                                   saturation:saturation
                                   brightness:brightness
                                        alpha:[color_ alpha]];
    
    [self setColor:newColor];
}

- (void) takeAlphaFrom:(PSColorSlider *)slider
{
    float alpha = slider.floatValue;
    
    PSColor *newColor = [PSColor colorWithHue:[color_ hue]
                                   saturation:[color_ saturation]
                                   brightness:[color_ brightness]
                                        alpha:alpha];
    [self setColor:newColor];
}

- (void) takeBrightnessFrom:(PSColorSlider *)slider
{
    float brightness = slider.floatValue;
    
    PSColor *newColor = [PSColor colorWithHue:[color_ hue]
                                   saturation:[color_ saturation]
                                   brightness:brightness
                                        alpha:[color_ alpha]];
    
    [self setColor:newColor];
}

- (void) takeSaturationFrom:(PSColorSlider *)slider
{
    float saturation = slider.floatValue;
    
    PSColor *newColor = [PSColor colorWithHue:[color_ hue]
                                   saturation:saturation
                                   brightness:[color_ brightness]
                                        alpha:[color_ alpha]];
    
    [self setColor:newColor];
}

- (void) setColor_:(PSColor *)color
{
    color_ = color;
    
    [self.colorWheel setColor:color_];
    [self.colorComparator setCurrentColor:color_];
    [self.colorSquare setColor:color_];
    [self.alphaSlider setColor:color_];
}

- (void) setInitialColor:(PSColor *)color
{
    [self.colorComparator setInitialColor:color];
    [self setColor_:color];
}

- (void) setColor:(PSColor *)color
{
    [self setColor_:color];
    [PSActiveState sharedInstance].paintColor = color;
}

- (PSBar *) bottomBar
{
    if (!bottomBar) {
        PSBar *aBar = [PSBar bottomBar];
        CGRect frame = aBar.frame;
        frame.origin.y  = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(aBar.frame);
        frame.size.width = CGRectGetWidth(self.view.bounds);
        aBar.frame = frame;
        aBar.tightHitTest = YES;
        
        [self.view addSubview:aBar];
        self.bottomBar = aBar;
    }
    
    return bottomBar;
}

- (NSArray *) bottomBarItems
{
    PSBarItem *dismiss = [PSBarItem barItemWithImage:[UIImage imageNamed:@"dismiss.png"]
                                              target:self action:@selector(dismiss:)];
    
//    WDBarItem *gear = [WDBarItem barItemWithImage:[UIImage imageNamed:@"gear.png"]
//            target:self
//            action: @selector(addCollect:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:[PSBarItem flexibleItem], dismiss, nil];
    
    return items;
}

- (UIView *) rotatingFooterView
{
    return self.bottomBar;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        if (PSDeviceIs4InchPhone()) {
            matrix.frame = CGRectOffset(CGRectInset(self.view.frame, 5, 20), 0, -5);
        } else {
            matrix.frame = self.view.frame;
        }
        
        matrix.columns = 2;
        matrix.rows = 1;
    } else {
        if (PSDeviceIs4InchPhone()) {
            matrix.frame = CGRectOffset(CGRectInset(self.view.frame, 5, 20), 0, -15);
        } else {
            matrix.frame = CGRectOffset(CGRectInset(self.view.frame, 0, 5), 0, -5);
        }
        
        matrix.columns = 1;
        matrix.rows = 2;
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.bottomBar setOrientation:self.interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) viewDidLayoutSubviews
{
    if (!PSDeviceIsPhone()) {
        return;
    }
    
    [self.bottomBar setOrientation:self.interfaceOrientation];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}



@end
