//
//  ViewController.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/4/28.
//  Copyright © 2017年 Kingstong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        automaticallyAdjustsScrollViewInsets = false
        
        let pageFrame = CGRect(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height)
        
        let tittles = ["推荐","游戏","娱乐","趣玩","飞机","大炮","美颜","礼物","赠送礼物"]
        var childVcs = [UIViewController]()
        var style = ZYPageStyle()
        style.isScrollEnable = true
        style.isNeedScale = true
        style.isShowCoverView = true
        
        for _ in 0..<tittles.count {
            let VC = UIViewController()
            VC.view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256))/255.0,
                                              green: CGFloat(arc4random_uniform(256))/255.0,
                                              blue: CGFloat(arc4random_uniform(256))/255.0,
                                              alpha: 1.0)
            childVcs.append(VC)
        }
        
        let pageView  =  ZYPageView(frame: pageFrame, tittles: tittles, style: style, childVcs: childVcs, parentVc: self)
        self.view.addSubview(pageView)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

