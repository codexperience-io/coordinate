//
//  Coordinating.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

public protocol Coordinated: AnyObject {
    var parentCoordinator: Coordinating? { get set }
}

// This protocol is the base for every Coordinator, which is to encapsulate the rootViewController and be able to be coordinated by a parent Coordinator
public protocol Coordinating: Coordinated, HasEvents {
    // Unique string to identify specific Coordinator instance.
    //
    // By default it will be String representation of the Coordinator's subclass.
    // If you directly instantiate `Coordinator<T>`, then you need to set it manually.
    var identifier: String { get }
    
    // Bool indicating if Coordinator is started.
    var isStarted: Bool { get }
    
    // Tells the coordinator to start, which means at the end of this method it should
    // display some UIViewController.
    func start(with completion: @escaping () -> Void)
    
    // Tells the coordinator to stop, which means it should clear out any internal stuff
    // it possibly tracks.
    func stop(with completion: @escaping () -> Void)
    
    // Activate Coordinator which was used before.
    //
    // This method is used when the Coordinator is visible again, giving you the chanee to do things like refreshing data, track screen usage, etc
    func activate()
    
    // This method returns the Coordinator rootViewController
    func getRootViewController() -> UIViewController
}

internal protocol HasChildren {
    var childCoordinators: [String: Coordinating] { get }
}
