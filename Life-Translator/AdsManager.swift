//
//  AdsManager.swift
//  Life-Translator
//
//  Created by Robin Champsaur on 07/11/2017.
//  Copyright © 2017 Robin Champsaur. All rights reserved.
//

import UIKit
import Foundation

class AdsManager: UIViewController {
   
    @IBOutlet weak var removeAdsSupportButton: UIButton!
   
    public static let adsPurchase = "com.robin.champsaur.polyglot.Ads"
    
    func disableAds(){
        let defaults = UserDefaults.standard
        defaults.set("false", forKey: "adDisplay")
    }
    
    @IBAction func removeAdsSupportAction(_ sender: Any) {
        IAPHandler.shared.purchaseMyProduct(index: 0)
        disableAds()
    }
    
    @IBAction func removeAdsFreeAction(_ sender: Any) {
        disableAds()
    }
}
