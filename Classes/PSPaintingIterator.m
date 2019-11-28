//
//  PSPaintingIterator.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//


#import "PSPaintingIterator.h"
#import "PSDocument.h"
#import "PSPaintingManager.h"
#import "PSUtilities.h"


@implementation PSPaintingIterator {

}

@synthesize paintings;
@synthesize index;
@synthesize block;

- (void) processNext
{
    // process sequentially such that we don't get a ton of documents open simultaneously on bg queues
    if (index < paintings.count) {
        NSString *name = paintings[index++];
        PSDocument *document = [[PSPaintingManager sharedInstance] paintingWithName:name];
        [document openWithCompletionHandler:^void(BOOL success) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^void() {
                    self.block(document);
                    [document closeWithCompletionHandler:^void(BOOL success) {
                        dispatch_async(dispatch_get_main_queue(), ^void() {
                            [self processNext];
                        });
                    }];
                });
            } else {
                WDLog(@"Failed to open document! %@", document.displayName);    
            }
        }];
    } else {
        if (self.completed) {
            self.completed(self.paintings);
        }
    }
}

@end
