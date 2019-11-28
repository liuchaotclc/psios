//
//  PSActiveState.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@class PSBrush;
@class PSColor;
@class PSStampGenerator;
@class PSTool;

@interface PSActiveState : NSObject {
    NSMutableDictionary     *swatches_;
    NSMutableArray          *canonicalGenerators_;
}

@property (nonatomic, readonly) NSString *deviceID;
@property (nonatomic, weak) PSTool *activeTool;
@property (nonatomic) PSColor *paintColor;
@property (nonatomic) NSMutableArray *historyColors;
@property (nonatomic) NSMutableArray *commonColors;
@property (nonatomic) NSMutableArray *collectColors;
@property (nonatomic, readonly) PSBrush *brush;
@property (nonatomic, readonly) BOOL eraseMode;
@property (nonatomic, readonly) NSArray *tools;
@property (nonatomic, readonly) NSUInteger brushesCount;
@property (weak, nonatomic, readonly) NSArray *stampClasses;
@property (nonatomic, readonly) NSMutableArray *canonicalGenerators;
@property (nonatomic) NSMutableArray *brushes;
- (PSColor *) defaultPaintColor;
+ (PSActiveState *) sharedInstance;

- (PSColor *) swatchAtIndex:(NSUInteger)index;
- (void) setSwatch:(PSColor *)color atIndex:(NSUInteger)index;

- (PSBrush *) brushAtIndex:(NSUInteger)index;
- (PSBrush *) brushWithID:(NSString *)uuid;
- (NSUInteger) indexOfBrush:(PSBrush *)brush;
- (NSUInteger) indexOfActiveBrush;

- (void) saveBrushes;
- (void) saveHistoryColor;
- (void) addBrush:(PSBrush *)brush;
- (void) addHistoryColor:(PSColor *)color;
- (void) addCollectColor:(PSColor *)color;
- (void) addTemporaryBrush:(PSBrush *)brush;
- (BOOL) canDeleteBrush;
- (void) deleteActiveBrush;

- (void) moveBrushAtIndex:(NSUInteger)origin toIndex:(NSUInteger)dest;

- (void) selectBrushAtIndex:(NSUInteger)index;

- (void) setCanonicalGenerator:(PSStampGenerator *)aGenerator;
- (NSUInteger) indexForGeneratorClass:(Class)class;

- (void) resetActiveTool;

@end

// notifications
extern NSString *WDActiveToolDidChange;
extern NSString *WDActivePaintColorDidChange;

extern NSString *WDActiveBrushDidChange;
extern NSString *WDBrushAddedNotification;
extern NSString *WDBrushDeletedNotification;

