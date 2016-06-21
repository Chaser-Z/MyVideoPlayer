//
//  TimeSheetView.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/13.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit

class TimeSheetView: UIView {

    var sheetStateImageView: UIImageView!
    var sheetTimeLabel: UILabel!
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.createUI()
    }
    private func createUI() {
        
        self.backgroundColor = UIColor.colorWith(redColor: 100, green: 100, blue: 100, alpha: 0.7)
        
        self.sheetStateImageView = UIImageView(frame: CGRectMake(54, 12, 43, 25))
        self.sheetStateImageView.image = UIImage(named: "progress_icon_l")
        self.addSubview(self.sheetStateImageView)
        
        self.sheetTimeLabel = UILabel(frame: CGRectMake(16, 49, 118, 16))
        self.sheetTimeLabel.text = "00:00:00/00:00:00"
        self.sheetTimeLabel.font = UIFont(name: "Arial-BoldItalicMT", size: 12)
        self.sheetTimeLabel.textAlignment = NSTextAlignment.Center
        self.sheetTimeLabel.textColor = UIColor.whiteColor()
        self.addSubview(self.sheetTimeLabel)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

}
