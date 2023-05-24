//
//  XLCardSwitchFlowLayout.m
//  XLCardSwitchDemo
//
//  Created by Apple on 2017/1/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "XLCardSwitchFlowLayout.h"
#import "XLCardCell.h"

//居中卡片宽度与据屏幕宽度比例
static float CardWidthScale = 0.7f;
static float CardHeightScale = 0.8f;

@implementation XLCardSwitchFlowLayout

//初始化方法
- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake([self insetY], [self insetX], [self insetY], [self insetX]);
    self.itemSize = CGSizeMake([self itemWidth], [self itemHeight]);
    self.minimumLineSpacing = 5;
}

//设置缩放动画
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    //获取cell的布局
    NSArray *attributesArr = [super layoutAttributesForElementsInRect:rect];
    //屏幕中线
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width/2.0f;
    //最大移动距离，计算范围是移动出屏幕前的距离
//    CGFloat maxApart = (self.collectionView.bounds.size.width + [self itemWidth])/2.0f;
    CGFloat maxApart = [self itemWidth];
    //刷新cell缩放
    for (UICollectionViewLayoutAttributes *attributes in attributesArr) {
        //获取cell中心和屏幕中心的距离
        CGFloat apart = fabs(attributes.center.x - centerX);
        //移动进度 -1~0~1
        CGFloat progress = apart/maxApart;
        
//        NSLog(@"aaron: Progress for index %ld is %f", attributes.indexPath.row,progress);
        //在屏幕外的cell不处理
        XLCardCell *cell = (XLCardCell *)[self.collectionView cellForItemAtIndexPath:attributes.indexPath];
        if (fabs(progress) > 1) {
           
            [cell setImageAlpha:0.6];
            continue;}
        //根据余弦函数，弧度在 -π/4 到 π/4,即 scale在 √2/2~1~√2/2 间变化
//        CGFloat scale = fabs(cos(progress * M_PI/4));
        CGFloat scale = 1 + (1 - progress) *0.1;
        //缩放大小
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
        
        
        // 设置图片透明度
        CGFloat alpha = 0.6 + (1-fabs(progress))*0.4;
        [cell setImageAlpha:alpha];
        //更新中间位
        if (apart <= [self itemWidth]/2.0f) {
            self.centerBlock(attributes.indexPath);
        }
    }
    return attributesArr;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalOffset = proposedContentOffset.x + self.collectionView.contentInset.left;
    NSInteger currentPage = (NSInteger)(horizontalOffset / (self.itemSize.width + self.minimumLineSpacing));

    for (NSInteger i = currentPage - 1; i <= currentPage + 1; i++) {
        CGFloat xOffset = i * (self.itemSize.width + self.minimumLineSpacing);
        if (ABS(xOffset - horizontalOffset) < ABS(offsetAdjustment)) {
            offsetAdjustment = xOffset - horizontalOffset;
        }
    }

    CGFloat targetX = proposedContentOffset.x + offsetAdjustment;
    CGPoint targetContentOffset = CGPointMake(targetX, proposedContentOffset.y);

    CGFloat deltaX = targetContentOffset.x - self.collectionView.contentOffset.x;
    CGFloat velX = velocity.x;

    if (deltaX == 0.0 || velX == 0 || (velX > 0.0 && deltaX > 0.0) || (velX < 0.0 && deltaX < 0.0)) {
        // 如果偏移量不变或者速度方向和偏移量方向相同，则直接返回目标偏移量
        return targetContentOffset;
    }

    NSInteger pageCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat nextPageX = currentPage * (self.itemSize.width + self.minimumLineSpacing);
    CGFloat nextPageOffsetX = nextPageX - self.collectionView.contentInset.left;

    BOOL shouldUseNextPage = NO;
    if ((velocity.x > 0.0 && deltaX > 0.0 && deltaX >= (self.itemSize.width / 2)) ||
        (velocity.x > 0.0 && deltaX < 0.0 && ABS(deltaX) >= (self.itemSize.width / 2))) {
        if (currentPage < pageCount - 1) {
            shouldUseNextPage = YES;
        }
    } else if ((velocity.x < 0.0 && deltaX < 0.0 && ABS(deltaX) >= (self.itemSize.width / 2)) ||
               (velocity.x < 0.0 && deltaX > 0.0 && deltaX >= (self.itemSize.width / 2))) {
        if (currentPage > 0) {
            shouldUseNextPage = YES;
            nextPageOffsetX -= (self.itemSize.width + self.minimumLineSpacing);
        }
    }

    if (shouldUseNextPage) {
        targetContentOffset.x = nextPageOffsetX;
    }

    return targetContentOffset;
}
#pragma mark -
#pragma mark 配置方法
//卡片宽度
- (CGFloat)itemWidth {
    return 72.f;
//    return self.collectionView.bounds.size.width * CardWidthScale;
}

- (CGFloat)itemHeight {
    return 72.f;
//    return self.collectionView.bounds.size.height * CardHeightScale;
}

//设置左右缩进
- (CGFloat)insetX {
    CGFloat insetX = (self.collectionView.bounds.size.width - [self itemWidth])/2.0f;
    return insetX;
}

- (CGFloat)insetY {
    CGFloat insetY = (self.collectionView.bounds.size.height - [self itemHeight])/2.0f;
    return insetY;
}

//是否实时刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return true;
}

@end
