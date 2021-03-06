//
//  ProgrammingExtensionViewController.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/15.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "プログラミング"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionsName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActionTableViewCell
        let imgStr = actionsName[indexPath.row].getImageName()
        cell.actionImageView.image = UIImage(named: imgStr)
        cell.backgroundColor = .white
        if indexPath.row == actionIndex {
            cell.backgroundColor = UIColor.blue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height * 0.1
    }
    
}
