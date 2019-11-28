//
//  PSCrossHatchGenerator.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSStampGenerator.h"

@class PSProperty;

@interface PSCrossHatchGenerator : PSStampGenerator

@property (weak, nonatomic, readonly) PSProperty *density;
@property (weak, nonatomic, readonly) PSProperty *deviation;

@end
