//
//  PSReorderLayers.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  

#import <Foundation/Foundation.h>
#import "PSSimpleDocumentChange.h"

@class PSLayer;

@interface PSReorderLayers : PSSimpleDocumentChange

@property (nonatomic) NSString *layerUUID;
@property (nonatomic) int destIndex;

+ (PSReorderLayers *) moveLayer:(PSLayer *)layer toIndex:(int)index;

@end
