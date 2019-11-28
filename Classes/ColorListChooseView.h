//
//  ColorListChooseView.h
//  FCUICollectionView
//
//  Created by liuchao on 2019/10/25.
//  Copyright © 2019 fc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//创建协议
@protocol CollectionClickDelegate <NSObject>
- (void)onCollectionClick:( NSInteger)section rowNum:(NSInteger) row; //声明协议方法
@end

@interface ColorListChooseView : UIView
@property (nonatomic, weak)id<CollectionClickDelegate> delegate; //声明协议变量
-(void) reloadCollectionData;
@end

NS_ASSUME_NONNULL_END
