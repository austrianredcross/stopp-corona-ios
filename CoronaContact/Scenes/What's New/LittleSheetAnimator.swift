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
    let tintAlpha: CGFloat = 0.5
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let whatsNewVC = transitionContext.viewController(forKey: presenting ? .to : .from) as? WhatsNewViewController else {
            fatalError()
        }
        let whatsNewView = whatsNewVC.view!
        
        let tinting = UIView()
        tinting.frame = container.frame
        tinting.backgroundColor = .black
        tinting.alpha = presenting ? 0 : tintAlpha
        
        let preferredHeight = whatsNewVC.preferredHeight(forWidth: container.frame.size.width)
        let height = min(preferredHeight, container.frame.size.height - 40)
        
        let frame = container.bounds
        let origin = CGPoint(x: 0, y: frame.maxY)
        let size = CGSize(width: frame.size.width, height: height)
        let destinationOrigin = CGPoint(x: 0, y: frame.maxY - height)
        
        let maskSize = CGSize(width: size.width, height: size.height + cornerRadius)
        
        let mask = UIView()
        mask.layer.cornerRadius = cornerRadius
        mask.layer.masksToBounds = true
        
        if !presenting {
            for view in container.subviews {
                view.removeFromSuperview()
            }
        }
        container.addSubview(tinting)
        container.addSubview(mask)
        mask.addSubview(whatsNewView)
        
        mask.frame = CGRect(origin: presenting ? origin : destinationOrigin, size: maskSize)
        whatsNewView.frame = CGRect(origin: .zero, size: size)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                mask.frame = CGRect(origin: self.presenting ? destinationOrigin : origin, size: maskSize)
                tinting.alpha = self.presenting ? self.tintAlpha : 0
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
}
