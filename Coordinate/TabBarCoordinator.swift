//
//  TabBarCoordinator.swift
//  Coordinate Library
//
//  Copyright © 2019 · https://codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

open class TabBarCoordinator<T: UITabBarController>: Coordinator<T>, UITabBarControllerDelegate {
    
    open override func start(with completion: @escaping () -> Void) {
        // assign itself as UITabBarControllerDelegate
        rootViewController.delegate = self
        // must call this
        super.start(with: completion)
    }
    
    /*
     Analog to UITabBarController.setControllers(),
     Use this to set the UITabBarController children Coordinators and its UIViewControllers/Tabs pairs
    */
    open func setCoordinators(_ coordinators: [Coordinating]) {
        coordinators.forEach { coordinator in
            self.addChild(coordinator: coordinator)
            
            if rootViewController.viewControllers == nil {
                rootViewController.viewControllers = [coordinator.getRootViewController()]
            } else {
                rootViewController.viewControllers?.append(coordinator.getRootViewController())
            }
        }
    }
    
    /*
     Override this method to intercept Tab taps so that you can do things before and after the Tab is changed,
     like setting loading states, async calls, etc
     
     By default it selects the Coordinator immediately
    */
    open func tabTapped(for coordinator: Coordinating) {
        select(coordinator)
    }
    
    // MARK:- Navigation
    
    /*
     Allows you to programatically select a Tab corresponding to the Coordinator you want
    */
    open func select(_ coordinator: Coordinating) {
        
        startOrActivateChild(coordinator: coordinator)
        
        let viewController = coordinator.getRootViewController()
        
        guard let index = rootViewController.viewControllers?.firstIndex(of: viewController) else {
            return
        }
        
        rootViewController.selectedViewController = viewController
        rootViewController.selectedIndex = index
    }
    
    // MARK:- UITabBarControllerDelegate
    
    /*
     Deactivate automatic Tab switch on UITabBarController
     It calls tabTapped with the Coordinator from the specific UIViewController
    */
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let coordinator = viewController.coordinator {
            tabTapped(for: coordinator)
        }
        
        return false
    }
}
