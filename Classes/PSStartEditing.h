//
//  PSStartEditing.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 
#import <Foundation/Foundation.h>
#import "PSSimpleDocumentChange.h"

@interface PSStartEditing : PSSimpleDocumentChange

@property (nonatomic) NSString *deviceID;
@property (nonatomic) NSString *deviceModel;
@property (nonatomic) NSArray *features;
@property (nonatomic, strong) NSString *historyVersion;
@property (nonatomic) NSString *systemVersion;

+ (PSStartEditing *) startEditing;

@end
