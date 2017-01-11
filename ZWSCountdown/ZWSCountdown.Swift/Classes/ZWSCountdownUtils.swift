//
//  ZWSCountdownUtils.swift
//  ZWSCountdown.Swift
//
//  Created by zhaowensky on 2017/1/5.
//  Copyright © 2017年 ZWS. All rights reserved.
//

import Foundation

typealias ZWSCountdownUtilsHandle = (Int32) -> ()

public final class ZWSCountdownUtils: NSObject{
    //MARK: - prams
    private var timer:Timer!
    private var phoneNumber:String!
    private var business:String!
    private var currentSecond:Int32 = 0
    private var totalSecond:Int32 = 0
    private var handle:ZWSCountdownUtilsHandle?
    
    private let nameEnterBackground = Notification.Name.UIApplicationDidEnterBackground;
    private let nameBecomeActive = Notification.Name.UIApplicationDidBecomeActive
    
    //MARK: - init
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector:#selector(didEnterBackground(notification:)), name: nameEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: nameBecomeActive, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self);
    }
    
    //MARK: - private
    @objc fileprivate func didEnterBackground(notification:Notification) -> Void {
        saveCountdown(phoneNumber: phoneNumber, business: business, second: currentSecond);
    }

    @objc fileprivate func didBecomeActive(notification:Notification) -> Void {
        getCountDown()
    }
    
    @objc fileprivate func updateTimer() -> Void {
        if (handle != nil){
            handle!(currentSecond)
            if (currentSecond == 0){
                timer.invalidate()
            }else{
                currentSecond -= 1
            }
        }
    }
    
    //TODO: - open
    
    /// 开启倒计时 start
    ///
    /// - Parameters:
    ///   - phoneNumber: 电话号码 phoneNumber
    ///   - business: 业务代号（eg:com.xxx.xxx）
    ///   - second: 倒计时长 time
    ///   - callback: block countdown time
    func startCountdown(startPhone:String?,startBusiness:String?,second:Int32,
                        callback:ZWSCountdownUtilsHandle?) -> Void {
        phoneNumber = startPhone
        business = startBusiness
        totalSecond = second
        
//        assert(startPhone == nil, "startPhone is nil")
//        assert(startBusiness == nil, "business is nil")
//        assert(second == 0, "totalSecond > 0")
        
        getCountDown()
        handle = callback
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopCountdown() -> Void {
        if (timer != nil){
            timer.invalidate()
        }
        if(currentSecond == 0){
            let defaults = UserDefaults.standard
            let key = phoneNumber + "_" + business
            defaults.removeObject(forKey: key)
            defaults.synchronize()
        }else{
            saveCountdown(phoneNumber: phoneNumber, business: business, second: currentSecond)
        }
    }
    
    func checkCountdown(phoneNumber:String,business:String) -> Bool {
        return getCountDownTime(phoneNumber: phoneNumber, business: business) > 0
    }
    
    //MARK: - setter / getter time
    private func saveCountdown(phoneNumber:String,business:String,second:Int32) -> Void {
        let key = phoneNumber + "_" + business
        let countValue:[String:Any] = ["second":NSNumber.init(value: second),"saveDate":Date.init()]
        let defaults = UserDefaults.standard
        defaults.set(countValue, forKey: key)
        defaults.synchronize()
    }
    
    private func getCountDown() -> Void {
        let result = getCountDownTime(phoneNumber:phoneNumber as String, business:business as String)
        if result == 0 {
            currentSecond = totalSecond
        }else{
            currentSecond = Int32(result)
        }
    }
    
    private func getCountDownTime(phoneNumber:String,business:String) -> Int32 {
        var result:Double = 0
        let key = phoneNumber + "_" + business
        
        let defaults = UserDefaults.standard
        var countValue = defaults.dictionary(forKey:key)
        let saveValue = countValue?["saveDate"] as? Date
        if (saveValue) != nil {
            let second = (countValue?["second"] as! NSNumber).doubleValue
            let timeInterval = Date().timeIntervalSince(saveValue!)
            if timeInterval >= second {
                result = 0
            }else{
                result = second - timeInterval
            }
        }
        return Int32(result)
    }
}






