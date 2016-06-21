//
//  MySlider.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/8.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit

// 协议
protocol mySliderDelegate {
    
    func sliderValueChangeDidBegin(slider: MySlider)
    func sliderValueChanged(slider: MySlider)
    func sliderValueChangeDidEnd(slider: MySlider)
    
}


class MySlider: UIControl {

    
    /**  UISlider */
    var slider: UISlider!
    /**  UIProgressView */
    var progressView: UIProgressView!
    /** mySliderDelegate */
    var delegate: mySliderDelegate!
    /**  */
    var value: Float! {
     
        didSet{
            
            if self.slider.value >= 1 {
                
                self.slider.value = 1
                
            } else {
              
                self.slider.value = value

            }
        }
        
    }
    /** 缓存值 */
    var bufferValue: Float! {
    
        didSet {
            
            if self.progressView.progress >= 1 {
                
                self.progressView.progress = 1
                
            } else {
                
                self.progressView.progress = bufferValue
                
            }

        }
        
    }

    
    /**  */
    var thumbTintColor: UIColor! {
        
        didSet {
            
            
            self.slider.thumbTintColor = thumbTintColor
        }
        
        
    }
    /**  进度颜色 */
    var minimumTrackTintColor: UIColor! {
        
        didSet {
            
            self.slider.minimumTrackTintColor = minimumTrackTintColor

        }
  
    }
    /** 进度条已经走完的那部分颜色 */
    var middleTrackTintColor: UIColor! {
        
        didSet {
            
            self.progressView.progressTintColor = middleTrackTintColor

        }
      
    }
    /** 进度条没有走完的那部分颜色 */
    var maximumTrackTintColor: UIColor! {
        
        didSet {
            
            self.progressView.trackTintColor = maximumTrackTintColor

        }
        
    }
    /**  */
    var thumbImage: UIImage! {
        
        didSet {
            
            self.slider.setThumbImage(thumbImage, forState: .Normal)

        }
      }
    /** 设置进度条走完进度颜色图片 */
    var minimumTrackImage: UIImage! {
        
        didSet {
            
            self.slider.setMinimumTrackImage(minimumTrackImage, forState: .Normal)

        }
    }
    /**  */
    var middleTrackImage: UIImage! {
        
        didSet {
            
            
            self.progressView.progressImage = middleTrackImage

        }
     }
    /**  */
    var maximumTrackImage: UIImage! {
        
        didSet {
            
            self.slider.setMaximumTrackImage(UIImage.imageWithColor(UIColor.clearColor(), size: maximumTrackImage.size), forState: .Normal)

            self.progressView.trackImage = maximumTrackImage

        }
        
    }
    /**  */
    var loaded: Bool! = false
    /**  */
    var target: AnyObject!
    /**  */
    var action: Selector!


    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.loadSubView()
    }
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.loadSubView()

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadSubView() {
        
        if (self.loaded == true) {
            
            return
        }
        self.loaded = true
        
        self.backgroundColor = UIColor.clearColor()
        
        self.slider = UISlider(frame: CGRectZero)
        self.slider.autoresizingMask = [UIViewAutoresizing.FlexibleWidth,UIViewAutoresizing.FlexibleHeight]
        //self.slider.continuous = false
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        self.addSubview(self.slider)
        
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChangeDidBegin(_:)), forControlEvents: .TouchDown)
        
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChangeDidEnd(_:)), forControlEvents: .TouchUpInside)
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChangeDidEnd(_:)), forControlEvents: .TouchCancel)
        self.slider.addTarget(self, action: #selector(MySlider.sliderValueChangeDidEnd(_:)), forControlEvents: .TouchUpOutside)

        
        self.progressView = UIProgressView(frame: CGRectZero)
        self.progressView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth,UIViewAutoresizing.FlexibleHeight]
        self.progressView.userInteractionEnabled = false
        
        self.slider.addSubview(self.progressView)
        self.slider.sendSubviewToBack(self.progressView)
        
        self.progressView.progressTintColor = UIColor.darkGrayColor()
        self.progressView.trackTintColor = UIColor.lightGrayColor()
        self.slider.maximumTrackTintColor = UIColor.clearColor()
        
    }
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.slider.frame = self.bounds
        var rect = self.slider.bounds
        rect.origin.x = rect.origin.x + 2
        rect.size.width = rect.size.width - 2 * 2
        self.progressView.frame = rect
        self.progressView.center = self.slider.center
    }
    func sliderValueChangeDidBegin(slider: UISlider) {
        
        self.delegate.sliderValueChangeDidBegin(self)
    }
    func sliderValueChanged(slider: UISlider) {
        
        self.delegate.sliderValueChanged(self)
    }
    func sliderValueChangeDidEnd(slider: UISlider) {
        
        self.delegate.sliderValueChangeDidEnd(self)
        
        
    }
    
    //MARK: - 设置slider的图片
    func setThumbImage(thumbImage: UIImage,state: UIControlState) {
        
        self.slider.setThumbImage(thumbImage, forState: state)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("点击")
    }

}

/** 扩展 UIImage */
extension UIImage {
    
    // public class func animatedImageNamed(name: String, duration: NSTimeInterval) -> UIImage? // read sequence of files with suffix starting at 0 or 1
    
    class func imageWithColor(color: UIColor,size: CGSize) -> UIImage {
        
        var image: UIImage!
        
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    
    
}
