//  Animator.swift
//  SonicCoolBomb
//
//  Created by ko on 2020/9/12.
//  Copyright © 2020 SM. All rights reserved.
//
import UIKit

class Animator : NSObject {
    var anim : UIViewImplicitlyAnimating?
    var context : UIViewControllerContextTransitioning?
}

extension Animator : UINavigationControllerDelegate {
    // comment out this whole function to restore the default pop gesture
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return self
        }
        return nil
    }
    
}

extension Animator {
    @objc func drag (_ g : UIPanGestureRecognizer) {
        let v = g.view!
        switch g.state {
        case .began:
            self.anim?.pauseAnimation()
            fallthrough
        case .changed:
            let delta = g.translation(in:v.superview)
            var c = v.center
            c.x += delta.x; c.y += delta.y
            v.center = c
            g.setTranslation(.zero, in: v.superview)
        case .ended, .cancelled:
            let anim = self.anim as! UIViewPropertyAnimator
            let ctx = self.context!
            let vc2 = ctx.viewController(forKey:.to)!
            anim.addAnimations {
                v.frame = ctx.finalFrame(for: vc2)
            }
            anim.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:break
        }
    }
}

extension Animator : UIViewControllerAnimatedTransitioning {
    
    func interruptibleAnimator(using ctx: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        
        if self.anim != nil {
            return self.anim!
        }
        
        let vc1 = ctx.viewController(forKey:.from)!
        let vc2 = ctx.viewController(forKey:.to)!
        let con = ctx.containerView
        let r2end = ctx.finalFrame(for:vc2)
        let v2 = ctx.view(forKey:.to)!
        
        var itemvc : UIViewController = UIViewController()
        var myfav: UIViewController = UIViewController()
        
        if vc1 is ItemViewController {
            itemvc = vc1 as! ItemViewController
        }
        else if vc1 is MyFavoriteViewController {
            myfav = vc1 as! MyFavoriteViewController
        }
        else {
            print("")
        }
        
        let tv = vc1 is ItemViewController ? (itemvc as! ItemViewController).tableView! : (myfav as! MyFavoriteViewController).tableView!

        var visibleFirstRowIndexPath: IndexPath = IndexPath(row: 0, section: 0)
        
        let indices = tv.indexPathsForVisibleRows
        visibleFirstRowIndexPath = indices?.last! as! IndexPath
        
        let r = tv.rectForRow(at: visibleFirstRowIndexPath)
        let r2 = con.convert(r, from: tv)
        
        
        v2.frame = r2end
        con.addSubview(v2)
        
        //snapshot
        let mySize:CGSize = CGSize(width: vc1.view.bounds.size.width/2, height: vc1.view.bounds.size.height/2)
        let myRect: CGRect = CGRect(x: 0, y: 0, width: vc1.view.bounds.size.width/2, height: vc1.view.bounds.size.height/2)
        let renderer = UIGraphicsImageRenderer(size: mySize)
        let image = renderer.image { _ in vc1.view.drawHierarchy(in: myRect, afterScreenUpdates: false) }
        
        let snapshot = UIImageView(image:image)
        snapshot.contentMode = .scaleAspectFit
        snapshot.clipsToBounds = true
        
        snapshot.frame = r2
        
        con.addSubview(snapshot)
        
        v2.alpha = 0
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drag))
        snapshot.addGestureRecognizer(pan)
        snapshot.isUserInteractionEnabled = true
        
        let anim = UIViewPropertyAnimator(duration: 0.35, curve: .linear) {
            snapshot.frame = r2end
        }
        
        anim.addCompletion { _ in
            ctx.completeTransition(true)
            v2.alpha = 1
            snapshot.removeFromSuperview()
        }
        
        self.anim = anim
        self.context = ctx
        
        return anim
    }
    
    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 2
    }
    
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let anim = self.interruptibleAnimator(using: ctx)
        anim.startAnimation()
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        print("animation ended")
        self.anim = nil
        self.context = nil
    }
    
}


