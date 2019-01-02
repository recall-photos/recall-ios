//
//  AuthViewController.swift
//  Recall
//
//  Created by Tiago Alves on 02/01/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit
import Blockstack

class AuthViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginViaBlockstack() {
        Blockstack.shared.signIn(redirectURI: "https://app.recall.photos/redirect-mobile.html",
                                 appDomain: URL(string: "https://app.recall.photos")!,
                                 manifestURI: nil,
                                 scopes: ["store_write", "publish_data"]) { authResult in
                                    switch authResult {
                                    case .success( _):
                                        print("sign in success")
                                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                            AppDelegate.shared.rootViewController.switchToMainScreen()
                                        })
                                    case .cancelled:
                                        print("sign in cancelled")
                                    case .failed(let error):
                                        print("sign in failed")
                                        print(error!)
                                    }
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
