//
//  PSActiveState.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "NSArray+Additions.h"

#import "PSActiveState.h"
#import "PSBrush.h"
#import "PSCoder.h"
#import "PSColor.h"
#import "PSEraserTool.h"
#import "PSJSONCoder.h"
#import "PSStylusManager.h"
#import "PSUtilities.h"

#import "PSBristleGenerator.h"
#import "PSCirclesGenerator.h"
#import "PSCrossHatchGenerator.h"
#import "PSMosaicGenerator.h"
#import "PSRoundGenerator.h"
#import "PSSquareBristleGenerator.h"
#import "PSVerticalBristleGenerator.h"
#import "PSPolygonGenerator.h"
#import "PSRectGenerator.h"
#import "PSStarGenerator.h"
#import "PSSpiralGenerator.h"
#import "PSZigZagGenerator.h"
#import "PSSplatGenerator.h"
#import "PSSplotchGenerator.h"

NSString *WDActiveToolDidChange = @"WDActiveToolDidChange";
NSString *WDActivePaintColorDidChange = @"WDActivePaintColorDidChange";
NSString *WDActiveBrushDidChange = @"WDActiveBrushDidChange";

NSString *WDBrushAddedNotification = @"WDBrushAddedNotification";
NSString *WDBrushDeletedNotification = @"WDBrushDeletedNotification";

static NSString *WDBrushesKey = @"WDBrushesKey";
static NSString *WDDeviceIdKey = @"WDDeviceIdKey";
static NSString *WDPaintColorKey = @"WDPaintColorKey";
static NSString *WDSwatchKey = @"WDSwatchKey";



@implementation PSActiveState {
    NSMutableDictionary *brushMap_;
    PSBrush *paintBrush;
    PSBrush *eraseBrush;
}

@synthesize activeTool = activeTool_;
@synthesize deviceID = deviceID_;
@synthesize paintColor = paintColor_;
@synthesize tools = tools_;
//@synthesize brushes = brushes_;

+ (PSActiveState *) sharedInstance
{
    static PSActiveState *toolManager_ = nil;
    
    if (!toolManager_) {
        toolManager_ = [[PSActiveState alloc] init];
    }
    
    return toolManager_;
}

- (id) init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.historyColors = [NSMutableArray array];
    self.commonColors = [NSMutableArray array];
    self.collectColors = [NSMutableArray array];
    
    // Configure swatches
    NSData *archivedSwatches = [defaults objectForKey:WDSwatchKey];
    if (archivedSwatches) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:archivedSwatches options:0 error:&error];
        if (json) {
            PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:nil];
            swatches_ = [coder reconstruct:json binary:nil];
        }
    }
    if (!swatches_) {
        // swatches were either undefined or could not be unarchived
        swatches_ = [[NSMutableDictionary alloc] init];
        
        // add some default swatches        
        int total = 0;
        [self setSwatch:[PSColor colorWithHue:(180.0f / 360) saturation:0.21f brightness:0.56f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(138.0f / 360) saturation:0.36f brightness:0.71f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(101.0f / 360) saturation:0.38f brightness:0.49f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(215.0f / 360) saturation:0.34f brightness:0.87f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(207.0f / 360) saturation:0.90f brightness:0.64f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(229.0f / 360) saturation:0.59f brightness:0.45f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(331.0f / 360) saturation:0.28f brightness:0.51f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(44.0f / 360) saturation:0.77f brightness:0.85f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(15.0f / 360) saturation:0.39f brightness:0.98f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(84.0f / 360) saturation:0.15f brightness:0.9f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(59.0f / 360) saturation:0.27f brightness:0.99f alpha:1] atIndex:total]; total++;
        [self setSwatch:[PSColor colorWithHue:(51.0f / 360) saturation:0.08f brightness:0.96f alpha:1] atIndex:total]; total++;
        
        for (int i = 0; i <= 4; i++) {
            float w = i; w /= 4.0f;
            [self setSwatch:[PSColor colorWithWhite:w alpha:1.0] atIndex:total]; total++;
        }
    }
    
    {
        [self.commonColors insertObject:[PSColor colorWithHue:(0.0f / 360) saturation:0.0f brightness:0.0f alpha:1] atIndex:0];
        [self.commonColors insertObject:[PSColor colorWithHue:(87.0f / 360) saturation:0.80f brightness:0.94f alpha:1] atIndex:1];
        [self.commonColors insertObject:[PSColor colorWithHue:(0.0f / 360) saturation:0.0f brightness:0.84f alpha:1] atIndex:2];
        
        [self.commonColors insertObject:[PSColor colorWithHue:(0.0f / 360) saturation:0.0f brightness:1.0f alpha:1] atIndex:3];
        [self.commonColors insertObject:[PSColor colorWithHue:(32.0f / 360) saturation:0.78f brightness:0.95f alpha:1] atIndex:4];
        [self.commonColors insertObject:[PSColor colorWithHue:(200.0f / 360) saturation:0.89f brightness:0.70f alpha:1] atIndex:5];
        
        [self.commonColors insertObject:[PSColor colorWithHue:(352.0f / 360) saturation:0.95f brightness:0.84f alpha:1] atIndex:6];
        [self.commonColors insertObject:[PSColor colorWithHue:(270.0f / 360) saturation:0.48f brightness:0.99f alpha:1] atIndex:7];
        [self.commonColors insertObject:[PSColor colorWithHue:(353.0f / 360) saturation:0.45f brightness:0.92f alpha:1] atIndex:8];
        
        [self.commonColors insertObject:[PSColor colorWithHue:(59.0f / 360) saturation:0.78f brightness:1.0f alpha:1] atIndex:9];
        [self.commonColors insertObject:[PSColor colorWithHue:(234.0f / 360) saturation:0.96f brightness:0.98f alpha:1] atIndex:10];
        [self.commonColors insertObject:[PSColor colorWithHue:(59.0f / 360) saturation:0.83f brightness:0.90f alpha:1] atIndex:11];
        
        [self.commonColors insertObject:[PSColor colorWithHue:(180.0f / 360) saturation:0.83f brightness:1.0f alpha:1] atIndex:12];
        [self.commonColors insertObject:[PSColor colorWithHue:(86.0f / 360) saturation:0.84f brightness:0.47f alpha:1] atIndex:13];
        [self.commonColors insertObject:[PSColor colorWithHue:(179.0f / 360) saturation:0.87f brightness:0.50f alpha:1] atIndex:14];
    }
    
    // configure paint color
    NSDictionary *colorDict = [defaults objectForKey:WDPaintColorKey];
    paintColor_ = colorDict ? [PSColor colorWithDictionary:colorDict] : [self defaultPaintColor];

    
    // use a unique deviceID since we are not allowed to use the one on UIDevice
    deviceID_ = [defaults objectForKey:WDDeviceIdKey];
    if (!deviceID_) {
        deviceID_ = generateUUID();
        [defaults setObject:deviceID_ forKey:WDDeviceIdKey];
    }
    
    [self performSelector:@selector(configureBrushes) withObject:nil afterDelay:0];
    
    self.activeTool = (self.tools)[0];
    
    brushMap_ = [[NSMutableDictionary alloc] init];
    
    return self;
}

