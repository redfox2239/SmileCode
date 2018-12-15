//
//  ViewController.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/14.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var playCollectionView: UICollectionView!
    let cellNumber = CGFloat(5)
    var cellSize = CGFloat(0)
    var characterPositionIndex = IndexPath(row: 0, section: 0)
    var goalPositionIndex = IndexPath(row: 0, section: 0)
    
    var actions = [()->Void]()
    enum actionName: String {
        case moveRight = "右に動く", moveLeft = "左に動く", moveUp = "上に動く", moveDown = "下に動く", hide = "かくす", show = "表示する"
    }
    var actionsName = [actionName]()
    
    let speed = TimeInterval(0.25)
    var isMoveFlag = false
    
    @IBOutlet weak var programmingTableView: UITableView!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionViewSetUp()
        programmingTableViewSetUp()
    }
    
    func collectionViewSetUp() {
        let characterRandom = arc4random() % UInt32(cellNumber * cellNumber)
        var goalRandom = arc4random() % UInt32(cellNumber * cellNumber)
        while true {
            if characterRandom != goalRandom {
                break
            }
            goalRandom = arc4random() % UInt32(cellNumber * cellNumber)
        }
        goalPositionIndex = IndexPath(row: Int(goalRandom), section: 0)
        characterPositionIndex = IndexPath(row: Int(characterRandom), section: 0)
        cellSize = UIScreen.main.bounds.size.width*0.5 / cellNumber
        playCollectionView.reloadData()
    }
    
    func programmingTableViewSetUp() {
        programmingTableView.reloadData()
        if actionsName.count > 0 {
            let lastIndexPath = IndexPath(row: actionsName.count-1, section: 0)
            programmingTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    @IBAction func tapAddImageButton(_ sender: Any) {
    }
    
    var actionIndex = -1
    @IBAction func tapBuildButton(_ sender: Any) {
        actionIndex = 0
        let firstIndexPath = IndexPath(row: actionIndex, section: 0)
        programmingTableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { (ti) in
            self.programmingTableView.reloadData()
            if self.actionIndex < self.actionsName.count {
                let firstIndexPath = IndexPath(row: self.actionIndex, section: 0)
                self.programmingTableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
            }
            if self.actions.count == self.actionIndex {
                ti.invalidate()
                self.actionIndex = -1
            }
            else {
                self.actions[self.actionIndex]()
            }
        }
    }
    
    @IBAction func tapResetButton(_ sender: Any) {
        timer.invalidate()
        actionIndex = -1
        actions = [()->Void]()
        actionsName = [actionName]()
        collectionViewSetUp()
        programmingTableViewSetUp()
    }
    
    enum moveType {
        case right, left, up, down
    }
    fileprivate func move(type: moveType) {
        if isMoveFlag {
            return
        }
        print(actionIndex)
        var i = 0
        switch type {
        case .right:
            i = 1
        case .left:
            i = -1
        case .down:
            i = Int(cellNumber)
        case .up:
            i = -Int(cellNumber)
        }
        let nextIndexPath = IndexPath(row: characterPositionIndex.row+i, section: characterPositionIndex.section)
        if let nextCell = playCollectionView.cellForItem(at: nextIndexPath) as? PlayCollectionViewCell {
            let cell = playCollectionView.cellForItem(at: characterPositionIndex) as! PlayCollectionViewCell
            let point = self.view.convert(cell.characterImageView.frame.origin, from: cell)
            let size = UIScreen.main.bounds.size.width * 0.5 / cellNumber * 0.7
            let nextPoint = self.view.convert(nextCell.characterImageView.frame.origin, from: nextCell)
            let dx = nextPoint.x - point.x
            let dy = nextPoint.y - point.y
            if (Int(dx) > Int(size/0.7) * 2) || (Int(dx) < -Int(size/0.7) * 2) {
                self.isMoveFlag = false
                self.actionIndex += 1
                return
            }
            isMoveFlag = true
            cell.characterImageView.isHidden = true
            let imageView = UIImageView(frame: CGRect(x: point.x, y: point.y, width: size, height: size))
            imageView.image = UIImage(named: "denko_normal")
            imageView.contentMode = .scaleAspectFit
            self.view.addSubview(imageView)
            UIView.animate(withDuration: speed, animations: {
                imageView.frame.origin.x += dx
                imageView.frame.origin.y += dy
            }) { (animate) in
                imageView.removeFromSuperview()
                self.characterPositionIndex = nextIndexPath
                self.playCollectionView.reloadData()
                self.isMoveFlag = false
                self.actionIndex += 1
                if self.actionIndex == self.actionsName.count {
                    self.showGoalWindow()
                }
            }
        }
        else {
            self.isMoveFlag = false
            self.actionIndex += 1
        }
    }
    
    var isHidden = false
    func showAndHide() {
        if isMoveFlag {
            return
        }
        isMoveFlag = true
        let cell = playCollectionView.cellForItem(at: characterPositionIndex) as! PlayCollectionViewCell
        UIView.animate(withDuration: speed, animations: {
            cell.characterImageView.isHidden = !self.isHidden
            self.isHidden = !self.isHidden
        }) { (animate) in
            self.isMoveFlag = false
            self.actionIndex += 1
        }
    }
    
    var goalWindow: UIWindow? = nil
    fileprivate func showGoalWindow() {
        goalWindow = UIWindow()
        goalWindow?.backgroundColor = UIColor.black
        goalWindow?.alpha = 0.5
        goalWindow?.makeKeyAndVisible()
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(ViewController.touchGoalWindow(_:)))
        goalWindow?.addGestureRecognizer(tapGestureRec)
        let goalViewXib = UINib(nibName: "GoalView", bundle: nil)
        if let goalView = goalViewXib.instantiate(withOwner: self, options: nil).first as? GoalView {
            goalView.frame = UIScreen.main.bounds
            if characterPositionIndex != goalPositionIndex {
                goalView.goalLabel.text = "残念(´；ω；｀)"
            }
            goalWindow?.addSubview(goalView)
        }
    }
    
    @objc func touchGoalWindow(_ touch: UITapGestureRecognizer) {
        if goalWindow != nil {
            UIApplication.shared.windows.forEach { (win) in
                if win == goalWindow {
                    goalWindow = nil
                }
                else {
                    win.makeKeyAndVisible()
                }
            }
        }
    }
    
    @IBAction func tapMoveRightButton(_ sender: Any) {
        actions.append {
            self.move(type: .right)
        }
        actionsName.append(.moveRight)
        programmingTableViewSetUp()
    }
    
    @IBAction func tapMoveLeftButton(_ sender: Any) {
        actions.append {
            self.move(type: .left)
        }
        actionsName.append(.moveLeft)
        programmingTableViewSetUp()
    }
    
    @IBAction func tapMoveUpButton(_ sender: Any) {
        actions.append {
            self.move(type: .up)
        }
        actionsName.append(.moveUp)
        programmingTableViewSetUp()
    }
    
    @IBAction func tapMoveDownButton(_ sender: Any) {
        actions.append {
            self.move(type: .down)
        }
        actionsName.append(.moveDown)
        programmingTableViewSetUp()
    }
    
    @IBAction func tapHideButton(_ sender: Any) {
        actions.append {
            self.showAndHide()
        }
        actionsName.append(.hide)
        programmingTableViewSetUp()
    }
    
    @IBAction func tapShowButton(_ sender: Any) {
        actions.append {
            self.showAndHide()
        }
        actionsName.append(.show)
        programmingTableViewSetUp()
    }
    
}

