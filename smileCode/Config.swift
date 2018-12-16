//
//  Config.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/16.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

class Config: NSObject {
    static var rate: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 0.5
        }
        else {
            return 0.35
        }
    }
}
