//
//  PSBrush.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "PSActiveState.h"
#import "PSBristleGenerator.h"
#import "PSBrush.h"
#import "PSBrushPreview.h"
#import "PSCoder.h"
#import "PSDecoder.h"
#import "PSUtilities.h"

NSString *PSBrushPropertyChanged = @"WDBrushPropertyChanged";
NSString *PSBrushGeneratorChanged = @"WDBrushGeneratorChanged";
NSString *PSBrushGeneratorReplaced = @"WDBrushGeneratorReplaced";

static NSString *PSGeneratorKey = @"generator";
static NSString *PSWeightKey = @"weight";
static NSString *PSIntensityKey = @"intensity";
static NSString *PSAngleKey = @"angle";
static NSString *PSSpacingKey = @"spacing";
static NSString *PSRotationalScatterKey = @"rotationalScatter";
static NSString *PSPositionalScatterKey = @"positionalScatter";
static NSString *PSAngleDynamicsKey = @"angleDynamics";
static NSString *PSWeightDynamicsKey = @"weightDynamics";
static NSString *PSIntensityDynamicsKey = @"intensityDynamics";
static NSString *PSUUIDKey = @"uuid";

@interface PSBrush ()
@property (nonatomic, assign) NSUInteger suppressNotifications;
@property (nonatomic) NSMutableSet *changedProperties;

- (void) suppressNotifications:(BOOL)flag;
@end

@implementation PSBrush

@synthesize generator;
@synthesize noise;

@synthesize weight;
@synthesize intensity;

@synthesize angle;
@synthesize spacing;
@synthesize rotationalScatter;
@synthesize positionalScatter;

@synthesize angleDynamics;
@synthesize weightDynamics;
@synthesize intensityDynamics;

@synthesize strokePreview;
@synthesize suppressNotifications;
@synthesize changedProperties;

@synthesize uuid = uuid_;

+ (PSBrush *) brushWithGenerator:(PSStampGenerator *)generator
{
    return [[[self class] alloc] initWithGenerator:generator];
}

+ (PSBrush *) randomBrush
{
    NSArray *generators = [[PSActiveState sharedInstance] canonicalGenerators];
    PSStampGenerator *generator = generators[PSRandomIntInRange(0, generators.count)];
    
    PSBrush *random = [PSBrush brushWithGenerator:[generator copy]];
    
    [generator randomize];
    [generator configureBrush:random];
    
    random.weight.value = PSRandomFloat() * 56 + 44;
    random.intensity.value = 0.15f;
    random.spacing.value = 0.02;
    
    return random;
}

- (id) copyWithZone:(NSZone *)zone
{
    PSStampGenerator *gen = [self.generator copy];
    PSBrush *copy = [[PSBrush alloc] initWithGenerator:gen];
    
    copy.angle.value = angle.value;
    copy.weight.value = weight.value;
    copy.intensity.value = intensity.value;
    copy.spacing.value = spacing.value;
    copy.rotationalScatter.value = rotationalScatter.value;
    copy.positionalScatter.value = positionalScatter.value;
    copy.angleDynamics.value = angleDynamics.value;
    copy.weightDynamics.value = weightDynamics.value;
    copy.intensityDynamics.value = intensityDynamics.value;
    
    copy.uuid = self.uuid;
    return copy;
}

- (BOOL) isEqual:(PSBrush *)object
{
    if (!object) {
        return NO;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    // in theory, if the uuid matches the rest should match too
    return ([self.uuid isEqualToString:object.uuid] &&
            [self.generator isEqual:object.generator] &&
            [[self allProperties] isEqual:[object allProperties]]);
}

- (NSUInteger) hash
{
    return self.uuid.hash;
}

- (void) suppressNotifications:(BOOL)flag
{
    suppressNotifications += flag ? 1 : (-1);
}

- (void) restoreDefaults
{
    self.changedProperties = [NSMutableSet set];
    
    [self suppressNotifications:YES];
    
    [[self generator] configureBrush:self];
    
    [self suppressNotifications:NO];
    
    if (changedProperties.count) {
        self.uuid = nil;
        self.strokePreview = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PSBrushPropertyChanged
                                                            object:self
                                                          userInfo:@{@"properties": changedProperties}];
    }
    
    self.changedProperties = nil;
}

