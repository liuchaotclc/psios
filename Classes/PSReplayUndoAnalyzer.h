//
//  PSReplayUndoAnalyzer.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 

#import <Foundation/Foundation.h>
#import "PSDocumentChangeVisitor.h"

@interface PSReplayUndoAnalyzer : NSObject

- (NSArray *) changesWithoutUndos;
- (NSSet *) undone;
- (void) visitUndo:(NSData *)undo;
- (void) visitRedo:(NSData *)redo;
- (void) visitClearUndoStack:(NSData *)clear;
- (void) visitOther:(NSData *)change;

@end
