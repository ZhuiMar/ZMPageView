//
//  UIColor+Extension.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/5/13.
//  Copyright © 2017年 Kingstong. All rights reserved.
//


import UIKit

func rgb(_ r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor{
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

func hexColor(_ hex:String) -> UIColor {
    
    var cString:String = hex.trimmingCharacters(in: (NSCharacterSet.whitespacesAndNewlines as NSCharacterSet) as CharacterSet).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
    }
    
    if (cString.characters.count != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
    
    class func randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
    
    // 从颜色中获取rgb的值
    func getRGBValue() -> (CGFloat, CGFloat, CGFloat) {
       
        guard let cmps = cgColor.components else {
            // break, continue, return, throws:抛出异常
            fatalError("重大错误!!!请确定改颜色是通过RGB创建的")
        }
        return (cmps[0] * 255, cmps[1] * 255, cmps[2] * 255)
    }
}

