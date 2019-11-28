//
//  PSColorIndicator.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <UIKit/UIKit.h>

@class PSColor;

@interface PSColorIndicator : UIView

@property (nonatomic, assign) BOOL alphaMode;
@property (nonatomic, strong) PSColor *color;

+ (PSColorIndicator *) colorIndicator;

@end
