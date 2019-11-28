//
//  PSActivity.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import "PSActivity.h"

@implementation PSActivity

@synthesize filePath;
@synthesize progress;
@synthesize type;

+ (PSActivity *) activityWithFilePath:(NSString *)filePath type:(WDActivityType)type
{
    PSActivity *activity = [[PSActivity alloc] initWithFilePath:filePath type:type];
    return activity;
}

- (id) initWithFilePath:(NSString *)aFilePath type:(WDActivityType)aType
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.filePath = aFilePath;
    type = aType;
    
    return self;
}


- (NSString *) description
{
    NSArray *types = @[@"DOWNLOAD", @"UPLOAD", @"IMPORT", @"EXPORT"];
    return [NSString stringWithFormat:@"%@: %@; %@; %.0f%%", [super description], types[type], self.filePath, self.progress * 100];
}

- (NSString *) title
{
    NSArray *formats = @[NSLocalizedString(@"Downloading “%@”", @"Downloading “%@”"),
                        NSLocalizedString(@"Uploading “%@”", @"Uploading “%@”"),
                        NSLocalizedString(@"Importing “%@”", @"Importing “%@”"),
                        NSLocalizedString(@"Exporting “%@”", @"Exporting “%@”")];
    
    return [NSString stringWithFormat:formats[type], [self.filePath lastPathComponent]];
}

@end
