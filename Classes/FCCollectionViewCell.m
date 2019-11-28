//
//  FCCollectionViewCell.m
//  FCUICollectionView
//

#import "FCCollectionViewCell.h"

@implementation FCCollectionViewCell
//方块视图的缓存池标示
+(NSString *)cellIdentifier{
    static NSString *cellIdentifier = @"CollectionViewCellIdentifier";
    return cellIdentifier;
}
//获取方块视图对象
+(instancetype)cellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath{
    FCCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:[FCCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    return cell;
    
}
//注册了方块视图后，当缓存池中没有底部视图的对象时候，自动调用alloc/initWithFrame创建
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        UILabel *textLabel=[[UILabel alloc]init];
        CGFloat x=5;
        CGFloat y=5;
        CGFloat width=frame.size.width-10;
        CGFloat height=frame.size.height-10;
        textLabel.frame=CGRectMake(x, y, width, height);
        textLabel.numberOfLines=0;
        textLabel.textAlignment=NSTextAlignmentCenter;
        textLabel.font=[UIFont systemFontOfSize:15];
        textLabel.textColor=[UIColor whiteColor];
        [self.contentView addSubview:textLabel];
        self.textLabel=textLabel;
    }
    return self;
}
@end
