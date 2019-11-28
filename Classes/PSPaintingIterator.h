//
//  PSPaintingIterator.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@class PSDocument;


@interface PSPaintingIterator : NSObject

@property (nonatomic, strong) NSArray *paintings;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) void (^block)(PSDocument *);
@property (nonatomic, copy) void (^completed)(NSArray *paintings);

- (void) processNext;

@end