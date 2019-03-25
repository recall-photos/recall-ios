//
//  OnboardViewController.swift
//  Recall
//
//  Created by Tiago Alves on 25/03/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit

class OnboardViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var pageControl = UIPageControl()
    
    func getStepOne() -> UIViewController {
        return storyboard!.instantiateViewController(withIdentifier: "StepOne")
    }
    
    func getStepTwo() -> UIViewController {
        return storyboard!.instantiateViewController(withIdentifier: "StepTwo")
    }
    
    func getStepThree() -> UIViewController {
        return storyboard!.instantiateViewController(withIdentifier: "StepThree")
    }
    
    func getStepFour() -> UIViewController {
        return storyboard!.instantiateViewController(withIdentifier: "StepFour")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        configurePageControl()
        self.setViewControllers([getStepOne()], direction: .forward, animated: false, completion: nil)
    }
    
    func configurePageControl() {
        let defaultColor = UIColor.init(red: 39.0/255.0, green: 15.0/255.0, blue: 51.0/255.0, alpha: 0.3)
        let selectedColor = UIColor.init(red: 39.0/255.0, green: 15.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.tintColor = selectedColor
        pageControl.pageIndicatorTintColor = defaultColor
        pageControl.currentPageIndicatorTintColor = selectedColor
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        if pageContentViewController.restorationIdentifier == "StepOne" {
            self.pageControl.currentPage = 0
        } else if pageContentViewController.restorationIdentifier == "StepTwo" {
            self.pageControl.currentPage = 1
        } else if pageContentViewController.restorationIdentifier == "StepThree" {
            self.pageControl.currentPage = 2
        } else if pageContentViewController.restorationIdentifier == "StepFour" {
            self.pageControl.currentPage = 3
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.restorationIdentifier == "StepOne" {
            return getStepTwo()
        } else if viewController.restorationIdentifier == "StepTwo" {
            return getStepThree()
        } else if viewController.restorationIdentifier == "StepThree" {
            return getStepFour()
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.restorationIdentifier == "StepTwo" {
            return getStepOne()
        } else if viewController.restorationIdentifier == "StepThree" {
            return getStepTwo()
        } else if viewController.restorationIdentifier == "StepFour" {
            return getStepThree()
        } else {
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
