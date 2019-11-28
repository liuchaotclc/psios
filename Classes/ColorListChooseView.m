//
//  ColorListChooseView.m
//  FCUICollectionView
//
//  Created by liuchao on 2019/10/25.
//  Copyright © 2019 fc. All rights reserved.
//

#import "ColorListChooseView.h"
#import "FCCollectionViewCell.h"
#import "FCCollectionHeaderView.h"
#import "PSActiveState.h"
#import "PSColor.h"

#define contentViewBgColor [UIColor colorWithRed:214.0f/255.0f green:214.0f/255.0f blue:214.0f/255.0 alpha:1]
#define viewBgColor [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:233.0f/255.0 alpha:1]

//屏幕宽和高
#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)


@interface ColorListChooseView ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;//容器视图

@end

@implementation ColorListChooseView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
        [self initCollectionView];
        
    }
    return self;
}

-(void)setUpUI{
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
}

-(void) reloadCollectionData{
    
    [self.collectionView reloadData];
}

//初始化容器视图
-(void)initCollectionView{
    CGFloat x=0;
    CGFloat y=0;
    CGFloat width=self.frame.size.width;
    CGFloat height=self.frame.size.height;
    //创建布局对象
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    //设置滚动方向为垂直滚动，说明方块是从左上到右下的布局排列方式
    layout.scrollDirection=UICollectionViewScrollDirectionVertical;
    //设置顶部视图和底部视图的大小，当滚动方向为垂直时，设置宽度无效，当滚动方向为水平时，设置高度无效
    layout.headerReferenceSize = CGSizeMake(100, 40);
//    layout.footerReferenceSize = CGSizeMake(100, 0);
    //创建容器视图
    UICollectionView *collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(x, y, width, height) collectionViewLayout:layout];
    collectionView.delegate=self;//设置代理
    collectionView.dataSource=self;//设置数据源
    collectionView.alwaysBounceVertical=FALSE;
    collectionView.bounces=FALSE;
    collectionView.backgroundColor = [UIColor whiteColor];//设置背景，默认为黑色

    //添加到主视图
    [self addSubview:collectionView];
    self.collectionView = collectionView;
   
    
    //注册容器视图中显示的方块视图
    [collectionView registerClass:[FCCollectionViewCell class] forCellWithReuseIdentifier:[FCCollectionViewCell cellIdentifier]];
    
    //注册容器视图中显示的顶部视图
    [collectionView registerClass:[FCCollectionHeaderView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:[FCCollectionHeaderView headerViewIdentifier]];
    
//    //注册容器视图中显示的底部视图
//    [collectionView registerClass:[FCCollectionFooterView class]
//       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
//              withReuseIdentifier:[FCCollectionFooterView footerViewIdentifier]];
    

}
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 3;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return [[PSActiveState sharedInstance].historyColors count];
            break;
         case 1:
             return [[PSActiveState sharedInstance].commonColors count];
            break;
          case 2:
            return [[PSActiveState sharedInstance].collectColors count];
            break;

        default:
            return 0;
            break;
    }
}
//设置方块的视图
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //获取cell视图，内部通过去缓存池中取，如果缓存池中没有，就自动创建一个新的cell
    FCCollectionViewCell *cell=[FCCollectionViewCell cellWithCollectionView:collectionView forIndexPath:indexPath];
    cell.contentView.backgroundColor=contentViewBgColor;
//    cell.textLabel.text = [NSString stringWithFormat:@"Cell %2ld",indexPath.row];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.backgroundColor = [[[PSActiveState sharedInstance].historyColors objectAtIndex:indexPath.row] UIColor];
//            cell.textLabel.backgroundColor = @(color);
            break;
            case 1:
            cell.textLabel.backgroundColor = [[[PSActiveState sharedInstance].commonColors objectAtIndex:indexPath.row] UIColor];
//            cell.textLabel.backgroundColor = [[WDActiveState sharedInstance].commonColors objectAtIndex:indexPath.row].UIColor;
                       break;
            case 2:
            cell.textLabel.backgroundColor = [[[PSActiveState sharedInstance].collectColors objectAtIndex:indexPath.row] UIColor];
//            cell.textLabel.backgroundColor = [[WDActiveState sharedInstance].collectColors objectAtIndex:indexPath.row].UIColor;
                       break;
            
        default:
            return 0;
    }
    return cell;
}
//设置顶部视图和底部视图
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        //获取顶部视图
        FCCollectionHeaderView *headerView=[FCCollectionHeaderView headerViewWithCollectionView:collectionView forIndexPath:indexPath];
        
        //设置顶部视图属性
        headerView.backgroundColor=[UIColor whiteColor];
        switch (indexPath.section) {
               case 0:
                headerView.textLabel.text = @"历史颜色";
                   break;
                case 1:
                    headerView.textLabel.text = @"常用颜色";
                   break;
                 case 2:
                  headerView.textLabel.text = @"收藏颜色";
                   break;

               default:
                   return 0;
                   break;
           }

        return headerView;
    }
    return nil;
}
#pragma mark - UICollectionViewDelegateFlowLayout
//设置各个方块的大小尺寸
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = 30;
    CGFloat height = 30;
    return CGSizeMake(width, height);
}
//设置每一组的上下左右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);

}
#pragma mark - UICollectionViewDelegate
//方块被选中会调用
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //当代理响应sendValue方法时，把_tx.text中的值传到VCA
    if (_delegate) {
        [_delegate onCollectionClick: indexPath.section rowNum:indexPath.row];
    }
}
//方块取消选中会调用
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"取消选择第%ld组，第%ld个方块",indexPath.section,indexPath.row);
    
     switch (indexPath.section) {
            case 0:
                [[PSActiveState sharedInstance] setPaintColor:[[PSActiveState sharedInstance].historyColors objectAtIndex:indexPath.row]];
    //            cell.textLabel.backgroundColor = @(color);
                break;
                case 1:
                [[PSActiveState sharedInstance] setPaintColor:[[PSActiveState sharedInstance].commonColors objectAtIndex:indexPath.row]];
    //            cell.textLabel.backgroundColor = [[WDActiveState sharedInstance].commonColors objectAtIndex:indexPath.row].UIColor;
                           break;
                case 2:
                [[PSActiveState sharedInstance] setPaintColor:[[PSActiveState sharedInstance].collectColors objectAtIndex:indexPath.row]];
    //            cell.textLabel.backgroundColor = [[WDActiveState sharedInstance].collectColors objectAtIndex:indexPath.row].UIColor;
                           break;
                
            default:
                return ;
        }
}

@end
