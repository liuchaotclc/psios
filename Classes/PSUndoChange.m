//
//  PSUndoChange.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  

#import "PSDocumentChangeVisitor.h"
#import "PSPainting.h"
#import "PSUndoChange.h"

@implementation PSUndoChange

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    return [painting.undoManager canUndo];
}

- (void) endAnimation:(PSPainting *)painting
{
    if ([painting.undoManager canUndo]) {
        [painting.undoManager undo];
    }
}

- (void) accept:(id<PSDocumentChangeVisitor>)visitor
{
    [visitor visitUndo:self];
}

+ (PSUndoChange *) undoChange 
{
    return [[PSUndoChange alloc] init];
}

@end
