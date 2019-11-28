//
//  PSJSONCoder
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSCoder.h"

@class PSCodingProgress;

@interface PSJSONCoder : NSObject <PSCoder>

- initWithProgress:(PSCodingProgress *)progress;

- (NSDictionary *) binaryData;
- (NSData *) jsonData;
- (NSDictionary *) dataWithRootNamed:(NSString *)name;
- (id) decodeRoot:(NSString *)name from:(NSDictionary *)source;
- (id) reconstruct:(id)obj binary:(NSDictionary *)binary;
+ (NSString *) extensionForType:(NSString *)type;
+ (NSString *) typeForExtension:(NSString *)extension;

@end
