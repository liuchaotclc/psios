//
//  PSSynchronizer.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  
#import "PSDocument.h"
#import "PSSynchronizer.h"
#import "PSUtilities.h"

@implementation PSSynchronizer {
    __weak PSDocument *document_;
}

- (id) initWithDocument:(PSDocument *)document
{
    self = [super init];
    if (!self) {
        return nil;
    }

    document_ = document;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentChanged:) name:WDDocumentChangedNotification object:document_.painting];

    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) documentChanged:(NSNotification *)notification
{
    if (notification.object == document_.painting) {
        id<PSDocumentChange> change = (notification.userInfo)[@"change"];
        [change beginAnimation:document_.painting];
        if (![change applyToPaintingAnimated:document_.painting step:1 of:1 undoable:YES]) {
            WDLog(@"ERROR: Synchronizer change failed: %@", change);
        }
        [change endAnimation:document_.painting];
    }
}

@end
