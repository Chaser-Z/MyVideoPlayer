//
//  FullView.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/7.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit

class FullView: UIView {

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        // 自动适应父视图大小
        self.autoresizesSubviews = true
        self.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]
        self.backgroundColor = UIColor.blackColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        // 自动适应父视图大小
        self.autoresizesSubviews = true
        self.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]
        self.backgroundColor = UIColor.blackColor()

        
    }

}
