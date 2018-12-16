//
//  ViewController.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/14.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit
import AVFoundation

enum actionName: String {
    case moveRight = "右に動く", moveLeft = "左に動く", moveUp = "上に動く", moveDown = "下に動く", hide = "かくす", show = "表示する"
    
    func getImageName() -> String {
        switch self {
        case .moveRight:
            return "face_right"
        case .moveLeft:
            return "face_left"
        case .moveUp:
            return "face_up"
        case .moveDown:
            return "face_down"
        default:
            return ""
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var playCollectionView: UICollectionView!
    let cellNumber = CGFloat(5)
    var cellSize = CGFloat(0)
    var characterPositionIndex = IndexPath(row: 0, section: 0)
    var goalPositionIndex = IndexPath(row: 0, section: 0)
    var poolPositionIndex = IndexPath(row: 0, section: 0)
    
    var actions = [()->Void]()
    var actionsName = [actionName]()
    
    var programmingManager = ProgrammingManager()
    
    let speed = TimeInterval(0.25)
    let timerInterval = TimeInterval(0.3)

    var isMoveFlag = false
    
    @IBOutlet weak var programmingTableView: UITableView!
    
    var timer: Timer!
    
    @IBOutlet weak var cameraView: UIView!
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var captureSession = AVCaptureSession()
    var photoOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureVideoDataOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var previewciImage: CIImage?
    
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var faceDirectionImageView: UIImageView!
    @IBOutlet weak var faceEyeImageView: UIImageView!
    
    let faceLimitAngle = Float(15)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        programmingManager.startProgramming()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)

        setupCaptureSession()
        setupDevice()
        setupVideoInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        
        collectionViewSetUp()
        programmingTableViewSetUp()
        
        startJudge()
    }
    
    func collectionViewSetUp() {
        let characterRandom = arc4random() % UInt32(cellNumber * cellNumber)
        var goalRandom = arc4random() % UInt32(cellNumber * cellNumber)
        var poolRandom = arc4random() % UInt32(cellNumber * cellNumber)
        while true {
            if characterRandom != goalRandom {
                break
            }
            goalRandom = arc4random() % UInt32(cellNumber * cellNumber)
        }
        while true {
            if poolRandom != goalRandom && poolRandom != characterRandom {
                break
            }
            poolRandom = arc4random() % UInt32(cellNumber * cellNumber)
        }
        goalPositionIndex = IndexPath(row: Int(goalRandom), section: 0)
        characterPositionIndex = IndexPath(row: Int(characterRandom), section: 0)
        poolPositionIndex = IndexPath(row: Int(poolRandom), section: 0)
        cellSize = UIScreen.main.bounds.size.width*Config.rate / cellNumber
        playCollectionView.reloadData()
    }
    
