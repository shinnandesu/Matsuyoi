//
//  ViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/07/29.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import UIKit
import CoreLocation
import Koloda
import Alamofire
import SwiftyJSON
import FloatRatingView
import RealmSwift
import SDWebImage
import KRProgressHUD
import PopupDialog
import TZSegmentedControl

//カードの初期設定
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1


//スポットのクラス
class SpotList: Object {
    dynamic var name:String!
    dynamic var url:String?
    dynamic var info:String!
    dynamic var score:String!
    dynamic var category:String!
    dynamic var lat:String!
    dynamic var lng:String!
}

class ViewController: UIViewController,FloatRatingViewDelegate,UIViewControllerTransitioningDelegate,CLLocationManagerDelegate{
    
    //取得したスポットの配列
    var spotLists:[SpotList] = []
    //選択したスポットの配列
    var selectedList:[SpotList] = []
    // タブのタイトルを設定
    
    //パラメータのデフォルト値
    var Latitude:Double = 0.0
    var currentLatitude:Double = 0.0
    var Longitude:Double = 0.0
    var currentLongitude:Double = 0.0
    var selectedType = 1
    var Distance:Int = 0
    var Level:Float = 0.0
    var Category:String = ""
    let uuid = UIDevice.current.identifierForVendor!.uuidString


