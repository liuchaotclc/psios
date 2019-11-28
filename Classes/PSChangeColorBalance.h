//
//  PSChangeColorBalance.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
//

#import <Foundation/Foundation.h>
#import "PSSimpleDocumentChange.h"

@class PSColorBalance;
@class PSLayer;

@interface PSChangeColorBalance : PSSimpleDocumentChange

@property (nonatomic) PSColorBalance *colorBalance;
@property (nonatomic) NSString *layerUUID;

+ (PSChangeColorBalance *) changeColorBalance:(PSColorBalance *)colorBalance forLayer:(PSLayer *)layer;

@end