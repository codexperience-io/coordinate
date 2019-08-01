//
//  Coordinating.swift
//  Coordinate Library
//
//  Copyright © 2019 · https://codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

///	Protocol to define what is required for an object to be Coordinator.
///
///	It also simplifies coordinator hierarchy management.
public protocol Coordinating: class {
	///	Unique string to identify specific Coordinator instance.
	///
	///	By default it will be String representation of the Coordinator's subclass.
	///	If you directly instantiate `Coordinator<T>`, then you need to set it manually.
	var identifier: String { get }

    var isStarted: Bool { get }
    
	/// Parent Coordinator can be any other Coordinator.
	var parent: Coordinating? { get set }
    
	///	A dictionary of child Coordinators, where key is Coordinator's identifier property.
	var childCoordinators: [String: Coordinating] { get }

	///	Returns either `parent` coordinator or `nil` if there isn‘t one
	var coordinatingResponder: UIResponder? { get }

	///	Tells the coordinator to start, which means at the end of this method it should
	///	display some UIViewController.
	func start(with completion: @escaping () -> Void)

	///	Tells the coordinator to stop, which means it should clear out any internal stuff
	///	it possibly tracks.
	///	I.e. list of shown `UIViewController`s.
	func stop(with completion: @escaping () -> Void)

	///	Adds the supplied coordinator into its `childCoordinators` dictionary and calls its `start` method
	func startChild(coordinator: Coordinating, completion: @escaping () -> Void)

	///	Calls `stop` on the supplied coordinator and removes it from its `childCoordinators` dictionary
	func stopChild(coordinator: Coordinating, completion: @escaping () -> Void)

	///	Activate Coordinator which was used before.
	///
	///	At the least, this Coordinator should assign itself as `parentCoordinator` of its `rootViewController`,
	///	ready to start displaying its content View Controllers. This is required due to the possibility that
	///	multiple Coordinator can share one UIViewController as their root VC.
	///
	///	See NavigationCoordinator for one possible usage.
	func activate()
    
    // MARK: - Helper methods
    
    func getCached<T: Coordinating>(_ coordinatorType: T.Type) -> T?
    
    func startOrActivateChild(coordinator: Coordinating)
    
    func getRootViewController() -> UIViewController
}


