//
//  HasEvents.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

public protocol CoordinateEvents {}

public protocol HasEvents {
    func emitEvent(_ event: CoordinateEvents) -> Void
    func interceptEvent(_ event: CoordinateEvents) -> Bool
}

public extension UIResponder {
    func emitEvent(_ event: CoordinateEvents) -> Void {
        if self.interceptEvent(event) == false {
            if let coordinator = (self as? Coordinated)?.parentCoordinator {
                coordinator.emitEvent(event)
            } else if let viewController = self as? UIViewController {

                if let parentController = viewController.parent {
                    parentController.emitEvent(event)
                } else if let presentingController = viewController.presentingViewController {
                    presentingController.emitEvent(event)
                } else {
                    viewController.view.superview?.emitEvent(event)
                }
                
            } else {
                next?.emitEvent(event)
            }
        }
    }
    
    func interceptEvent(_ event: CoordinateEvents) -> Bool {
        return false
    }
}
