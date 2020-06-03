//
//  LittleSheetAnimator.swift
//  CoronaContact
//

import UIKit

class LittleSheetAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.3
    var presenting = true
    let height: CGFloat = 360
    let cornerRadius: CGFloat = 8
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: .to) as? WhatsNewViewController else {
            fatalError()
        }
        let toView = toViewController.view!
        
        let tinting = UIView()
        tinting.frame = container.frame
        tinting.backgroundColor = .black
        tinting.alpha = 0
        
        let preferredHeight = toViewController.preferredHeight(forWidth: container.frame.size.width)
        let height = min(preferredHeight, container.frame.size.height - 40)
        
        let frame = container.bounds
        let origin = CGPoint(x: 0, y: frame.maxY)
        let size = CGSize(width: frame.size.width, height: height)
        let destinationOrigin = CGPoint(x: 0, y: frame.maxY - height)
        
        let maskSize = CGSize(width: size.width, height: size.height + cornerRadius)
        
        let mask = UIView()
        mask.layer.cornerRadius = cornerRadius
        mask.layer.masksToBounds = true
        
        container.addSubview(tinting)
        container.addSubview(mask)
        mask.addSubview(toView)
        
        mask.frame = CGRect(origin: origin, size: maskSize)
        toView.frame = CGRect(origin: .zero, size: size)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                mask.frame = CGRect(origin: destinationOrigin, size: maskSize)
                tinting.alpha = 0.5
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
}
