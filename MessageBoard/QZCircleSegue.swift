//
//  QZCircleSegue.swift
//  QZCircleSegue
//
//  Created by Alex Tarragó on 4/11/15.
//  Copyright (c) 2015 Dribba Development & Consulting. All rights reserved.
//

import UIKit

class QZCircleSegue: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate  {
    
    fileprivate var presenting = false
    var animationDuration = 0.5
    var animationColor = UIColor.white
    var animationChild: AnyObject! = nil
    var fromViewController: AnyObject! = nil
    var toViewController: AnyObject! = nil
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animationSize = animationChild.frame.size
        let animationPoint = animationChild.center
        
        let container = transitionContext.containerView
        let screenComp = (UIScreen.main.bounds.size.height - animationSize.height) / (animationSize.height / 2);

        
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!, transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        
        let newViewController = !self.presenting ? screens.from as UIViewController : screens.to as UIViewController
        let bottomViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
        
        let newView = newViewController.view
        let bottomView = bottomViewController.view
        
        if (self.presenting){
            self.offStageMenuController(newViewController, fromViewController: bottomViewController)
        }
        
        container.addSubview(bottomView!)
        container.addSubview(newView!)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        if (self.presenting) {
            let circularView = UIView()
            circularView.frame.size = CGSize(width: animationSize.width, height: animationSize.height)
            circularView.backgroundColor = self.animationColor
            circularView.center = animationPoint!
            circularView.layer.cornerRadius = animationSize.height/2
            circularView.layer.masksToBounds = true
            circularView.alpha = 1.0
            circularView.tag = 764
            bottomViewController.view.addSubview(circularView)
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                let scale:CGFloat = screenComp;
                circularView.transform = CGAffineTransform(scaleX: scale, y: scale)
                circularView.center = animationPoint!
                }, completion: { (Finished) -> Void in
                    UIView.animate(withDuration: duration,
                        delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        self.onStageMenuController(newViewController, fromViewController: bottomViewController)
                        }, completion: { finished in
                            transitionContext.completeTransition(true)
                            UIApplication.shared.keyWindow!.addSubview(screens.to.view)
                    })
            }) 
        } else {
            let circularView: UIView = bottomViewController.view.viewWithTag(764)!
            self.offStageMenuController(newViewController, fromViewController: bottomViewController)
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                let scale:CGFloat = -screenComp;
                circularView.transform = CGAffineTransform(scaleX: 1, y: 1)
                circularView.center = animationPoint!
                }, completion: { (Finished) -> Void in
                    circularView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                    UIApplication.shared.keyWindow!.addSubview(screens.to.view)
            }) 
        }
    }
    func offStage(_ amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(translationX: amount, y: 0)
    }
    func offStageMenuController(_ menuViewController: UIViewController, fromViewController: UIViewController){
        menuViewController.view.alpha = 0
    }
    func onStageMenuController(_ menuViewController: UIViewController, fromViewController: UIViewController){
        menuViewController.view.alpha = 1
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
}


