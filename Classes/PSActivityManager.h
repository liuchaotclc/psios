//
//  PSActivityManager.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@class PSActivity;

@interface PSActivityManager : NSObject <UITableViewDataSource>

@property (nonatomic) NSMutableArray *activities;
@property (nonatomic, readonly) NSUInteger count;

// add
- (void) addActivity:(PSActivity *)activity;

// find
- (PSActivity *) activityWithFilepath:(NSString *)filepath;
- (NSUInteger) indexOfActivity:(PSActivity *)activity;

// delete
- (void) removeActivityWithFilepath:(NSString *)filepath;
- (void) removeActivity:(PSActivity *)activity;

// update
- (void) updateProgressForFilepath:(NSString *)filepath progress:(float)progress;

@end

extern NSString *PSActivityAddedNotification;
extern NSString *PSActivityRemovedNotification;
extern NSString *PSActivityProgressChangedNotification;