    let userDefaults = UserDefaults.standard
    //リフレッシュするボタン
    let button = UIButton()
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var unlikeButton: UIButton!
    @IBOutlet weak var floatRatingView: FloatRatingView! //レビュー星
    @IBOutlet weak var kolodaView: CustomKolodaView! //tinderView
    @IBOutlet weak var kolodaLabel: UILabel! //名前
    @IBOutlet weak var revertButton: UIButton!//戻るボタン
    @IBOutlet weak var score: UILabel! //隠れスポット度
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    
    var locationManager: CLLocationManager!


    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        currentLatitude = userDefaults.double(forKey: "currentlat")
        currentLongitude = userDefaults.double(forKey: "currentlng")
        


        
        //オフライン時の再読み込みボタン
        button.setImage(#imageLiteral(resourceName: "refresh"), for:UIControlState())
        button.addTarget(self, action: #selector(self.buttonEvent(sender:)), for: .touchUpInside)
        button.sizeToFit()
        button.center = self.view.center
        self.view.addSubview(button)
        button.isHidden = true
    
        
        locationManager = CLLocationManager() // インスタンスの生成
        locationManager.delegate = self as! CLLocationManagerDelegate // CLLocationManagerDelegateプロトコルを実装するクラスを指定する


        //レビュー星の設定
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
        // Optional params
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIViewContentMode.scaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 1
        self.floatRatingView.editable = false
        self.floatRatingView.floatRatings = true
        self.floatRatingView.halfRatings = true
        
        //tinderUIの設定
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        

        
        checkNetwork()

    }
    //Saveされたら再読み込み
    override func viewWillAppear(_ animated: Bool) {
        
       

        

        //ナビゲーションバー透過
        self.navigationController?.isToolbarHidden = true
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem

        // タイトルをセット
        self.navigationItem.title = "MATSUYOI"
        
        
        // フォント種をTime New Roman、サイズを10に指定
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSFontAttributeName: UIFont(name: "Futura", size: 20)!]
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let count = userDefaults.bool(forKey: "count")
        
        if (count == true){
            checkNetwork()
        }
        self.userDefaults.set(false, forKey: "count")

    }
    //セグエ設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination
        
//        //セグエの設定
//        if segue.identifier == "nextSegue" {
//            let detailViewController = segue.destination as! DetailViewController
//            detailViewController.SelectedList = selectedList
//            detailViewController.SelectedType = selectedType
//        }
    }
       //位置情報更新
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        currentLatitude = (location?.coordinate.latitude)!
        currentLongitude = (location?.coordinate.longitude)!
        self.userDefaults.set(self.currentLatitude, forKey: "currentLat")
        self.userDefaults.set(self.currentLongitude, forKey: "currentLng")
    }
    
    
    //ネット状況チェック
    func checkNetwork(){
        //一旦ボタン隠す
        self.floatRatingView.isHidden = true
        self.likeButton.isHidden = true
        self.unlikeButton.isHidden = true
        self.revertButton.isHidden = true
        self.kolodaView.isHidden = true
        self.kolodaLabel.isHidden = true
        self.score.isHidden = true
        self.settingButton.isHidden = true
        self.locationButton.isHidden = true

        let net = NetworkReachabilityManager()
        net?.startListening()
        if  net?.isReachable ?? false {
            
            if ((net?.isReachableOnEthernetOrWiFi) != nil) {
                //do some
                print("isReachableOnEthernetOrWiFi")
                getImages()
                
            }else if(net?.isReachableOnWWAN)! {
                //do some
                print("isReachableOnWWAN")
                getImages()
            }
        } else {
            //オフライン
            print("no connection")
            floatRatingView.isHidden = true
            likeButton.isHidden = true
            unlikeButton.isHidden = true
            revertButton.isHidden = true
            kolodaView.isHidden = true
            kolodaLabel.isHidden = true
            score.isHidden = true
            settingButton.isHidden = true
            locationButton.isHidden = true
            self.button.isHidden = false


            showImageDialog(Title:"No Connection",Message:"インターネットに接続されていません")
        }
    }
    //ダイアログメッセージ
    func showImageDialog(animated: Bool = true,Title:String,Message:String) {
        // Prepare the popup
        let title = Title
        let message = Message
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: "OK") {
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
    //再読み込みボタン
    func buttonEvent(sender: UIButton) {
       checkNetwork()
    }
    
    //APIからJSONを取ってくる
    func getImages(){
        Latitude = userDefaults.double(forKey: "lat")
        Longitude = userDefaults.double(forKey: "lng")
        Distance = userDefaults.integer(forKey: "distance")
        Level = userDefaults.float(forKey: "level")
        Category = userDefaults.string(forKey: "category")!

        print(Category)
        self.spotLists = []
        let parameters = [
            "lat": Latitude,
            "lng": Longitude,
            "distance": Distance,
            "level":Level,
            "category":Category,
            ] as [String : Any]
    
        Alamofire.request("https://life-cloud.ht.sfc.keio.ac.jp/~shinsan/SpoTrip/json.php", method:.post,parameters: parameters)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                if (json == []){
                    // Prepare the popup
                    let title = "No Data"
                    let message = "検索範囲を変更してください"
                    
                    // Create the dialog
                    let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
                    }
                    
                    // Create first button
                    let buttonOne = DefaultButton(title: "設定") {
                        self.performSegue(withIdentifier: "toSetting",sender: nil)
                        self.button.isHidden = false
                    }
                
                    // Add buttons to dialog
                    popup.addButtons([buttonOne])
                    
                    // Present dialog
                    self.present(popup, animated: true, completion: nil)

                }else{
                    self.revertButton.isEnabled = false
                    self.floatRatingView.isHidden = false
                    self.likeButton.isHidden = false
                    self.unlikeButton.isHidden = false
                    self.revertButton.isHidden = false
                    self.kolodaView.isHidden = false
                    self.kolodaLabel.isHidden = false
                    self.score.isHidden = false
                    self.settingButton.isHidden = false
                    self.locationButton.isHidden = false
                    self.button.isHidden = true
               
                    
                    for (_, subJson):(String, JSON) in json {
                        let spotList:SpotList = SpotList()
                        spotList.name = subJson["name"].string
                        spotList.url = subJson["url"].string
                        spotList.info = subJson["info"].string
                        spotList.score = subJson["score"].string
                        spotList.category = subJson["category_name"].string
                        spotList.lat = subJson["lat"].string
                        spotList.lng = subJson["lng"].string
                        self.spotLists.append(spotList)
                    }
                }
                
                
                self.kolodaView.reloadData()
        }
    }
    
        //結果をサーバに送る
        func sendArray(venueName:String,bool:Int) {
    
            let parameters = [
                "name": venueName,
                "bool": bool,
                "lat" : currentLatitude,
                "lon" : currentLongitude,
                "uuid" : uuid,
            ] as [String : Any]
    
            Alamofire.request(NSURL(string:"http://life-cloud.ht.sfc.keio.ac.jp/~shinsan/SpoTrip/get_result.php")! as URL, method:.post, parameters: parameters)
    
    
        }


    //右スワイプさせる
    @IBAction func goodButton(_ sender: Any) {
        kolodaView?.swipe(.right)

    }
    //左スワイプさせる
    @IBAction func badTapped(_ sender: Any) {
        kolodaView?.swipe(.left)
    }
    //戻らせる
    @IBAction func returnTapped(_ sender: Any) {
        if(spotLists != []){
            KRProgressHUD.show()
            KRProgressHUD.show(withMessage: "一つ前に戻ります") {
                print("Complete handler")
            }
            kolodaView?.revertAction()
            revertButton.isEnabled = false
        }
    }
    @IBAction func locationTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if(currentLatitude>35.58 && 35.74>currentLatitude && currentLongitude>139.66 && 139.80>currentLongitude){
            
            
            // Create the dialog
            let popup = PopupDialog(title:"現在地から検索", message: "検索位置を現在地にしてよろしいですか？", buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
            }
            
            // Create first button
            let buttonOne = CancelButton(title: "CANCEL") {
            }
            
            // Create second button
            let buttonTwo = DefaultButton(title: "OK") {
                self.userDefaults.set(self.currentLatitude, forKey: "lat")
                self.userDefaults.set(self.currentLongitude, forKey: "lng")
                self.checkNetwork()
            }
            // Add buttons to dialog
            popup.addButtons([buttonOne, buttonTwo])
            // Present dialog
            self.present(popup, animated: true, completion: nil)
        }else{
            // Create the dialog
            let popup = PopupDialog(title:"東京にいません", message: "現在地機能は東京23区のみ使用可能です", buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
            }
            // Create first button
            let buttonOne = CancelButton(title: "OK") {
            }
            // Add buttons to dialog
            popup.addButtons([buttonOne])
            // Present dialog
            self.present(popup, animated: true, completion: nil)
        }
    }

}

