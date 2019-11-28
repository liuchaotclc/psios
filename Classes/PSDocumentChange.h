//
//  PSDocumentChange.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <Foundation/Foundation.h>
#import "PSCoding.h"

@class PSPainting;
@protocol PSDocumentChangeVisitor;

@protocol PSDocumentChange <PSCoding>

@property int changeIndex;

- (int) animationSteps:(PSPainting *)painting;
- (void) beginAnimation:(PSPainting *)painting;
- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable;
- (void) endAnimation:(PSPainting *)painting;

- (void) accept:(id<PSDocumentChangeVisitor>)visitor;
- (void) scale:(float)scale;

@end

extern NSString *WDDocumentChangedNotification;
extern NSString *WDDocumentChangedNotificationChange;
extern NSString *WDHistoryVersion;

extern void changeDocument(PSPainting *painting, id<PSDocumentChange> change);