#pragma mark - Paint Color

- (PSColor *) defaultPaintColor
{
    return [PSColor colorWithHue:(138.0f / 360) saturation:0.36f brightness:0.71f alpha:1];
}

- (void) setPaintColor:(PSColor *)paintColor
{
    paintColor_ = paintColor;
    
    [[NSUserDefaults standardUserDefaults] setObject:[paintColor_ dictionary] forKey:WDPaintColorKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:WDActivePaintColorDidChange object:nil userInfo:nil];
    
    [[PSStylusManager sharedStylusManager] setPaintColor:paintColor.UIColor];
    
    [self setActiveTool:tools_[0]];
}

#pragma mark -  Tools

- (NSArray *) tools
{
    if (!tools_) {
        tools_ = @[[PSFreehandTool tool],
                  [PSEraserTool tool]];
    }
    
    return tools_;
}

- (void) setActiveTool:(PSTool *)activeTool
{
    if (activeTool == activeTool_) {
        return;
    }
    
    [activeTool_ deactivated];
    activeTool_ = activeTool;
    
    [activeTool_ activated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WDActiveToolDidChange object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:WDActiveBrushDidChange object:nil userInfo:nil];
}

#pragma mark - Swatches

- (void) saveSwatches
{
    PSJSONCoder *coder = [[PSJSONCoder alloc] init];
    [coder encodeDictionary:swatches_ forKey:nil];
    NSData *swatchData = [coder jsonData];
    [[NSUserDefaults standardUserDefaults] setObject:swatchData forKey:WDSwatchKey];
}

- (PSColor *) swatchAtIndex:(NSUInteger)index
{
    return swatches_[[@(index) stringValue]];
}

- (void) setSwatch:(PSColor *)color atIndex:(NSUInteger)index
{
    NSString *key = [@(index) stringValue];
    
    if (!color) {
        [swatches_ removeObjectForKey:key];
    } else {
        swatches_[key] = color;
    }
    
    [self saveSwatches];
}

#pragma mark - Brushes

- (BOOL) eraseMode
{
    return [activeTool_ isKindOfClass:[PSEraserTool class]];
}

