//
//  ZYPageCollectionView.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/6/13.
//  Copyright © 2017年 Kingstong. All rights reserved.
//

import UIKit

protocol ZYPageCollectionViewDateSource: class {
    // 有多少组  _ 表示在外部不显示参数的标识符
    func numberSectionInPageCollectionView(_ pageCollectionView: ZYPageCollectionView) ->Int
   
    // 每一组里面有多少个 numberOfSection外部参数方便识别 section内不参数比较短方便使用
    func pageCollectionView(_ pageCollectionView: ZYPageCollectionView, numberOfSection section: Int) ->Int
    
    // 每一个cell长什么样子
    func pageCollectionView(_ pageCollectionView: ZYPageCollectionView, _ collectionView: UICollectionView, cellAtIndexPath indexPath: IndexPath) ->UICollectionViewCell
}

class ZYPageCollectionView: UIView {

    weak var dateSource: ZYPageCollectionViewDateSource?
    fileprivate var titles:[String]
    fileprivate var style:ZYPageStyle
    fileprivate var collectionView: UICollectionView!
    fileprivate var layout: ZYPageCollectionViewLayout
    fileprivate var pageCtroller: UIPageControl! // 写！话就必须保证要赋值
    fileprivate var currentIndex: IndexPath = IndexPath(item: 0, section: 0)
    fileprivate var titltView: ZYTittleView!
   
    init(frame:CGRect , titles:[String], style:ZYPageStyle , layout: ZYPageCollectionViewLayout) {
        self.titles = titles
        self.style = style
        self.layout = layout
        super.init(frame: frame)
        setupUi()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ZYPageCollectionView {

    fileprivate func setupUi() {
        
        // 1.titleView
        let titleY = style.isTitleInTop ? 0 : bounds.height - style.tittleHeight
        let titleFrame = CGRect(x: 0, y: titleY, width: bounds.width, height: style.tittleHeight)
        let titleView = ZYTittleView(frame: titleFrame, tittles: titles, style: style)
        titleView.backgroundColor = UIColor.blue
        titleView.delegate = self
        addSubview(titleView)
        self.titltView = titleView
        
        // 2.collectionView
        let collectionY = style.isTitleInTop ? style.tittleHeight : 0
        let collectionH = bounds.height - style.tittleHeight - style.pageControlHeight
        let collectionFrame = CGRect(x: 0, y: collectionY, width: bounds.width, height: collectionH)
        
        let collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.green
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        self.collectionView = collectionView
        
        // 3.pageController
        let pageFrame = CGRect(x: 0, y: collectionFrame.maxY, width: bounds.width, height: style.pageControlHeight)
        let pageCtrl = UIPageControl(frame: pageFrame)
        pageCtrl.numberOfPages = 4
        pageCtrl.backgroundColor = UIColor.orange
        addSubview(pageCtrl)
        self.pageCtroller = pageCtrl
    }
}


// MARK : 暴露cell的方法
extension ZYPageCollectionView {
    func registerCell(_ cell :AnyClass?, reusableIdentifier : String) {
        collectionView.register(cell, forCellWithReuseIdentifier: reusableIdentifier)
    }
    func registerNib(_ nib :UINib?, reusableIdentifier : String) {
        collectionView.register(nib, forCellWithReuseIdentifier: reusableIdentifier)
    }
    func reloadData() {
         collectionView.reloadData()
    }
}


extension ZYPageCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        // return dateSource?.numberSectionInPageCollectionView(self) ?? 0
        
        guard let num = dateSource?.numberSectionInPageCollectionView(self) else {
            return 0
        }
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let  sectionItemsCount = dateSource?.pageCollectionView(self, numberOfSection: section) ?? 0
        if section == 0 {
            pageCtroller.numberOfPages = (sectionItemsCount - 1) / (layout.cols * layout.rows) + 1
        }
        return sectionItemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (dateSource?.pageCollectionView(self, collectionView, cellAtIndexPath: indexPath))!
    }
}




extension ZYPageCollectionView: UICollectionViewDelegate {

    // 有减速的停止
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewEndScroll()
    }
    
    // 没有减速，只是拖拽停止
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewEndScroll()
        }
    }
    
    // 停止的时候过程中
   private func scrollViewEndScroll() {
        // 1. 获取滚动位置对应的Section (根据点获取indexPath)
        let point = CGPoint(x: layout.sectionInSet.left + 1 + collectionView.contentOffset.x, y: layout.sectionInSet.top + 1)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
        // 2.判断是否需要改变组
        if indexPath.section != currentIndex.section {
            
            let itemsCount = dateSource?.pageCollectionView(self, numberOfSection: indexPath.section) ?? 0
            pageCtroller.numberOfPages = (itemsCount - 1) / (layout.cols * layout.rows) + 1
            pageCtroller.currentPage = indexPath.item / (layout.cols * layout.rows)
            pageCtroller.currentPage = 0
            // 改变title的位置
            titltView.setCurrentIndex(indexPath.section)
            
            // 设置最新的indexPath
            currentIndex = indexPath
        }
    
        pageCtroller.currentPage = indexPath.item / (layout.cols * layout.rows)
    }

}



extension ZYPageCollectionView: ZYTittleViewDelegate {

    func tittleView(_ tittleView: ZYTittleView, targetIndex: Int) {
        
        // 1.根据targetIndex创建IndexPath
        let indexPath = IndexPath(item: 0, section: targetIndex)
        
        // 2.滚到正确的位置
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
        // 3.设置pageCtroller的个数
        let sectionNum = dateSource?.numberSectionInPageCollectionView(self) ?? 0
        let sectionItemNum = dateSource?.pageCollectionView(self, numberOfSection: targetIndex) ?? 0
        pageCtroller.numberOfPages = (sectionItemNum - 1)/(layout.cols * layout.rows) + 1  // 求出可以占用多少页
        // (count - 1) / pageCount + 1  --->知道总的个数，求可以占用多少页
        // index / pageCount ----> 知道下标值，请求该下标值在第几页
        
        // 4.设置最新的indexPath
        currentIndex = indexPath
        
        
        // 5.调整正确的位置
        if targetIndex == sectionNum - 1 && sectionItemNum <= layout.cols * layout.rows {
            return
        }
        collectionView.contentOffset.x -= layout.sectionInSet.left
    }
}





