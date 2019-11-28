//
//  PSDragChip.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <UIKit/UIKit.h>

@class PSColor;

@interface PSDragChip : UIView 
@property (nonatomic, strong) PSColor *color;
@end

@protocol PSColorDragging <NSObject>
@optional
- (void)dragMoved:(UITouch *)touch colorChip:(PSDragChip *)chip colorSource:(id)source;
- (void)dragExited;
- (BOOL)dragEnded:(UITouch *)touch colorChip:(PSDragChip *)chip colorSource:(id)source destination:(CGPoint *)flyLoc;
@end
