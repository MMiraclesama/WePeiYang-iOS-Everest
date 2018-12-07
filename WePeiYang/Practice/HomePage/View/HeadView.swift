//
//  HeadView.swift
//  WePeiYang
//
//  Created by JasonEWNL on 2018/7/13.
//  Copyright © 2018年 twtstudio. All rights reserved.
//

import UIKit

class HeadView: UIView {
    
    /* 蓝色背景 */
    private let headBackgroundView: UIView = {
        let headBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: deviceWidth, height: 64))
        headBackgroundView.backgroundColor = .practiceBlue
        
        // 设置圆角 //
        headBackgroundView.setCorners([.bottomLeft, .bottomRight], radius: 20)

        // 渐变
        let gradient = CAGradientLayer()

        gradient.frame = CGRect(x: 0, y: 0, width: deviceWidth, height: 128)
        gradient.colors = [UIColor.practiceBlue.cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)

        headBackgroundView.layer.insertSublayer(gradient, at: 0)

        return headBackgroundView
    }()
    
    /* 切换按钮 (题库, 我的) */
    private static func addOptionButton(withText text: String, x: CGFloat) -> UIButton {
        let optionButton = UIButton(frame: CGRect(x: x, y: 10, width: deviceWidth / 2, height: 44))
        
        optionButton.setTitle(text, for: .normal)
        optionButton.setTitleColor(.white, for: .normal)
        
        return optionButton
    }
    
    let userOptionButton = addOptionButton(withText: "我的", x: deviceWidth / 2)
    let homeOptionButton = addOptionButton(withText: "题库", x: 0)
    
    /* 白色指示条 */
    let underLine: UIView = {
        let underLine = UIView(frame: CGRect(x: deviceWidth * 2 / 3, y: 54, width: deviceWidth / 6, height: 2))
        underLine.backgroundColor = .white
        return underLine
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headBackgroundView)
        
        userOptionButton.isEnabled = false
        addSubview(userOptionButton)
        addSubview(homeOptionButton)
        
        addSubview(underLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIView {
    // 设置独立圆角 //
    func setCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        
        self.layer.mask = maskLayer
    }
}