- (PSBrush *) brush
{
    PSBrush *b = self.eraseMode ? eraseBrush : paintBrush;
    if (b) {
        return b;
    } else {
        if (self.eraseMode) {
            b = eraseBrush = paintBrush;
        } else {
            b = paintBrush = eraseBrush;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:WDActiveBrushDidChange object:nil userInfo:nil];
    }
    return b;
}

- (void) mapBrushes
{
    [self.brushes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PSBrush *brush = obj;
        brushMap_[brush.uuid] = brush;
    }];
}

- (void) saveBrushes
{
    PSJSONCoder *coder = [[PSJSONCoder alloc] init];
    [coder encodeArray:self.brushes forKey:nil];
    NSData *brushData = [coder jsonData];
    [[NSUserDefaults standardUserDefaults] setObject:brushData forKey:@"brushes"];
    [self mapBrushes];
    NSInteger brushIndex = [self.brushes indexOfObjectIdenticalTo:paintBrush];
    [[NSUserDefaults standardUserDefaults] setObject:@(brushIndex) forKey:@"brush"];
    NSInteger eraserIndex = [self.brushes indexOfObjectIdenticalTo:eraseBrush];
    [[NSUserDefaults standardUserDefaults] setObject:@(eraserIndex) forKey:@"eraser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void) saveHistoryColor
{
    PSJSONCoder *colorCoder = [[PSJSONCoder alloc] init];
    [colorCoder encodeArray:self.historyColors forKey:nil];
    NSData *historyColorsData = [colorCoder jsonData];
    [[NSUserDefaults standardUserDefaults] setObject:historyColorsData forKey:@"history_colors"];
}

- (void) initializeBrushes
{
    // configure brushes (temporary setup)
    self.brushes = [NSMutableArray array];
    for (int i = 0; i < 12; i++) {
        [self.brushes addObject:[PSBrush randomBrush]];
    }
    [self saveBrushes];
}

- (void) configureBrushes
{
    NSData *brushData = [[NSUserDefaults standardUserDefaults] objectForKey:@"brushes"];
    
    if (!brushData) {
        // load default brushes
        brushData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default_brushes" ofType:@"json"]];
    }
    
    if (brushData) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:brushData options:0 error:&error];
        if (json) {
            PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:nil];
            self.brushes = [coder reconstruct:json binary:nil];
        } else {
            WDLog(@"Error loading saved brushes: %@", error);
            [self initializeBrushes];
        }
    } else {
        // create some random ones
        [self initializeBrushes];
    }
    
    //初始化历史颜色数据
    NSData *historyColorsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"history_colors"];
    if (historyColorsData) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:historyColorsData options:0 error:&error];
        if (json) {
            PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:nil];
            self.historyColors = [coder reconstruct:json binary:nil];
        } else {
            WDLog(@"Error loading saved brushes: %@", error);
            [self initializeBrushes];
        }
    }
    
    //初始化搜藏颜色数据
    NSData *collectColorsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"collect_colors"];
    if (collectColorsData) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:collectColorsData options:0 error:&error];
        if (json) {
            PSJSONCoder *coder = [[PSJSONCoder alloc] initWithProgress:nil];
            self.collectColors = [coder reconstruct:json binary:nil];
        } else {
            WDLog(@"Error loading saved brushes: %@", error);
            [self initializeBrushes];
        }
    }
    
    [self mapBrushes];
    
    int index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"brush"] intValue];
    if (index < 0 || index >= self.brushes.count) {
        index = 0;
    }
    paintBrush = (self.brushes)[index];

    index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"eraser"] intValue];
    if (index < 0 || index >= self.brushes.count) {
        index = 0;
    }
    eraseBrush = (self.brushes)[index];
}

- (PSBrush *) brushAtIndex:(NSUInteger)index
{
    if (index > self.brushes.count) {
        return nil;
    }
    
    return (self.brushes)[index];
}

- (PSBrush *) brushWithID:(NSString *)uuid
{
    PSBrush *brush = brushMap_[uuid];
    if (!brush) {
        WDLog(@"ERROR: Brush not found: %@", uuid);
        brush = [self brushAtIndex:0];
    }
    return brush;
}

- (NSUInteger) indexOfBrush:(PSBrush *)brush
{
    return [_brushes indexOfObjectIdenticalTo:brush];
}

- (NSUInteger) indexOfActiveBrush
{
    return [_brushes indexOfObjectIdenticalTo:self.brush];
}

- (BOOL) canDeleteBrush
{
    return (_brushes.count > 1);
}

- (void) deleteActiveBrush
{
    if ([self canDeleteBrush]) {
        NSUInteger index = self.indexOfActiveBrush;
        
        [_brushes removeObjectIdenticalTo:self.brush];
        if (paintBrush == eraseBrush) {
            if (self.eraseMode) {
                paintBrush = nil;
            } else {
                eraseBrush = nil;
            }
        }
    
        NSDictionary *userInfo = @{@"index": @(index)};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WDBrushDeletedNotification
                                                            object:nil
                                                          userInfo:userInfo];
        
        index = WDClamp(0, _brushes.count - 1, index);
        [self selectBrushAtIndex:index];
    }
}