- (void) buildProperties
{
    self.weight = [PSProperty property];
    weight.title = @"宽度";
    weight.conversionFactor = 1;
    weight.minimumValue = 1;
    weight.maximumValue = 512;
    weight.delegate = self;
    
    self.intensity = [PSProperty property];
    intensity.title = NSLocalizedString(@"Intensity", @"Intensity");
    intensity.delegate = self;
    
    self.angle = [PSProperty property];
    angle.title = NSLocalizedString(@"Angle", @"Angle");
    angle.maximumValue = 360;
    angle.conversionFactor = 1;
    angle.delegate = self;
    
    self.spacing = [PSProperty property];
    spacing.title = NSLocalizedString(@"Spacing", @"Spacing");
    spacing.minimumValue = 0.004f;
    spacing.maximumValue = 2.0f;
    spacing.percentage = YES;
    spacing.delegate = self;
    
    self.rotationalScatter = [PSProperty property];
    rotationalScatter.title = NSLocalizedString(@"Jitter", @"Jitter");
    rotationalScatter.delegate = self;
    
    self.positionalScatter = [PSProperty property];
    positionalScatter.title = NSLocalizedString(@"Scatter", @"Scatter");
    positionalScatter.delegate = self;
    
    self.angleDynamics = [PSProperty property];
    angleDynamics.title = NSLocalizedString(@"Dynamic Angle", @"Dynamic Angle");
    angleDynamics.minimumValue = -1.0f;
    angleDynamics.delegate = self;
    
    self.weightDynamics = [PSProperty property];
    weightDynamics.title = NSLocalizedString(@"Dynamic Weight", @"Dynamic Weight");
    weightDynamics.minimumValue = -1.0f;
    weightDynamics.delegate = self;
    
    self.intensityDynamics = [PSProperty property];
    intensityDynamics.title = NSLocalizedString(@"Dynamic Intensity", @"Dynamic Intensity");
    intensityDynamics.minimumValue = -1.0f;
    intensityDynamics.delegate = self;
}

- (id) initWithGenerator:(PSStampGenerator *)shapeGenerator
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.generator = shapeGenerator;
    generator.delegate = self;
    [self buildProperties];
    
    return self;
}


- (void) propertyChanged:(PSProperty *)property
{
    if (suppressNotifications == 0) {
        self.uuid = nil;
        self.strokePreview = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PSBrushPropertyChanged
                                                            object:self
                                                          userInfo:@{@"property": property}];
    } else {
        [changedProperties addObject:property];
    }
}

- (void) generatorChanged:(PSStampGenerator *)aGenerator
{
    self.uuid = nil;
    self.strokePreview = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PSBrushGeneratorChanged
                                                        object:self
                                                      userInfo:@{@"generator": aGenerator}];
}

- (void) setGenerator:(PSStampGenerator *)aGenerator
{
    generator = aGenerator;
    
    generator.delegate = self;
    
    self.uuid = nil;
    self.strokePreview = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PSBrushGeneratorReplaced
                                                        object:self
                                                      userInfo:@{@"generator": aGenerator}];
}

- (float) radius
{
    return self.weight.value / 2;
}

- (NSUInteger) numberOfPropertyGroups
{
    return 1;//[generator properties] ? 3 : 2;
}
             
- (NSArray *) allProperties
{
    return @[weight, intensity, angle, spacing, rotationalScatter, positionalScatter,
         angleDynamics, weightDynamics, intensityDynamics];
}

