//
//  PSActivity.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    WDActivityTypeDownload,
    WDActivityTypeUpload,
    WDActivityTypeImport,
    WDActivityTypeExport,
} WDActivityType;

@interface PSActivity : NSObject

@property (nonatomic, assign) WDActivityType type;
@property (nonatomic) NSString *filePath;
@property (nonatomic, assign) float progress;
@property (weak, nonatomic, readonly) NSString *title;

+ (PSActivity *) activityWithFilePath:(NSString *)title type:(WDActivityType)type;
- (id) initWithFilePath:(NSString *)aFilePath type:(WDActivityType)aType;

@end
