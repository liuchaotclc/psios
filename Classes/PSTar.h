//
//  PSTar
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>


@interface PSTar : NSObject

- (void) writeTarToStream:(NSOutputStream *)stream withFiles:(NSDictionary *)files baseURL:(NSURL *)baseURL order:(NSArray *)list;
- (void) writeTarToFile:(NSURL *)path withFiles:(NSDictionary *)files baseURL:(NSURL *)baseURL order:(NSArray *)list;
- (NSDictionary *) readTar:(NSURL *)url error:(NSError **)outError;
- (NSData *) readEntry:(NSString *)name fromTar:(NSURL *)url;

@end
