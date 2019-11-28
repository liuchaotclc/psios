//
//  FCCollectionViewCell.h
//  FCUICollectionView
//
#import <UIKit/UIKit.h>


@interface FCCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *textLabel;
//方块视图的缓存池标示
+ (NSString *)cellIdentifier;
// 获取方块视图对象
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;
@end


