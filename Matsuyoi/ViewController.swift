//
//  ViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/07/29.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import UIKit
import Koloda
import Alamofire
import SwiftyJSON
import FloatRatingView
import RealmSwift
import SDWebImage

//カードのvar定
private let numberOfCards: Int = 50
private let frameAnimationSpringBounciness: CGFloat = 12
private let frameAnimationSpringSpeed: CGFloat = 20
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1


class SpotList: Object {
    dynamic var name:String!
    dynamic var url:String?
    dynamic var info:String!
    dynamic var score:String!
}
var selectedList:[SpotList] = []


class ViewController: UIViewController,FloatRatingViewDelegate {
    
    var spotLists:[SpotList] = []
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var kolodaLabel: UILabel!    
    @IBOutlet weak var score: UILabel!
    let userDefaults = UserDefaults.standard

    private var urlString:String = "https://google.com"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
        // Optional params
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIViewContentMode.scaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 1
        self.floatRatingView.editable = true
        self.floatRatingView.floatRatings = true
        self.floatRatingView.halfRatings = true

        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        //写真を50枚取得する
        getImages()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextSegue" {
            var detailViewController = segue.destination as! DetailViewController
            detailViewController.SelectedList = selectedList
            dump(selectedList)
        }
    }
    
  
    @IBAction func goodButton(_ sender: Any) {
        kolodaView?.swipe(.right)
    }
    @IBAction func badTapped(_ sender: Any) {
        kolodaView?.swipe(.left)
    }
    @IBAction func returnTapped(_ sender: Any) {
        kolodaView?.revertAction()
    }
    
    //APIから写真と地名を取ってくる
    func getImages(){
        Alamofire.request("http://life-cloud.ht.sfc.keio.ac.jp/~shinsan/SpoTrip/json.php", method:.post)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                for (_, subJson):(String, JSON) in json {
                    let spotList:SpotList = SpotList()
                    spotList.name = subJson["name"].string
                    spotList.url = subJson["url"].string
                    spotList.info = subJson["info"].string
                    self.spotLists.append(spotList)
                }
            self.kolodaView.reloadData()
        }
    }
    
    //    //結果をサーバに送る
    //    func sendArray(venueName:String,bool:Int) {
    //
    //        let Token = userDefaults.value(forKey: "Token") as! String
    //
    //        let parameters = [
    //            "name": venueName,
    //            "bool": bool,
    //            "token": Token,
    //        ] as [String : Any]
    //
    //        Alamofire.request(NSURL(string:"http://life-cloud.ht.sfc.keio.ac.jp/~shinsan/PicTrip/getResult.php")! as URL, method:.post, parameters: parameters)
    //
    //
    //    }
    

}



//MARK: KolodaViewDelegate
extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        self.spotLists = []
        getImages()
        kolodaView.resetCurrentCardIndex()
    }
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
         performSegue(withIdentifier: "nextSegue", sender: nil)
    }
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }

    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        switch direction {
        case .left :
            if self.spotLists.count != 0{
            }
        case .right :
            if self.spotLists.count != 0{
                var goodList = [self.spotLists[Int(index)]]
                let realm = try! Realm()
                try! realm.write() {
                    realm.add(goodList)
                }
                if let names  = self.spotLists[Int(index)].name{
                    let boolean = 1
                    //                        sendArray(venueName: names,bool:boolean)
                }
            }
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
        return numberOfCards
    }
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        var imageView = UIImageView()
        if self.spotLists.count != 0 {
            if let image = self.spotLists[Int(index)].url{
                imageView = UIImageView(frame: self.view.frame)
                imageView.sd_setImage(with: NSURL(string: image) as URL!)
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                self.view.addSubview(imageView)
            }
        }
        return imageView
    }
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        //        let label = labels[Int(index)]
        if self.spotLists.count != 0 {
            if let spotName  = self.spotLists[Int(index)].name{
                kolodaLabel.text = spotName
                selectedList = [self.spotLists[Int(index)]]
                self.floatRatingView.rating = 1.7
                score.text = "1.7"
            }
        }
    }
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
//        self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
//        self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }

}



