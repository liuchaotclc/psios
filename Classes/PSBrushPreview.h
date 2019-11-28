//
//  PSBrushPreview.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>

@class PSBrush;
@class PSPath;
@class PSShader;
@class PSTexture;

@interface PSBrushPreview : NSObject {
    GLfloat projection[16];
}

@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint defaultFramebuffer;

@property (nonatomic) PSTexture *brushTexture;

@property (nonatomic) PSShader *brushShader;
@property (nonatomic) PSBrush *brush;
@property (nonatomic, strong) PSPath *path;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) CGContextRef cgContext;
@property (nonatomic, assign) GLvoid *pixels;

+ (PSBrushPreview *) sharedInstance;
- (UIImage *) previewWithSize:(CGSize)size;

@end