- (NSArray *) propertiesForGroupAtIndex:(NSUInteger)ix
{
    if ([generator properties] == nil) {
        ix++;
    }
    
    if (ix == 0) {
        // shape group
        return [generator properties];
    } else if (ix == 1) {
        // spacing group
        return @[intensity, angle, spacing, rotationalScatter, positionalScatter];
    } else if (ix == 2) {
        // dynamic group
        return @[angleDynamics, weightDynamics, intensityDynamics];
    }
    
    return nil;
}

- (void) setStrokePreview:(UIImage *)aStrokePreview
{
    strokePreview = aStrokePreview;
}

- (UIImage *) previewImageWithSize:(CGSize)size
{
    if (strokePreview && CGSizeEqualToSize(size, strokePreview.size)) {
        return strokePreview;
    }

    PSBrushPreview *preview = [PSBrushPreview sharedInstance];

    preview.brush = self;
    self.strokePreview = [preview previewWithSize:size];
    
    return strokePreview;
}

#pragma mark -
#pragma mark WDCoding

- (NSString *) uuid
{
    if (!uuid_) {
        uuid_ = generateUUID();
    }
    return uuid_;
}

- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep
{
    if (deep) {
        [coder encodeObject:self.generator forKey:PSGeneratorKey deep:deep];
    }
    [coder encodeString:self.uuid forKey:PSUUIDKey];
    [coder encodeFloat:self.weight.value forKey:PSWeightKey];
    [coder encodeFloat:self.intensity.value forKey:PSIntensityKey];
    [coder encodeFloat:self.angle.value forKey:PSAngleKey];
    [coder encodeFloat:self.spacing.value forKey:PSSpacingKey];
    [coder encodeFloat:self.rotationalScatter.value forKey:PSRotationalScatterKey];
    [coder encodeFloat:self.positionalScatter.value forKey:PSPositionalScatterKey];
    [coder encodeFloat:self.angleDynamics.value forKey:PSAngleDynamicsKey];
    [coder encodeFloat:self.weightDynamics.value forKey:PSWeightDynamicsKey];
    [coder encodeFloat:self.intensityDynamics.value forKey:PSIntensityDynamicsKey];
}

- (float) decodeValue:(NSString *)key fromDecoder:(id<PSDecoder>)decoder defaultTo:(float)deft
{
    float value = [decoder decodeFloatForKey:key defaultTo:NAN];
    if (isnan(value)) {
        // for legacy files
        PSProperty *old = [decoder decodeObjectForKey:([key isEqualToString:PSWeightKey] ? @"noise" : key)];
        return old ? old.value : deft;
    } else {
        return value;
    }
}

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep
{
    if (deep) {
        self.generator = [decoder decodeObjectForKey:PSGeneratorKey];
        self.generator.delegate = self;
        [self buildProperties];
    }
    self.weight.value = [self decodeValue:PSWeightKey fromDecoder:decoder defaultTo:self.weight.value];
    self.intensity.value = [self decodeValue:PSIntensityKey fromDecoder:decoder defaultTo:self.intensity.value];
    self.angle.value = [self decodeValue:PSAngleKey fromDecoder:decoder defaultTo:self.angle.value];
    self.spacing.value = [self decodeValue:PSSpacingKey fromDecoder:decoder defaultTo:self.spacing.value];
    self.rotationalScatter.value = [self decodeValue:PSRotationalScatterKey fromDecoder:decoder defaultTo:self.rotationalScatter.value];
    self.positionalScatter.value = [self decodeValue:PSPositionalScatterKey fromDecoder:decoder defaultTo:self.positionalScatter.value];
    self.angleDynamics.value = [self decodeValue:PSAngleDynamicsKey fromDecoder:decoder defaultTo:self.angleDynamics.value];
    self.weightDynamics.value = [self decodeValue:PSWeightDynamicsKey fromDecoder:decoder defaultTo:self.weightDynamics.value];
    self.intensityDynamics.value = [self decodeValue:PSIntensityDynamicsKey fromDecoder:decoder defaultTo:self.intensityDynamics.value];
    self.uuid = [decoder decodeStringForKey:PSUUIDKey];
}

@end
