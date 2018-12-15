//
//  DenkoImageView.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/15.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

class DenkoImageView: UIImageView {
    
    enum status: String {
        case normal = "denko_normal", smile = "denko_smile"
        func getNextStatus() -> status {
            switch self {
            case .normal:
                return .smile
            default:
                return .normal
            }
        }
    }
    
    var imageStatus = status(rawValue: "denko_normal")
    let speed = TimeInterval(0.5)

    override func awakeFromNib() {
        animateDenko()
    }
    
    func animateDenko() {
        Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { (ti) in
            let nextStatus = self.imageStatus?.getNextStatus()
            if let imgString = nextStatus?.rawValue {
                self.imageStatus = nextStatus
                self.image = UIImage(named: imgString)
            }
        }
    }

}
