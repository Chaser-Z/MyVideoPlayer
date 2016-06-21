//
//  VideoPlayerTopColumnView.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/20.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit

protocol VideoPlayerTopColumnViewDelegate {
    func backAction()
}

class VideoPlayerTopColumnView: UIView {

    /**  返回按钮 */
    var backButton: UIButton!
    var delegate: VideoPlayerTopColumnViewDelegate!
    /**  判断是否是全屏状态 */
    var isFullScreen = false
    
    /** 电池栏 */
    var topView: UIView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.configureUI()
    }
    private func configureUI() {
        
        self.backgroundColor = UIColor.colorWith(redColor: 0, green: 0, blue: 0, alpha: 0.6)
        
        topView = UIView()
        self.addSubview(topView)
        // 添加约束 - Visual Format Language(VFL)
        let topViewDictionary = ["topView":topView]
        let topViewHList = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[topView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: topViewDictionary)
        let topViewVList = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[topView(==20)]", options: NSLayoutFormatOptions(), metrics: nil, views: topViewDictionary)
        self.addConstraints(topViewHList)
        self.addConstraints(topViewVList)
        // 还有为了避免和系统生成的自动伸缩的约束不冲突 一般加上这句
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = UIColor.colorWith(redColor: 94, green: 85, blue: 72, alpha: 1)

        if self.isFullScreen == false {
            
            topView.hidden = true
        }
        
        // 返回按钮
        self.backButton = UIButton(type: .Custom)
        if self.isFullScreen == false {
            
            self.backButton.frame = CGRectMake(5, 19/2, 21, 21)

        }
        self.backButton.setImage(UIImage(named: "btn_back"), forState: .Normal)
        self.backButton.addTarget(self, action: #selector(VideoPlayerTopColumnView.backBtnClick(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(self.backButton)
        
    }
    func layoutUI(isFullScreen: Bool) {
        
        if isFullScreen {
            
            self.topView.hidden = false
            self.backButton.frame = CGRectMake(5, 20 + 19/2, 21, 21)

            
        } else {
            
            self.topView.hidden = true
            self.backButton.frame = CGRectMake(5, 19/2, 21, 21)
        }
        
    }
    func backBtnClick(btn: UIButton) {
        
        delegate.backAction()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
