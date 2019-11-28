//
//  PSImageView.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@interface PSImageView : UIView

@property (nonatomic) UIImage *image;
@property (nonatomic, assign) float opacity;
@property (nonatomic, assign) float scalingFactor;

@end
