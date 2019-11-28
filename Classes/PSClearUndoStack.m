//
//  PSClearUndoStack.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSClearUndoStack.h"
#import "PSDocumentChangeVisitor.h"
#import "PSPainting.h"

@implementation PSClearUndoStack

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    return undoable;
}

- (void) endAnimation:(PSPainting *)painting
{
    if ([painting.undoManager isUndoRegistrationEnabled]) {
        // calling this when undo registration is disable will explode
        [painting.undoManager removeAllActions];
        [painting clearSelectionStack];
    }
}

- (void) accept:(id<PSDocumentChangeVisitor>)visitor
{
    [visitor visitClearUndoStack];
}

+ (PSClearUndoStack *) clearUndoStack 
{
    return [[PSClearUndoStack alloc] init];
}

@end
