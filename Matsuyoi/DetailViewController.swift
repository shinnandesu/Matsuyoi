//
//  DetailViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/07/29.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import UIKit
import ZKCarousel
import MapKit
import SafariServices
import FloatRatingView
import KRProgressHUD
import FloatRatingView
import CoreLocation
import Alamofire
import RealmSwift
import PopupDialog

class DetailViewController: UIViewController,FloatRatingViewDelegate{

    @IBOutlet weak var mapPoint: MKMapView!
    let userDefaults = UserDefaults.standard //UserDefalut

    var SelectedList:[SpotList] = []
    var SelectedUrl:String? = nil
    var SelectedInfo:String? = nil
    var SelectedName:String? = nil
    var SelectedScore:String? = nil
    var SelectedCategory:String? = nil
    var SelectedLat:String? = nil
    var SelectedLng:String? = nil
    var SelectedType:Int? = nil
    var SelectedCount:Int? = nil
    var reversObjs:[SpotList] = []

    var currentLat:Double = 0.0
    var currentLng:Double  = 0.0
    var doubleLat:Double = 0.0
    var doubleLng:Double = 0.0
    
    // Instantiated and used with Storyboards
    @IBOutlet var carousel: ZKCarousel! = ZKCarousel()
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        KRProgressHUD.show()
//        KRProgressHUD.show(withMessage: "Loading...") {
//            print("セル選択")
//        }
        
//        if(SelectedType == 1){
            trashButton.isEnabled = false
            self.trashButton.tintColor = UIColor.clear
//        }
        
               //受け取りデータ
        currentLat = userDefaults.double(forKey: "currentLat")
        currentLng = userDefaults.double(forKey: "currentLng")
        SelectedUrl = SelectedList[0].url
        SelectedInfo = SelectedList[0].info
        SelectedName = SelectedList[0].name
        SelectedScore = SelectedList[0].score
        SelectedCategory = SelectedList[0].category
        SelectedLat = SelectedList[0].lat
        SelectedLng = SelectedList[0].lng
    
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
        
        //スコア
        scoreLabel.text = SelectedScore!
        let floatScore = Float(SelectedScore!)
        self.floatRatingView.rating = floatScore!
        categoryLabel.text = SelectedCategory
        
        //距離の計算
        doubleLat = Double(SelectedLat!)!
        doubleLng = Double(SelectedLng!)!
//        let currentLocation: CLLocation = CLLocation(latitude: currentLat, longitude: currentLng)
//        let goalLocation: CLLocation = CLLocation(latitude: doubleLat, longitude: doubleLng)
//        let distance = goalLocation.distance(from: currentLocation)
//        let kilometer = Int((distance/1000000))
//        distanceLabel.text = String(kilometer) + "km"

        //MapKit設定
        let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(doubleLat), CLLocationDegrees(doubleLng))
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapPoint.setRegion(region, animated:true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(doubleLat), CLLocationDegrees(doubleLng))
        self.mapPoint.addAnnotation(annotation)

        if(SelectedUrl != nil){
            // Setup
            self.checkNetwork()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //ナビゲーションバー透過
        self.navigationController?.isToolbarHidden = true
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

//    @IBAction func tapTrash(_ sender: Any) {
//
//        let realm = try! Realm()
//        let objs = realm.objects(SpotList.self)
//        reversObjs = objs.reversed()    //オブジェクトを降順にする
//        // Prepare the popup
//        let title = "Delete This Data"
//        let message = "お気に入りから削除しますか？"
//
//        // Create the dialog
//        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
//        }
//
//        // Create first button
//        let buttonOne = CancelButton(title: "CANCEL") {
//        }
//
//        // Create second button
//        let buttonTwo = DefaultButton(title: "OK") {
//            self.navigationController?.popViewController(animated: true)
//        }
//        // Add buttons to dialog
//        popup.addButtons([buttonOne, buttonTwo])
//
//        // Present dialog
//        self.present(popup, animated: true, completion: nil)
//    }
    
    @IBAction func openInfo(_ sender: Any) {
        let vc = SFSafariViewController(url: NSURL(string: SelectedInfo!)! as URL)
        present(vc, animated: true, completion: nil)
    }
    @IBAction func tapAction(_ sender: Any) {
        
        // styleをActionSheetに設定
        let alertSheet = UIAlertController(title: "経路", message: "アプリを開きます", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // 自分の選択肢を生成
        let action2 = UIAlertAction(title: "Google Maps", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            print("google")
            UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)
            let urlStr:String = "comgooglemaps://?daddr=\(self.doubleLat),\(self.doubleLng)&directionsmode=walking&zoom=14"
            
            UIApplication.shared.openURL(NSURL(string:urlStr)! as URL)
            
        })
        
        let action3 = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) in
        })
        
        // アクションを追加.
        alertSheet.addAction(action2)
        alertSheet.addAction(action3)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
        //位置情報更新
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        currentLat = (location?.coordinate.latitude)!
        currentLng = (location?.coordinate.longitude)!
        userDefaults.set(currentLat, forKey: "lat")
        userDefaults.set(currentLng, forKey: "lng")
    }

    func checkNetwork(){
        let net = NetworkReachabilityManager()
        net?.startListening()
        if  net?.isReachable ?? false {
            
            if ((net?.isReachableOnEthernetOrWiFi) != nil) {
                //do some
                setupCarousel()
                
            }else if(net?.isReachableOnWWAN)! {
                //do some
                setupCarousel()
            }
        } else {
            //オフライン
            print("no connection")
        }
    }
    func setupCarousel() {
        
        let url: NSURL = NSURL(string:SelectedUrl!)!  //urlの文字列を与えてNSURLのインスタンスを作成
        let imageData = try? Data(contentsOf: url as URL)
        let image = UIImage(data:imageData!)

        // Create as many slides as you'd like to show in the carousel
        let slide = ZKCarouselSlide(image: image!,  title: "", description: SelectedName!)
        let slideArray = [slide]
        // Add the slides to the carousel
        self.carousel.slides = slideArray
//        KRProgressHUD.dismiss()
    }

    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
        //        self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        //        self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }

}


