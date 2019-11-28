//
//  PSEventForwardingView.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import "PSEventForwardingView.h"


@implementation PSEventForwardingView

@synthesize forwardToView = forwardToView_;

- (void) awakeFromNib
{
    self.opaque = NO;
    self.backgroundColor = nil;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    return (view == self) ? forwardToView_ : view;
}

@end
