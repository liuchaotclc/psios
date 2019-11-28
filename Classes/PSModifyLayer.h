//
//  PSModifyLayer.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "PSSimpleDocumentChange.h"

typedef enum {
    WDMergeLayer,
    WDClearLayer,
    WDDesaturateLayer,
    WDInvertLayerColor,
    WDFlipLayerHorizontal,
    WDFlipLayerVertical,
} WDLayerOperation;

@class PSLayer;

@interface PSModifyLayer : PSSimpleDocumentChange

@property (nonatomic) NSString *layerUUID;
@property (nonatomic, assign) WDLayerOperation operation;

+ (PSModifyLayer *) modifyLayer:(PSLayer *)layer withOperation:(WDLayerOperation)operation;
+ (PSModifyLayer *) modifyLayerUUID:(NSString *)layerUUID withOperation:(WDLayerOperation)operation;

@end
