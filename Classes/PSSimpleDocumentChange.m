//
//  PSSimpleDocumentChange.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  

#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSDocumentChangeVisitor.h"
#import "PSSimpleDocumentChange.h"

@implementation PSSimpleDocumentChange

@synthesize changeIndex;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    self.changeIndex = [decoder decodeIntegerForKey:@"change-index"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [coder encodeInteger:self.changeIndex forKey:@"change-index"];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ #%d", [super description], self.changeIndex];
}

- (int) animationSteps:(PSPainting *)painting
{
    return 1;
}

- (void) beginAnimation:(PSPainting *)painting
{
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    return NO;
}

- (void) endAnimation:(PSPainting *)painting
{
}

- (void) accept:(id<PSDocumentChangeVisitor>)visitor
{
    [visitor visitGeneric:self];
}

- (void) scale:(float)scale
{
}

@end
