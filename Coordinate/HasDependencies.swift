//
//  HasDependencies.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

/// Base protocol for AppDependencies, use this as the base of your AppDependecies struct to make it work with the Coordinators.
public protocol AppDependenciesProtocol {}

/// This protocol is for intern use only, do no use it.
public protocol HasDependenciesProtocol: AnyObject {
    /**
     This is used intead of a direct property assignment.
     
     - Parameter dependencies: The dependencies to be set.
    */
    func setDependencies(dependencies: AppDependenciesProtocol?)
    
    /**
     Returns the dependencies
    */
    func getDepencencies() -> AppDependenciesProtocol?
}

/// Use this protocol in your Coordinators to enable automatic dependency injection
public protocol HasDependencies: HasDependenciesProtocol {
    /**
     This is inferred from dependencies property
    */
    associatedtype DependeciesType: AppDependenciesProtocol
    
    /**
     Set this with an object that conform to `AppDependenciesProtocol`, but never to `AppDependenciesProtocol` directly.
    */
    var dependencies: DependeciesType? { get set }
}

/// Give Coordinators the ability to handle dependencies
public extension HasDependencies where Self: Coordinating {
    func setDependencies(dependencies: AppDependenciesProtocol?) {
        if let dependencies = dependencies as? DependeciesType {
            self.dependencies = dependencies
        }
    }
    
    func getDepencencies() -> AppDependenciesProtocol? {
        return self.dependencies
    }
}

internal extension HasDependencies where Self: HasChildren {
    func setDependencies(dependencies: AppDependenciesProtocol?) {
        if let dependencies = dependencies as? DependeciesType {
            self.dependencies = dependencies
            self.updateChildCoordinatorDependencies()
        }
    }
    
    private func updateChildCoordinatorDependencies() {
        self.childCoordinators.forEach { (_, coordinator) in
            if let coordinator = coordinator as? HasDependenciesProtocol {
                coordinator.setDependencies(dependencies: dependencies)
            }
        }
    }
}
