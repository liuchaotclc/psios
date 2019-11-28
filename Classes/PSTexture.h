//
//  PSTexture.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
#import <Foundation/Foundation.h>

@interface PSTexture : NSObject {
    GLubyte     *data_;
	
	GLsizei     size_;
	GLuint      width_;
	GLuint      height_;
	GLenum      format_;
	GLenum      type_;
	GLuint      rowByteSize_;
	GLuint      unpackAlignment_;
}

@property (nonatomic, readonly) GLuint textureName;

+ (PSTexture *) textureWithCGImage:(CGImageRef)imageRef;
+ (PSTexture *) textureWithImage:(UIImage *)image;

+ (PSTexture *) alphaTextureWithCGImage:(CGImageRef)imageRef;
+ (PSTexture *) alphaTextureWithImage:(UIImage *)image;

- (id) initWithCGImage:(CGImageRef)imageRef forceRGB:(BOOL)forceRGB;

- (void) freeGLResources;

@end
