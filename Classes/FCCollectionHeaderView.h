//
//  FCCollectionHeaderView.h
//  FCUICollectionView
//
#import <UIKit/UIKit.h>


@interface FCCollectionHeaderView : UICollectionReusableView
@property (strong, nonatomic) UILabel *textLabel;

//顶部视图的缓存池标示
+ (NSString *)headerViewIdentifier;
//获取顶部视图对象
+ (instancetype)headerViewWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;
@end


