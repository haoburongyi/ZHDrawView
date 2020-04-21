//
//  ZHDrawView.swift
//  test
//
//  Created by VIP Mac on 2018/10/25.
//  Copyright © 2018 VIP Mac. All rights reserved.
//

import UIKit

enum ZHDrawStyle: String {
    
    case `static`   = "static"
    case line       = "line"
    case angle      = "angle"
    case oval       = "oval"
}

class ZHDrawPath: UIBezierPath {
    
    enum SelectPoint {
        case none
        case start
        case end
        case angle
        case oval
    }
    
    var drawStyle: ZHDrawStyle = .static
    var lineColor = UIColor.black
    var startLoc = CGPoint.zero
    var angleLoc = CGPoint.zero
    var endLoc = CGPoint.zero
    var ovalLoc = CGPoint.zero
    var ovalRotateAngle: CGFloat = 0
    var ovalHeight: CGFloat = 0
    var showLineInfo = true
    var selectPoint: SelectPoint = .none
}

class ZHDrawView: UIView {
    
    fileprivate let lineWidth: CGFloat = 1
    fileprivate let lineColor = UIColor.white
    private(set) var allPath = [ZHDrawPath]()
    fileprivate var tempPath: ZHDrawPath?
    fileprivate let responseRange: CGFloat = 30// 拖动时响应范围
    var drawStyle: ZHDrawStyle = .static {
        didSet {
            setNeedsDisplay()
        }
    }
    var scale: CGFloat = 1
    var drawingFinished: (() -> ())?
    var showLineInfo = true// 显示线的长度等信息
    
    public func deleteLastLine() {
        if allPath.count > 0 {
            allPath.removeLast()
            setNeedsDisplay()
        }
    }
    
