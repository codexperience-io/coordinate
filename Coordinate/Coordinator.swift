//
//  Coordinator.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

// Main Coordinator instance, where T is UIViewController or any of its subclasses
// This is the base Coordinator class, intended to be used for simple Coordinators that do not manage any child Coordinator. Use this as a wrapper to encapsulate your UIViewController, to manage its data fetching, modeling and other stuff that should not be of the UIViewController's concern. The idea is that the UIViewController will only need input of information to produce an output, it should not care about where this data came from and who and how is presenting it
open class Coordinator<T>: NSObject, Coordinating where T: UIViewController, T: Coordinated {
    public var rootViewController: T
    
    open lazy var identifier: String = {
        return String(describing: type(of: self))
    }()
    
    open weak var parentCoordinator: Coordinating?
    
    private(set) public var isStarted: Bool = false
    
    // This is the beginning of the Coordinator Lifecycle. It will set the rootViewController as a instance of T and assign itself as the Coordinator of the same UIViewController.
    //
    // If you need to override this, because your T needs arguments to be initialized or other reason, do not forget to assign this Coordinator rootViewController and the UIViewController Coordinator to this instance. This is essentially the required connection to make the rest work
    public override init()  {
        self.rootViewController = T()
        super.init()
        rootViewController.parentCoordinator = self
    }
    
    // MARK:- Lifecycle
    
    // Tells the coordinator to create/display its initial view controller and take over the user flow. Use this method to start anything that might be necessary before its rootViewController is presented
    //
    //    - Parameter completion: An optional `Callback` executed at the end.
    //
    // Note: if you override this method, you must call `super` and pass the `completion` closure.
    open func start(with completion: @escaping () -> Void = {}) {
        isStarted = true
        completion()
    }
    
    // Tells the coordinator that it is done and that it should clear out its backyard.
    //
    // Possible stuff to do here: dismiss presented controller or pop back pushed ones.
    //
    //    - Parameter completion: Closure to execute at the end.
    //
    // Note: if you override this method, you must call `super` and pass the `completion` closure.
    open func stop(with completion: @escaping () -> Void = {}) {
        rootViewController.parentCoordinator = nil
        isStarted = false
        completion()
    }
    
    // By default this is empy, but always call super.activte() in case you override this to make sure its compatible with future implementations
    open func activate() {
    }
    
    public func getRootViewController() -> UIViewController {
        return rootViewController
    }
    
    // MARK: - HasEvents
    
    public func emitEvent(_ event: CoordinateEvents) {
        if self.interceptEvent(event) == false {
            parentCoordinator?.emitEvent(event)
        }
    }
    
    // default implementation, to capture events override this method to perform the logic you want
    open func interceptEvent(_ event: CoordinateEvents) -> Bool {
        return false
    }
}
