//
//  MyVideoPlayView.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/7.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit
import AVFoundation
import ReachabilitySwift
import SnapKit
import MediaPlayer

let myWindow = UIApplication.sharedApplication().delegate?.window

let iOS8 = (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0

// 枚举
enum ControlType {
    case progressControl
    case voiceControl
    case lightControl
    case noneControl
}


// 协议
protocol MyVideoPlayViewDelegate {
    
    // 返回按钮
    func backAction()
    // 分享按钮
    func shareAction()
    
}


class MyVideoPlayView: UIView, mySliderDelegate,VideoPlayerBottomColumnViewDelegate,VideoPlayerTopColumnViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate {


    /**  播放地址URL */
    var urlString: String!
    /**  协议 */
    var delegate: MyVideoPlayViewDelegate!
    /**  包含在哪一个控制器中 */
    var contrainerViewController: UIViewController!
    /**  播放器 */
    var player: AVPlayer!
    /**  播放器的layer */
    var playerLayer: AVPlayerLayer!
    /**  播放器的playItem */
    var currentItem: AVPlayerItem!
    /**  背景图片 */
    var bgImageView: UIImageView!
    /**  全屏控制器  */
    var fullVC: FullViewController!
    /**  播放时间 */
    var playTime: NSTimer!
    /**  视频总长度 */
    var duration: Float!
    /**  视频当前进度 */
    var currentTime: Float!
    /**  监控进度 */
    var timeObserve: AnyObject!
    /**  是否移动slider */
    var isSeeking = false
    
    
    /**  视频底部栏 */
    var columnView: VideoPlayerBottomColumnView!
    /**  是否隐藏上下栏 */
    var isHideColumn = true
    /**  是否处于暂停状态  */
    var isPause = false
    /**  判断是否为第一次布局 */
    var isFisrtConfig = false
    /**  判断是否是全屏状态 */
    var isFullScreen = false
    /**  用来规定是否可以全屏 */
    var canFullScreen = false
    
    
    /** 视频顶部栏*/
    var topColumnView: VideoPlayerTopColumnView!
    
    /**  屏幕中间的滑动时间显示的view */
    var timeView: TimeSheetView!
    /**  触摸开始触碰到的点 */
    var touchBeginPoint: CGPoint!
    /**  是否在滑动屏幕 */
    var isTouch = false
    /**  判断手势是否移动过*/
    var hasMoved = false
    
    /** 音量控制控件 */
    var volumeView: MPVolumeView!
    /** 用这个来控制音量 */
    var volumeSlider: UISlider!
    /** 记录触摸开始的音量 */
    var touchBeginVoiceValue: Float!
    
    
    /** 亮度View */
    var lightView: LightView!
    /** 记录触摸开始亮度 */
    var touchBeginLightValue: CGFloat!
    /** 给显示亮度的view添加毛玻璃效果 */
    var effectView: UIVisualEffectView!
    
    
    /** 枚举*/
    var controlType: ControlType!
    
    /**  返回按钮 */
   // var backButton: UIButton!
    /**  分享按钮 */
    var shareButton: UIButton!
    
    
    /**  这个是用来切换全屏时, 将self添加到不同的位置 */
    var avplayerSuperView: UIView!
    /**  横屏闭包 */
    // 定义闭包类型，类型别名－> 首字母一定要大写
    internal typealias PortraitClosure = ((ConstraintMaker!) -> Void)
    var portraitClosure: PortraitClosure?
    /**  竖屏闭包 */
    internal typealias LandscapeClosure = ((ConstraintMaker!) -> Void)
    var landscapeClosure: LandscapeClosure?
    
    
    internal typealias LayoutClosure = ((ConstraintMaker!) -> Void)


    //MARK: - Initialization
    init(frame: CGRect,urlString: String) {
        
        super.init(frame: frame)
        self.urlString = urlString
        self.createPlayer()
        self.configureUI()
        
        
        
    }
    // 第二种方法
    //    convenience init(frame: CGRect,urlString: String) {
    //
    //        self.init(frame: frame)
    //
    //    }
    //MARK: - 添加通知
    private func addNotic() {
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoPlayView.startPlay(_:)), name: AVPlayerItemTimeJumpedNotification, object: nil)
        
        // 播放结束通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoPlayView.playEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoPlayView.resignActiveNotification(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoPlayView.becomeActiveNotification(_:)), name:UIApplicationDidBecomeActiveNotification, object: nil)

        // 添加在线视频缓存通知
        self.currentItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.New, context: nil)
        // AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
        self.currentItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        self.currentItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.New, context: nil)

        self.currentItem.addObserver(self, forKeyPath: "presentationSize", options: NSKeyValueObservingOptions.New, context: nil)

    }
    //MARK: - 移除通知
    private func removeObserver() {
        
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemTimeJumpedNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
         NSNotificationCenter.defaultCenter().removeObserver(self)

        
        self.currentItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.currentItem.removeObserver(self, forKeyPath: "status")
        self.currentItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.currentItem.removeObserver(self, forKeyPath: "presentationSize")


    }
    //MARK: - 开始播放
    func startPlay(sender: AnyObject?) {
        
        self.isFisrtConfig = false
        print("startPlay")
        // 获取总的播放时间
        let totalTime = Int(self.currentItem.duration.value) / Int(self.currentItem.duration.timescale)
        self.columnView.totalTimeLabel.text = self.timeFormatted(totalTime)
        
        
//        self.timeObserve = self.player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue(), usingBlock: { (time) in
//            
//            // 当前时间
//            let currentTimeSec = Int(CMTimeGetSeconds(self.player.currentTime()))
//            self.currentTime = Float(currentTimeSec)
//            self.currentTimeLabel.text = self.timeFormatted(currentTimeSec)
//
//            self.slider.value = Float(currentTimeSec) / Float(totalTime)
//
//        })
        
        if self.playTime != nil {
            
            self.playTime.invalidate()
            
        }
        if self.player != nil {
            // 加一个计时器
            self.playTime = NSTimer(timeInterval: 0.25, target: self, selector: #selector(MyVideoPlayView.progressSliderMove(_:)), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(self.playTime, forMode: NSDefaultRunLoopMode)
            self.playTime.fire()

        } else {
            
            print("11111111")
        }

    }
    //MARK: - 计时器方法（处理进度）
    func progressSliderMove(sender: AnyObject) {
        
        //print("计时中。。。。。")
        // 当前时间
        let currentTimeSec = Int(CMTimeGetSeconds(self.player.currentTime()))
        
        
        self.currentTime = Float(currentTimeSec)
        // 总时间
        let totalTime = Int(self.currentItem.duration.value) / Int(self.currentItem.duration.timescale)
        //let totalTime = self.duration
        
        let nowString = self.timeFormatted(currentTimeSec)
        // 如果不是在移动slider中
        if self.isSeeking == false {
            

            self.columnView.currentTimeLabel.text = nowString

            self.columnView.slider.value = Float(currentTimeSec) / Float(totalTime)

        }
    }
    // MARK: - 播放完毕
    func playEnd(sender: AnyObject) {
        
        print("播放结束")
        self.playTime.invalidate()
        self.player.pause()
        let cmTime = CMTimeMake(Int64(0), 1)
        self.player.seekToTime(cmTime)
        //self.removeObserver()

    }
    //MARK: - 创建Player
    private func createPlayer() {
        
        if  (self.player == nil)  {
            
            self.isFisrtConfig = true
            self.player = AVPlayer()
            
        }
        
    }
    //MARK: - 配置UI
    private func configureUI() {
        
        self.multipleTouchEnabled = true
                
        // 背景图片
        self.bgImageView = UIImageView(frame: self.bounds)
        self.bgImageView.image = UIImage(named: "bg_media_default.jpg")
        self.addSubview(self.bgImageView)

        
        // playerLayer
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.frame = self.bounds
        self.bgImageView.layer.addSublayer(self.playerLayer)

        
        self.createTimeView()
        self.createVolumeView()
        self.createLightView()
        
//        // 给进度条添加手势
//        let tap = UITapGestureRecognizer(target: self, action: #selector(MyVideoPlayView.hideOrShowBtnClick(_:)))
//        tap.delegate = self
//        tap.numberOfTapsRequired = 1
//        tap.numberOfTouchesRequired = 1
//        self.columnView.slider.addGestureRecognizer(tap)
        // 视频顶部栏
        self.topColumnView = VideoPlayerTopColumnView(frame: CGRectMake(0,0,SCREENW,40))
        self.topColumnView.delegate = self
        self.topColumnView.hidden = true
        self.addSubview(self.topColumnView)
        
        // 视频底部栏
        columnView  = VideoPlayerBottomColumnView(frame: CGRectMake(0,self.frame.size.height - 50,SCREENW,50))
        columnView.tag = 100
        //columnView.userInteractionEnabled = false
        self.columnView.hidden = true
        columnView.delegate = self
        columnView.slider.delegate = self
        columnView.backgroundColor = UIColor.blackColor()
        self.addSubview(columnView)

        
    }
    //MARK: - 创建timeView
    private func createTimeView(){
        
        self.timeView = TimeSheetView(frame: CGRectMake(0,0,150,70))
        self.timeView.layer.cornerRadius = 10.0
        self.timeView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        self.timeView.hidden = true
        self.addSubview(self.timeView)
        
        

    }
    //MARK: - 创建控制声音的控制器, 通过self.volumeSlider来控制声音
    private func createVolumeView() {
        
        self.volumeView = MPVolumeView()
        self.volumeView.showsRouteButton = false
        self.volumeView.showsVolumeSlider = false
        
        for view in self.volumeView.subviews {
            
            if NSStringFromClass(view.classForCoder) == "MPVolumeSlider" {
                
                self.volumeSlider = view as? UISlider
                break
            }
            
        }
        
        self.addSubview(self.volumeView)
        
    }
    //MARK: - 用来创建用来显示亮度的view
    private func createLightView() {
        
        myWindow!!.translatesAutoresizingMaskIntoConstraints = false
        if iOS8 {
            
            self.effectView = UIVisualEffectView(frame: self.bounds)
            UIView.animateWithDuration(0.5) {
                
                let blur: UIBlurEffect = UIBlurEffect(style: .ExtraLight)
                self.effectView = UIVisualEffectView(effect: blur)
            }
            self.effectView.alpha = 0
            self.effectView.contentView.layer.cornerRadius = 10.0
            self.effectView.layer.masksToBounds = true
            self.effectView.layer.cornerRadius = 10.0
            
            self.lightView = LightView(frame: CGRectZero)
            self.lightView.translatesAutoresizingMaskIntoConstraints = false
            self.lightView.alpha = 0
            self.effectView.contentView.addSubview(self.lightView)
            
            self.lightView.snp_makeConstraints(closure: { (make) in
                
                make.edges.equalTo(self.effectView)
                
            })
            myWindow!?.addSubview(self.effectView)
            
            self.effectView.snp_makeConstraints(closure: { (make) in
                
                make.center.equalTo(self.effectView.superview!)
                make.width.equalTo(155)
                make.height.equalTo(155)
                
            })
            
            
        } else {
            
            self.lightView = LightView(frame: CGRectMake(0,0,155,155))
            self.lightView.translatesAutoresizingMaskIntoConstraints = false
            self.lightView.alpha = 0
            myWindow!?.addSubview(self.lightView)
            
            self.lightView.snp_makeConstraints(closure: { (make) in
                
                make.center.equalTo(myWindow!!)
                make.width.equalTo(155)
                make.height.equalTo(155)
                
            })

        }
        
    }

    
    
    //MARK: - 设置播放视频
    func playVideo() {
    
        let url = NSURL(string: self.urlString)
        let item = AVPlayerItem(URL: url!)
        self.currentItem = item
        
        
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        // 判断连接状态
        if reachability.isReachable(){
            print("网络连接：可用")
        }else{
            print("网络连接：不可用")
        }
        
        // 判断连接类型
        if reachability.isReachableViaWiFi() {
            print("连接类型：WiFi")
            self.play()
        }else if reachability.isReachableViaWWAN() {
            print("连接类型：移动网络")
            
            let alertView = UIAlertView()
            
            
            alertView.title = "警告"
            alertView.delegate = self
            alertView.message = "当前处于2G/3G/4G状态,是否播放"
            
            alertView.addButtonWithTitle("取消")
            
            alertView.addButtonWithTitle("播放")
            
            alertView.show()
            
            
            
            

            
        }else {
            print("连接类型：没有网络连接")
            return
        }
        

    }
    private func play() {
        
        
        if self.player == nil {
            
            print("player == nil")
            return
        }
        
        self.player .replaceCurrentItemWithPlayerItem(self.currentItem)
        self.player.play()
        
        // 添加通知
        self.addNotic()
        
        // 允许slider滑动
        self.columnView.slider.userInteractionEnabled = true

    }
    //MARK: - VideoPlayerTopColumnViewDelegate
    func backAction() {
       
        delegate.backAction()

    }
    //MARK: - VideoPlayerBottomColumnViewDelegate
    //MARK: - 全屏按钮点击事件
    //MARK: - *****处理屏幕旋转位置关系****
    func fullScreenButtonClick(sender: UIButton) {
        
        sender.selected = !sender.selected
        
        if self.isFullScreen  {
            
            self.toOrientation(UIInterfaceOrientation.Portrait)
            
        } else {
            
            self.toOrientation(UIInterfaceOrientation.LandscapeRight)
        }
        
       // self.videoplayViewSwitchOrientation(sender.selected)
        
    }
    func closeFull() {
        
        if self.isFullScreen  {
            
            self.toOrientation(UIInterfaceOrientation.Portrait)

        }
        
    }
    func orientationChanged(notic: AnyObject) {
        
        let orientation = UIDevice.currentDevice().orientation
        
        switch orientation {
        case .Portrait:
            self.toOrientation(.Portrait)
            break
        case .LandscapeLeft:
            self.toOrientation(.LandscapeRight)
            break
        case .LandscapeRight:
            self.toOrientation(.LandscapeLeft)
            break
        case .PortraitUpsideDown:
            self.toOrientation(.PortraitUpsideDown)
            break
        default: break
            
        }
        
    }
    //MARK: - 以下是处理全屏旋转
    private func toOrientation(orientation: UIInterfaceOrientation) {
        
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        if currentOrientation == orientation  {
            
            return
        }
        if orientation == UIInterfaceOrientation.Portrait || orientation == UIInterfaceOrientation.PortraitUpsideDown{
            
            self.removeFromSuperview()
            self.frame = CGRectMake(0, 20, SCREENW, 200)
            self.contrainerViewController.view.addSubview(self)

            
            self.snp_removeConstraints()

            self.snp_makeConstraints(closure: { (make) in
                
                make.top.equalTo(self.contrainerViewController.view).offset(20)
                make.left.equalTo(self.contrainerViewController.view)
                make.right.equalTo(self.contrainerViewController.view)
                make.height.equalTo(200)

                
            })
            self.playerLayer.frame = CGRectMake(0, 0, SCREENW, 200)
            self.bgImageView.layer.addSublayer(self.playerLayer)

            // 视频下栏View
            self.columnView.frame = CGRectMake(0, self.frame.size.height - 50, SCREENW, 50)
            self.columnView.slider.frame = CGRectMake(60 + 50,15,SCREENW - 60 - 50 - 60 - 50,20)
            self.timeView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
            
            // 视频上栏View
            self.topColumnView.frame = CGRectMake(0, 0, SCREENW, 40)
            self.topColumnView.layoutUI(false)

            

            
        } else {
            
            if currentOrientation == UIInterfaceOrientation.Portrait || orientation == UIInterfaceOrientation.PortraitUpsideDown{
                
                
                self.removeFromSuperview()
                myWindow!!.backgroundColor = UIColor.purpleColor()
                myWindow!!.addSubview(self)
                self.frame = CGRectMake(0, 0, SCREENH, SCREENW)
                self.snp_removeConstraints()

                self.snp_makeConstraints(closure: { (make) in
                    
                    make.size.equalTo(CGSizeMake(SCREENH, SCREENW))
                    make.center.equalTo(myWindow!!)
                })
                self.playerLayer.frame = self.bounds

                // 视频下栏View
                self.columnView.frame = CGRectMake(0, self.frame.size.height - 50, SCREENH, 50)
                self.columnView.slider.frame = CGRectMake(60 + 50,15,SCREENH - 60 - 50 - 60 - 50,20)
                self.timeView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                // 视频上栏View
                self.topColumnView.frame = CGRectMake(0, 0, SCREENH, 60)
                self.topColumnView.layoutUI(true)


                self.bringLightViewToFront()

            }


        }
        UIApplication.sharedApplication().statusBarOrientation = orientation
        UIView.beginAnimations(nil, context: nil)
        // 旋转视频播放的view和显示亮度的view
        self.transform = self.getOrientation(orientation)
        self.lightView.transform = self.getOrientation(orientation)
        UIView.setAnimationDuration(0.5)
        UIView.commitAnimations()
        
        
    }
    func getOrientation(orientation: UIInterfaceOrientation) -> CGAffineTransform {
        
        
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation

        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            
            return CGAffineTransformIdentity
        }
        if currentOrientation == UIInterfaceOrientation.Portrait {
            self.toPortraitUpdate()
            return CGAffineTransformIdentity;
            
        } else if currentOrientation == UIInterfaceOrientation.LandscapeLeft {
            
            self.toLandscapeUpdate()

            return CGAffineTransformMakeRotation(CGFloat(-M_PI_2))

            
        } else if currentOrientation == UIInterfaceOrientation.LandscapeRight {
            self.toLandscapeUpdate()
            return CGAffineTransformMakeRotation(CGFloat(M_PI_2))

        }

        return CGAffineTransformIdentity
        
    }
    private func toPortraitUpdate() {
        
        self.isFullScreen = false

        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        if UIApplication.sharedApplication().statusBarHidden {
            
            UIApplication.sharedApplication().statusBarHidden = false
        }
    }
    private func toLandscapeUpdate() {
        
        self.isFullScreen = true
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        if self.topColumnView.hidden {
            
            UIApplication.sharedApplication().statusBarHidden = true

        } else {
            UIApplication.sharedApplication().statusBarHidden = false

        }

    }
    //MARK: - 播放暂停按钮点击事件
    func playAndPauseButtonClick(sender: UIButton) {

        sender.selected = !sender.selected
        
        // 暂停
        if sender.selected {
            
            self.player.pause()
            
            self.playTime.fireDate = NSDate.distantFuture()
            self.isPause = true

            print("暂停")
            
        } else {
            // 播放
            self.player.play()

            self.playTime.fireDate = NSDate()
            self.isPause = false
            print("播放")

        }
        
        
    }
    //MARK: - 转换时间（00:00）
    private func timeFormatted(totalSeconds: Int) -> String {
        
        
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        
        return String(format: "%02d:%02d", minutes, seconds)
        
        
    }
    
    //MARK: - KVO(监控视频各种状态)
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "isTopAndBottomShouldShow" {
            
        } else if keyPath == "loadedTimeRanges" {
            
            
            // 计算缓冲进度
            let timeInterval = self.availableDuration()
            // 计算总播放时间
            let duration = self.currentItem.duration
            let totalDuration = CMTimeGetSeconds(duration)
            self.duration = Float(totalDuration)
            // 显示缓冲进度
            self.columnView.slider.bufferValue = timeInterval / Float(totalDuration)
            
            
        }  else if keyPath == "status" {
            
            if self.player.status == .Failed {
                
                print("Failed")
                
            } else if self.player.status == .ReadyToPlay {
                print("ReadyToPlay")
                
                if self.isFisrtConfig == true {
                    
                    self.startPlay(nil)

                }
                
            } else if self.player.status == .Unknown {
                
                print("Unknown")
                
            }

        } else if keyPath == "playbackLikelyToKeepUp" {
            
            if self.isFisrtConfig == false {
                
                
                print("playbackLikelyToKeepUp")
            }
            
        } else if keyPath == "presentationSize" {
            
            // 用来监测屏幕旋转
            UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoPlayView.orientationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)

            
        } else {
            
            
        }
        
        
    }
    // 暂停
    private func pause(){
        
        self.player.pause()
        
        self.playTime.fireDate = NSDate.distantFuture()

        
    }
    // 继续播放
    private func goonPlay(){
        
        self.player.play()
        
        self.playTime.fireDate = NSDate()

    }
    //MARK: - 计算缓冲进度
    private func availableDuration() -> Float {
        
        let ranges = self.player.currentItem?.loadedTimeRanges
        // 获取缓冲区域
        let timeRange = ranges?.first!.CMTimeRangeValue
        let startSeconds = CMTimeGetSeconds((timeRange?.start)!)
        let durationSeconds = CMTimeGetSeconds((timeRange?.duration)!)
        // 计算缓冲总进度
        let result = Float(startSeconds + durationSeconds)
        
        return result
        
    }
    //MARK: - mySliderDelegate
    func sliderValueChangeDidBegin(slider: MySlider) {
        
        print("sliderValueChangeDidBegin")
        
        isSeeking = true
        
    }

    func sliderValueChanged(slider: MySlider) {
        
        print("slider.value = \(slider.value)")
        
        if slider == self.columnView.slider {
            
            let progress = self.duration * slider.slider.value
            self.currentTime = progress
            self.columnView.currentTimeLabel.text = self.timeFormatted(Int(self.currentTime))

        }
        print("sliderValueChanged")
    }
    func sliderValueChangeDidEnd(slider: MySlider) {
        print("sliderValueChangeDidEnd")

        
        if slider == self.columnView.slider {
            
            let progress = self.duration * slider.slider.value
            self.currentTime = progress
            self.columnView.currentTimeLabel.text = self.timeFormatted(Int(self.currentTime))
            
            self.isSeeking = false

            //播放到
            let cmTime = CMTimeMake(Int64(self.currentTime), 1)
            self.player.seekToTime(cmTime)
            
        }

        
    }
    
    //MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        print(buttonIndex)
        if buttonIndex == 0 {
            
            print("取消")
            
        } else {
            
            print("播放")

            self.play()

        }
        
    }
    //MARK: -
    //MARK: - notic 进入前后台通知
    func resignActiveNotification(notic:AnyObject) {
        
        print("进入后台")
        self.pause()
        
    }
    func becomeActiveNotification(notic: AnyObject) {
        
        print("返回前台")
        if self.isPause == false {
            
            self.goonPlay()

        }
    }
    //MARK: - 
    //MARK: - Tap Actions
    func tapAction(tap: UITapGestureRecognizer) {
        
        
        
        
    }
    //MARK: - 隐藏或者显示上下栏手势
    func hideOrShowBtnClick(sender: AnyObject?) {
        
        // 防止点击底部栏视图隐藏
        let point = sender!.locationInView(self)
        var subY =  self.frame.size.height - self.columnView.frame.size.height
        if self.isFullScreen == true {
            
            subY = self.frame.size.width - self.columnView.frame.size.height
        }
        let flag: Bool = (point.y < subY) && (point.y != 0) ? true : false
        
        let topSubY = self.topColumnView.frame.height
        let topFlag: Bool = (point.y > topSubY) && (point.y != 0) ? true : false
        
        self.isHideColumn = !self.isHideColumn
        
        if self.isHideColumn  && flag  && topFlag {
            
            self.columnView.hidden = true
            self.topColumnView.hidden = true
            
            if self.isFullScreen == true {
                
                UIApplication.sharedApplication().statusBarHidden = true

            }


        } else {
            
            self.columnView.hidden = false
            self.topColumnView.hidden = false
            UIApplication.sharedApplication().statusBarHidden = false


        }

        
    }

    //MARK: - 处理滑动视频时手势
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        super.touchesBegan(touches, withEvent: event)
        
        self.hasMoved = false
        self.touchBeginVoiceValue = self.volumeSlider.value
        self.touchBeginLightValue = UIScreen.mainScreen().brightness
        self.touchBeginPoint = (touches as NSSet).anyObject()?.locationInView(self)
        //print("touchesBegan")
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        super.touchesMoved(touches, withEvent: event)
        
        //print("touchesMoved")
        // 如果移动的距离过于小, 就判断为没有移动
        let tempPoint = (touches as NSSet).anyObject()?.locationInView(self)
        if (fabs((tempPoint?.x)! - self.touchBeginPoint.x) < 15) && (fabs((tempPoint?.y)! - self.touchBeginPoint.y) < 15) {
            
            print("移动距离过小")
            return
        } else {
            
            //self.hasMoved = true
            
            let tan = fabs(tempPoint!.y - self.touchBeginPoint.y) / fabs(tempPoint!.x - self.touchBeginPoint.x)
            
            // 当滑动角度小于30度的时候, 进度手势
            if tan < 1 / sqrt(3) {
                
                self.controlType = ControlType.progressControl
                self.hasMoved = true

                 print("hahahahahah")
                let value = self.moveProgressControllWithTempPoint(tempPoint!)
                self.timeValueChangingWithValue(value)
                
                self.isSeeking = true
                
                self.columnView.currentTimeLabel.text = self.timeFormatted(Int(value))
                
                self.columnView.slider.value = Float(value) / Float(self.duration)
                
            } else if tan > 1 / sqrt(3) {
                // 亮度
                if  self.touchBeginPoint.x < self.bounds.size.width / 2  {
                    self.hasMoved = true
                    self.controlType = ControlType.lightControl

                    print("亮度")
                    self.hideTheLightViewWithHidden(false)
                    var tempLightValue = self.touchBeginLightValue - ((tempPoint!.y - self.touchBeginPoint.y)/self.bounds.size.height)
                    if tempLightValue < 0 {
                        tempLightValue = 0
                    } else if tempLightValue > 1 {
                        tempLightValue = 1
                    }
                    // 控制亮度的方法
                    UIScreen.mainScreen().brightness = tempLightValue

                    // 实时改变现实亮度进度的view
                    self.lightView.changeLightViewWithValue(Float(tempLightValue))

                    
                } else {
                    // 声音
                    print("声音")
                    self.controlType = ControlType.voiceControl

                    let voiceValue = self.touchBeginVoiceValue - Float((tempPoint!.y - self.touchBeginPoint.y)/self.bounds.size.height)
                    if voiceValue < 0 {
                        
                        self.volumeSlider.value = 0
                    } else if voiceValue > 1 {
                        self.volumeSlider.value = 1
                    } else {
                        self.volumeSlider.value = voiceValue
                    }

                }
                
            } else {
                
                print("3303030303")
            }

        }
        

        

    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        super.touchesEnded(touches, withEvent: event)
        
        print("touchesEnded")
        if self.hasMoved == true {
            
            let tempPoint = (touches as NSSet).anyObject()?.locationInView(self)
            let value = self.moveProgressControllWithTempPoint(tempPoint!)
            
            self.isSeeking = false
            
            self.hideTheLightViewWithHidden(true)
            
            
            //播放到
            //let changedTime = CMTimeMakeWithSeconds(Float64(value), 1)
            let cmTime = CMTimeMake(Int64(value), 1)
            //self.player.seekToTime(changedTime)
            if self.controlType == ControlType.progressControl {
                
                self.player.seekToTime(cmTime) { (finished) in
                    
                    self.player.play()
                    
                }

            }

            self.timeView.hidden = true
        } else {
            
            //self.touchBeginPoint = (touches as NSSet).anyObject()?.locationInView(self)

            self.hideOrShowBtnClick((touches as NSSet).anyObject())
            
        }


    }
    //MARK: - 用来控制移动过程中计算手指划过的时间
    private func moveProgressControllWithTempPoint(tempPoint: CGPoint) -> Float {
        
        var tempVaule: Float = self.currentTime + 90 * Float((tempPoint.x - self.touchBeginPoint.x) / SCREENW)
        if tempVaule >= self.duration {
            
            tempVaule = self.duration
            
        } else if tempVaule <= 0 {
            tempVaule = 0.0
        }
        //print(tempVaule)
        return tempVaule
        
    }
    //MARK: - 用来显示时间的view在时间发生变化时所作的操作
    private func timeValueChangingWithValue(value: Float) {
        
        if value > self.currentTime {
            
            self.timeView.sheetStateImageView.image = UIImage(named: "progress_icon_r")
            
        } else if value < self.currentTime {
            
            self.timeView.sheetStateImageView.image = UIImage(named: "progress_icon_l")

        }
        self.timeView.hidden = false

        let tempTime = self.timeFormatted(Int(value))
        let totalTime = self.timeFormatted(Int(self.duration))
        self.timeView.sheetTimeLabel.text = String(format: "%@/%@", tempTime,totalTime)
    }
    //MARK: - 用来控制显示亮度的view, 以及毛玻璃效果的view
    private func hideTheLightViewWithHidden(hidden: Bool) {
        
        if hidden {
            
            UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { 
                
                self.lightView.alpha = 0.0
                if iOS8 {
                    self.effectView.alpha = 0.0
                }
                
                }, completion: nil)
            
        } else {
            
            self.alpha = 1.0
            if iOS8 {
                
                self.lightView.alpha = 1.0
                self.effectView.alpha = 1.0
                
            }
        }
        
    }
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.bringLightViewToFront()
    }
    private func bringLightViewToFront() {
        
        if iOS8 {
            myWindow!?.bringSubviewToFront(self.effectView)
        } else {
            myWindow!?.addSubview(self.lightView)
        }
    }
    
    //MARK: - 
    //MARK: - 以下是销毁以及销毁后再播放的相关方法
    //MARK: - 
    func destoryAVPlayer() {
        
        self.removeFromSuperview()

        if self.playTime != nil {
            
            self.playTime.invalidate()
            
        }
        if self.player != nil {
            
            self.player.pause()
            self.player = nil
            
        }
        if (self.currentItem != nil) {
            
            self.removeObserver()

        }

        self.currentItem = nil
        self.player = nil
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
