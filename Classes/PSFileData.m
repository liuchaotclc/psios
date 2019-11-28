//
//  PSFileData.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSFileData.h"
#import "PSJSONCoder.h"

@implementation PSFileData

@synthesize path;
@synthesize mediaType;

+ (PSFileData *)withPath:(NSString *)path mediaType:(NSString *)mediaType
{
    PSFileData *data = [[PSFileData alloc] init];
    data.mediaType = mediaType;
    data.path = path;
    return data;
}

- (NSString *)mediaType
{
    if (mediaType) {
        return mediaType;
    } else {
        return [PSJSONCoder typeForExtension:self.path];
    }
}

- (NSData *)data
{
    return [NSData dataWithContentsOfFile:self.path];
}

- (WDSaveStatus)isSaved
{
    return kWDSaveStatusSaved;
}

- (NSString *)uuid
{
    return nil;
}

@end
