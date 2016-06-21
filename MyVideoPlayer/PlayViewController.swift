//
//  PlayViewController.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/13.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD

class PlayViewController: UIViewController,MyVideoPlayViewDelegate {

    
    var myPlayerView: MyVideoPlayView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarOrientation = .Portrait

        
        self.view.backgroundColor = UIColor.whiteColor()
        myPlayerView = MyVideoPlayView(frame: CGRectMake(0, 20, SCREENW, 200), urlString: "http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4")
        myPlayerView.avplayerSuperView = self.view
        self.myPlayerView.playVideo()
        self.myPlayerView.delegate = self
        self.view.addSubview(myPlayerView)
        
        self.myPlayerView.contrainerViewController = self
        
        
        
        let label = UILabel()
        label.frame = CGRectMake(0, 300,SCREENW, 100)
        label.numberOfLines = 0
        label.text = "dsljfslijflsdjfldsjflkdjslfkjdslkfjlsdkjfldsknfldsjfoiewjfoiwejflejflejflekjflekfknmfeflknelknfl"
        self.view.addSubview(label)
        label.backgroundColor = UIColor.greenColor()

    
    }
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)

        self.myPlayerView.destoryAVPlayer()
        self.myPlayerView = nil

        
    }
    override func viewDidDisappear(animated: Bool){
        
        super.viewDidDisappear(animated)

    }
    
    //MARK: - MyVideoPlayViewDelegate
    func backAction() {
        
        print("返回")
        if self.myPlayerView.isFullScreen {
            
            self.myPlayerView.closeFull()
        } else {
            
//            UIApplication.sharedApplication().statusBarOrientation = .Portrait
//            
//            self.myPlayerView.transform = self.myPlayerView.getOrientation(UIInterfaceOrientation.Portrait)

            self.dismissViewControllerAnimated(true, completion: nil)


        }
        
    }
    func shareAction() {
        
    }
    //MARK: - 关闭设备自动旋转, 然后手动监测设备旋转方向来旋转avplayerView
    override func shouldAutorotate() -> Bool {
        
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return .Portrait
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
