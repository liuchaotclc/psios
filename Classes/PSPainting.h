//
//  PSPainting.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "PSCoding.h"

@class PSBrush;
@class PSColor;
@class PSLayer;
@class PSPath;
@class PSRandom;
@class PSShader;
@class PSTexture;

@interface PSPainting : NSObject <PSCoding, NSCopying> {
    CGSize                  dimensions_;
    NSMutableArray          *layers_;
    
    NSUndoManager           *undoManager_;
    NSInteger               suppressNotifications_;
    
    GLfloat                 projection_[16];
    NSInteger               undoNesting_;
}

@property (nonatomic) CGSize dimensions;
@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) float aspectRatio;

@property (nonatomic, readonly) NSMutableArray *layers;
@property (weak, nonatomic, readonly) PSLayer *activeLayer;
@property (nonatomic, readonly) NSUInteger indexOfActiveLayer;

@property (nonatomic, strong) NSUndoManager *undoManager;

@property (nonatomic, readonly) BOOL isSuppressingNotifications;

@property (nonatomic, readonly) EAGLContext *context;
@property (nonatomic, readonly) GLuint quadVAO;
@property (nonatomic, readonly) GLuint quadVBO;
@property (nonatomic, readonly) GLuint reusableFramebuffer;
@property (nonatomic, readonly) NSDictionary *shaders;
@property (nonatomic, readonly) GLuint activePaintTexture;
@property (nonatomic) PSTexture *brushTexture;
@property (nonatomic) PSPath *activePath;
@property (nonatomic) NSCountedSet *brushes;
@property (nonatomic) NSMutableSet *undoneBrushes;
@property (nonatomic) NSCountedSet *colors;
@property (nonatomic, assign) NSUInteger strokeCount;
@property (nonatomic, strong) NSMutableDictionary *imageData;
@property (nonatomic) NSString *uuid;
@property (nonatomic) int changeCount;

@property (nonatomic) BOOL flattenMode;
@property (nonatomic, readonly) GLuint flattenedTexture;
@property (nonatomic) BOOL flattenedIsDirty;

+ (BOOL) supportsDeepColor;

- (id) initWithSize:(CGSize)size;

- (void) beginSuppressingNotifications;
- (void) endSuppressingNotifications;

- (void) activateLayerAtIndex:(NSUInteger)ix;
- (void) addLayer:(PSLayer *)layer;
- (void) removeLayer:(PSLayer *)layer;
- (void) deleteActiveLayer;
- (void) insertLayer:(PSLayer *)layer atIndex:(NSUInteger)index;
- (void) moveLayer:(PSLayer *)layer toIndex:(NSUInteger)dest;
- (void) mergeDown;
- (void) duplicateActiveLayer;
- (PSLayer *) layerWithUUID:(NSString *)uuid;

// these will draw the painting over a white background
- (UIImage *) image;
- (UIImage *) imageForCurrentState;
- (UIImage *) thumbnailImage;
- (CGSize) thumbnailSize;
- (NSData *) PNGRepresentation;
- (NSData *) JPEGRepresentation;

// returns data for the painting that includes uncommitted changes (like partially rendered strokes)
- (NSData *) PNGRepresentationForCurrentState;
- (NSData *) JPEGRepresentationForCurrentState;

- (UIImage *) imageWithSize:(CGSize)size backgroundColor:(UIColor *)color;
- (NSData *) imageDataWithSize:(CGSize)size backgroundColor:(UIColor *)color;

- (BOOL) canAddLayer;
- (BOOL) canDeleteLayer;
- (BOOL) canMergeDown;

- (void) reloadBrush;
- (void) preloadPaintTexture;

- (GLuint) generateTexture:(GLubyte *)pixels;
- (void) blit:(GLfloat *)proj;

- (CGRect) paintStroke:(PSPath *)path randomizer:(PSRandom *)randomizer clear:(BOOL)clearBuffer;
- (void) recordStroke:(PSPath *)path;

- (void) configureBrush:(PSBrush *)brush;

- (PSShader *) getShader:(NSString *)shaderKey;

// selection state management
- (void) clearSelectionStack;

@end

// Notifications
extern NSString *WDLayersReorderedNotification;
extern NSString *WDLayerAddedNotification;
extern NSString *WDLayerDeletedNotification;
extern NSString *WDActiveLayerChangedNotification;
extern NSString *WDStrokeAddedNotification;

