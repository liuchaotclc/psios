//
//  PSThumbButton.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@interface PSThumbButton : UIView

+ (PSThumbButton *) thumbButtonWithFrame:(CGRect)frame;

@property (nonatomic) UIImage *image;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) BOOL pressed;
@property (nonatomic, assign) BOOL marked;

@end
