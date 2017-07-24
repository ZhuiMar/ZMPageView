//
//  ZYPageView.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/4/28.
//  Copyright © 2017年 Kingstong. All rights reserved.
//

import UIKit

class ZYPageView: UIView {

    // MARK: 属性
    var titles : [String]
    var style : ZYPageStyle
    var childVcs : [UIViewController]
    var parentVc : UIViewController
    
    init(frame:CGRect, tittles:[String], style:ZYPageStyle, childVcs:[UIViewController], parentVc:UIViewController) {
        
        self.titles = tittles
        self.style = style
        self.childVcs = childVcs
        self.parentVc = parentVc
       
        super.init(frame:frame)
        
        let contentViewFrame = CGRect(x: 0, y: 44, width: self.frame.size.width, height: self.frame.size.height)
        let contentView = ZYContentView(frame: contentViewFrame, childvcs: childVcs, parentVc: parentVc)
        self.addSubview(contentView)
        
        let tittleViewFrame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44)
        let tittleView = ZYTittleView(frame: tittleViewFrame, tittles: titles, style: style)
        self.addSubview(tittleView)
        
        // 让contentView和tittle进行沟通
        tittleView.delegate = contentView
        contentView.delegate = tittleView
    }
    
    // 用required修饰的构造函数,如果子类重新自定义其他的构造函数。那么必须重新required修饰的构造函数。目的是希望走自己定义的构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
