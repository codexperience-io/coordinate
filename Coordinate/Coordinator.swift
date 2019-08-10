//
//  Coordinator.swift
//  Coordinate Library
//
//  Copyright © 2019 · https://codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

/*
 Coordinators are a design pattern that encourages decoupling view controllers
 such that they know as little as possible about how they are presented.
 As such, View Controllers should never directly push/pop or present other VCs.
 They should not be aware of their existence.
 
 That is Coordinator's job.
 
 Coordinators can be “nested” such that child coordinators encapsulate different flows
 and prevent any one of them from becoming too large.
 
 Each coordinator has an identifier to simplify logging and debugging.
 Identifier is also used as key for the `childCoordinators` dictionary.
 
 You should never use this class directly (although you can).
 Make a proper subclass and add specific behavior for the given particular usage.
 
 Note: Don't overthink this. Idea is to have fairly small number of coordinators in the app.
 If you embed controllers into other VC (thus using them as simple UI components),
 then keep that flow inside the given container controller.
 Expose to Coordinator only those behaviors that cause push/pop/present to bubble up.
 */

import UIKit

// Main Coordinator instance, where T is UIViewController or any of its subclasses.
open class Coordinator<T: UIViewController>: UIResponder, Coordinating {
    
    public let rootViewController: T
    
    open lazy var identifier: String = {
        return String(describing: type(of: self))
    }()
    
    /// You need to supply UIViewController (or any of its subclasses) that will be loaded as root of the UI hierarchy.
    ///    Usually one of container controllers (UINavigationController, UITabBarController etc).
    ///
    /// - returns: Coordinator instance, fully prepared but started yet.
    ///
    ///    Note: if you override this init, you must call `super`.
    public override init() {
        self.rootViewController = T()
        super.init()
        rootViewController.coordinator = self
    }
    
    ///    Next coordinatingResponder for any Coordinator instance is its parent Coordinator.
    open override var coordinatingResponder: UIResponder? {
        return parent as? UIResponder
    }
    
    //    MARK:- Lifecycle
    
    private(set) public var isStarted: Bool = false
    
    /// Tells the coordinator to create/display its initial view controller and take over the user flow.
    ///    Use this method to configure your `rootViewController` (if it isn't already).
    ///
    ///    Some examples:
    ///    * instantiate and assign `viewControllers` for UINavigationController or UITabBarController
    ///    * assign itself (Coordinator) as delegate for the shown UIViewController(s)
    ///    * setup closure entry/exit points
    ///    etc.
    ///
    ///    - Parameter completion: An optional `Callback` executed at the end.
    ///
    ///    Note: if you override this method, you must call `super` and pass the `completion` closure.
    open func start(with completion: @escaping () -> Void = {}) {
        isStarted = true
        completion()
    }
    
    
    /// Tells the coordinator that it is done and that it should
    ///    clear out its backyard.
    ///
    ///    Possible stuff to do here: dismiss presented controller or pop back pushed ones.
    ///
    ///    - Parameter completion: Closure to execute at the end.
    ///
    ///    Note: if you override this method, you must call `super` and pass the `completion` closure.
    open func stop(with completion: @escaping () -> Void = {}) {
        rootViewController.coordinator = nil
        isStarted = false
        completion()
    }
    
    ///    Coordinator can be in memory, but it‘s not currently displaying anything.
    ///    For example, coordinator started some other Coordinator which then took over root VC to display its VCs,
    ///    but did not stop this one.
    ///
    ///    Parent Coordinator can then re-activate this one, in which case it should take-over the
    ///    the ownership of the root VC.
    ///
    ///    Note: if you override this method, you should call `super`
    ///
    ///    By default, it sets itself as `coordinator` for its `rootViewController`.
    open func activate() {
        rootViewController.coordinator = self
    }
    
    //    MARK:- Containment
    
    open weak var parent: Coordinating?
    
    ///    A dictionary of child Coordinators, where key is Coordinator's identifier property.
    ///    The only way to add/remove something is through `startChild` / `stopChild` methods.
    private(set) public var childCoordinators: [String: Coordinating] = [:]
    
    /**
     Adds new child coordinator.
     */
    public func addChild(coordinator: Coordinating) {
        childCoordinators[coordinator.identifier] = coordinator
        coordinator.parent = self
    }
    
    /**
     Starts child.
     
     - Parameter coordinator: The coordinator implementation to start.
     - Parameter completion: An optional `Callback` passed to the coordinator's `start()` method.
     */
    public func startChild(coordinator: Coordinating, completion: @escaping () -> Void = {}) {
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
    public func stopChild(coordinator: Coordinating, completion: @escaping () -> Void = {}) {
        coordinator.parent = nil
        coordinator.stop {
            [unowned self] in
            
            self.childCoordinators.removeValue(forKey: coordinator.identifier)
            completion()
        }
    }
    
    // MARK: - Helper Methods
    
    public func getCached<T>(_ coordinatorType: T.Type) -> T? {
        let identifier = String(describing: coordinatorType)
        return childCoordinators[identifier] as? T
    }
    
    public func startOrActivateChild(coordinator: Coordinating) {
        if coordinator.isStarted {
            coordinator.parent = self
            coordinator.activate()
        } else {
            self.startChild(coordinator: coordinator)
        }
    }
    
    public func getRootViewController() -> UIViewController {
        return rootViewController
    }
    
    // MARK: - Default presentation methods from UIViewController
    
    open func show(_ coordinator: Coordinating, sender: Any?) {
        startOrActivateChild(coordinator: coordinator)
        rootViewController.show(coordinator.getRootViewController(), sender: sender)
    }
    
    open func present(_ coordinator: Coordinating, animated: Bool, completion: (() -> Void)?) {
        startOrActivateChild(coordinator: coordinator)
        rootViewController.present(coordinator.getRootViewController(), animated: animated, completion: completion)
    }
    
    open func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        rootViewController.dismiss(animated: animated, completion: completion)
    }
}
