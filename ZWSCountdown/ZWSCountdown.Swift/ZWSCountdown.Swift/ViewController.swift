//
//  ViewController.swift
//  ZWSCountdown.Swift
//
//  Created by zhaowensky on 2017/1/5.
//  Copyright © 2017年 ZWS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var labTime: UILabel!
    var countdownUtils:ZWSCountdownUtils?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneAction(_ sender: Any) {
        if(countdownUtils != nil){
            countdownUtils?.stopCountdown()
        }
        
        weak var weakSelf:ViewController! = self
        countdownUtils = ZWSCountdownUtils.init();
        countdownUtils?.startCountdown(startPhone: "911", startBusiness: "911", second: 60, callback: { (temp) in
            weakSelf.labTime.text = String(temp) + "s"
        })
    }

}

