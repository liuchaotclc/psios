//
//  PSColorBalance.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <Foundation/Foundation.h>
#import "PSCoding.h"

@interface PSColorBalance : NSObject <PSCoding>

@property (nonatomic, assign) float redShift;
@property (nonatomic, assign) float greenShift;
@property (nonatomic, assign) float blueShift;

+ (PSColorBalance *) colorBalanceWithRed:(float)redShift green:(float)greenShift blue:(float)blueShift;

@end
