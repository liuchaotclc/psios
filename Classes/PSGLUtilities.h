#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

void PSGLBuildQuadForRect(CGRect rect, CGAffineTransform transform, GLuint *quadVAO, GLuint *quadVBO);
void PSGLRenderInRect(CGRect rect, CGAffineTransform transform);
