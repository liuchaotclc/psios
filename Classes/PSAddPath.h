//
//  PSAddPath.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <Foundation/Foundation.h>
#import "PSDocumentChange.h"

@class PSLayer;
@class PSPath;

@interface PSAddPath : NSObject <PSDocumentChange>

@property (nonatomic) PSPath *path;
@property (nonatomic, assign) BOOL erase;
@property (nonatomic) NSString *layerUUID;
@property (nonatomic, weak) PSPainting *sourcePainting;

+ (PSAddPath *) addPath:(PSPath *)added erase:(BOOL)erase layer:(PSLayer *)layer sourcePainting:(PSPainting *)painting;

@end
