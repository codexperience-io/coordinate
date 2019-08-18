//
//  Coordinated+Coordinating.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

// This protocol is the base for every Coordinator, which is to encapsulate the rootViewController and be able to be coordinated by a parent Coordinator
public protocol Coordinated: AnyObject {
    //    Unique string to identify specific Coordinator instance.
    //
    //    By default it will be String representation of the Coordinator's subclass.
    //    If you directly instantiate `Coordinator<T>`, then you need to set it manually.
    var identifier: String { get }
    
    // Bool indicating if Coordinator is started.
    var isStarted: Bool { get }
    
    // Parent Coordinator can be any other Coordinator.
    var parent: Coordinating? { get set }
    
    //    Returns either `parent` coordinator or `nil` if there isn‘t one
    var coordinatingResponder: UIResponder? { get }
    
    //    Tells the coordinator to start, which means at the end of this method it should
    //    display some UIViewController.
    func start(with completion: @escaping () -> Void)
    
    //    Tells the coordinator to stop, which means it should clear out any internal stuff
    //    it possibly tracks.
    func stop(with completion: @escaping () -> Void)
    
    //    Activate Coordinator which was used before.
    //
    // This method is used when the Coordinator is visible again, giving you the change to do things like refreshing data, track screen usage, etc
    func activate()
    
    // This method returns the Coordinator rootViewController
    func getRootViewController() -> UIViewController
}

// This protocol allows a Coordinator to manage other children Coordinators and its hierarchy
public protocol Coordinating: Coordinated {
	//	A dictionary of child Coordinators, where key is Coordinator's identifier property.
	var childCoordinators: [String: Coordinated] { get }

    // Add child Coordinator to the childCoordinators dictionary but doesnt start it yet. This is useful if you want to keep track of all children before you start them, like in the case of TabBarCoordinator
    func addChild(coordinator: Coordinated)

	//	Adds the supplied coordinator into its `childCoordinators` dictionary and calls its `start` method
	func startChild(coordinator: Coordinated, completion: @escaping () -> Void)

	//	Calls `stop` on the supplied coordinator and removes it from its `childCoordinators` dictionary
	func stopChild(coordinator: Coordinated, completion: @escaping () -> Void)

    // This checks if the Coordinator is already instantiated and inside childCoordinators dictionary
    func getCached<T: Coordinated>(_ coordinatorType: T.Type) -> T?
    
    // This is used before presentation methods to make sure the Coordinator that is going to be presented is started and activated when its needed
    func startOrActivateChild(coordinator: Coordinated)
}
