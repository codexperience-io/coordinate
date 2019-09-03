//
//  Coordinating.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

/// This protocol is to be appliead to every UIViewController that is a rootViewController of a Coordinator.
public protocol Coordinated: AnyObject {
    /**
     The parent Coordinator
    */
    var parentCoordinator: Coordinating? { get set }
}

/// This protocol is the base for every Coordinator, which is to encapsulate the rootViewController and be able to be coordinated by a parent Coordinator
public protocol Coordinating: Coordinated, HasEvents {
    /**
     Unique string to identify specific Coordinator instance.
    
     By default it will be the String representation of the Coordinator's subclass.
     If you directly instantiate `Coordinator<T>`, then you need to set it manually.
    */
    var identifier: String { get }
    
    /// Bool indicating if Coordinator is started.
    var isStarted: Bool { get }
    
    /**
     Starts the Coordinator.
     
     Override this method if you want to perform any setup before the Coordinator presents anything.
    */
    func start(with completion: @escaping () -> Void)
    
    /**
     Stops the Coordinator.
     
     Override this method to perform any logic before the Coordinator is deinitialized
    */
    func stop(with completion: @escaping () -> Void)
    
    /**
     Activate Coordinator which was started before.
    
     This method is used when the Coordinator is visible again, giving you the chanee to do things like refreshing data, track screen, etc.
    */
    func activate()
    
    /// Returns the Coordinator rootViewController
    func getRootViewController() -> UIViewController
}

/// Intern protocol for Coordinators that manage children
internal protocol HasChildren {
    /// An array containing the children Coordinators
    var childCoordinators: [String: Coordinating] { get }
}
