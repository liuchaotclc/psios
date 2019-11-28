//
//  PSStartEditing.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  
#import "UIDeviceHardware.h"
#import "PSActiveState.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSStartEditing.h"
#import "PSUtilities.h"

@implementation PSStartEditing

@synthesize deviceID;
@synthesize deviceModel;
@synthesize historyVersion;
@synthesize systemVersion;
@synthesize features;

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    // does nothing
    return [self canPlayHistoryVersion:self.historyVersion];
}

- (BOOL) canPlayHistoryVersion:(NSString *)version
{
    NSScanner *scanner1 = [NSScanner scannerWithString:WDHistoryVersion];
    [scanner1 setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    int supportedMajor, supportedMinor, supportedPoint;
    if (![scanner1 scanInt:&supportedMajor] || ![scanner1 scanInt:&supportedMinor] || ![scanner1 scanInt:&supportedPoint]) {
        WDLog(@"ERROR: Can't parse supported history version: %@", WDHistoryVersion);
        return NO;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:version];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    int testMajor, testMinor, testPoint;
    if (![scanner scanInt:&testMajor] || ![scanner scanInt:&testMinor] || ![scanner scanInt:&testPoint]) {
        WDLog(@"ERROR: Can't parse test history version: %@", version);
        return NO;
    }
    
    return (supportedMajor > testMajor)
        || (supportedMajor == testMajor && supportedMinor > testMinor)
        || (supportedMajor == testMajor && supportedMinor == testMinor && supportedPoint >= testPoint);
}

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:self.deviceID forKey:@"deviceID"];
    [coder encodeString:self.deviceModel forKey:@"deviceModel"];
    [coder encodeString:self.historyVersion forKey:@"historyVersion"];
    [coder encodeString:self.systemVersion forKey:@"systemVersion"];
    [coder encodeArray:self.features forKey:@"features"];
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.deviceID = [decoder decodeStringForKey:@"deviceID"];
    self.deviceModel = [decoder decodeStringForKey:@"deviceModel"];
    self.historyVersion = [decoder decodeStringForKey:@"historyVersion"];
    self.systemVersion = [decoder decodeStringForKey:@"systemVersion"];
    self.features = [decoder decodeArrayForKey:@"features"];
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ deviceID:%@ deviceModel:%@ historyVersion:%@ systemVersion:%@", [super description], self.deviceID, self.deviceModel, self.historyVersion, self.systemVersion];
}

+ (PSStartEditing *) startEditing
{
    PSStartEditing *change = [[PSStartEditing alloc] init];
    change.deviceID = [PSActiveState sharedInstance].deviceID;
    change.deviceModel = [UIDeviceHardware platform];
    change.historyVersion = [WDHistoryVersion copy];
    change.systemVersion = [UIDevice currentDevice].systemVersion;
    return change;
}

@end
