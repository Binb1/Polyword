//
//  Credits.swift
//  Life-Translator
//
//  Created by Robin Champsaur on 07/11/2017.
//  Copyright © 2017 Robin Champsaur. All rights reserved.
//

import Foundation
import UIKit

class CreditsViewController: UIViewController {
    
    @IBAction func robinChampsaurAction(_ sender: Any) {
        openUrl(urlStr: "http://robinchampsaur.me")
    }
    
    @IBAction func goBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func openUrl(urlStr:String!) {
        if let url = URL(string: "mailto:\(contactEmail)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}
