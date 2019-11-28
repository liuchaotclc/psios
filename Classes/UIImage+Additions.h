//
//  UIImage+Additions.h
//  PSIos
//
//

#import <UIKit/UIKit.h>

@interface UIImage (WDAdditions)

+ (UIImage *) relevantImageNamed:(NSString *)imageName;

- (void) drawToFillRect:(CGRect)bounds;

- (UIImage *) rotatedImage:(int)rotation;

- (UIImage *) downsampleWithMaxDimension:(float)constraint;

- (UIImage *) JPEGify:(float)compressionFactor;

- (BOOL) hasAlpha;
- (BOOL) reallyHasAlpha;

@end
