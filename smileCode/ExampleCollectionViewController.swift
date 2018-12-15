//
//  ExampleCollectionViewController.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/15.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

class ExampleCollectionViewController: UIViewController {
    
    let exampleNumber = CGFloat(5)
    let exampleData = [
        "顔を右に傾ける→右に動く",
        "顔を左に傾ける→左に動く",
        "顔を右目を閉じる→上に動く",
        "顔を左目を閉じる→下に動く",
        "笑顔→プログラミング追加",
        "両目を閉じる→プログラミング削除",
        "画面から顔をなくす→プログラミング実行",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension ExampleCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exampleData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCollectionViewCell", for: indexPath) as! ExampleCollectionViewCell
        cell.exampleLabel.text = exampleData[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.size.width * 0.5 / exampleNumber
        return CGSize(width: size, height: size)
    }
}