    public func clearScreen() {
        allPath.removeAll()
        setNeedsDisplay()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        let doubleTap = UITapGestureRecognizer.init(target:self, action: #selector(handleDoubleTap(tap:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panAction(pan:)))
        addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func handleDoubleTap(tap: UITapGestureRecognizer) {
        
        let loc = tap.location(in: self)
        switch drawStyle {
        case .static:break//            drawStyle = .move
        case .line:
            if let _tempPath = tempPath, _tempPath.startLoc != .zero {
                _tempPath.endLoc = loc
                _tempPath.move(to: _tempPath.startLoc)
                _tempPath.addLine(to: loc)
                allPath.append(_tempPath)
                tempPath = nil
            } else {
                tempPath = ZHDrawPath.init()
                tempPath?.lineColor = lineColor
                tempPath?.lineWidth = lineWidth
                tempPath?.lineCapStyle = .round
                tempPath?.lineJoinStyle = .round
                tempPath?.showLineInfo = showLineInfo
                tempPath?.drawStyle = drawStyle
                tempPath?.startLoc = loc
            }
        case .oval:
            if let _tempPath = tempPath, _tempPath.startLoc != .zero {
                _tempPath.endLoc = loc
                let savePath = getSavePath(lastPath: _tempPath)
                tempPath = nil
                allPath.append(savePath)
            } else {
                tempPath = ZHDrawPath.init()
                tempPath?.lineColor = lineColor
                tempPath?.lineWidth = lineWidth
                tempPath?.showLineInfo = showLineInfo
                tempPath?.drawStyle = drawStyle
                tempPath?.startLoc = loc
            }
        case .angle:
            if let _tempPath = tempPath, _tempPath.startLoc != .zero {
                if _tempPath.angleLoc == .zero {
                    _tempPath.angleLoc = loc
                    _tempPath.move(to: _tempPath.startLoc)
                    _tempPath.addLine(to: loc)
                } else {
                    _tempPath.endLoc = loc
                    _tempPath.move(to: _tempPath.angleLoc)
                    _tempPath.addLine(to: loc)
                    allPath.append(_tempPath)
                    tempPath = nil
                }
            } else {
                tempPath = ZHDrawPath.init()
                tempPath?.lineColor = lineColor
                tempPath?.lineWidth = lineWidth
                tempPath?.lineCapStyle = .round
                tempPath?.lineJoinStyle = .round
                tempPath?.showLineInfo = showLineInfo
                tempPath?.drawStyle = drawStyle
                tempPath?.startLoc = loc
            }
        }
        setNeedsDisplay()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //        super.draw(rect)
        
        if let _tempPath = tempPath {
            if _tempPath.endLoc != .zero || _tempPath.angleLoc != .zero {
                drawPath(path: _tempPath)
            }
            
            drawMovePoint(path: _tempPath)
        }
        allPath.forEach {
            drawPath(path: $0)
            drawMovePoint(path: $0)
        }
    }
    
    fileprivate func drawPath(path: ZHDrawPath) {
        path.lineColor.set()
        path.stroke()
        guard path.showLineInfo else { return }
        
        switch path.drawStyle {
        case .line:
            drawLineDistance(path: path)
            break
        case .oval:
            drawOvalArea(path: path)
        case .angle:
            guard path.startLoc != .zero && path.angleLoc != .zero && path.endLoc != .zero else { return }
            drawAngle(path: path)
        default: break
        }
    }
    
    fileprivate func drawMovePoint(path: ZHDrawPath) {
        
        let wg: CGFloat = 8
        let margin = wg * 0.5
        let size = CGSize.init(width: wg, height: wg)
        
        func convertPath(_ x: CGFloat, _ y: CGFloat) -> UIBezierPath {
            let rect = CGRect.init(origin: CGPoint.init(x: x, y: y), size: size)
            return UIBezierPath.init(roundedRect: rect, cornerRadius: wg)
        }
        
        var points = [UIBezierPath]()
        switch path.drawStyle {
        case .line:
            
            let startRound = convertPath(path.startLoc.x - margin, path.startLoc.y - margin)
            points.append(startRound)
            if path.endLoc != .zero {
                let endRound = convertPath(path.endLoc.x - margin, path.endLoc.y - margin)
                points.append(endRound)
            }
        case .oval:
            let startRound = convertPath(path.startLoc.x - margin, path.startLoc.y - margin)
            points.append(startRound)
            if path.endLoc != .zero {
                let endRound = convertPath(path.endLoc.x - margin, path.endLoc.y - margin)
                points.append(endRound)
            }
            if path.ovalLoc != .zero {
                let angleRound = convertPath(path.ovalLoc.x - margin, path.ovalLoc.y - margin)
                //                points.append(angleRound)
                UIColor.red.set()
                angleRound.stroke()
            }
        case .angle:
            let startRound = convertPath(path.startLoc.x - margin, path.startLoc.y - margin)
            points.append(startRound)
            if path.endLoc != .zero {
                let endRound = convertPath(path.endLoc.x - margin, path.endLoc.y - margin)
                points.append(endRound)
            }
            if path.angleLoc != .zero {
                let angleRound = convertPath(path.angleLoc.x - margin, path.angleLoc.y - margin)
                points.append(angleRound)
            }
        default: break
        }
        
        path.lineColor.set()
        points.forEach {
            $0.stroke()
        }
    }
    
    @objc fileprivate func panAction(pan: UIPanGestureRecognizer) {
        
        guard drawStyle != .static else {
            return
        }
        if tempPath != nil {
            switch tempPath!.drawStyle {
            case .line:
                guard tempPath!.startLoc != .zero && tempPath!.endLoc != .zero else { return }
            case .oval:
                guard tempPath!.startLoc != .zero && tempPath!.endLoc != .zero && tempPath!.ovalLoc != .zero else { return }
            case .angle:
                guard tempPath!.startLoc != .zero && tempPath!.endLoc != .zero && tempPath!.angleLoc != .zero else { return }
            case .static: break
            }
        }
        
        let loc = pan.location(in: self)
        switch pan.state {
        case .began:
            touchesBegan(loc)
        case .changed:
            touchesMoved(loc)
        case .ended:
            touchesEnded(loc)
        default: break
        }
    }
    
    fileprivate func touchesBegan(_ loc: CGPoint) {
        var allMargin = CGFloat.init(Int.max)
        var index = -1
        
        // 是否在响应范围内
        func checkInResponseRange(point: CGPoint) -> Bool {
            let hMargin = abs(point.x - loc.x)
            let vMargin = abs(point.y - loc.y)
            if hMargin < responseRange && vMargin < responseRange {
                let _allMargin = hMargin + vMargin
                if allMargin > _allMargin {
                    allMargin = _allMargin
                    return true
                }
            }
            return false
        }
        
        var movePoint: CGPoint?
        allPath.enumerated().forEach {
            switch $1.drawStyle {
            case .line:
                let start = checkInResponseRange(point: $1.startLoc)
                let end = checkInResponseRange(point: $1.endLoc)
                if end {
                    movePoint = $1.endLoc
                    $1.selectPoint = .end
                    index = $0
                } else if start {
                    movePoint = $1.startLoc
                    $1.selectPoint = .start
                    index = $0
                }
            case .oval:
                let start = checkInResponseRange(point: $1.startLoc)
                let oval = checkInResponseRange(point: $1.ovalLoc)
                let end = checkInResponseRange(point: $1.endLoc)
                if start {
                    movePoint = $1.startLoc
                    $1.selectPoint = .start
                    index = $0
                } else if oval {
                    movePoint = $1.angleLoc
                    $1.selectPoint = .oval
                    index = $0
                } else if end {
                    movePoint = $1.endLoc
                    $1.selectPoint = .end
                    index = $0
                }
            case .angle:
                let start = checkInResponseRange(point: $1.startLoc)
                let angle = checkInResponseRange(point: $1.angleLoc)
                let end = checkInResponseRange(point: $1.endLoc)
                if start {
                    movePoint = $1.startLoc
                    $1.selectPoint = .start
                    index = $0
                } else if angle {
                    movePoint = $1.angleLoc
                    $1.selectPoint = .angle
                    index = $0
                } else if end {
                    movePoint = $1.endLoc
                    $1.selectPoint = .end
                    index = $0
                }
            default:break
            }
        }
        
        if index != -1 {
            
            print("拿到点")
            tempPath = allPath[index]
            switch tempPath!.drawStyle {
            case .line:
                if movePoint == tempPath!.startLoc {
                    //                let start = tempPath!.startLoc
                    tempPath!.startLoc = tempPath!.endLoc
                }
                tempPath?.endLoc = movePoint ?? .init()
                tempPath?.move(to: tempPath!.startLoc)
            case .oval:
                break
            case .angle:
                tempPath?.move(to: tempPath!.startLoc)
                tempPath?.addLine(to: tempPath!.angleLoc)
                tempPath?.move(to: tempPath!.angleLoc)
                tempPath?.move(to: tempPath!.endLoc)
            default: print("没拿到点")
            }
            allPath.remove(at: index)
            setNeedsDisplay()
        } else {
            print("没拿到点, 去画")
        }
    }
    
    fileprivate func touchesMoved(_ loc: CGPoint) {
        
        guard let _tempPath = tempPath else { return }
        
        switch _tempPath.drawStyle {
        case .line:
            lineModeTouchesMoved(loc)
        case .oval:
            ovalModeTouchesMoved(loc)
        case .angle:
            angleModeTouchesMoved(loc)
        default:
            break
        }
    }
    
    fileprivate func touchesEnded(_ loc: CGPoint) {
        
        guard let _tempPath = tempPath else { return }
        
        switch _tempPath.drawStyle {
        case .line:
            lineModeTouchesEnded(loc)
        case .oval:
            ovalModeTouchesEnded(loc)
        case .angle:
            angleModeTouchesEnded(loc)
        default:
            break
        }
    }
    
}

// MARK: - Line
extension ZHDrawView {
    
    fileprivate func lineModeTouchesMoved(_ loc: CGPoint) {
        
        guard let _tempPath = tempPath else { return }

        _tempPath.endLoc = loc
        _tempPath.removeAllPoints()
        _tempPath.move(to: _tempPath.startLoc)
        _tempPath.addLine(to: loc)
        setNeedsDisplay()
    }
    
    fileprivate func lineModeTouchesEnded(_ loc: CGPoint) {
        
        guard let _tempPath = tempPath else { return }
        //        tempPath?.addLine(to: loc)
        let hDistance = abs(_tempPath.startLoc.x - loc.x)
        let vDistance = abs(_tempPath.startLoc.y - loc.y)
        let distance = sqrt(hDistance * hDistance + vDistance * vDistance)
        tempPath = nil
        setNeedsDisplay()
        guard distance >= 1 else {
            return
        }
        _tempPath.selectPoint = .none
        allPath.append(_tempPath)
        //        drawingFinished?()
//        drawStyle = .move
    }
}

// MARK: - oval
extension ZHDrawView {
    
    fileprivate func ovalModeTouchesMoved(_ loc: CGPoint) {
        
        guard let _tempPath = tempPath else { return }
        
        switch _tempPath.selectPoint {
        case .start: _tempPath.startLoc = loc
        case .oval: _tempPath.ovalLoc = loc
        case .end: _tempPath.endLoc = loc
        default: break
        }
        _tempPath.removeAllPoints()
        tempPath = getSavePath(lastPath: _tempPath)
        setNeedsDisplay()
    }
    
    fileprivate func ovalModeTouchesEnded(_ loc: CGPoint) {
        guard let _tempPath = tempPath else { return }
        
        tempPath = nil
        _tempPath.selectPoint = .none
        allPath.append(_tempPath)
        setNeedsDisplay()
//        drawStyle = .move
    }
}

// MARK: - oval
extension ZHDrawView {
    
    fileprivate func angleModeTouchesMoved(_ loc: CGPoint) {
        
        guard let _tempPath = tempPath else { return }
        
        _tempPath.removeAllPoints()
        
        switch _tempPath.selectPoint {
        case .start:    _tempPath.startLoc = loc
        case .angle:    _tempPath.angleLoc = loc
        case .end:      _tempPath.endLoc = loc
        default: break
        }
        
        _tempPath.move(to: _tempPath.startLoc)
        _tempPath.addLine(to: _tempPath.angleLoc)
        _tempPath.move(to: _tempPath.angleLoc)
        _tempPath.addLine(to: _tempPath.endLoc)
        setNeedsDisplay()
    }
    
    fileprivate func angleModeTouchesEnded(_ loc: CGPoint) {
        guard let _tempPath = tempPath else { return }
        tempPath = nil
        _tempPath.selectPoint = .none
        allPath.append(_tempPath)
        setNeedsDisplay()
//        drawStyle = .move
    }
}

extension ZHDrawView {
    
    fileprivate func getLocation(touches: Set<UITouch>) -> CGPoint? {
        let touch = touches.randomElement()
        return touch?.location(in: self)
    }
    
    fileprivate func getCenterFrame(p1: CGPoint, p2: CGPoint, width: CGFloat, height: CGFloat) -> CGRect {
        
        var maxX: CGFloat = 0; var minX: CGFloat = 0
        if p1.x > p2.x { maxX = p1.x; minX = p2.x } else { maxX = p2.x; minX = p1.x }
        var maxY: CGFloat = 0; var minY: CGFloat = 0
        if p1.y > p2.y { maxY = p1.y; minY = p2.y } else { maxY = p2.y; minY = p1.y }
        let centerPoint = CGPoint.init(x: minX + (maxX - minX) * 0.5, y: minY + (maxY - minY) * 0.5)
        return CGRect.init(x: centerPoint.x - width * 0.5, y: centerPoint.y - height * 0.5, width: width, height: height)
    }
    
    fileprivate func getDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let hDistance = abs(p1.x - p2.x)
        let vDistance = abs(p1.y - p2.y)
        func squared(_ num: CGFloat) -> CGFloat {
            return num * num
        }
        let distance = sqrt(squared(hDistance) + squared(vDistance))// / scale
        return distance
    }
    
    fileprivate func convertPoint2RotatePoint(flag: Int, point: CGPoint, angle: CGFloat, center: CGPoint, radius: CGFloat) -> CGPoint {
        
        var toHDistance: CGFloat = 0
        var toVDistance: CGFloat = 0
        
        print("外边的angle:\(angle)")
        func topLeft(angle: CGFloat) -> CGPoint {
            toHDistance = sin(angle * CGFloat.pi / 180) * radius
            toVDistance = cos(angle * CGFloat.pi / 180) * radius
            print(point)
            print(center)
            print(angle)
            return CGPoint.init(x: center.x - abs(toVDistance), y: center.y - abs(toHDistance))
        }
        
        func topRight(angle: CGFloat) -> CGPoint {
            let _angle = 180 - angle
            toHDistance = sin(_angle * CGFloat.pi / 180) * radius
            toVDistance = cos(_angle * CGFloat.pi / 180) * radius
            return CGPoint.init(x: center.x + abs(toVDistance), y: center.y - abs(toHDistance))
        }
        
        func bottomRight(angle: CGFloat) -> CGPoint {
            toHDistance = sin(angle * CGFloat.pi / 180) * radius
            toVDistance = cos(angle * CGFloat.pi / 180) * radius
            return CGPoint.init(x: center.x + abs(toVDistance), y: center.y + abs(toHDistance))
        }
        
        func bottomLeft(angle: CGFloat) -> CGPoint {
            toHDistance = sin(angle * CGFloat.pi / 180) * radius
            toVDistance = cos(angle * CGFloat.pi / 180) * radius
            return CGPoint.init(x: center.x - abs(toVDistance), y: center.y + abs(toHDistance))
        }
        
        var tempAngle = angle
        
        switch flag {
        case 0:// start
            //            if tempAngle >= 180 {
            //                tempAngle -= 180
            //            }
            if angle <= 90 { return topLeft(angle: tempAngle) }
            else if angle <= 180 { return topRight(angle: tempAngle) }
            else if angle <= 270 { return bottomRight(angle: tempAngle) }
            else { return bottomLeft(angle: tempAngle) }
        case 1:// end
            //            if tempAngle >= 180 {
            //                tempAngle -= 180
            //            }
            tempAngle += 180
            if tempAngle >= 360 {
                tempAngle -= 360
            }
            if angle <= 90 { return bottomRight(angle: tempAngle) }
            else if angle <= 180 { return bottomLeft(angle: tempAngle) }
            else if angle <= 270 { return topLeft(angle: tempAngle) }
            else { return topRight(angle: tempAngle) }
        case 2:// bottom
            tempAngle += 270
            if tempAngle >= 360 {
                tempAngle -= 360
            }
            if angle <= 90 { return bottomLeft(angle: tempAngle) }
            else if angle <= 180 { return topLeft(angle: tempAngle) }
            else if angle <= 270 { return topRight(angle: tempAngle) }
            else { return bottomRight(angle: tempAngle) }
        default: return CGPoint.zero
        }
    }
    
    fileprivate func getSavePath(lastPath: ZHDrawPath) -> ZHDrawPath {
        let distance = getDistance(p1: lastPath.startLoc, p2: lastPath.endLoc)
        var ovalHeight = lastPath.ovalHeight == 0 ? distance * 0.5 : lastPath.ovalHeight
        print(lastPath.ovalHeight)
        print(ovalHeight)
        if lastPath.selectPoint == .oval {
            let centerX = lastPath.startLoc.x + (lastPath.endLoc.x - lastPath.startLoc.x) * 0.5
            let centerY = lastPath.startLoc.y + (lastPath.endLoc.y - lastPath.startLoc.y) * 0.5
            ovalHeight = getDistance(p1: lastPath.ovalLoc, p2: CGPoint.init(x: centerX, y: centerY)) * 2
        }
        print(ovalHeight)
        let centerFrame = getCenterFrame(p1: lastPath.startLoc, p2: lastPath.endLoc, width: distance, height: ovalHeight)
        print(centerFrame)
        let centerPoint = CGPoint.init(x: centerFrame.origin.x + centerFrame.size.width * 0.5, y: centerFrame.origin.y + centerFrame.size.height * 0.5)
        lastPath.ovalLoc = CGPoint.init(x: centerPoint.x, y: centerFrame.origin.y + centerFrame.size.height)
        var rotateAngle = AngleTool.getAnglesWithThreePoints(p1: lastPath.startLoc, p2: centerPoint, p3: CGPoint.init(x: centerFrame.origin.x - 100, y: centerPoint.y))
        if lastPath.startLoc.y < centerPoint.y {// 上
            if lastPath.startLoc.x < centerPoint.x {// 左上, 不处理
            } else {// 右上
                rotateAngle = 180 - rotateAngle
            }
        } else {// 下
            if lastPath.startLoc.x < centerPoint.x {// 左下
                rotateAngle = 360 - rotateAngle
            } else {// 右下
                rotateAngle += 180
            }
        }
        
        let savePath = ZHDrawPath(ovalIn: centerFrame)
        savePath.zh_rotate(angle: CGFloat(rotateAngle * Double.pi / 180))
        savePath.lineColor = lastPath.lineColor
        savePath.lineWidth = lastPath.lineWidth
        savePath.showLineInfo = lastPath.showLineInfo
        savePath.drawStyle = lastPath.drawStyle
        savePath.ovalHeight = ovalHeight
        savePath.selectPoint = lastPath.selectPoint
        
        let startPoint = CGPoint.init(x: centerFrame.origin.x, y: centerPoint.y)
        let endPoint = CGPoint.init(x: centerPoint.x + centerFrame.size.width, y: centerPoint.y)
        savePath.startLoc = convertPoint2RotatePoint(flag: 0, point: startPoint, angle: CGFloat(rotateAngle), center: centerPoint, radius: centerFrame.size.width * 0.5)
        savePath.endLoc = convertPoint2RotatePoint(flag: 1, point: endPoint, angle: CGFloat(rotateAngle), center: centerPoint, radius: centerFrame.size.width * 0.5)
        savePath.ovalLoc = convertPoint2RotatePoint(flag: 2, point: lastPath.ovalLoc, angle: CGFloat(rotateAngle), center: centerPoint, radius: ovalHeight * 0.5)
        
        return savePath
    }
}

extension ZHDrawView {
    
