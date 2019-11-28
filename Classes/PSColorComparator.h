//
//  PSColorComparator.h
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
#import <UIKit/UIKit.h>
#import "PSColorSourceView.h"

@class PSColor;
@class PSColorWell;

@protocol WDColorComparatorDragDestination;

@interface PSColorComparator : PSColorSourceView {
    CGRect  leftCircle_;
    CGRect  rightCircle_;
}

@property (nonatomic, assign) SEL action;
@property (nonatomic, weak) id target;
@property (nonatomic) PSColor *initialColor;
@property (nonatomic) PSColor *currentColor;
@property (nonatomic, weak) PSColor *tappedColor;


@end
