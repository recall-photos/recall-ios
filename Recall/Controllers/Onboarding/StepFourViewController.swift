//
//  StepFourViewController.swift
//  Recall
//
//  Created by Tiago Alves on 25/03/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit
import Blockstack

class StepFourViewController: UIViewController {
    
    @IBOutlet weak var cta : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cta.layer.cornerRadius = 4
        cta.layer.borderWidth = 1
        cta.layer.borderColor = cta.backgroundColor!.cgColor
    }
    
    @IBAction func getStarted() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "sawOnboarding")
        
        if (Blockstack.shared.isUserSignedIn()) {
            AppDelegate.shared.rootViewController.switchToMainScreen()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                AppDelegate.shared.rootViewController.switchToAuthScreen()
            })
        }
    }

}
