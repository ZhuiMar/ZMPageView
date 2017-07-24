//
//  ZYContentView.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/4/28.
//  Copyright © 2017年 Kingstong. All rights reserved.
//

import UIKit


/*
 self. 在常见的两个地方是不能省略的 
 1:如果上下文中其他的地方有歧义不能省略
 2:闭包中用到的当前对象的所有的属性不能省略
 */

private let kcontentCellId = "kcontentCellId"

// 加上class表示该协议只能被类遵守
protocol ZYContentViewDelegate : class {
    func contentView(_ contentView : ZYContentView, didEndScroll index : Int)
    func contentView(_ contentView : ZYContentView, sourceIndex : Int, targetIndex : Int, progress : CGFloat)
}

class ZYContentView: UIView {

    // MARK: 属性
    weak var delegate : ZYContentViewDelegate? // weak 一般只能被用来修饰一个类
    fileprivate var childVcs : [UIViewController]
    fileprivate var parentVc : UIViewController
    fileprivate var startOffsetX : CGFloat = 0
    fileprivate var isForbidDelegate : Bool = false
    
    fileprivate lazy var conllectionView : UICollectionView = { // 大括号代表闭包(也叫匿名函数): {}代表闭包 ()代表执行函数
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumInteritemSpacing = 0 // 间距
        layout.minimumLineSpacing = 0 // 行间距
        layout.scrollDirection = .horizontal // 滚动方向
        let conllectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        conllectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kcontentCellId)
        conllectionView.delegate = self
        conllectionView.dataSource = self
        conllectionView.isPagingEnabled = true
        conllectionView.showsHorizontalScrollIndicator = false
        conllectionView.scrollsToTop = false
        conllectionView.bounces = false
        return conllectionView
    }()
    
    // MARK: 构造函数
    init(frame: CGRect, childvcs:[UIViewController], parentVc:UIViewController) {
        
        self.childVcs = childvcs
        self.parentVc = parentVc
        super.init(frame: frame)
        setupUi()
        self.addSubview(self.conllectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK : 设置UI界面
extension ZYContentView {

    fileprivate func setupUi(){
        for childvc in childVcs {
            parentVc.addChildViewController(childvc)
        }
    }
}


// MARK : 遵守UICollectionViewDelegate
extension ZYContentView : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = conllectionView.dequeueReusableCell(withReuseIdentifier: kcontentCellId, for: indexPath)
        
        cell.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256))/255.0,
                                      green: CGFloat(arc4random_uniform(256))/255.0,
                                      blue: CGFloat(arc4random_uniform(256))/255.0,
                                      alpha: 1.0)
        
        // 应为cell可以循环的利用可能会导致同一个cell上面添加了太多的View所以要先删除View然后添加View
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        let childVc = childVcs[indexPath.item]
    
        cell.contentView.addSubview(childVc.view)
        return cell
    }
}

// MARK : 遵守UICollectionViewDataSource
extension ZYContentView : UICollectionViewDataSource {
    
    // 将要拽动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidDelegate = false
        startOffsetX = scrollView.contentOffset.x
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll()
    }
    
    
    // 停止滚动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll()
        }
    }
    
    // 控制头部滚动条的滚送
    private func scrollViewDidEndScroll() {
        let index = Int(conllectionView.contentOffset.x / conllectionView.bounds.width)
        delegate?.contentView(self, didEndScroll: index)  // ?.叫做可选链这样写可以省去if的判断
    }
    
    // 控制颜色渐变
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        

        // 先判断有没有滑动(一页没有完整的滑完)
        let contentOffsetX = scrollView.contentOffset.x
        guard startOffsetX != contentOffsetX && !isForbidDelegate else {
            return
        }
        
        // 1.定义变量
        var sourceIndex = 0
        var targetIndex = 0
        var progress : CGFloat = 0.0
        
        
        // 2.获取所需要的参数
        let colletionWidth = conllectionView.bounds.width
    
        if contentOffsetX > startOffsetX { // 左滑
            
            sourceIndex = Int(contentOffsetX/colletionWidth)
            targetIndex = sourceIndex + 1
            
            // 判断越界
            if targetIndex >= childVcs.count {
                targetIndex = childVcs.count - 1
            }
            
            progress = (contentOffsetX - startOffsetX)/colletionWidth
            
            if (contentOffsetX - startOffsetX) == colletionWidth {
                targetIndex = sourceIndex
            }
            
        }else { // 右滑
            
            targetIndex = Int(contentOffsetX/colletionWidth)
            sourceIndex = targetIndex + 1
            progress = (startOffsetX - contentOffsetX)/colletionWidth
            
            if sourceIndex >= childVcs.count {
                sourceIndex = childVcs.count - 1
            }
        }
        
        delegate?.contentView(self, sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
    } 
}


// MARK : tittleView的代理方法
extension ZYContentView : ZYTittleViewDelegate {
    func tittleView(_ tittleView: ZYTittleView, targetIndex: Int) {
        isForbidDelegate = true
        // 根据index 创建IndexPath
        let indextPath = IndexPath(item: targetIndex, section:0)
        conllectionView.scrollToItem(at: indextPath, at: .centeredHorizontally, animated: false)
    }
}