- (void) addBrush:(PSBrush *)brush
{
    NSUInteger index = [self indexOfActiveBrush];
    
    [_brushes insertObject:brush atIndex:index];
    
    NSDictionary *userInfo = @{@"brush": brush,
                              @"index": @(index)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WDBrushAddedNotification
                                                        object:nil
                                                      userInfo:userInfo];
    
    [self selectBrushAtIndex:index];
}

- (void) addHistoryColor:(PSColor *)color
{
    [self.historyColors insertObject:color atIndex:0];
    if (self.historyColors.count > 9){
        [self.historyColors removeLastObject];
    }
}

- (void) addCollectColor:(PSColor *)color
{
    [self.collectColors insertObject:color atIndex:0];
    if (self.collectColors.count > 9){
        [self.collectColors removeLastObject];
    }
    
    PSJSONCoder *colorCoder = [[PSJSONCoder alloc] init];
    [colorCoder encodeArray:self.collectColors forKey:nil];
    NSData *collectColorsData = [colorCoder jsonData];
    [[NSUserDefaults standardUserDefaults] setObject:collectColorsData forKey:@"collect_colors"];
    
}

- (void) addTemporaryBrush:(PSBrush *)brush
{
    brushMap_[brush.uuid] = brush;
}

- (void) moveBrushAtIndex:(NSUInteger)src toIndex:(NSUInteger)dst
{
    PSBrush *brush = _brushes[src];
    
    [_brushes removeObjectIdenticalTo:brush];
    [_brushes insertObject:brush atIndex:dst];
}

- (void) brushGeneratorChanged:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WDActiveBrushDidChange object:nil userInfo:nil];
}

- (void) brushGeneratorReplaced:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WDActiveBrushDidChange object:nil userInfo:nil];
}

- (void) selectBrushAtIndex:(NSUInteger)index
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    PSBrush *oldBrush = self.brush;
    PSBrush *newBrush = _brushes[index];
    if (oldBrush) {
        [nc removeObserver:self name:nil object:oldBrush];
    }

    if (self.eraseMode) {
        eraseBrush = newBrush;
    } else {
        paintBrush = newBrush;
    }
    
    [nc addObserver:self selector:@selector(brushGeneratorChanged:) name:PSBrushGeneratorChanged object:newBrush];
    [nc addObserver:self selector:@selector(brushGeneratorReplaced:) name:PSBrushGeneratorReplaced object:newBrush];
    
    [nc postNotificationName:WDActiveBrushDidChange object:nil userInfo:nil];
}

- (NSUInteger) brushesCount
{
    return _brushes.count;
}

#pragma mark - Generators

- (NSArray *) stampClasses
{
    static NSArray *classes_ = nil;
    
    if (!classes_) {
//        classes_ = @[[WDBristleGenerator class],
//                    [WDRoundGenerator class],
//                    [WDSplatGenerator class],
//                    [WDSplotchGenerator class],
//                    [WDZigZagGenerator class],
//                    [WDCirclesGenerator class],
//                    [WDSpiralGenerator class],
//                    [WDCrossHatchGenerator class],
//                    [WDVerticalBristleGenerator class],
//                    [WDMosaicGenerator class],
//                    [WDSquareBristleGenerator class],
//                    [WDPolygonGenerator class],
//                    [WDStarGenerator class],
//                    [WDRectGenerator class]];
        
        classes_ = @[
                           [PSRoundGenerator class],
       [PSRectGenerator class] ];
        
    }
    
    return classes_;
}

- (NSArray *) canonicalGenerators
{
    if (!canonicalGenerators_) {
        NSArray *result = [[self stampClasses] map:^id(id obj) {
            PSStampGenerator *gen = [obj generator];
            [gen randomize];
            return gen;
        }];
        
        canonicalGenerators_ = [result mutableCopy];
    }
    
    return canonicalGenerators_;
}

- (void) setCanonicalGenerator:(PSStampGenerator *)aGenerator
{
    int ix = 0;
    
    for (PSStampGenerator *gen in self.canonicalGenerators) {
        if ([gen class] == [aGenerator class]) {
            break;
        }
        ix++;
    }
    
    if (![aGenerator isEqual:canonicalGenerators_[ix]]) {
        canonicalGenerators_[ix] = [aGenerator copy];
    }
}

- (NSUInteger) indexForGeneratorClass:(Class)class
{
    return [[self stampClasses] indexOfObject:class];
}

- (void) resetActiveTool
{
    self.activeTool = tools_[0];
}

@end
