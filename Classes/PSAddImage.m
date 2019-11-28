//
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "NSData+Additions.h"
#import "PSAddImage.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSLayer.h"
#import "PSTypedData.h"
#import "PSUtilities.h"
#import "UIImage+Additions.h"

@implementation PSAddImage

@synthesize imageData;
@synthesize imageHash;
@synthesize layerIndex;
@synthesize layerUUID;
@synthesize mediaType;
@synthesize mergeDown;
@synthesize transform;

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep 
{
    [super updateWithPSDecoder:decoder deep:deep];
    self.imageHash = [decoder decodeStringForKey:@"imageHash"];
    self.layerIndex = [decoder decodeIntegerForKey:@"index" defaultTo:NSUIntegerMax];
    self.layerUUID = [decoder decodeStringForKey:@"layer"];
    self.mergeDown = [decoder decodeBooleanForKey:@"mergeDown"];
    self.transform = [decoder decodeTransformForKey:@"transform"];
}

- (void) encodeWithPSCoder:(id <PSCoder>)coder deep:(BOOL)deep 
{
    [super encodeWithPSCoder:coder deep:deep];
    [coder encodeString:self.imageHash forKey:@"imageHash"];
    [coder encodeInteger:(int)self.layerIndex forKey:@"index"];
    [coder encodeString:self.layerUUID forKey:@"layer"];
    [coder encodeBoolean:self.mergeDown forKey:@"mergeDown"];
    [coder encodeTransform:self.transform forKey:@"transform"];
}

- (int) animationSteps:(PSPainting *)painting
{
    return (self.layerIndex != NSUIntegerMax || painting.layers.count > 1) ? 30 : 1;
}

- (void) beginAnimation:(PSPainting *)painting
{
    if (self.layerIndex != NSUIntegerMax) {
        // older versions did not add a layer automatically
        NSUInteger n = MIN(self.layerIndex, painting.layers.count);
        PSLayer *layer = [[PSLayer alloc] initWithUUID:self.layerUUID];
        layer.painting = painting;
        [painting insertLayer:layer atIndex:n];
        [painting activateLayerAtIndex:n];
    }

    if (!self.imageData) {
        // during replay, this data will have been loaded by the painting but not this object, yet
        PSTypedData *typedData = (painting.imageData)[self.imageHash];
        self.imageData = typedData.data;
    } else {
        // during recording/collaboration the imageData needs to go to the painting for storage
        PSTypedData *typedData = [PSTypedData data:self.imageData mediaType:self.mediaType compress:NO uuid:self.imageHash isSaved:kWDSaveStatusUnsaved];
        (painting.imageData)[self.imageHash] = typedData;
    }

    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    layer.opacity = 0;
    UIImage *image = [UIImage imageWithData:self.imageData];
    [layer renderImage:image transform:self.transform];
}

- (BOOL) applyToPaintingAnimated:(PSPainting *)painting step:(int)step of:(int)steps undoable:(BOOL)undoable
{
    PSLayer *layer = [painting layerWithUUID:self.layerUUID];
    if (layer) {
        layer.opacity = PSSineCurve(1.0f * step / steps);
        return YES;
    } else {
        return NO;
    }
}

- (void) endAnimation:(PSPainting *)painting
{
    if (self.mergeDown) {
        [painting mergeDown];
    }
    [[painting undoManager] setActionName:NSLocalizedString(@"Place Image", @"Place Image")];
}

- (void) scale:(float)scale
{
    // seems like this is scaling the translation portion twice, but it works...?   
    CGAffineTransform t = self.transform;
    self.transform = CGAffineTransformMake(t.a, t.b, t.c, t.d, t.tx * scale, t.ty * scale);
    self.transform = CGAffineTransformScale(self.transform, scale, scale);
}

- (NSString *) description 
{
    return [NSString stringWithFormat:@"%@ addedto:%@ hash:%@ transform:%@", [super description], self.layerUUID, self.imageHash,
            NSStringFromCGAffineTransform(self.transform)];
}

+ (PSAddImage *) addImage:(UIImage *)image atIndex:(NSUInteger)index mergeDown:(BOOL)mergeDown transform:(CGAffineTransform)transform;
{
    PSAddImage *notification = [[PSAddImage alloc] init];
    
    BOOL hasAlpha = [image hasAlpha];

    notification.imageData = hasAlpha ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, 0.9f);
    notification.imageHash = [PSSHA1DigestForData(notification.imageData) hexadecimalString];
    notification.layerIndex = index;
    notification.layerUUID = generateUUID();
    notification.mergeDown = mergeDown;
    notification.mediaType = hasAlpha ? @"image/png" : @"image/jpeg";
    notification.transform = transform;
    return notification;
}

@end
