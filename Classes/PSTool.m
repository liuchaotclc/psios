//
//  PSTool.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSTool.h"

@implementation PSTool

@synthesize moved = moved_;

+ (PSTool *) tool
{
    return [[[self class] alloc] init];
}

- (NSString *) iconName
{
    return nil;
}

- (id) icon
{
    return [UIImage imageNamed:self.iconName];
}

- (void) activated
{
}

- (void) deactivated
{
}

- (void) buttonDoubleTapped
{
}

- (void) gestureBegan:(UIGestureRecognizer *)recognizer
{
    moved_ = NO;
}

- (void) gestureMoved:(UIGestureRecognizer *)recognizer
{
    moved_ = YES;
}

- (void) gestureEnded:(UIGestureRecognizer *)recognizer
{
    
}

- (void) gestureCanceled:(UIGestureRecognizer *)recognizer
{
    
}

@end
