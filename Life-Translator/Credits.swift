//
//  Credits.swift
//  Life-Translator
//
//  Created by Robin Champsaur on 07/11/2017.
//  Copyright © 2017 Robin Champsaur. All rights reserved.
//

import Foundation
import UIKit

class Credits: UIViewController {
    
    @IBAction func robinChampsaurAction(_ sender: Any) {
        openUrl(urlStr: "http://robinchampsaur.me")
    }
    
    func openUrl(urlStr:String!) {
        if let url = NSURL(string:urlStr) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
}
