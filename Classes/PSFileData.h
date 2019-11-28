//
//  PSFileData.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 
#import <Foundation/Foundation.h>

#import "PSDataProvider.h"

@interface PSFileData : NSObject <PSDataProvider>

@property (nonatomic) NSString *mediaType;
@property (nonatomic) NSString *path;

+ (PSFileData *) withPath:(NSString *)path mediaType:(NSString *)mediaType;

@end
