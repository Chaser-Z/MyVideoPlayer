//
//  UIColorExt.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/8.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    class func colorWith(redColor red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        let color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
        return color
    }
    
    
    
    
}