    fileprivate func drawLineDistance(path: ZHDrawPath) {
        
        let distance = getDistance(p1: path.startLoc, p2: path.endLoc)
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                          NSAttributedString.Key.foregroundColor: path.lineColor,
                          NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle()]
        let nsstr = String.init(format: "%dmm", Int(distance)) as NSString
        let size = nsstr.boundingRect(with: CGSize.init(width: 100, height: 30), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        func getLoc(start: CGFloat, end: CGFloat) -> CGFloat {
            return start < end ? start + (end - start) * 0.5 : end + (start - end) * 0.5
        }
        
        let x: CGFloat = getLoc(start: path.startLoc.x, end: path.endLoc.x)
        let y: CGFloat = getLoc(start: path.startLoc.y, end: path.endLoc.y)
        let disRect = CGRect.init(x: x, y: y, width: size.width, height: size.height)
        
        nsstr.draw(in: disRect, withAttributes: attributes)
    }
    
    fileprivate func drawOvalArea(path: ZHDrawPath) {
        
        //        let hDistance = abs(path.startLoc.x - path.endLoc.x)
        //        let vDistance = abs(path.startLoc.y - path.endLoc.y)
        let hDistance = getDistance(p1: path.startLoc, p2: path.endLoc)
        let vDistance = path.ovalHeight * 2
        let area = CGFloat.pi * hDistance * vDistance / scale
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                          NSAttributedString.Key.foregroundColor: path.lineColor,
                          NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle()]
        let nsstr = String.init(format: "%dmm²", Int(area)) as NSString
        let size = nsstr.boundingRect(with: CGSize.init(width: 100, height: 30), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        let centerX = path.startLoc.x + (path.endLoc.x - path.startLoc.x) * 0.5
        let centerY = path.startLoc.y + (path.endLoc.y - path.startLoc.y) * 0.5
        
        let disRect = CGRect.init(x: centerX - size.width * 0.5, y: centerY - size.height * 0.5, width: size.width, height: size.height)
        
        nsstr.draw(in: disRect, withAttributes: attributes)
    }
    
    
    fileprivate func getAngle(point: CGPoint, anglePoint: CGPoint) -> CGFloat {
        
        var resultAngle: Double = AngleTool.getAnglesWithThreePoints(p1: point, p2: anglePoint, p3: CGPoint.init(x: anglePoint.x + 100, y: anglePoint.y))
        if point.x <= anglePoint.x && point.y <= anglePoint.y || point.x >= anglePoint.x && point.y <= anglePoint.y {// 左上 右上
            resultAngle = (180 - resultAngle) + 180
        }
        
        return CGFloat(resultAngle)
    }
    
