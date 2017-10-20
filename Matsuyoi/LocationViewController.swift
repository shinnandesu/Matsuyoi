//
//  LocationViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/08/09.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//
import CoreLocation
import UIKit
import KRProgressHUD

class LocationViewController: UIViewController {
    
    var locationManager: CLLocationManager!
    let userDefaults = UserDefaults.standard
    var latitude:Double = 35.7095839115165
    var longitude:Double = 139.79667333797
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userDefaults.set(latitude, forKey: "lat")
        userDefaults.set(longitude, forKey: "lng")
        userDefaults.set(3.0, forKey: "distance")
        userDefaults.set(3.5, forKey: "level")
        userDefaults.setValue("徒歩圏内", forKey: "distanceLabel")
        userDefaults.setValue("飲食店", forKey: "category")

        locationManager = CLLocationManager() // インスタンスの生成
        locationManager.delegate = self as! CLLocationManagerDelegate // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
    }
}

extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            locationManager.requestWhenInUseAuthorization() // 起動中のみの取得許可を求める
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            performSegue(withIdentifier: "toTab", sender: nil)
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            performSegue(withIdentifier: "toTab", sender: nil)
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        let currentlatitude = (location?.coordinate.latitude)!
        let currentlongitude = (location?.coordinate.longitude)!
        userDefaults.set(currentlatitude, forKey: "currentlat")
        userDefaults.set(currentlongitude, forKey: "currentlng")


        performSegue(withIdentifier: "toTab", sender: nil)
    }
}
