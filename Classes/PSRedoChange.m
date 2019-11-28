//
//  PSRedoChange.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 

#import "PSDocumentChangeVisitor.h"
#import "PSPainting.h"
#import "PSRedoChange.h"

@implementation PSRedoChange

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    return [painting.undoManager canRedo];
}

- (void) endAnimation:(PSPainting *)painting
{
    if ([painting.undoManager canRedo]) {
        [painting.undoManager redo];
    }
}

- (void) accept:(id<PSDocumentChangeVisitor>)visitor
{
    [visitor visitRedo:self];
}

+ (PSRedoChange *) redoChange
{
    return [[PSRedoChange alloc] init];
}

@end
