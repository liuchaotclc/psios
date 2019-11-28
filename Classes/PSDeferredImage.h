//
//  PSDeferredImage.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <Foundation/Foundation.h>

#import "PSDataProvider.h"

@interface PSDeferredImage : NSObject <PSDataProvider>

@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *mediaType;
@property (nonatomic) CGSize size;

+ (PSDeferredImage *) image:(UIImage *)image mediaType:(NSString *)type size:(CGSize)size;
- (UIImage *)scaledImage;

@end
