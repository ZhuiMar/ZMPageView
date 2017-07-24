//
//  ZYTittleView.swift
//  ZYPageView
//
//  Created by  luzhaoyang on 17/4/28.
//  Copyright © 2017年 Kingstong. All rights reserved.
//

import UIKit

protocol ZYTittleViewDelegate : class {
    func tittleView(_ tittleView : ZYTittleView, targetIndex : Int)
}


class ZYTittleView: UIView,UIScrollViewDelegate {

    // MARK: 属性
    weak var delegate : ZYTittleViewDelegate?
    fileprivate var tittles : [String]
    fileprivate var style : ZYPageStyle
    fileprivate var tittleLables : [UILabel] = [UILabel]()
    fileprivate var currentIndex : Int = 0
    fileprivate var lastIndex: String = ""  
    
    fileprivate lazy var normalRGB : (CGFloat, CGFloat, CGFloat) = self.style.normalColor.getRGBValue()
    fileprivate lazy var selectRGB : (CGFloat, CGFloat, CGFloat) = self.style.selectColor.getRGBValue()
    
    fileprivate lazy var deltaRGB : (CGFloat, CGFloat, CGFloat) = {
        let deltaR = self.selectRGB.0 - self.normalRGB.0
        let deltaG = self.selectRGB.1 - self.normalRGB.1
        let deltaB = self.selectRGB.2 - self.normalRGB.2
        return (deltaR, deltaG, deltaB)
    }()
    fileprivate lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        return scrollView
    }()
    fileprivate lazy var bottomLine : UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.bottomLineColor
        bottomLine.frame.size.height = self.style.bottomLineHeight
        bottomLine.frame.origin.y = self.style.tittleHeight - self.style.bottomLineHeight
        return bottomLine
    }()
    fileprivate lazy var coverView : UIView = {
        let coverView = UIView()
        coverView.backgroundColor = self.style.coverViewColor
        coverView.alpha = self.style.coverViewAlpha
        return coverView
    }()
    
    
    // MARK: 构造函数
    init(frame: CGRect, tittles : [String], style : ZYPageStyle) {
        
        self.tittles = tittles
        self.style = style
        super.init(frame: frame)
        self.backgroundColor = UIColor.green
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK : 设置UI
extension ZYTittleView {

    fileprivate func setupUI() {
        self.addSubview(scrollView)
        setupTittles()
        
        if style.isShowBottomLine {
            setupBottomLine()
        }
    }
    
    private func setupBottomLine() {
        scrollView.addSubview(self.bottomLine)
        bottomLine.frame = tittleLables.first!.frame
        bottomLine.frame.size.height = style.bottomLineHeight
        bottomLine.frame.origin.y = style.tittleHeight - style.bottomLineHeight
    }
    
    private func setupTittles() {
        
        // MARK: 设置tittlelable的属性
        for (i , tittle) in tittles.enumerated() {
        
            let tittleLable = UILabel()
            tittleLable.text = tittle
            tittleLable.tag = i
            tittleLable.textAlignment = .center
            tittleLable.textColor = i == 0 ? style.selectColor : style.normalColor
            tittleLable.font = style.tittleFont
            scrollView.addSubview(tittleLable)
            
            // 监听tittle的点击事件
            // #selector(方法名)
            // tapGes为外部的额参数如果不需要有外部的参数的话可以用_
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(tittleLableClick(_:)))
            tittleLable.addGestureRecognizer(tapGes)
            tittleLable.isUserInteractionEnabled = true
            tittleLables.append(tittleLable)
        }
        
        // MARK: 设置tittleLable的frame
        let lableH : CGFloat = style.tittleHeight
        let lableY : CGFloat = 0
        var lableW : CGFloat = bounds.width / CGFloat(tittles.count)
        var lableX : CGFloat = 0
        
        for  (i, tittleLable) in tittleLables.enumerated() {
            
            if style.isScrollEnable { // 可以滚动
              lableW = (tittleLable.text! as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : style.tittleFont], context: nil).width
              lableX = i == 0 ? style.tittleMargin * 0.5: tittleLables[i - 1].frame.maxX + style.tittleMargin
            }else{ // 不能滚动
                lableX = lableW * CGFloat(i)
            }
            tittleLable.frame = CGRect(x: lableX, y: lableY, width: lableW, height: lableH)
        }
        
        // MARK : 设置ScrollView的ContentSize
        if style.isScrollEnable {
            scrollView.contentSize = CGSize(width: (tittleLables.last!.frame.maxX) + style.tittleMargin * 0.5, height: 0)
        }
        
        // 设置缩放
        if style.isNeedScale {
            tittleLables.first?.transform = CGAffineTransform(scaleX: style.maxScale, y: style.maxScale)
        }
        
        // 设置遮挡View
        if style.isShowCoverView {
            scrollView.insertSubview(coverView, at: 0)
            guard let firstLabel = tittleLables.first else { return }
            var  coverW = firstLabel.frame.size.width
            let coverH = style.coverViewHeight
            var coverX = firstLabel.frame.origin.x
            let coverY = (firstLabel.frame.size.height - coverH) * 0.5
            
            if style.isScrollEnable {
                coverX -= style.coverViewMargin
                coverW += style.coverViewMargin * 2
            }
            coverView.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
            coverView.layer.cornerRadius = style.coverViewRadius
            coverView.layer.masksToBounds = true
            coverView.frame = CGRect(x: 0, y: 0, width: coverW, height: coverH)
            coverView.center = tittleLables.first!.center
        }
        
    }
    
}

