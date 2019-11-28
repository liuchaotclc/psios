//
//  PSEraserTool.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSEraserTool.h"

@implementation PSEraserTool

- (NSString *) iconName
{
    return @"eraser.png";
}

- (id) init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.eraseMode = YES;

    return self;
}

@end
