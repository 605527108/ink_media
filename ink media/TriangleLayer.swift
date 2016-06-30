//
//  TriangleLayer.swift
//  SBLoader
//
//  Created by Satraj Bambra on 2015-03-19.
//  Copyright (c) 2015 Satraj Bambra. All rights reserved.
//

import UIKit

class TriangleLayer: CAShapeLayer {
  
  let innerPadding: CGFloat = 30.0
    let animationDuration: CFTimeInterval = 0.3
  
  override init() {
    super.init()
    fillColor = UIColor.redColor().CGColor
    strokeColor = UIColor.redColor().CGColor
    lineWidth = 7.0
    lineCap = kCALineCapRound
    lineJoin = kCALineJoinRound
    path = trianglePathMedium.CGPath
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var trianglePathSmall: UIBezierPath {
    let trianglePath = UIBezierPath()
    trianglePath.moveToPoint(CGPoint(x: 5.0 + innerPadding, y: 95.0))
    trianglePath.addLineToPoint(CGPoint(x: 50.0, y: 12.5 + innerPadding))
    trianglePath.addLineToPoint(CGPoint(x: 95.0 - innerPadding, y: 95.0))
    trianglePath.closePath()
    return trianglePath
  }
    var trianglePathMedium: UIBezierPath {
        return UIBezierPath(ovalInRect: CGRect(x: 50.0, y: 50.0, width: 0.0, height: 0.0))
    }
  
    var trianglePathBig: UIBezierPath {
        let trianglePath = UIBezierPath()
        trianglePath.moveToPoint(CGPoint(x: 5.0, y: 95.0))
        trianglePath.addLineToPoint(CGPoint(x: 50.0, y: 18.06))
        trianglePath.addLineToPoint(CGPoint(x: 95.0 , y: 95.0))
        trianglePath.closePath()
        return trianglePath
    }
    
  var trianglePathLeftExtension: UIBezierPath {
    let trianglePath = UIBezierPath()
    trianglePath.moveToPoint(CGPoint(x: 5.0, y: 95.0))
    trianglePath.addLineToPoint(CGPoint(x: 50.0, y: 12.5 + innerPadding))
    trianglePath.addLineToPoint(CGPoint(x: 95.0 - innerPadding, y: 95.0))
    trianglePath.closePath()
    return trianglePath
  }
  
  var trianglePathRightExtension: UIBezierPath {
    let trianglePath = UIBezierPath()
    trianglePath.moveToPoint(CGPoint(x: 5.0, y: 95.0))
    trianglePath.addLineToPoint(CGPoint(x: 50.0, y: 12.5 + innerPadding))
    trianglePath.addLineToPoint(CGPoint(x: 95.0, y: 95.0))
    trianglePath.closePath()
    return trianglePath
  }
  
  var trianglePathTopExtension: UIBezierPath {
    let trianglePath = UIBezierPath()
    trianglePath.moveToPoint(CGPoint(x: 5.0, y: 95.0))
    trianglePath.addLineToPoint(CGPoint(x: 50.0, y: 12.5))
    trianglePath.addLineToPoint(CGPoint(x: 95.0, y: 95.0))
    trianglePath.closePath()
    return trianglePath
  }
    
    func fromMedToLarge()
    {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = trianglePathMedium.CGPath
        expandAnimation.toValue = trianglePathBig.CGPath
        expandAnimation.duration = animationDuration
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.removedOnCompletion = false
        addAnimation(expandAnimation, forKey: nil)
    }
    func fromLargeToMed()
    {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = trianglePathBig.CGPath
        expandAnimation.toValue = trianglePathMedium.CGPath
        expandAnimation.duration = animationDuration
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.removedOnCompletion = false
        addAnimation(expandAnimation, forKey: nil)
    }
  
    func animate() {
        let triangleAnimationLeft: CABasicAnimation = CABasicAnimation(keyPath: "path")
        triangleAnimationLeft.fromValue = trianglePathSmall.CGPath
        triangleAnimationLeft.toValue = trianglePathLeftExtension.CGPath
        triangleAnimationLeft.beginTime = 0.0
        triangleAnimationLeft.duration = 0.3
        
        let triangleAnimationRight: CABasicAnimation = CABasicAnimation(keyPath: "path")
        triangleAnimationRight.fromValue = trianglePathLeftExtension.CGPath
        triangleAnimationRight.toValue = trianglePathRightExtension.CGPath
        triangleAnimationRight.beginTime = triangleAnimationLeft.beginTime + triangleAnimationLeft.duration
        triangleAnimationRight.duration = 0.25
        
        let triangleAnimationTop: CABasicAnimation = CABasicAnimation(keyPath: "path")
        triangleAnimationTop.fromValue = trianglePathRightExtension.CGPath
        triangleAnimationTop.toValue = trianglePathTopExtension.CGPath
        triangleAnimationTop.beginTime = triangleAnimationRight.beginTime + triangleAnimationRight.duration
        triangleAnimationTop.duration = 0.20
        
        let triangleAnimationGroup: CAAnimationGroup = CAAnimationGroup()
        triangleAnimationGroup.animations = [triangleAnimationLeft, triangleAnimationRight,
                                             triangleAnimationTop]
        triangleAnimationGroup.duration = triangleAnimationTop.beginTime + triangleAnimationTop.duration
        triangleAnimationGroup.fillMode = kCAFillModeForwards
        triangleAnimationGroup.removedOnCompletion = false
        addAnimation(triangleAnimationGroup, forKey: nil)
    }
}
