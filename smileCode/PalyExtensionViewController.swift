//
//  PalyViewController.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/14.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(cellNumber * cellNumber)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayCollectionViewCell", for: indexPath) as! PlayCollectionViewCell
        cell.characterImageView.isHidden = true
        cell.goalImageView.isHidden = true
        cell.poolImageView.isHidden = true
        if indexPath == characterPositionIndex {
            cell.characterImageView.isHidden = isHidden
        }
        else if indexPath == goalPositionIndex {
            cell.goalImageView.isHidden = false
        }
        else if indexPath == poolPositionIndex {
            cell.poolImageView.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
}
