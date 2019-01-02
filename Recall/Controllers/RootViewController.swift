//
//  RootViewController.swift
//  Recall
//
//  Created by Tiago Alves on 02/01/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    private var current: UIViewController
    
    required init?(coder aDecoder: NSCoder) {
        self.current = SplashViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.current = storyboard?.instantiateViewController(withIdentifier: "splashController") as! SplashViewController
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switchToMainScreen() {
        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "mainTabController") as! UITabBarController
        animateFadeTransition(to: mainTabController)
    }
    
    func switchToAuthScreen() {
        let authViewController = self.storyboard?.instantiateViewController(withIdentifier: "authController") as! AuthViewController
        animateFadeTransition(to: authViewController)
    }
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)
        self.view.addSubview(new.view)
        new.view.alpha = 0
        new.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            new.view.alpha = 1
            self.current.view.alpha = 0
        }) { (finished) in
            self.current.view.removeFromSuperview()
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
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
