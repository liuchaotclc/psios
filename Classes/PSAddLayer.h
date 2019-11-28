//
//  PSAddLayer
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

@interface PSAddLayer : PSSimpleDocumentChange

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic) NSString  *layerUUID;

+ (PSAddLayer *) addLayerAtIndex:(NSUInteger)index;

@end
