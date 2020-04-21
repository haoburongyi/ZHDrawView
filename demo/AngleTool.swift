//
//  AngleTool.swift
//  HandheldColorUltrasound
//
//  Created by 张淏 on 2018/12/28.
//  Copyright © 2018 张淏. All rights reserved.
//

import UIKit

class AngleTool: NSObject {
    
    /// 计算三点之间的角度
    ///
    /// - Parameters:
    ///   - p1: 点1
    ///   - p2: 点2（也是角度所在点）
    ///   - p3: 点3
    /// - Returns: 角度（180度制）
    class func getAnglesWithThreePoints(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> Double {
        //排除特殊情况，三个点一条线
        if (p1.x == p2.x && p2.x == p3.x) || ( p1.y == p2.x && p2.x == p3.x){
            return 0
        }
        
        let a = abs(p1.x - p2.x)
        let b = abs(p1.y - p2.y)
        let c = abs(p3.x - p2.x)
        let d = abs(p3.y - p2.y)
        
        if (a < 1.0 && b < 1.0) || (c < 1.0 && d < 1.0){
            return 0
        }
        let e = a*c+b*d
        let f = sqrt(a*a+b*b)
        let g = sqrt(c*c+d*d)
        let r = Double(acos(e/(f*g)))
//        return r        //弧度值
        
        //角度值
        var angle = (180*r/Double.pi)
        if (p1.x < p2.x && p2.x < p3.x) || (p1.y < p2.y && p2.y < p3.y) {
            angle = 90 + (90 - angle)
        }
        
        return angle
        
    }

    /// 根据等腰三角形的斜边长和角度算出垂线
    ///
    /// - Parameters:
    ///   - angle: 角度
    ///   - hypotenuse: 斜边长
    /// - Returns: 垂线
    class func getPerpendicularLen(angle: CGFloat, hypotenuse: CGFloat) -> CGFloat {
        
        let halfAngle = angle * 0.5
        let jiaoduToF = CGFloat.pi / (180 / halfAngle)
        let len = cos(jiaoduToF) * hypotenuse
        return len
    }
    
    /// 根据直角三角形的临边长和角度算出斜边长
    ///
    /// - Parameters:
    ///   - angle: 角度
    ///   - slidLen: 临边长
    /// - Returns: 斜边长
    class func getHypotenuseSideLen(angle: CGFloat, sideLen: CGFloat) -> CGFloat {
        
        let jiaoduToF = CGFloat.pi / (180 / angle)
        return sideLen / cos(jiaoduToF)
    }
    
    /// 根据直角三角形的临边长和角度算出对边长
    ///
    /// - Parameters:
    ///   - angle: 角度
    ///   - sideLen: 临边长
    /// - Returns: 对边长
    class func getOppositeSideLen(angle: CGFloat, sideLen: CGFloat) -> CGFloat {
        
        let jiaoduToF = CGFloat.pi / (180 / angle)
        return sideLen * tan(jiaoduToF)
    }
    
}
