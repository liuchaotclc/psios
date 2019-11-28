//
//  PSActivityManager.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSActivity.h"
#import "PSActivityManager.h"
#import "PSProgressView.h"
#import "PSSleepTimer.h"
#import "UIView+Additions.h"

NSString *PSActivityAddedNotification = @"PSActivityAddedNotification";
NSString *PSActivityRemovedNotification = @"PSActivityRemovedNotification";
NSString *PSActivityProgressChangedNotification = @"PSActivityProgressChangedNotification";

#define kLabelTag        1
#define kProgressTag     2

@implementation PSActivityManager

@synthesize activities;

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.activities = [NSMutableArray array];
    
    return self;
}


- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: %@", [super description], activities];
}

- (void) addActivity:(PSActivity *)activity
{
    [activities addObject:activity];
    NSDictionary *userInfo = @{@"activity": activity,
                              @"index": @([self indexOfActivity:activity])};
    
    [[PSSleepTimer sharedInstance] disableTimer:activity];

    [[NSNotificationCenter defaultCenter] postNotificationName:PSActivityAddedNotification object:self userInfo:userInfo];
}

- (PSActivity *) activityWithFilepath:(NSString *)filepath
{
    for (PSActivity *activity in activities) {
        if ([activity.filePath isEqualToString:filepath]) {
            return activity;
        }
    }
    
    return nil;
}

- (NSUInteger) count
{
    return activities.count;
}

- (NSUInteger) indexOfActivity:(PSActivity *)activity
{
    return [activities indexOfObject:activity];
}

- (void) removeActivity:(PSActivity *)activity
{
    NSUInteger  index = [self indexOfActivity:activity];
    NSDictionary *userInfo = @{@"activity": activity,
                              @"index": @(index)};
    
    [[PSSleepTimer sharedInstance] enableTimer:activity];

    // do this after creating the dictionary, to make sure activity doesn't get released prematurely
    [activities removeObject:activity];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PSActivityRemovedNotification object:self userInfo:userInfo];
}

- (void) removeActivityWithFilepath:(NSString *)filepath
{
    [self removeActivity:[self activityWithFilepath:filepath]];
}

- (void) updateProgressForFilepath:(NSString *)filepath progress:(float)progress
{
    PSActivity *activity = [self activityWithFilepath:filepath];
    
    activity.progress = progress;
    
    NSDictionary *userInfo = @{@"activity": activity, 
                              @"index": @([self indexOfActivity:activity])};
    [[NSNotificationCenter defaultCenter] postNotificationName:PSActivityProgressChangedNotification object:self userInfo:userInfo];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return activities.count;
}

- (UITableViewCell *) freshCellWithIdentifier:(NSString *)identifier
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    CGRect frame = cell.contentView.bounds;
    frame.origin.x += 42;
    frame.size.width = (CGRectGetWidth(cell.contentView.bounds) - 10) - frame.origin.x;
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.tag = 1;
    [cell.contentView addSubview:label];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSActivity *activity = (PSActivity *) activities[indexPath.row];
    UITableViewCell *cell;
    
    if (activity.type == WDActivityTypeImport) {
        NSString    *cellIdentifier = @"indeterminateIdentifier";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [self freshCellWithIdentifier:cellIdentifier];
            
            UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell.contentView addSubview:activity];
            activity.sharpCenter = CGPointMake(21, CGRectGetMidY(cell.contentView.bounds));
            [activity startAnimating];
        }
    } else {
        NSString    *cellIdentifier = @"progressIdentifier";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [self freshCellWithIdentifier:cellIdentifier];
            
            PSProgressView *progressView = [[PSProgressView alloc] initWithFrame:CGRectMake(0,0,28,28)];
            [cell.contentView addSubview:progressView];
            progressView.sharpCenter = CGPointMake(21, CGRectGetMidY(cell.contentView.bounds));
            progressView.tag = kProgressTag;
        }
    }
    
    PSProgressView *progressView = (PSProgressView *) [cell viewWithTag:kProgressTag];
    progressView.progress = activity.progress;
    
    UILabel *label = (UILabel *) [cell viewWithTag:kLabelTag];
    label.text = activity.title;
    
    return cell;
}

@end
