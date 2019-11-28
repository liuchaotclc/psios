//
//  PSTimePenCountView.h
//  PSIos
//

#ifndef WDTimePenCountView_h
#define WDTimePenCountView_h


#endif /* WDTimePenCountView_h */
#import <UIKit/UIKit.h>

@interface PSTimePenCountView : UIView
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UILabel *penCountLabel;
@property (nonatomic) UILabel *timeLabelDesc;
@property (nonatomic) UILabel *penCountLabelDesc;

- (void) setTime:(NSString *)time;
- (void) setpenCount:(NSString *)penCount;

@end
