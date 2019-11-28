//
//  PSCanvas.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class PSColor;
@class PSCanvas;
@class PSCanvasController;
@class PSPainting;
@class PSEyedropper;
@class PSGLRegion;
@class PSLabel;
@class PSPath;
@class PSTransformOverlay;
@class PSTexture;

@interface PSCanvas : UIView <UIGestureRecognizerDelegate> {
@private
    // pinch gesture handling
    CGPoint                 correction_;
    NSUInteger              lastTouchCount_;
    float                   previousScale_;
    
    // managing the view scale and visible area
    float                   scale_;
    float                   trueViewScale_;
    CGPoint                 userSpacePivot_;
    CGPoint                 deviceSpacePivot_;
    CGAffineTransform       canvasTransform_;
    
    // adornments
    PSEyedropper            *eyedropper_;
    
    PSLabel                 *messageLabel_;
    NSTimer                 *messageTimer_;
    UIView                  *imageMessageView_;
    NSTimer                 *imageMessageTimer_;
    
    // Photo placement mode
    BOOL                    photoPlacementMode_;
    PSTransformOverlay      *transformOverlay_;
}

@property (nonatomic, weak) EAGLContext *context;

@property (nonatomic) PSPainting *painting;
@property (nonatomic, readonly) CGRect visibleRect;
@property (nonatomic, assign) float scale;
@property (nonatomic, readonly) float displayableScale;
@property (nonatomic, weak) PSCanvasController *controller;
@property (nonatomic, readonly) PSEyedropper *eyedropper;
@property (nonatomic, assign) BOOL gesturesDisabled;
@property (nonatomic, assign) BOOL isZooming;
@property (nonatomic, assign) BOOL interfaceWasHidden;

@property (nonatomic) PSGLRegion *mainRegion;
@property (nonatomic) UIImage *photo;
@property (nonatomic) PSTexture *photoTexture;
@property (nonatomic) CGAffineTransform photoTransform;
@property (nonatomic) CGAffineTransform rawPhotoTransform;
@property (nonatomic) CGAffineTransform layerTransform;
@property (nonatomic) CGAffineTransform rawLayerTransform;
@property (nonatomic, readonly) BOOL hasEverBeenScaledToFit;
@property (nonatomic) NSArray *shadowSegments;
@property (nonatomic) CGRect dirtyRect;
@property (nonatomic) BOOL currentlyPainting;

- (id) initWithPainting:(PSPainting *)painting;
- (void) drawView;
- (void) drawViewInRect:(CGRect)dirtyRect;
- (void) drawViewAtEndOfRunLoop;
- (void) cancelUpdate;

- (void) offsetByDelta:(CGPoint)delta;
- (void) scaleDocumentToFit:(BOOL)animated;

// displaying messages to the user
- (void) showImageMessage:(NSArray *)images;
- (void) showMessage:(NSString *)message;
- (void) showMessage:(NSString *)message autoHide:(BOOL)autoHide position:(CGPoint)position duration:(float)duration;
- (void) nixMessageLabel;

// eyedropper
- (PSColor *) colorAtPoint:(CGPoint)pt;
- (void) displayEyedropperAtPoint:(CGPoint)pt;
- (void) moveEyedropperToPoint:(CGPoint)pt;
- (void) dismissEyedropper;

- (void) resetUserSpacePivot;
- (void) resetDeviceSpacePivot;

- (void) updateFromSettings:(NSDictionary *)settings;
- (NSDictionary *) viewSettings;

- (CGPoint) convertPointToDocument:(CGPoint)pt;
- (CGPoint) convertPointFromDocument:(CGPoint)pt;

- (void) adjustForReplayScale:(float)scale;

@end

@interface PSCanvas (WDPlacePhotoMode)
- (void) beginPhotoPlacement:(UIImage *)image;
- (void) cancelPhotoPlacement;
- (void) placePhoto;
@end

@interface PSCanvas (WDLayerTransformMode)
- (void) beginLayerTransformation;
- (void) cancelLayerTransformation;
- (void) transformActiveLayer;
@end

extern NSString* WDGestureBeganNotification;
extern NSString* WDGestureEndedNotification;
