//
//  HasEvents.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

/**
 Base protocol to be used on the enums that define events
*/
public protocol CoordinateEvents {}

/**
 Protocol to be used in any Class that needs to emit and intercept events
*/
public protocol HasEvents: AnyObject {
    /**
     Emits an Event that will bubble up the UIResponder chain until reaches the first Coordinator, where it will continue to bubble up
     
     - Parameter event: The event to emit
     */
    func emitEvent(_ event: CoordinateEvents)
    
    /**
     Intercepts events and react to them. Return true to stop the event propagation, return false to continue event propagation
     
     - Parameter event: The event to intercept
     
     If you override this method, you can cast the event parameter to the desired enum you wish to compare.
     */
    func interceptEvent(_ event: CoordinateEvents) -> Bool
}

public extension UIResponder {
    /**
     Emits an Event that will bubble up the UIResponder chain until reaches the first Coordinator, where it will continue to bubble up
     
     - Parameter event: The event to emit
     */
    func emitEvent(_ event: CoordinateEvents) {
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
    
    /**
     Intercepts events and react to them. Return true to stop the event propagation, return false to continue event propagation
     
     - Parameter event: The event to intercept
     
     If you override this method, you can cast the event parameter to the desired enum you wish to compare.
     */
    func interceptEvent(_ event: CoordinateEvents) -> Bool {
        return false
    }
}
