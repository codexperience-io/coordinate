//
//  ContainerCoordinator.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

/**
 The simplest Coordinator that can have other children Coordinators.
 
 This does everything that Coordinator does plus managing the hierarchy and navigation flow, i.e. how the children are presented and where in the navigation flow.
 The idea is that you can use it as a "switch" between any kind of Coordinator.
*/
open class ContainerCoordinator<T>: Coordinator<T>, HasChildren where T: UIViewController, T: Coordinated {
    
    /// An array containing the children Coordinators
    private(set) public var childCoordinators: [String : Coordinating] = [:]
    
    /// The currently presented UIViewController inside this Coordinator
    private(set) open var currentViewController: UIViewController?
    
    //    MARK:- Containment
    
    /**
     Adds new child Coordinator.
     */
    internal func addChild(coordinator: Coordinating) {
        childCoordinators[coordinator.identifier] = coordinator
        coordinator.parentCoordinator = self
    }
    
    /**
     Starts child.
     
     - Parameter coordinator: The Coordinator implementation to start.
     - Parameter completion: An optional `Callback` passed to the Coordinator's `start()` method.
    */
    internal func startChild(coordinator: Coordinating, completion: @escaping () -> Void = {}) {
        if childCoordinators[coordinator.identifier] == nil {
            self.addChild(coordinator: coordinator)
        }
        coordinator.start(with: completion)
    }
    
    /**
     Stops the given child coordinator and removes it from the `childCoordinators` array
     
     - Parameter coordinator: The coordinator implementation to stop.
     - Parameter completion: An optional `Callback` passed to the coordinator's `stop()` method.
     */
    internal func stopChild(coordinator: Coordinating, completion: @escaping () -> Void = {}) {
        coordinator.parentCoordinator = nil
        coordinator.stop {
            [unowned self] in
            
            self.childCoordinators.removeValue(forKey: coordinator.identifier)
            completion()
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     Returns a cached children Coordinator if it exists
     
     - Parameter coordinatorType: The Coordinator.Type from the Coordinator to be returned.
     
     Use this method to verify if the Coordinator you want to present is not already in use to avoid wasting resources or creating conflicts
    */
    public func getCached<C>(_ coordinatorType: C.Type) -> C? {
        let identifier = String(describing: coordinatorType)
        return childCoordinators[identifier] as? C
    }
    
    /// Helper method used internally
    internal func startOrActivateChild(coordinator: Coordinating) {
        if let parentHasDependencies = self as? HasDependenciesProtocol, let childHasDependencies = coordinator as? HasDependenciesProtocol {
            childHasDependencies.setDependencies(dependencies: parentHasDependencies.getDepencencies())
        }
        
        if coordinator.isStarted {
            coordinator.parentCoordinator = self
            coordinator.activate()
        } else {
            self.startChild(coordinator: coordinator)
        }
    }
    
    // MARK: - Presentation methods mirroring UIViewController
    
    
    // The idea here is to provide the Coordinator with the ability to present its children Coordinator, without having to refer the children rootViewController. Because this is the base Coordinator class and its rootViewControoler is supposed to be a base UIVIewController, this is essentially a mirror of the main presentation methods of UIVIewController, just using Coordinator as its argument.
     
    // If you need, you can implement other presentation methods, but remember to always call `startOrActivateChild` on the Coordinator that is going to be presented.
    
    /**
     Analog to UIViewController's `show(_ vc: UIViewController, sender: Any?)` method but for Coordinators.
     
     - Parameter coordinator: The Coordinator with the rootViewController to be presented.
     - Parameter sender: The sender.
     
     It makes sure that the Coordinator is properly initialized before presenting its rootViewController.
    */
    public func show(_ coordinator: Coordinating, sender: Any?) {
        startOrActivateChild(coordinator: coordinator)
        rootViewController.show(coordinator.getRootViewController(), sender: sender)
    }
    
    /**
     Analog to UIViewController's `present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil)` method but for Coordinators.
     
     - Parameter coordinator: The Coordinator with the rootViewController to be presented.
     - Parameter animated: Whether the transition should be animated or not.
     - Parameter completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     
     It makes sure that the Coordinator is properly initialized before presenting its rootViewController
     */
    public func present(_ coordinator: Coordinating, animated: Bool, completion: (() -> Void)?) {
        startOrActivateChild(coordinator: coordinator)
        rootViewController.present(coordinator.getRootViewController(), animated: animated, completion: completion)
    }
    
    /**
     Analog to UIViewController's `dismiss(animated flag: Bool, completion: (() -> Void)? = nil)` method but for Coordinators.
     
     - Parameter animated: Whether the transition should be animated or not.
     - Parameter completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     
     */
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        rootViewController.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - Custom presentation methods
    
    /**
     On a ContainerCoordinator, we can stack other Coordinators and change them with or without animation with this method.
     
     - Parameter coordinator: The Coordinator with the rootViewController to be presented.
     - Parameter animated: Whether the transition should be animated or not.
     - Parameter completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     
     You can override this method and use custom Animations/Transitions.
    */
    open func root(_ coordinator: Coordinating, animated: Bool = false, completion: (() -> Void)? = nil) {
        startOrActivateChild(coordinator: coordinator)
        
        let viewController = coordinator.getRootViewController()
        
        // Avoid re-setting the same rootViewController
        if currentViewController == viewController { return }
        
        // Add new ViewController
        rootViewController.addChild(viewController)
        viewController.view.alpha = animated ? 0 : 1
        rootViewController.view.insertSubview(viewController.view, at: 0)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.topAnchor.constraint(equalTo: rootViewController.view.topAnchor).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor).isActive = true
        
        viewController.didMove(toParent: rootViewController)
        
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveLinear,
                           animations: {
                            
                            viewController.view.alpha = 1
                            
            }, completion: { [weak self] _ in
                self?.replaceCurrentViewController(with: viewController, completion: completion)
            })
        } else {
            replaceCurrentViewController(with: viewController, completion: completion)
        }
    }
    
    /// internal helper method
    private func replaceCurrentViewController(with viewController: UIViewController, completion: (() -> Void)? = nil) {
        // Remove current ViewController, if existing
        if let currentViewController = currentViewController {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }
        
        // Replace current ViewController
        currentViewController = viewController
        
        completion?()
    }
}
