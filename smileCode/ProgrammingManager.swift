//
//  ProgrammingManager.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/15.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

class ProgrammingManager: NSObject {
    
    let faceLimitAngle = Float(15)
    
    enum programmingState {
        case none, programming, wasProgramming, commit
    }
    
    var state = programmingState.none
    
    func startProgramming() {
        state = .programming
    }
    
    func insertProgramming() {
        state = .wasProgramming
    }
    
    func startCommitting() {
        state = .commit
    }
    
    func canProgramming() -> Bool {
        return state == .programming || state == .wasProgramming
    }
    
    func canCommitProgramming() -> Bool {
        return state == .wasProgramming
    }
    
    func commitingProgramming() -> Bool {
        return state == .commit
    }
    
    func programming(feature: CIFaceFeature?) -> actionName? {
        guard let f = feature else { return nil }
        // 左に傾いてる
        // 右に傾いてる
        // 右目つぶる
        // 左目つぶる
        if f.faceAngle < Float(-1)*faceLimitAngle {
            return .moveLeft
        }
        else if f.faceAngle > faceLimitAngle {
            return .moveRight
        }
        else if f.rightEyeClosed {
            return .moveUp
        }
        else if f.leftEyeClosed {
            return .moveDown
        }
        return nil
    }
}
