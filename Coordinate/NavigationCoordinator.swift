//
//  NavigationCoordinator.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

/**
 The NavigationCoordinator is a specialized `ContainerCoordinator` for UINavigationControlelrs

 It is to be used with a UINavigationController as rootViewController and it has specific logic to cope with the intricacies of said UINavigationController. It has specialized presentation methods that mirror the ones from UINavigationController.
*/
open class NavigationCoordinator<T>: ContainerCoordinator<T>, UINavigationControllerDelegate where T: UINavigationController, T: Coordinated {

    /**
     This is a mirror of the UINavigationController.viewControllers, useful to test later if a UIViewController was popped or not
    */
    private(set) open var currentViewControllers: [UIViewController] = []

    //  MARK:- Coordinator lifecycle

    /**
     Starts the Coordinator.

     - Parameter completion: An optional `Callback` executed at the end.
     
     In this particular case, it also assigns the rootViewController as the UINavigationControllerDelegate.
     If you override this method do not forget to call `super.start()` or the subclass won't work properly.
    */
    open override func start(with completion: @escaping () -> Void) {
        // assign itself as UITabBarControllerDelegate
        rootViewController.delegate = self
        // must call this
        super.start(with: completion)
    }
    
    /**
     Activates the Coordinator. This is called everytime the Coordinator is about to be presented
     
     If you override this method do not forget to call `super.activate()` or the subclass won't work properly.
    */
    open override func activate() {
        super.activate()
        
        // Also activate the Coordinator of the visible UIViewController
        guard let topViewController = rootViewController.topViewController as? Coordinated else { return }
        topViewController.parentCoordinator?.activate()
    }
    
    // MARK: - Presentation methods mirroring UINavigationController
    
    /**
     Convenience method to set the rootViewController from the UINavigationController, or to pop to it in case it is already on the navigation stack.
     
     - Parameter coordinator: The Coordinator with the rootViewController to be presented.
     - Parameter animated: Whether the transition should be animated or not.
     - Parameter completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
    */
    open override func root(_ coordinator: Coordinating, animated: Bool = false, completion: (() -> Void)? = nil) {
        self.startOrActivateChild(coordinator: coordinator)
        let viewController = coordinator.getRootViewController()

        if rootViewController.viewControllers.first != viewController {
            self.rootViewController.setViewControllers([viewController], animated: false)
        } else {
            self.popToCoordinator(coordinator, animated: false)
        }
    }
    
    /**
     Analog to UINavigationController's `show(_ vc: UIViewController, sender: Any?)`
     
     - Parameter coordinator: The Coordinator with the rootViewController to be presented.
     - Parameter sender: The sender.
     
     If a Coordinator+UIViewController is already on the navigation stack, the UINavigationController will be pop to it
     If you override this method, keep in mind that UIViewController cannot be pushed twice to the same navigation stack, or you will get an error
    */
    public override func show(_ coordinator: Coordinating, sender: Any?) {
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
    
    /**
     Analog to UINavigationController's `popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?`

     - Parameter coordinator: The Coordinator with the rootViewController to be presented.
     - Parameter animated: Whether the transition should be animated or not.
     
     */
    public func popToCoordinator(_ coordinator: Coordinating, animated: Bool) {
        self.startOrActivateChild(coordinator: coordinator)
        let viewController = coordinator.getRootViewController()
        
        rootViewController.popToViewController(viewController, animated: animated)
    }
    
    // MARK: - Handle Pop Back
    
    /**
     This method tries to determine if a UIViewController was effectively popped (i.e. is back visually on the navigation stack)
     
     - Parameter viewController: The view controller whose view and navigation item properties are being shown.

    */
    public func checkPoppedBack(viewController: UIViewController) {
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
        
        guard let viewController = viewController as? Coordinated else { return }
        
        // Means that the UINavigationController actually popped to another UIViewController, so here we call poppedBack() to have a chance
        // of reacting to this event
        poppedBack(to: viewController.parentCoordinator)
    }
    
    /**
     Callback called with the Coordinator belonging to the UIViewController that was just popped back.
     
     Use this to react to the pop back event that happens when a user taps the Back button or slides from left to right on a UINavigationController. By accessing the Coordinator, you have the chance to perform some logic in the wake of this event.
     
     By default, it activates the Coordinator that was popped back
     */
    open func poppedBack(to coordinator: Coordinating?) {
        coordinator?.activate()
    }
    
    // MARK: - UINavigationControllerDelegate
    
    /**
     Called just before the navigation controller displays a view controller’s view and navigation item properties.
    
     - Parameter navigationController: The navigation controller that is showing the view and properties of a view controller.
     - Parameter viewController: The view controller whose view and navigation item properties are being shown.
     - Parameter animated: true to animate the transition; otherwise, false.
     
     By default it checks if the viewControlelr was popped.
     If you override this method, do not forget to call `checkPoppedBack(viewController: UIViewController)`
    */
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.checkPoppedBack(viewController: viewController)
    }
    
    /**
     This method will sync the current UINavigationControllers.viewControllers so that we can later use it to determine if a UIViewController was popped or not
     
     - Parameter navigationController: The navigation controller that is showing the view and properties of a view controller.
     - Parameter viewController: The view controller whose view and navigation item properties are being shown.
     - Parameter animated: true to animate the transition; otherwise, false.
     
     If you override this method, do not forget to sync the viewControllers
    */
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.currentViewControllers = rootViewController.viewControllers
    }
}
