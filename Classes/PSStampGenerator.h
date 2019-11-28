//
//  PSStampGenerator.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
#import <Foundation/Foundation.h>
#import "PSCoding.h"
#import "PSProperty.h"

@class PSBrush;
@class PSPath;
@class PSRandom;

@protocol WDGeneratorDelegate;

@interface PSStampGenerator : NSObject<WDPropertyDelegate, NSCopying, PSCoding>

@property (nonatomic) unsigned int seed;
@property (nonatomic) CGSize size;
@property (nonatomic, readonly) float baseDimension;
@property (nonatomic, readonly) CGRect baseBounds;
@property (nonatomic, readonly) float scale;
@property (nonatomic) UIImage *stamp;
@property (nonatomic) UIImage *smallStamp;
@property (weak, nonatomic, readonly) UIImage *preview;
@property (weak, nonatomic, readonly) UIImage *bigPreview;
@property (weak, nonatomic, readonly) NSArray *properties;
@property (nonatomic, readonly) NSMutableDictionary *rawProperties;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic) UInt8 blurRadius;
@property (nonatomic, readonly) BOOL canRandomize;

@property (nonatomic, weak) id<WDGeneratorDelegate> delegate;

+ (PSStampGenerator *) generator;

- (void) resetSeed;
- (void) randomize;
- (void) buildProperties;

- (void) renderStamp:(CGContextRef)ctx randomizer:(PSRandom *)randomizer;
- (void) configureBrush:(PSBrush *)brush;

- (CGImageRef) radialFadeWithHardness:(float)hardness;
- (PSPath *) splatInRect:(CGRect)rect maxDeviation:(float)percentage randomizer:(PSRandom *)randomizer;
- (CGRect) randomRect:(PSRandom *)randomizer minPercentage:(float)minP maxPercentage:(float)maxP;

@end

@protocol WDGeneratorDelegate <NSObject>
- (void) generatorChanged:(PSStampGenerator *)generator;
@end
