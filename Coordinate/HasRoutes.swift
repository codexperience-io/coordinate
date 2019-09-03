//
//  HasRoutes.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

/// Protocol to indicate your Coordinator has Routes. Future implementation will try and base on this to provide ways of managing routing easier
public protocol HasRoutes: AnyObject {
    /**
     Associatedtype RouteType
     
     This will be deduced from setting the property activeRoute
     */
    associatedtype RouteType
    
    /**
     The currently active route on this class
     */
    var activeRoute: RouteType { get set }
    
    /**
     This method tries to change the route state to the desired parameter. If successful, the property activeRoute will reflect the passed parameter.
     
     - Parameter route: The desired route
     
     If you override this method, you can check if the user has access to that specific route before changing the activeRoute and presenting a new Coordinator.
     */
    func goTo(_ route: RouteType)
}
