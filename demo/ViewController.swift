//
//  ViewController.swift
//  demo
//
//  Created by zhanghao on 2020/4/21.
//  Copyright © 2020 zhanghao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let tableView = UITableView.init(frame: UIScreen.main.bounds, style: .plain)
    private let source: [ZHDrawStyle] = [.line, .angle, .oval]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = DrawController.init()
        controller.drawStyle = source[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            cell?.selectionStyle = .none
        }
        
        cell?.textLabel?.text = source[indexPath.row].rawValue
        
        return cell!
    }
    
}
