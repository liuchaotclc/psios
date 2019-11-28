//
//  PSStylusManager.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  

#import <Foundation/Foundation.h>
// Pogo Connect (Blue Tiger)
#import "T1PogoManager.h"

typedef enum {
    WDNoStylus = 0,
    WDApplePencilStylus,
    WDPogoConnectStylus,
    WDMaxStylusTypes
} WDStylusType;

@interface PSStylusData : NSObject
@property (nonatomic) NSString *productName;  // required
@property (nonatomic) NSNumber *batteryLevel; // can be nil
@property (nonatomic) BOOL connected;
@property (nonatomic) T1PogoPen *pogoPen;
@property (nonatomic) WDStylusType type;
@end

@interface PSStylusManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic) T1PogoManager *pogoManager;
@property (nonatomic, readonly) NSUInteger numberOfStylusTypes;
@property (nonatomic) WDStylusType mode;

+ (PSStylusManager *) sharedStylusManager;

- (NSUInteger) numberOfStylusesForType:(WDStylusType)type;

- (float) pressureForTouch:(UITouch *)touch realPressue:(BOOL *)isRealPressure;

- (void) setPaintColor:(UIColor *)color;

@end

extern NSString *WDStylusPrimaryButtonPressedNotification;
extern NSString *WDStylusSecondaryButtonPressedNotification;

extern NSString *WDStylusDidConnectNotification;
extern NSString *WDStylusDidDisconnectNotification;


