//
//  ZYPageStyle.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/4/28.
//  Copyright © 2017年 Kingstong. All rights reserved.
//

import UIKit

// 类可以继承也可以不继承,不继承的话更加轻量级
struct ZYPageStyle {
    
    var isTitleInTop: Bool = true   // 话条是否在顶部
    var pageControlHeight: CGFloat = 20 // UIPageController的高度
    var tittleHeight : CGFloat = 44 // tittle标题的高度
    var normalColor : UIColor = UIColor(r: 255, g: 255, b: 255) // 文本普通的颜色
    var selectColor : UIColor = UIColor(r: 255, g: 127, b: 0) // 文本选中的颜色
    var tittleFont : UIFont = UIFont.systemFont(ofSize: 14) // 文字的大小
    var isScrollEnable : Bool = false  // 能否滚动
    var tittleMargin : CGFloat = 20 // 能滚动的情况下的文字的间距
    
    var isShowBottomLine :Bool = false // 是否显示滚送条
    var bottomLineColor : UIColor = UIColor(r: 255, g: 127, b: 0) // 滚动条默认的颜色
    var bottomLineHeight : CGFloat = 1.5 // 滚条的高度
    
    var isNeedScale : Bool = false  // 是否需要缩放的动画
    var maxScale : CGFloat = 1.2  // 最大的缩放的程度
    
    var isShowCoverView : Bool = false
    var coverViewColor : UIColor = UIColor.black
    var coverViewAlpha : CGFloat = 0.3  // 透明度
    var coverViewHeight : CGFloat = 25 // 遮挡高度
    var coverViewRadius : CGFloat = 12  // 圆角
    var coverViewMargin : CGFloat = 10 // 间距
}
