//
//  PSAppDelegate.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import <UIKit/UIKit.h>
//@class PSPaintingSizeController;
@class PSBrowserController;

@interface PSAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet UINavigationController *navigationController;
@property (nonatomic) IBOutlet PSBrowserController *browserController;
@property (nonatomic, copy) void (^performAfterDropboxLoginBlock)(void);

@end

