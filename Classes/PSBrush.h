//
//  PSBrush.h
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
#import "PSCoding.h"
#import "PSProperty.h"
#import "PSStampGenerator.h"

@interface PSBrush : NSObject <NSCopying, PSCoding, WDPropertyDelegate, WDGeneratorDelegate> {
@private
}

@property (nonatomic, strong) PSStampGenerator *generator;
@property (nonatomic) UIImage *noise;

@property (nonatomic) PSProperty *weight;             // [1.0, 512.0] -- pixels
@property (nonatomic) PSProperty *intensity;          // [0.0, 1.0]

@property (nonatomic) PSProperty *angle;              // [0.0, 1.0];
@property (nonatomic) PSProperty *spacing;            // [0.01, 2.0] -- percentage of brush width
@property (nonatomic) PSProperty *rotationalScatter;  // [0.0, 1.0]
@property (nonatomic) PSProperty *positionalScatter;  // [0.0, 1.0]

@property (nonatomic) PSProperty *angleDynamics;     // [-1.0, 1.0]
@property (nonatomic) PSProperty *weightDynamics;     // [-1.0, 1.0]
@property (nonatomic) PSProperty *intensityDynamics;  // [-1.0, 1.0]

@property (nonatomic) UIImage *strokePreview;
@property (nonatomic, readonly) float radius;

@property (nonatomic) NSString *uuid;

+ (PSBrush *) randomBrush;

+ (PSBrush *) brushWithGenerator:(PSStampGenerator *)generator;
- (id) initWithGenerator:(PSStampGenerator *)generator;

- (UIImage *) previewImageWithSize:(CGSize)size;

- (NSUInteger) numberOfPropertyGroups;
- (NSArray *) propertiesForGroupAtIndex:(NSUInteger)ix;
- (NSArray *) allProperties;

- (void) restoreDefaults;

@end

extern NSString *PSBrushPropertyChanged;
extern NSString *PSBrushGeneratorChanged;
extern NSString *PSBrushGeneratorReplaced;
