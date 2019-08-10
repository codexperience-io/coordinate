//
//  NavigationCoordinator.swift
//  Coordinate Library
//
//  Copyright © 2019 · https://codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

open class NavigationCoordinator<T: UINavigationController>: Coordinator<T>, UINavigationControllerDelegate {

    /*
     This is a mirror of the UINavigationController.viewControllers, useful to test later if a UIViewController was popped or not
    */
    open var currentViewControllers: [UIViewController] = []

    /*
        If you subclass NavigationCoordinator, then override this method if you need to do something special when customer taps the UIKit's backButton in the navigationBar or the UINavigationController pops back to another view controller
     
        By default, it activates the Coordinator that was popped into
     */
    open func poppedBack(to coordinator: Coordinating?) {
        coordinator?.activate()
    }

    //    MARK:- Coordinator lifecycle

    open override func start(with completion: @escaping () -> Void) {
        // assign itself as UITabBarControllerDelegate
        rootViewController.delegate = self
        // must call this
        super.start(with: completion)
    }
    
    open override func activate() {
        super.activate()
        
        // Also activate the Coordinator of the visible UIViewController
        rootViewController.topViewController?.coordinator?.activate()
    }
    
    //  MARK:- Navigation
    
    /*
     This is a convenience method to set the rootViewController from the UINavigationController, or to pop to it in case it is already on the navigation stack
    */
    open func root(_ coordinator: Coordinating, animated: Bool = false, completion: (() -> Void)? = nil) {
        self.startOrActivateChild(coordinator: coordinator)
        let viewController = coordinator.getRootViewController()

        if rootViewController.viewControllers.first != viewController {
            self.rootViewController.setViewControllers([viewController], animated: false)
        } else {
            self.popToCoordinator(coordinator, animated: false)
        }
    }
    
    /*
     Analog to UINavigationController.show()
     
     If a Coordinator+UIViewController is already on the navigation stack, the UINavigationController will be pop to it
     If you override this method, keep in mind that UIViewController cannot be pushed twice to the same navigation stack, or you will get an error
    */
    open override func show(_ coordinator: Coordinating, sender: Any?) {
        self.startOrActivateChild(coordinator: coordinator)
        let viewController = coordinator.getRootViewController()
        
        if rootViewController.topViewController != viewController {
            if rootViewController.viewControllers.contains(viewController) == false {
                rootViewController.show(viewController, sender: self)
            } else {
                self.popToCoordinator(coordinator, animated: true)
            }
        }
    }
    
    /*
     Analog to UINavigationController.popToViewController()
    */
    open func popToCoordinator(_ coordinator: Coordinating, animated: Bool) {
        self.startOrActivateChild(coordinator: coordinator)
        let viewController = coordinator.getRootViewController()
        
        rootViewController.popToViewController(viewController, animated: animated)
    }
    
    // MARK: - UINavigationControllerDelegate
    
    /*
     This method tries to determine if a UIViewController was effectively popped (i.e. is back visually on the navigation stack)
    */
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // No change, so we don't need to react to it
        if viewController === currentViewControllers.last {
            return
        }
        
        // Make sure we have a valid index
        guard let index = currentViewControllers.firstIndex(of: viewController) else {
            return
        }
        
        // No change, so we don't need to react to it
        let lastIndex = currentViewControllers.count - 1
        if lastIndex <= index {
            return
        }
        
        // Means that the UINavigationController actually popped to another UIViewController, so here we call poppedBack() to have a chance
        // of reacting to this event
        poppedBack(to: viewController.coordinator)
    }
    
    /*
     This method will sync the current UINavigationControllers.viewControllers so that we can later use it to determine if a UIViewController was popped or not
    */
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.currentViewControllers = rootViewController.viewControllers
    }
}
