//
//  PSGLRegion.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@protocol WDGLRegionDelegate;

@interface PSGLRegion : NSObject

@property (nonatomic) CAEAGLLayer *layer;
@property (nonatomic) GLuint renderbuffer;
@property (nonatomic) GLuint framebuffer;
@property (nonatomic) GLuint stencilBuffer;
@property (nonatomic) GLint width;
@property (nonatomic) GLint height;

@property (nonatomic, weak) EAGLContext *context;
@property (nonatomic, weak) id<WDGLRegionDelegate> delegate;

+ (PSGLRegion *) regionWithContext:(EAGLContext *)context andLayer:(CAEAGLLayer *)layer;
- (id) initWithContext:(EAGLContext *)context andLayer:(CAEAGLLayer *)layer;
- (void) freeGLResources;

- (BOOL) resize;
- (void) present;

@end

