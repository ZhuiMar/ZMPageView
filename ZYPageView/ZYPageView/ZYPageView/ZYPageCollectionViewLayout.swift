//
//  ZYPageCollectionViewLayout.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/6/13.
//  Copyright © 2017年 Kingstong. All rights reserved.
//

import UIKit

class ZYPageCollectionViewLayout: UICollectionViewLayout {

    var sectionInSet: UIEdgeInsets = UIEdgeInsets.zero
    var itemMargin: CGFloat = 0
    var lineMargin: CGFloat = 0
    var cols: Int = 0
    var rows: Int = 0

    fileprivate lazy var attributes : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    fileprivate var totalWidth: CGFloat = 0
}


extension ZYPageCollectionViewLayout {
    
    override func prepare() {
        
        // 0 对conllectionView进行校验
        guard let collectionView = collectionView else {
            return
        }
        
        // 1.获取有多少组
        let sections = collectionView.numberOfSections
        
        // 计算item的Size
        let itemWidth = (collectionView.bounds.width - sectionInSet.left - sectionInSet.right - CGFloat(cols - 1) * itemMargin)/CGFloat(cols)
        let itemHeight = (collectionView.bounds.height - sectionInSet.top - sectionInSet.bottom - CGFloat(rows - 1) * lineMargin)/CGFloat(rows)
        var previousNumOfPage = 0
        
        // 2.遍历所有的组
        for section in 0..<sections{
            
            // 3. 获取没组的items
            let items = collectionView.numberOfItems(inSection: section)
            
            // 4. 遍历出所有的items
            for item in 0..<items {
                
                // 5.根据section/和items创建UICollectionViewLayoutAttribute
                let indexPath = IndexPath(item: item, section: section)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                // 6.给attribute的frame进行赋值
                let currentPage = item / (cols * rows)
                let currentIndex = item % (cols * rows)
                
                let itemX : CGFloat = CGFloat(previousNumOfPage + currentPage) * collectionView.bounds.width + sectionInSet.left + (itemWidth + itemMargin) * CGFloat(currentIndex % cols)
                let itemY = sectionInSet.top + (itemHeight + lineMargin) * CGFloat(currentIndex / cols)
               
                attribute.frame = CGRect(x: itemX, y: itemY, width: itemWidth, height: itemHeight)
                
                // 7.attribute 放入数组
                attributes.append(attribute)
            }
    
            previousNumOfPage += (items - 1) / (cols * rows) + 1
        }
        
        // 8.获取总的宽度
        totalWidth = CGFloat(previousNumOfPage) * collectionView.bounds.width
    }
}


extension ZYPageCollectionViewLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
}


extension ZYPageCollectionViewLayout {
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: totalWidth, height: 0)
    }
}



