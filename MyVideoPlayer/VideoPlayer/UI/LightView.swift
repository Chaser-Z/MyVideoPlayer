//
//  LightView.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/20.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit

class LightView: UIView {

    var lightBackView: UIView!
    var lightViewArr: Array<UIView>!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.configureUI()
    }
    private func configureUI() {
    
        //self.backgroundColor = UIColor.colorWith(redColor: 213, green: 213, blue: 213, alpha: 1)
        
        // 亮度
        let lightLabel = UILabel()
        lightLabel.frame = CGRectMake(0, 0, 155, 30)
        lightLabel.text = "亮度"
        lightLabel.textColor = UIColor.blackColor()
        lightLabel.textAlignment = .Center
        self.addSubview(lightLabel)
        // 图片
        let lightImageView = UIImageView()
        lightImageView.frame = CGRectMake(30, 30, 95, 95)
        lightImageView.image = UIImage(named: "play_new_brightness_day")
        self.addSubview(lightImageView)
        
        
        
        self.lightBackView = UIView()
        self.lightBackView.frame = CGRectMake(10, 134, 135, 6)
        self.lightBackView.backgroundColor  = UIColor.lightGrayColor()
        self.addSubview(self.lightBackView)
        
        self.lightViewArr = Array()
        self.layer.cornerRadius = 10.0
        let backWidth = self.lightBackView.bounds.size.width
        let backHeight = self.lightBackView.bounds.size.height
        let viewWidth = (backWidth - (16 + 1)) / 16
        let viewHeight = backHeight - 2
        
        for i in 0..<16 {
            
            let view = UIView()
            view.frame = CGRectMake(1 + CGFloat(i) * (viewWidth + 1), 1, viewWidth, viewHeight)
            view.backgroundColor = UIColor.whiteColor()
            self.lightViewArr.append(view)
            self.lightBackView.addSubview(view)
        }
    
    }
    func changeLightViewWithValue(lightValue: Float) {
        
        let allCount = self.lightViewArr.count
        let lightCount: Float = lightValue * Float(allCount)
        
        print("lightCount = \(lightCount)")
        for i in 0..<allCount {
            
            let view = self.lightViewArr[i]
            if Float(i) < lightCount {
                
                view.backgroundColor = UIColor.whiteColor()
            } else {
                
                view.backgroundColor = UIColor.colorWith(redColor: 65, green: 67, blue: 70, alpha: 1)
            }

        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
