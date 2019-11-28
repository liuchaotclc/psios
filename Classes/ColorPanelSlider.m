//
//  PSUnlockSlider.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "UIView+Additions.h"
#import "ColorPanelSlider.h"
#import "PSUtilities.h"
#import "PSColorWell.h"
#import "PSActiveState.h"

#define kCornerRadius 15

@interface ColorPanelSlider ()
//@property (nonatomic) UIImageView *thumb;
@property (nonatomic) UILabel *label;
@property (nonatomic) PSColorWell         *colorWell_;
@end

@implementation ColorPanelSlider

@synthesize colorWell_;
@synthesize label;
//@synthesize thumb;

+ (ColorPanelSlider *) unlockSlider
{
    ColorPanelSlider *slider = [[ColorPanelSlider alloc] initWithFrame:CGRectMake(-50, ([UIScreen mainScreen].bounds.size.height - 76) /2 , 120, 76)];
    return slider;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.opaque = NO;
    self.backgroundColor = nil;
    
     CGRect wellFrame = CGRectMake(0, 0, 88, 66);
           colorWell_ = [[PSColorWell alloc] initWithFrame:wellFrame];
           colorWell_.color = [PSActiveState sharedInstance].paintColor;
           [colorWell_ addTarget:self action:@selector(showColorPicker:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:colorWell_];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    return self;
}

- (void) showColorPicker:(id)sender
{
   if (_delegate) {
       [_delegate onColorSliderSingleClick: sender];
   }
}


- (void) setColor:(PSColor *)inColor
{
    [colorWell_ setColor:inColor];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return CGRectContainsPoint(colorWell_.bounds, [touch locationInView:colorWell_]);
}

- (void) handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint center = self.colorWell_.center;
    float   buffer = self.colorWell_.bounds.size.width / 2;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // nothing special
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // translate the thumb appropriately
        center.x += [gestureRecognizer translationInView:self].x;        
        center.x = WDClamp(buffer, CGRectGetWidth(self.bounds) - buffer, center.x);
        colorWell_.sharpCenter = center;
        
        // computer proper fade for label
        float percentage = (center.x - buffer) / ((CGRectGetWidth(self.bounds) - buffer) / 5.0f);
        label.alpha = 1.0f - percentage;
        
        [gestureRecognizer setTranslation:CGPointZero inView:self];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (colorWell_.center.x == CGRectGetWidth(self.bounds) - buffer) {
            if (_delegate) {
                [_delegate onColorSliderToEnd:colorWell_];
               }
               
            // successful slide to the right, so send action
//            [self sendActionsForControlEvents:UIControlEventValueChanged];
        } else {
           
            
        }
        // didn't make it, so reset the world
        [UIView animateWithDuration:0.4f animations:^{
            colorWell_.sharpCenter = CGPointMake(buffer, center.y);
            label.alpha = 1.0f;
        }];
    }
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
}

@end
