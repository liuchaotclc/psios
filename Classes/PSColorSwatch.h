//
//  PSColorSwatch.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "PSUtilities.h"

@class PSColor;

@interface PSColorSwatch : UIControl {
    PSColor         *color_;
    UIRectCorner    corners_;
}

- (PSColor *) color;
- (void) setColor:(PSColor *)color;
- (void) setRoundedCorners:(UIRectCorner) corners;

@end
