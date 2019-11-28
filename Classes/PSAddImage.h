//
//  PSAddImage.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>
#import "PSSimpleDocumentChange.h"

@class PSLayer;

@interface PSAddImage : PSSimpleDocumentChange

@property (nonatomic) NSUInteger layerIndex;
@property (nonatomic) NSString *mediaType;
@property (nonatomic, assign) BOOL mergeDown;
@property (nonatomic) NSData *imageData;
@property (nonatomic) NSString *imageHash;
@property (nonatomic) NSString *layerUUID;
@property (nonatomic, assign) CGAffineTransform transform;

+ (PSAddImage *) addImage:(UIImage *)image atIndex:(NSUInteger)index mergeDown:(BOOL)mergeDown transform:(CGAffineTransform)transform;

@end
