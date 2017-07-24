//
//  PageController.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/6/13.
//  Copyright © 2017年 Kingstong. All rights reserved.
//

import UIKit

private let KcellKey = "KcellKey"

class PageController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGray
        automaticallyAdjustsScrollViewInsets = true
        
        // 创建pageViewController
        // 1.创建frame
        let pageFrame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 300)
        
        // 2.获取标题
        let titles = ["热门", "高级", "专属", "豪华"]
        
        // 3.获取样式
        var style = ZYPageStyle()
        style.isShowBottomLine = true
        
        // 4.创建pageView
        let layout = ZYPageCollectionViewLayout()
        layout.sectionInSet = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemMargin = 5
        layout.lineMargin = 5
        layout.cols = 4
        layout.rows = 3
        
        let pageConllectionView = ZYPageCollectionView(frame: pageFrame, titles: titles, style: style, layout: layout)
        pageConllectionView.registerCell(UICollectionViewCell.self, reusableIdentifier: KcellKey)
        pageConllectionView.backgroundColor = UIColor.red
        view.addSubview(pageConllectionView)
        pageConllectionView.dateSource = self
    }

}


extension PageController: ZYPageCollectionViewDateSource {

    func numberSectionInPageCollectionView(_ pageCollectionView: ZYPageCollectionView) -> Int {
        return 4
    }
    
    func pageCollectionView(_ pageCollectionView: ZYPageCollectionView, numberOfSection section: Int) -> Int {
        
        if  section == 0 {
            return 100
        }else if section == 1 {
            return 10
        }else if section == 2 {
            return 40
        }else {
            return 50
        }
    }
    
    
    func pageCollectionView(_ pageCollectionView: ZYPageCollectionView, _ collectionView: UICollectionView, cellAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KcellKey, for: indexPath)
        cell.backgroundColor = UIColor.randomColor()
        return cell
    }
    
}


