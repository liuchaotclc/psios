//
//  PSChangeHueSaturation.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "PSSimpleDocumentChange.h"

@class PSHueSaturation;
@class PSLayer;

@interface PSChangeHueSaturation : PSSimpleDocumentChange

@property (nonatomic) PSHueSaturation *hueSaturation;
@property (nonatomic) NSString *layerUUID;

+ (PSChangeHueSaturation *) changeHueSaturation:(PSHueSaturation *)hueSaturation forLayer:(PSLayer *)layer;

@end
