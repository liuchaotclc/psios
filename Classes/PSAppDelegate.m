//
//  PSAppDelegate.m
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSAppDelegate.h"
#import "PSBrowserController.h"
#import "PSColor.h"
#import "PSCanvasController.h"
#import "PSPaintingManager.h"
#import "PSPaintingSizeController.h"
#import "PSDocument.h"
#import "PSStylusManager.h"
//#import <Crashlytics/Crashlytics.h>

@implementation PSAppDelegate

@synthesize window;
@synthesize navigationController;
//@synthesize paintingSizeController;
@synthesize performAfterDropboxLoginBlock;

#pragma mark -
#pragma mark Application lifecycle

- (void) setupDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Defaults.plist"];
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:defaultPath]];
    
    [PSPaintingSizeController registerDefaults];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    
    [self setupDefaults];
    
    //[Crashlytics startWithAPIKey:@"xxxx"];
    _browserController = [[PSBrowserController alloc] initWithNibName:nil bundle:nil];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:_browserController];
    
    // set a good background color for the superview so that orientation changes don't look hideous
    window.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];

    // use this line to forget registered Pogo Connects
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"T1PogoManagerKnownPeripherals"];
    
    // create the shared stylus manager so it can set things up for the pressure pens
    [PSStylusManager sharedStylusManager];
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

@end
