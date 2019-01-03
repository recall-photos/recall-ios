//
//  SplashViewController.swift
//  Recall
//
//  Created by Tiago Alves on 02/01/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit
import Blockstack

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Fetching blockstack login status")
        
        if (Blockstack.shared.isUserSignedIn()) {
            print("Logged in")
            AppDelegate.shared.rootViewController.switchToMainScreen()
        } else {
            print("Not logged in")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                AppDelegate.shared.rootViewController.switchToAuthScreen()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
