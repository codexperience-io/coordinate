//
//  HasEvents.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

public protocol CoordinateEvent {}

public protocol HasEvents {
    func emitEvent(_ event: CoordinateEvent) -> Void
    func interceptEvent(_ event: CoordinateEvent) -> Bool
}

public extension UIResponder {
    func emitEvent(_ event: CoordinateEvent) -> Void {
        if self.interceptEvent(event) == false {
            if let coordinator = (self as? Coordinated)?.parentCoordinator {
                coordinator.emitEvent(event)
            } else {
                next?.emitEvent(event)
            }
        }
    }
    
    func interceptEvent(_ event: CoordinateEvent) -> Bool {
        return false
    }
}
