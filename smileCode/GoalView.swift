//
//  GoalView.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/15.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

class GoalView: UIView {

    @IBOutlet weak var goalImageView: UIImageView!
    
    enum status: String {
        case success = "denko_success", fail = "denko_fail"
    }
    
    func changeGoalImage() {
        if let goalStatus = status(rawValue: "denko_success") {
            goalImageView.image = UIImage(named: goalStatus.rawValue)
        }
    }
    
    func changeFailImage() {
        if let goalStatus = status(rawValue: "denko_fail") {
            goalImageView.image = UIImage(named: goalStatus.rawValue)
        }
    }
    
}