//MARK: KolodaViewDelegate
extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        self.floatRatingView.isHidden = true
        self.likeButton.isHidden = true
        self.unlikeButton.isHidden = true
        self.revertButton.isHidden = true
        self.kolodaView.isHidden = true
        self.kolodaLabel.isHidden = true
        self.score.isHidden = true
        self.settingButton.isHidden = true
        self.locationButton.isHidden = true
        self.button.isHidden = false
        self.kolodaView.resetCurrentCardIndex()

        let title = "No Card"
        let message = "検索範囲のスポットがなくなりました"
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL") {
        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "再読み込み") {
            self.checkNetwork()
        }
        let buttonThree = DefaultButton(title: "設定変更"){
            self.performSegue(withIdentifier: "toSetting",sender: nil)
        }
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo,buttonThree])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        performSegue(withIdentifier: "nextSegue", sender: nil)
    }
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }

    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let realm = try! Realm()
       switch direction {
        case .left :
            if self.spotLists.count != 0{
                if let swipenames  = self.spotLists[Int(index)].name{
                    
                    let boolean = 0
                    
                    sendArray(venueName:swipenames,bool:boolean)
                    
                    
                }
            }
            revertButton.isEnabled = true
        case .right :
            if self.spotLists.count != 0{
                if let swipenames  = self.spotLists[Int(index)].name{
                    
                    let boolean = 1
                    
                    sendArray(venueName: swipenames,bool:boolean)
                    
                }
                
                let goodList = [self.spotLists[Int(index)]]
                try! realm.write() {
                    realm.add(goodList)

                }
            }
            revertButton.isEnabled = true
        default:
            return
        }
    }
}


extension ViewController: KolodaViewDataSource {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return spotLists.count
    }
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        var imageView = UIImageView()
        imageView = UIImageView(frame: self.view.frame)
        if self.spotLists.count != 0 {
            if var image = self.spotLists[Int(index)].url{
                imageView.sd_setImage(with: NSURL(string: image) as URL!)
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                self.view.addSubview(imageView)
            }
        }
       
        return imageView
    }
    
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        if self.spotLists.count != 0 {
            if let spotName  = self.spotLists[Int(index)].name{
                if let spotScore = self.spotLists[Int(index)].score{
                    let floatScore = Float(spotScore)
                    kolodaLabel.text = spotName
                    selectedList = [self.spotLists[Int(index)]]
                    self.floatRatingView.rating = floatScore!
                    score.text = spotScore
                    KRProgressHUD.dismiss()

                }
            }
        }
    }
//    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
//        return Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? OverlayView
//    }
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
//        self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
//        self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }

}