    fileprivate func drawAngle(path: ZHDrawPath) {
        
        let startAngle = getAngle(point: path.startLoc, anglePoint: path.angleLoc)
        let endAngle = getAngle(point: path.endLoc, anglePoint: path.angleLoc)
        
        var clockwise: Bool = true
        var subAngle: CGFloat = 0
        
        func changeColckwise() {
            if startAngle > endAngle {
                subAngle = startAngle - endAngle
                clockwise = subAngle > 180
                
            } else {
                subAngle = endAngle - startAngle
                clockwise = subAngle < 180
            }
            if subAngle > 180 {
                subAngle = 360 - subAngle
            } else {
            }
        }
        
        changeColckwise()
        
        let _startAngle = startAngle * CGFloat.pi / 180
        let _endAngle = endAngle * CGFloat.pi / 180
        
        let anglePath = UIBezierPath(arcCenter: path.angleLoc, radius: 30, startAngle: _startAngle, endAngle: _endAngle, clockwise: clockwise)
        
        anglePath.stroke()
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                          NSAttributedString.Key.foregroundColor: path.lineColor,
                          NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle()]
        let nsstr = "\(Int(subAngle))°" as NSString
        let size = nsstr.boundingRect(with: CGSize.init(width: 100, height: 50), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        let disRect = CGRect.init(x: path.angleLoc.x - size.width * 0.5, y: path.angleLoc.y - size.height - 4, width: size.width, height: size.height)
        
        nsstr.draw(in: disRect, withAttributes: attributes)
    }
}
