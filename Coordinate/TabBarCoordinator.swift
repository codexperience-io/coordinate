//
//  TabBarCoordinator.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

/**
The TabBarCoordinator is a specialized ContainerCoordinator for UITabBarController

 It is to be used with a UITabBarCoordinator as rootViewController and has specific logic to cope with the intricacies of said UITabBarController. It has specialized presentation methods that mirror the ones from UITabBarController.
*/
open class TabBarCoordinator<T>: ContainerCoordinator<T>, UITabBarControllerDelegate where T: UITabBarController, T: Coordinated {
    
    /**
     Starts the Coordinator.
     
     - Parameter completion: An optional `Callback` executed at the end.
     
     In this particular case, it also assigns the rootViewController as the UITabBarControllerDelegate.
     If you override this method do not forget to call `super.start()` or the subclass won't work properly.
     */
    open override func start(with completion: @escaping () -> Void) {
        // assign itself as UITabBarControllerDelegate
        rootViewController.delegate = self
        // must call this
        super.start(with: completion)
    }
    
    /**
     Analog to UITabBarController's `setControllers()`.
     
     Use this to set the UITabBarController children Coordinators and its UIViewControllers/Tabs pairs.
     This is usually called inside `start()` because the UITabBarController needs to know its children in order to populate the TabBar with the corresponding buttons.
    */
    public func setCoordinators(_ coordinators: [Coordinating]) {
        coordinators.forEach { coordinator in
            self.addChild(coordinator: coordinator)
            
            if rootViewController.viewControllers == nil {
                rootViewController.viewControllers = [coordinator.getRootViewController()]
            } else {
                rootViewController.viewControllers?.append(coordinator.getRootViewController())
            }
        }
    }
    
    /**
     Callback for when a Tab is tapped.
     
     - Parameter coordinator: Coordinator corresponding to the tapped Tab.
     
     Override this method to intercept Tab taps so that you can do things before and after the Tab is changed,
     like setting loading states, async calls, etc.
     
     By default it selects the Coordinator immediately.
    */
    open func tabTapped(for coordinator: Coordinating) {
        select(coordinator)
    }
    
    // MARK: - Navigation
    
    /**
     Allows you to programatically select a Tab corresponding to the Coordinator you want
     
     - Parameter coordinator: Coordinator to be selected.
    */
    public func select(_ coordinator: Coordinating) {
        
        startOrActivateChild(coordinator: coordinator)
        
        let viewController = coordinator.getRootViewController()
        
        guard let index = rootViewController.viewControllers?.firstIndex(of: viewController) else {
            return
        }
        
        rootViewController.selectedViewController = viewController
        rootViewController.selectedIndex = index
    }
    
    // MARK: - UITabBarControllerDelegate
    
    /**
     Deactivate automatic Tab switch on UITabBarController
     It calls tabTapped with the Coordinator from the specific UIViewController
    */
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let viewController = viewController as? Coordinated else { return false }

        if let coordinator = viewController.parentCoordinator {
            tabTapped(for: coordinator)
        }
        
        return false
    }
}
