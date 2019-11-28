//
//  PSHueSaturation.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "PSCoding.h"

@interface PSHueSaturation : NSObject <PSCoding>

@property (nonatomic, assign) float hueShift;
@property (nonatomic, assign) float saturationShift;
@property (nonatomic, assign) float brightnessShift;

+ (PSHueSaturation *) hueSaturationWithHue:(float)hueShift saturation:(float)saturationShift brightness:(float)brightnessShift;

@end
