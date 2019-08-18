//
//  HasRoutes.swift
//  Coordinate Library
//
//  Copyright © 2019 codexperience.io · https://codexperience.io
//  Website and Docs · https://coordinate.codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

// Protocol to indicate your Coordinator has Routes. Future implementation will try and base on this to provide ways of managing routing easier
public protocol HasRoutes {
    associatedtype RouteType
    var activeRoute: RouteType { get set }
    func goTo(_ route: RouteType)
}
