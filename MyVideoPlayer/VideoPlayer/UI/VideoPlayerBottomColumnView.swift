//
//  VideoPlayerBottomColumnView.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/12.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit

protocol VideoPlayerBottomColumnViewDelegate {
    
    func fullScreenButtonClick(fullBtn: UIButton)
    func playAndPauseButtonClick(btn: UIButton)
}


class VideoPlayerBottomColumnView: UIView {

    /**  包含在哪一个控制器中 */
    var contrainerViewController: UIViewController!
    /**  全屏按钮 */
    var fullScreenButton: UIButton!
    /**  全屏控制器  */
    var fullVC: FullViewController!
    /**  播放暂停按钮 */
    var playAndPauseButton: UIButton!
    /**  播放总时间label */
    var totalTimeLabel: UILabel!
    /**  现在播放的时间label */
    var currentTimeLabel: UILabel!
    /**  播放时间 */
    var playTime: NSTimer!
    /**  播放进度slider */
    var slider: MySlider!
    
    var delegate: VideoPlayerBottomColumnViewDelegate!

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.createUI()
    }
    private func createUI() {
        
        // 全屏按钮
        self.fullScreenButton = UIButton(frame: CGRectMake(SCREENW - 50,0,50,50))
        self.fullScreenButton.setImage(UIImage(named: "btn_vdo_full"), forState: .Normal)
        self.fullScreenButton.setImage(UIImage(named: "btn_vdo_full_click"), forState: .Selected)
        self.fullScreenButton.addTarget(self, action: #selector(VideoPlayerBottomColumnView.fullScreenButtonClick(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(self.fullScreenButton)
        // 添加约束 - Visual Format Language(VFL)
        let viewsDictionary = ["fullScreenButton":self.fullScreenButton]
        let pHList = NSLayoutConstraint.constraintsWithVisualFormat("H:[fullScreenButton]-10-|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary)
        let pVList = NSLayoutConstraint.constraintsWithVisualFormat("V:[fullScreenButton]-10-|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary)
        //             let pHList = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[promptLabel]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDictionary)
        
        self.addConstraints(pHList)
        self.addConstraints(pVList)
        // 还有为了避免和系统生成的自动伸缩的约束不冲突 一般加上这句
        self.fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        // 播放暂停按钮
        self.playAndPauseButton = UIButton(frame: CGRectMake(10,0,50,50))
        self.playAndPauseButton.setImage(UIImage(named: "full_pause_btn"), forState: .Normal)
        self.playAndPauseButton.setImage(UIImage(named: "full_play_btn"), forState: .Selected)
        self.playAndPauseButton.addTarget(self, action: #selector(VideoPlayerBottomColumnView.playAndPauseButtonClick(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(self.playAndPauseButton)
        // 添加约束 - Visual Format Language(VFL)
        let playAndPauseButtonDictionary = ["playAndPauseButton":self.playAndPauseButton]
        let playAndPauseButtonHList = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[playAndPauseButton]", options: NSLayoutFormatOptions(), metrics: nil, views: playAndPauseButtonDictionary)
        let playAndPauseButtonVList = NSLayoutConstraint.constraintsWithVisualFormat("V:[playAndPauseButton]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: playAndPauseButtonDictionary)
        self.addConstraints(playAndPauseButtonHList)
        self.addConstraints(playAndPauseButtonVList)
        // 还有为了避免和系统生成的自动伸缩的约束不冲突 一般加上这句
        self.playAndPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 现在播放时间的label
        self.currentTimeLabel = UILabel()
        self.currentTimeLabel.textColor = UIColor.whiteColor()
        self.currentTimeLabel.text = "00:00"
        self.addSubview(self.currentTimeLabel)
        // 添加约束
        let currentTimeLabelDictionary = ["currentTimeLabel":self.currentTimeLabel]
        let currentTimeLabelDictionary1 = ["playAndPauseButton":self.playAndPauseButton,"currentTimeLabel":self.currentTimeLabel]
        
        // 距playAndPauseButton的距离为0
        let metrics = ["margin":0]
        
        let currentTimeLabelHList = NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[playAndPauseButton]-margin-[currentTimeLabel(==50)]", options: NSLayoutFormatOptions(), metrics: metrics, views: currentTimeLabelDictionary1)
        let currentTimeLabelVList = NSLayoutConstraint.constraintsWithVisualFormat("V:[currentTimeLabel(==20)]-15-|", options: NSLayoutFormatOptions(), metrics: nil, views: currentTimeLabelDictionary)
        self.addConstraints(currentTimeLabelHList)
        self.addConstraints(currentTimeLabelVList)
        // 还有为了避免和系统生成的自动伸缩的约束不冲突 一般加上这句
        self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        // 总的播放时间的label
        self.totalTimeLabel = UILabel()
        self.totalTimeLabel.textColor = UIColor.whiteColor()
        self.totalTimeLabel.text = "00:00"
        self.addSubview(self.totalTimeLabel)
        // 添加约束
        let totalTimeLabelDictionary = ["totalTimeLabel":self.totalTimeLabel]
        let totalTimeLabelDictionary1 = ["fullScreenButton":self.fullScreenButton,"totalTimeLabel":self.totalTimeLabel]
        
        // 距playAndPauseButton的距离为0
        let totalTimeLabelMetrics = ["margin":10]
        
        let totalTimeLabelHList = NSLayoutConstraint.constraintsWithVisualFormat("H:[totalTimeLabel(==50)]-margin-[fullScreenButton]-margin-|", options: NSLayoutFormatOptions(), metrics: totalTimeLabelMetrics, views: totalTimeLabelDictionary1)
        let totalTimeLabelVList = NSLayoutConstraint.constraintsWithVisualFormat("V:[totalTimeLabel(==20)]-15-|", options: NSLayoutFormatOptions(), metrics: nil, views: totalTimeLabelDictionary)
        self.addConstraints(totalTimeLabelHList)
        self.addConstraints(totalTimeLabelVList)
        // 还有为了避免和系统生成的自动伸缩的约束不冲突 一般加上这句
        self.totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        // slider
        self.slider = MySlider(frame: CGRectMake(60 + 50,15,SCREENW - 60 - 50 - 60 - 50,20))
        self.slider.alpha = 1
        self.slider.userInteractionEnabled = false
        self.slider.value = 0
        self.slider.bufferValue = 0
        // slider把圆点设置成图片
        self.slider.setThumbImage(UIImage(named: "bg_slider_nal")!, state: .Normal)
        self.slider.setThumbImage(UIImage(named: "bg_slider_sel")!, state: .Highlighted)
        
        self.slider.middleTrackImage = UIImage(named: "slider_buffer")
        self.slider.maximumTrackImage = UIImage(named: "slider_bg_shu")
        self.slider.minimumTrackImage = UIImage(named: "slider_progress")
        
        self.slider.middleTrackTintColor = UIColor.colorWith(redColor: 104, green: 104, blue: 104, alpha: 1)
        self.slider.maximumTrackTintColor = UIColor.colorWith(redColor: 51, green: 51, blue: 51, alpha: 1)
        self.addSubview(self.slider)

        
        
        
        
    }
    
    func fullScreenButtonClick(sender: UIButton) {
        
        delegate.fullScreenButtonClick(sender)
        
    }
    func playAndPauseButtonClick(sender: UIButton) {
        delegate.playAndPauseButtonClick(sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
}
