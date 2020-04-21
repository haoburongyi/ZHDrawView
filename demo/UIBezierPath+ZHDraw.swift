//
//  UIBezierPath+Extension.swift
//  SectorView
//
//  Created by 张淏 on 2019/1/9.
//  Copyright © 2019 张淏. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    func zh_rotate(angle: CGFloat) {
        
        let transform = CGAffineTransform.init(rotationAngle: angle)
        zh_applyCenteredPathTransform(transform: transform)
    }
    
    // Translate path’s origin to its center before applying the transform
    func zh_applyCenteredPathTransform(transform: CGAffineTransform) {
        let center = zh_pathBoundingCenter()
        var t = CGAffineTransform.identity
        t = t.translatedBy(x: center.x, y: center.y)
        t = transform.concatenating(t)
        t = t.translatedBy(x: -center.x, y: -center.y)
        apply(t)
    }
    
    func zh_offsetPath(path:UIBezierPath,offset:CGSize) {
        let transform = CGAffineTransform.init(translationX: offset.width, y: offset.height)
        zh_applyCenteredPathTransform(transform: transform)
    }
    
    func zh_scalePath(path:UIBezierPath,size:CGSize) {
        let transform = CGAffineTransform.init(scaleX: size.width, y: size.height)
        zh_applyCenteredPathTransform(transform: transform)
    }
    
    func zh_mirrorPathHorizontally(path :UIBezierPath) {
        let transform = CGAffineTransform.init(scaleX: -1, y: 1)
        zh_applyCenteredPathTransform(transform: transform)
    }
    
    func zh_mirrorPathVertically(path :UIBezierPath) {
        let transform = CGAffineTransform.init(scaleX: -1, y: 1)
        zh_applyCenteredPathTransform(transform: transform)
        
    }
    
    func zh_pathBoundingCenter() -> CGPoint{
        return zh_rectGetCenter(rect: zh_pathBoundingBox())
    }
    
    func zh_pathBoundingBox() -> CGRect {
        return cgPath.boundingBox
    }
    
    func zh_rectGetCenter(rect:CGRect) -> CGPoint {
        return CGPoint.init(x: rect.midX, y: rect.midY)
    }
}
