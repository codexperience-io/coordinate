//
//  ContainerCoordinator.swift
//  Coordinate Library
//
//  Copyright © 2019 · https://codexperience.io
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

open class ContainerCoordinator<T: UIViewController>: Coordinator<T>  {
 
    private(set) open var currentViewController: UIViewController?
    
    // MARK: - Custom presentation methods
    
    /*
     On a Coordinator<UIViewController>, we can stack UIViewControllers and change them with or without animation with this method
     
     You can override this method and use custom Animations/Transitions
    */
    open func root(_ coordinator: Coordinating, animated: Bool = false, completion: (() -> Void)? = nil) {
        startOrActivateChild(coordinator: coordinator)
        
        let viewController = coordinator.getRootViewController()
        
        // Avoid re-setting the same rootViewController
        if currentViewController == viewController { return }
        
        // Add new ViewController
        rootViewController.addChild(viewController)
        viewController.view.alpha = animated ? 0 : 1
        rootViewController.view.insertSubview(viewController.view, at: 0)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.topAnchor.constraint(equalTo: rootViewController.view.topAnchor).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor).isActive = true
        
        viewController.didMove(toParent: rootViewController)
        
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveLinear,
                           animations: {
                            
                            viewController.view.alpha = 1
                            
            }, completion: { [weak self] _ in
                self?.replaceCurrentViewController(with: viewController, completion: completion)
            })
        } else {
            replaceCurrentViewController(with: viewController, completion: completion)
        }
    }
    
    private func replaceCurrentViewController(with viewController: UIViewController, completion: (() -> Void)? = nil) {
        // Remove current ViewController, if existing
        if let currentViewController = currentViewController {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }
        
        // Replace current ViewController
        currentViewController = viewController
        
        completion?()
    }
}
