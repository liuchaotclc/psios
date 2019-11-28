//
//  PSActionSheet.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <Foundation/Foundation.h>

@protocol PSActionSheetDelegate;

@interface PSActionSheet : NSObject <UIActionSheetDelegate>

@property (nonatomic) UIActionSheet *sheet;
@property (nonatomic) NSMutableArray *actions;
@property (nonatomic) NSMutableArray *tags;
@property (nonatomic, weak) id<PSActionSheetDelegate> delegate;

+ (PSActionSheet *) sheet;

- (void) addButtonWithTitle:(NSString *)title action:(void (^)(id))action;
- (void) addButtonWithTitle:(NSString *)title action:(void (^)(id))action tag:(int)tag;
- (void) addCancelButton;

@end

@protocol PSActionSheetDelegate <NSObject>
- (void) actionSheetDismissed:(PSActionSheet *)actionSheet;
@end
