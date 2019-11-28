//
//  UIColor+Additions.h
//  Test
//
//

#import <UIKit/UIKit.h>

@interface UIColor (WDAdditions)

+ (UIColor *) randomColor:(BOOL)includeAlpha;

- (void) getHue:(float *)hue saturation:(float *)saturation brightness:(float *)brightness;

- (float) hue;
- (float) saturation;
- (float) brightness;

- (float) red;
- (float) green;
- (float) blue;

- (float) alpha;

- (void) openGLSet;
+ (UIColor *) saturatedRandomColor;

@end
