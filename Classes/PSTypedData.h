//
//  PSTypedData
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

#import "PSDataProvider.h"

@interface PSTypedData : NSObject <PSDataProvider>

@property (nonatomic, assign) BOOL compress;
@property (nonatomic) NSData *data;
@property (nonatomic, assign) WDSaveStatus isSaved;
@property (nonatomic) NSString *mediaType;
@property (nonatomic) NSString *uuid;

+ (PSTypedData *) data:(NSData *)data mediaType:(NSString *)type;
+ (PSTypedData *) data:(NSData *)data mediaType:(NSString *)type compress:(BOOL)compress uuid:(NSString *)uuid isSaved:(WDSaveStatus)saved;

@end
