//
//  PSSleepTimer.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  

#import "PSSleepTimer.h"
#import "PSUtilities.h"

static PSSleepTimer *instance;

@implementation PSSleepTimer {
    int sleepCount_;
    NSMutableSet *actives_;
}

// assuming this may get called by background tasks, thus the synchronization

+ (PSSleepTimer *) sharedInstance {
    @synchronized ([PSSleepTimer class]) {
        if (!instance) {
            instance = [[PSSleepTimer alloc] init];
        }
    }
    return instance;
}

- (id) init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    sleepCount_ = 0;
    actives_ = [NSMutableSet set];
    
    return self;
}

- (void) enableTimer:(id)active {
    @synchronized(self) {
        if (sleepCount_ > 0 && [actives_ containsObject:active]) {
            [actives_ removeObject:active];
            --sleepCount_;
            if (sleepCount_ == 0) {
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            }
            WDLog(@"Sleep timer level is now: %d", sleepCount_);
        }
    }
}

- (void) disableTimer:(id)active {
    @synchronized(self) {
        if (![actives_ containsObject:active]) {
            [actives_ addObject:active];
            ++sleepCount_;
            if (sleepCount_ == 1) {
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            }
            WDLog(@"Sleep timer level is now: %d", sleepCount_);
        }
   }
}

@end
