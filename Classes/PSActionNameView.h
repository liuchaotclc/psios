//
//  PSActionNameView.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@protocol PSActionNameViewDelegate;

@interface PSActionNameView : UIView
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) id<PSActionNameViewDelegate> delegate;

- (void) setUndoActionName:(NSString *)undoActionName;
- (void) setRedoActionName:(NSString *)redoActionName;

- (void) setConnectedDeviceName:(NSString *)deviceName;
- (void) setDisconnectedDeviceName:(NSString *)deviceName;

@end

@protocol PSActionNameViewDelegate <NSObject>
- (void) fadingOutActionNameView:(PSActionNameView *)actionNameView;
@end
