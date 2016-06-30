//
//  WaitingView.swift
//  ink media
//
//  Created by Syn Ceokhou on 6/23/16.
//  Copyright © 2016 iNankai. All rights reserved.
//

import UIKit

protocol WaitingViewDelegate:class {
    func checkReadyToDisplay() -> Bool
    func readyToBeRemoved()
}

class WaitingView: UIView {

    let triangleLayer = TriangleLayer()
    let redRectangleLayer = RectangleLayer()
    let arcLayer = ArcLayer()
    
    weak var waitingViewdelegate: WaitingViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func addTriangleLayer() {
        layer.addSublayer(triangleLayer)
        triangleLayer.fromMedToLarge()
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self,
                                               selector: #selector(self.spinAndTransform), userInfo: nil,
                                               repeats: false)
    }
    func drawAnimatedTriangle() {
        triangleLayer.fromMedToLarge()
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(self.spinAndTransform),
                                               userInfo: nil, repeats: false)
    }
    
    func spinAndTransform(times: Double) {
        layer.anchorPoint = CGPointMake(0.5, 0.69)
        
        let rotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI * times)
        rotationAnimation.duration = 0.45 * times
        rotationAnimation.removedOnCompletion = true
        layer.addAnimation(rotationAnimation, forKey: nil)
        NSTimer.scheduledTimerWithTimeInterval(0.45 * times, target: self,
                                               selector: #selector(self.closeTriangleLayer), userInfo: nil,
                                               repeats: false)
        
    }
    
    func closeTriangleLayer()
    {
        triangleLayer.fromLargeToMed()
    }
    
    func drawRedAnimatedRectangle() {
        layer.addSublayer(redRectangleLayer)
//        redRectangleLayer.animateStrokeWithColor(UIColor(red: 242/255, green: 71/255, blue: 63/255, alpha: 1))
        redRectangleLayer.animateStrokeWithColor(UIColor(red: 248/255, green: 0/255, blue: 0/255, alpha: 1))
        NSTimer.scheduledTimerWithTimeInterval(0.40, target: self, selector: #selector(self.drawArc),userInfo: nil, repeats: false)
    }
    func drawArc() {
        layer.addSublayer(arcLayer)
        arcLayer.animate()
        NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: #selector(self.repeatArcAnimation),
                                                       userInfo: nil, repeats: false)
    }
    
    func repeatArcAnimation()
    {
        if let delegate = waitingViewdelegate
        {
            if delegate.checkReadyToDisplay()
            {
                delegate.readyToBeRemoved()
            }
            else
            {
                arcLayer.animate()
                NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: #selector(self.repeatArcAnimation),
                                                       userInfo: nil, repeats: false)
            }
        }
        
    }
    
}
