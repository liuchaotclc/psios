//
//  PSTimePenCountView.m
//  PSIos
//
//  Created by liuchao on 2019/10/21.
//  Copyright © 2019 Taptrix, Inc. All rights reserved.
//
#import "PSTimePenCountView.h"

#define kWDActionNameFadeDelay          0.666f
#define kWDActionNameFadeOutDuration    0.2f

@implementation PSTimePenCountView

@synthesize timeLabel;
@synthesize penCountLabel;
@synthesize timeLabelDesc;
@synthesize penCountLabelDesc;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    self.opaque = NO;
    self.autoresizesSubviews = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    frame = CGRectMake(40, 0 , 40, self.bounds.size.height);
    self.timeLabelDesc = [[UILabel alloc] initWithFrame:frame];
    timeLabelDesc.font = [UIFont boldSystemFontOfSize:16.0f];
    timeLabelDesc.textAlignment = NSTextAlignmentCenter;
    timeLabelDesc.backgroundColor = nil;
    timeLabelDesc.opaque = NO;
    timeLabelDesc.text = @"时间:";
    timeLabelDesc.textColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
    [self addSubview:timeLabelDesc];
    
    frame = CGRectMake(80, 0 , 100, self.bounds.size.height);
       self.timeLabel = [[UILabel alloc] initWithFrame:frame];
       timeLabel.font = [UIFont boldSystemFontOfSize:16.0f];
       timeLabel.textAlignment = NSTextAlignmentLeft;
       timeLabel.backgroundColor = nil;
       timeLabel.opaque = NO;
       timeLabel.text = @"00:00:00";
       timeLabel.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0];
       [self addSubview:timeLabel];
    
    
    frame = CGRectMake(180, 0 , 40, self.bounds.size.height);
    self.penCountLabelDesc = [[UILabel alloc] initWithFrame:frame];
    penCountLabelDesc.font = [UIFont systemFontOfSize:16.0f];
    penCountLabelDesc.textAlignment = NSTextAlignmentCenter;
    penCountLabelDesc.backgroundColor = nil;
    penCountLabelDesc.opaque = NO;
    penCountLabelDesc.text = @"笔数:";
    penCountLabelDesc.textColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
    penCountLabelDesc.adjustsFontSizeToFitWidth = YES;
    [self addSubview:penCountLabelDesc];
    
    frame = CGRectMake(220, 0 , 50, self.bounds.size.height);
          self.penCountLabel = [[UILabel alloc] initWithFrame:frame];
          penCountLabel.font = [UIFont boldSystemFontOfSize:16.0f];
          penCountLabel.textAlignment = NSTextAlignmentCenter;
          penCountLabel.backgroundColor = nil;
          penCountLabel.opaque = NO;
          penCountLabel.text = @"0";
          penCountLabel.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0];
          [self addSubview:penCountLabel];
    
    return self;
}

- (void) setTime:(NSString *)time
{
    timeLabel.text = time;
}

- (void) setpenCount:(NSString *)penCount
{
    penCountLabel.text = penCount;
}

@end
