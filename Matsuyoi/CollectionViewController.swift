//
//  CollectionViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/07/31.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//


import UIKit
import RealmSwift
import KRProgressHUD
import PopupDialog
import StatusProvider


class CollectionViewController: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,StatusController{
    
    @IBOutlet weak var collection: UICollectionView!
    var photos:[NSURL] = []
    var names:[String] = []
    var selectedList:[SpotList] = []
    var reversObjs:[SpotList] = []

    let refresh = UIRefreshControl()
    
    //Realm
    let realm = try! Realm()

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲートの宣言
        collection.delegate = self
        collection.dataSource = self
        
        //ナビゲーションバーの設定
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        //更新画面
        if #available(iOS 10.0, *) {
            collection.refreshControl = refresh
        } else {
            // Fallback on earlier versions
        }
        refresh.addTarget(self, action: #selector(CollectionViewController.getData), for: UIControlEvents.valueChanged)
        
        //Realmのデータ取得
        getData()
    }
    
    //画面切り替わったら更新
    override public func viewDidAppear(_ animated: Bool) {
        self.getData()
    }
    
    //選択されたら画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.SelectedList = selectedList
        }
    }
    
    //Realmからデータ取得
    func getData(){
        let objs = realm.objects(SpotList.self)
        reversObjs = objs.reversed()    //オブジェクトを降順にする
        self.photos = []
        self.names = []
        
        if reversObjs == []{
            let status = Status(title: "No Data", description: "データがありません",  image: UIImage(named: "matsuyoi")) {
                self.hideStatus()
            }
            show(status: status) //nodataの表示
        }else if reversObjs != []{
            hideStatus()    //nodata画面閉じる
            for myList in reversObjs {
                let url = myList.url
                let name = myList.name
                let photoUrl: NSURL = NSURL(string:url!)!  //urlの文字列を与えてNSURLのインスタンスを作成
                photos.append(photoUrl)
                names.append(name!)
            }
        }
        self.collection.reloadData()
        self.refresh.endRefreshing()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width/2-1
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


    //全データ削除
    @IBAction func tappedTrash(_ sender: Any) {
        showImageDialog()
    }
    //削除するかのアラート
    func showImageDialog(animated: Bool = true) {
        let realm = try! Realm()
        let delete = realm.objects(SpotList.self)
        // Prepare the popup
        let title = "Delete All Data"
        let message = "お気に入りにスワイプしたスポットのデータが全て消去されますがよろしいですか？"
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
            self.getData()
        }
        
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL") {
        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "OK") {
            delete.forEach { data in
                try! realm.write() {
                    realm.delete(data)
                }
            }
        }
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