// MARK : 监听点击事件
extension ZYTittleView {

    func tittleLableClick(_ tapGes : UITapGestureRecognizer) {
    
        // 教研Lab是佛有值
        guard let targetlabel = tapGes.view as? UILabel else {return}
        
        // 1.判断lab是否是之前的点击的Lab
        guard targetlabel.tag != currentIndex else {return}
        
        // 2.代理通知
        // ?. 可选链,如果可选类型有值则执行代码,如果可选类型没有值则什么都不发生
        delegate?.tittleView(self, targetIndex: targetlabel.tag)
        
        addjustTitle(targetlabel)
    }
    
    
    fileprivate func addjustTitle(_ targetlabel : UILabel) {
    
        // 1.让之前的额label不选中, 让新的label可以选中
        if lastIndex != "" {
            let lastLabel = tittleLables[Int(lastIndex)!]
            lastLabel.textColor = style.normalColor
        }
        
        let scrollLabel = tittleLables[currentIndex]
        scrollLabel.textColor = style.normalColor
        targetlabel.textColor = style.selectColor
        
        // 2.让新的tag作为currentIndex
        currentIndex = targetlabel.tag
        
        // 3.调整电机的label的位置,滚动到中间去
        adjustLabelPosition()
        
        // 4.调整bottomLine的位置
        if style.isShowBottomLine {
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomLine.frame.origin.x = targetlabel.frame.origin.x
                self.bottomLine.frame.size.width = targetlabel.frame.width
            })
        }
        
        // 5.设置缩放
        if style.isNeedScale {
            UIView.animate(withDuration: 0.2, animations: {
                scrollLabel.transform = CGAffineTransform.identity
                targetlabel.transform = CGAffineTransform(scaleX: self.style.maxScale, y: self.style.maxScale)
            })
        }
        
        // 6.调整遮挡view
        if  style.isShowCoverView {
            UIView.animate(withDuration: 0.2, animations: {
                self.coverView.frame.origin.x = self.style.isScrollEnable ? (targetlabel.frame.origin.x - self.style.coverViewMargin) : targetlabel.frame.origin.x
                self.coverView.frame.size.width = self.style.isScrollEnable ? (targetlabel.frame.size.width + self.style.coverViewMargin * 2) : targetlabel.frame.width
            })
        }
    }
    
    
    // 9.让titile滚动
    fileprivate func adjustLabelPosition() {
        
        guard style.isScrollEnable else { return }
        let targetlabel = tittleLables[currentIndex]
        var offsetX = targetlabel.center.x - scrollView.bounds.width * 0.5
        if offsetX < 0 {
            offsetX = 0
        }
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}



// MARK : 监听点击事件
extension ZYTittleView {
    
    func setCurrentIndex(_ index: Int) {
        // 出去targatLabel
        let targatLabel = tittleLables[index]
        addjustTitle(targatLabel)
    }
}


// MARK : 遵守contentView的代理
extension ZYTittleView : ZYContentViewDelegate {
    
    func contentView(_ contentView: ZYContentView, didEndScroll index: Int) {
        currentIndex = index
        adjustLabelPosition()
    }
    
    func contentView(_ contentView: ZYContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        
        let sourelabel = tittleLables[sourceIndex]
        let targetLabel = tittleLables[targetIndex]
        lastIndex = "\(targetIndex)"
        
        // 1.设置颜色的渐变
        let deltaRGB = self.deltaRGB
        sourelabel.textColor = UIColor(r: selectRGB.0 - deltaRGB.0 * progress , g: selectRGB.1 - deltaRGB.1 * progress, b: selectRGB.2 - deltaRGB.2 * progress)
        targetLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress , g: normalRGB.1 + deltaRGB.1 * progress, b: normalRGB.2 + deltaRGB.2 * progress)
        
        // 2.计算bottomLine
        let deltaW = targetLabel.frame.width - sourelabel.frame.width
        let deltaX = targetLabel.frame.origin.x - sourelabel.frame.origin.x
        if style.isShowBottomLine {
            bottomLine.frame.size.width = deltaW * progress + sourelabel.frame.width
            bottomLine.frame.origin.x = deltaX * progress + sourelabel.frame.origin.x
        }
        
        // 3.设置渐变的缩放
        if style.isNeedScale {
            let deltaScale = style.maxScale - 1.0
            sourelabel.transform = CGAffineTransform(scaleX: style.maxScale - deltaScale * progress, y: style.maxScale - deltaScale * progress)
            targetLabel.transform = CGAffineTransform(scaleX: 1.0 + deltaScale * progress, y: 1.0 + deltaScale * progress)
        }
        
        // 4.coverView的渐变
        if style.isShowCoverView  {
            coverView.frame.origin.x = style.isScrollEnable ? (sourelabel.frame.origin.x - style.coverViewMargin + deltaX * progress):(sourelabel.frame.origin.x + deltaX * progress)
            coverView.frame.size.width = style.isScrollEnable ? (sourelabel.frame.width + style.coverViewMargin * 2 + deltaW * progress):(sourelabel.frame.width + deltaW * progress)
        }
        
    }
}















