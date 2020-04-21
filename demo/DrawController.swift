//
//  DrawController.swift
//  demo
//
//  Created by zhanghao on 2020/4/21.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

class DrawController: UIViewController {

    public var drawStyle: ZHDrawStyle = .static
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .black
        let drawView = ZHDrawView.init(frame: view.bounds)
        drawView.drawStyle = drawStyle
        view.addSubview(drawView)
    }

}
