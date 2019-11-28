//
//  PSDocumentChange
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//

#import "PSDocumentChange.h"
#import "PSPainting.h"

NSString *WDHistoryVersion = @"1.0.7";

NSString *WDDocumentChangedNotification = @"WDDocumentChangedNotification";
NSString *WDDocumentChangedNotificationChange = @"change";

void changeDocument(PSPainting *painting, id<PSDocumentChange> change) {
    change.changeIndex = ++painting.changeCount;
    NSDictionary *info = @{WDDocumentChangedNotificationChange: change};
    [[NSNotificationCenter defaultCenter] postNotificationName:WDDocumentChangedNotification object:painting userInfo:info];
}
