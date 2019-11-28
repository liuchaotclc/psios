//
//  PSShader.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 
#import <Foundation/Foundation.h>

@interface PSShader : NSObject

@property (nonatomic, readonly) GLuint program;
@property (nonatomic, readonly) NSDictionary *uniforms;


+ (PSShader *) shaderWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader
                      attributesNames:(NSArray *)attributeNames uniformNames:(NSArray *)uniformNames;

- (id) initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader
            attributesNames:(NSArray *)attributeNames uniformNames:(NSArray *)uniformNames;

- (GLuint) locationForUniform:(NSString *)uniform;

- (void) freeGLResources;

@end
