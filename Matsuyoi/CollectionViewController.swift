//
//  CollectionViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/07/31.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//


import UIKit
import RealmSwift

class CollectionViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection: UICollectionView!
    var photos:[NSURL] = []
    var names:[String] = []
    var selectedList:[SpotList] = []
    var reversObjs:[SpotList] = []

    let refresh = UIRefreshControl()

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        let realm = try! Realm()
        collection.refreshControl = refresh
        refresh.addTarget(self, action: #selector(CollectionViewController.getData), for: UIControlEvents.valueChanged)
        getData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            var detailViewController = segue.destination as! DetailViewController
            detailViewController.SelectedList = selectedList
        }
    }

    func getData(){
        let realm = try! Realm()
        var objs = realm.objects(SpotList.self)
        reversObjs = objs.reversed()
        self.photos = []
        self.names = []
        for myList in reversObjs {
            let url = myList.url
            let name = myList.name
            let photoUrl: NSURL = NSURL(string:url!)!  //urlの文字列を与えてNSURLのインスタンスを作成
            photos.append(photoUrl)
            names.append(name!)
            dump(name)
        }
        self.collection.reloadData()
        self.refresh.endRefreshing()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width/2-2
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize)
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return photos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // Cell はストーリーボードで設定したセルのID
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let photo = photos[indexPath.row]
        imageView.sd_setImage(with: photo as URL!)
        
        // Tag番号を使ってLabelのインスタンス生成
        let label = cell.contentView.viewWithTag(2) as! UILabel
        label.text = names[(indexPath as NSIndexPath).row]
        
        return cell
    }
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedList = [reversObjs[(indexPath as NSIndexPath).row]]
        performSegue(withIdentifier: "DetailSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

