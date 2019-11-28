//
//  PSChangeOpacity.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSChangeOpacity.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSLayer.h"

@implementation PSChangeOpacity {
    float startOpacity_;
}

@synthesize layerUUID;
@synthesize opacity;

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:self.layerUUID forKey:@"layer"];
    [coder encodeFloat:self.opacity forKey:@"opacity"];
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
    self.opacity = [decoder decodeFloatForKey:@"opacity"];
}

- (int) animationSteps:(PSPainting *)painting
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    return layer.visible ? fabsf(self.opacity - layer.opacity) / 0.03f : 0;
}

- (void) beginAnimation:(PSPainting *)painting
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    startOpacity_ = layer.opacity;
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    float progress = 1.0f * step / steps;
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    if (layer) {
        layer.opacity = startOpacity_ + (self.opacity - startOpacity_) * progress;
        return YES;
    } else {
        return NO;
    }
}

- (void) endAnimation:(PSPainting *)painting
{
    NSString *format = NSLocalizedString(@"Layer Opacity: %d%%", @"Layer Opacity: %d%%");
    [[painting undoManager] setActionName:[NSString stringWithFormat:format, (int) roundf(self.opacity * 100)]];
}


- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ layer:%@ opacity:%g", [super description], self.layerUUID, self.opacity];
}

+ (PSChangeOpacity *) changeOpacity:(float)opacity forLayer:(PSLayer *)layer
{
    PSChangeOpacity *change = [[PSChangeOpacity alloc] init];
    change.layerUUID = layer.uuid;
    change.opacity = opacity;
    return change;
}

@end
