//
//  PSColorSquare.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class PSColor;
@class PSColorIndicator;
@class PSShader;

@interface PSColorSquare : UIControl {
    // the pixel dimensions of the backbuffer
    GLint               backingWidth;
    GLint               backingHeight;
    
    GLuint              colorRenderbuffer;
    GLuint              defaultFramebuffer;
    
    PSColorIndicator    *indicator_;
}

@property (nonatomic) EAGLContext *context;
@property (nonatomic, strong) PSColor *color;
@property (nonatomic, readonly) float saturation;
@property (nonatomic, readonly) float brightness;
@property (nonatomic, assign) GLuint quadVAO;
@property (nonatomic, assign) GLuint quadVBO;
@property (nonatomic) PSShader *colorShader;

@end
