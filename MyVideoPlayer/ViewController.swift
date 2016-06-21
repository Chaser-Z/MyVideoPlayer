//
//  ViewController.swift
//  MyVideoPlayer
//
//  Created by yeeaoo on 16/6/7.
//  Copyright © 2016年 枫韵海. All rights reserved.
//

import UIKit

let SCREENW = UIScreen.mainScreen().bounds.width
let SCREENH = UIScreen.mainScreen().bounds.height

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let btn = UIButton(type: .Custom)
        btn.frame = CGRectMake(0, 100, SCREENW, 100)
        btn.setTitle("下一页", forState: .Normal)
        btn.addTarget(self, action: #selector(ViewController.btnClick), forControlEvents: .TouchUpInside)
        btn.backgroundColor = UIColor.purpleColor()
        self.view.addSubview(btn)
        
        
     
        
        
    }
    func btnClick() {
        
        let playVC = PlayViewController()
        self.presentViewController(playVC, animated: true, completion: nil)
        
    }
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


}