    func programmingTableViewSetUp() {
        programmingTableView.reloadData()
        if actionsName.count > 0 {
            let lastIndexPath = IndexPath(row: actionsName.count-1, section: 0)
            programmingTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }

    func removeActionForLastIndex() {
        if actionsName.count > 0 && actions.count > 0 {
            let lastIndex = IndexPath(row: actions.count - 1, section: 0)
            var newAction = [()->Void]()
            actions.enumerated().forEach { (index, val) in
                if index != actions.count - 1 {
                    newAction.append {
                        val()
                    }
                }
            }
            actions = newAction
            actionsName.removeLast()
            programmingTableView.deleteRows(at: [lastIndex], with: .fade)
        }
    }
    
    var actionIndex = -1
    func execProgramming() {
        if actionsName.count > 0 && actions.count > 0 && actionIndex == -1 {
            programmingManager.state = .none
            actionIndex = 0
            let firstIndexPath = IndexPath(row: actionIndex, section: 0)
            programmingTableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { (ti) in
                self.programmingTableView.reloadData()
                if self.actionIndex < self.actionsName.count {
                    let firstIndexPath = IndexPath(row: self.actionIndex, section: 0)
                    self.programmingTableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
                }
                if self.actions.count == self.actionIndex {
                    ti.invalidate()
                }
                else {
                    self.actions[self.actionIndex]()
                }
            }
        }
    }
    
    @IBAction func tapBuildButton(_ sender: Any) {
        execProgramming()
    }
    
    fileprivate func reset() {
        timer.invalidate()
        actionIndex = -1
        actions = [()->Void]()
        actionsName = [actionName]()
        collectionViewSetUp()
        programmingTableViewSetUp()
    }
    
    @IBAction func tapResetButton(_ sender: Any) {
        reset()
    }
    
    enum moveType {
        case right, left, up, down
    }
    fileprivate func move(type: moveType) {
        if isMoveFlag {
            return
        }
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
            let size = UIScreen.main.bounds.size.width * Config.rate / cellNumber * 0.7
            let nextPoint = self.view.convert(nextCell.characterImageView.frame.origin, from: nextCell)
            let dx = nextPoint.x - point.x
            let dy = nextPoint.y - point.y
            if (Int(dx) > Int(size/0.7) * 2) || (Int(dx) < -Int(size/0.7) * 2) {
                self.isMoveFlag = false
                self.actionIndex += 1
                if self.actionIndex == self.actionsName.count {
                    self.showGoalOrFailWindow()
                }
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
                if self.characterPositionIndex == self.poolPositionIndex {
                    self.showPoolFailWindow()
                    self.timer.invalidate()
                    self.actionIndex = -1
                }
                if self.actionIndex == self.actionsName.count {
                    self.showGoalOrFailWindow()
                }
            }
        }
        else {
            self.isMoveFlag = false
            self.actionIndex += 1
            if self.actionIndex == self.actionsName.count {
                self.showGoalOrFailWindow()
            }
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
    fileprivate func showGoalOrFailWindow() {
        goalWindow = UIWindow()
        goalWindow?.backgroundColor = UIColor.clear
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        goalWindow?.addSubview(view)
        goalWindow?.makeKeyAndVisible()
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(ViewController.touchGoalWindow(_:)))
        goalWindow?.addGestureRecognizer(tapGestureRec)
        let goalViewXib = UINib(nibName: "GoalView", bundle: nil)
        if let goalView = goalViewXib.instantiate(withOwner: self, options: nil).first as? GoalView {
            goalView.frame = UIScreen.main.bounds
            if characterPositionIndex != goalPositionIndex {
                goalView.changeFailImage()
            }
            else {
                goalView.changeGoalImage()
            }
            goalWindow?.addSubview(goalView)
        }
    }
    
    fileprivate func showPoolFailWindow() {
        goalWindow = UIWindow()
        goalWindow?.backgroundColor = UIColor.clear
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        goalWindow?.addSubview(view)
        goalWindow?.makeKeyAndVisible()
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(ViewController.touchGoalWindow(_:)))
        goalWindow?.addGestureRecognizer(tapGestureRec)
        let goalViewXib = UINib(nibName: "GoalView", bundle: nil)
        if let goalView = goalViewXib.instantiate(withOwner: self, options: nil).first as? GoalView {
            goalView.frame = UIScreen.main.bounds
            goalView.changeFailImage()
            goalWindow?.addSubview(goalView)
        }
    }
    
    func addAction(_ action: actionName) {
        switch action {
        case .moveRight:
            actions.append {
                self.move(type: .right)
            }
        case .moveLeft:
            actions.append {
                self.move(type: .left)
            }
        case .moveUp:
            actions.append {
                self.move(type: .up)
            }
        case .moveDown:
            actions.append {
                self.move(type: .down)
            }
        case .hide: break
        case .show: break
        }
        actionsName.append(action)
        programmingTableViewSetUp()
        programmingManager.startProgramming()
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
        reset()
        programmingManager.startProgramming()
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

