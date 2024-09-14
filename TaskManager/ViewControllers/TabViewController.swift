//
//  TabViewController.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 14/09/2024.
//

import Foundation
import UIKit

class TabViewController: UITabBarController {
    var isAnimating = false // Cờ kiểm soát trạng thái chuyển cảnh
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension TabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        // Nếu đang trong quá trình chuyển cảnh, không cho phép animation mới
        if !isAnimating {
            return TabViewAnimation(tabBarController: self)
        } else {
            return nil
        }
    }
}

class TabViewAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    weak var tabBarController: TabViewController?
    
    init(tabBarController: TabViewController) {
        self.tabBarController = tabBarController
    }

    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        // Đặt trạng thái isAnimating thành true khi bắt đầu chuyển cảnh
        tabBarController?.isAnimating = true

        guard let destinationVC = transitionContext.viewController(forKey: .to),
              let sourceVC = transitionContext.viewController(forKey: .from),
              let tabBarController = sourceVC.tabBarController else {
            print("Error: Could not retrieve view controllers or tabBarController.")
            tabBarController?.isAnimating = false
            return
        }

        let destinationView = destinationVC.view!
        let sourceView = sourceVC.view!
        
        let containerView = transitionContext.containerView
        containerView.addSubview(destinationView)

        let fromIndex = tabBarController.viewControllers?.firstIndex(of: sourceVC) ?? 0
        let toIndex = tabBarController.viewControllers?.firstIndex(of: destinationVC) ?? 0
        let isMovingRight = toIndex > fromIndex
        let offsetX = isMovingRight ? containerView.frame.width : -containerView.frame.width
        
        destinationView.transform = CGAffineTransform(translationX: offsetX, y: 0)

        CATransaction.begin() // Bắt đầu transaction để đồng bộ hóa animation
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            sourceView.transform = CGAffineTransform(translationX: -offsetX, y: 0)
            destinationView.transform = .identity
        }, completion: { finished in
            sourceView.transform = .identity
            destinationView.transform = .identity

            // Hoàn thành quá trình chuyển cảnh
            transitionContext.completeTransition(finished)
            self.tabBarController?.isAnimating = false
        })
        CATransaction.commit() // Kết thúc transaction
    }
}
