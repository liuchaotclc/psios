//
//  PSFilePlusData.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSFilePlusData.h"

@implementation PSFilePlusData

@synthesize path;
@synthesize mediaType;
@synthesize plusData;

+ (PSFilePlusData *)withPath:(NSString *)path data:(NSData *)data mediaType:(NSString *)mediaType
{
    PSFilePlusData *fpd = [[PSFilePlusData alloc] init];
    fpd.mediaType = mediaType;
    fpd.path = path;
    fpd.fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];   
    fpd.plusData = data;
    return fpd;
}

- (NSData *)data
{
    NSMutableData *file = [NSMutableData dataWithContentsOfFile:self.path];
    if (file) {
        [file setLength:self.fileSize];
        [file appendData:self.plusData];
        return file;
    } else {
        return self.plusData;
    }
}

- (WDSaveStatus)isSaved
{
    return kWDSaveStatusUnsaved;
}

- (NSString *)uuid
{
    return nil;
}

@end
