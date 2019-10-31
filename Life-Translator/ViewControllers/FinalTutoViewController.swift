//
//  FinalTutoViewController.swift
//  Life-Translator
//
//  Created by Robin Champsaur on 13/08/2019.
//  Copyright © 2019 Robin Champsaur. All rights reserved.
//

import Foundation

import UIKit

class FinalTutoViewController: UIViewController {
    
    @IBAction func dismissViewButtonAction(_ sender: Any) {
    
        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

    }
}
