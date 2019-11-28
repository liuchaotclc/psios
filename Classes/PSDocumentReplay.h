//
//  PSDocumentReplay.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 

#import <Foundation/Foundation.h>

@class PSDocument;
@class PSPainting;

@protocol PSDocumentReplayDelegate <NSObject>

- (void) replayFinished;
- (void) replayError;

@end

@interface PSDocumentReplay : NSObject

@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, strong) PSPainting *painting;
@property (nonatomic) NSString *paintingName;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, weak) id<PSDocumentReplayDelegate> replayDelegate;
@property (nonatomic) int errorCount;
@property (nonatomic, assign) float scale;

- (id) initWithDocument:(PSDocument *)document includeUndos:(BOOL)undos scale:(float)scale;
- (void) play;
- (void) pause;
- (void) restart;
- (BOOL) isFinished;
- (BOOL) isPlaying;

@end
