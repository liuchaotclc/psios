//
//  PSDocumentChangeVisitor.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 

#import <Foundation/Foundation.h>

@class PSAddPath;
@class PSRedoChange;
@class PSUndoChange;
@protocol PSDocumentChange;

@protocol PSDocumentChangeVisitor <NSObject>

- (void) visitAddPath:(PSAddPath *)change;
- (void) visitClearUndoStack;
- (void) visitGeneric:(id<PSDocumentChange>)change;
- (void) visitRedo:(PSRedoChange *)change;
- (void) visitUndo:(PSUndoChange *)change;

@end
