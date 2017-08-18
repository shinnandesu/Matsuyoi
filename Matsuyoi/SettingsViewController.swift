
//
//  SettingViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/08/16.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import UIKit
import Eureka
import MapKit
import KRProgressHUD
import PopupDialog

class SettingsViewController : FormViewController{
    
    let userDefault = UserDefaults.standard
    
    @IBAction func clickSave(_ sender: Any) {
        self.userDefault.set(true, forKey: "count")
        
        let title = "Saved"
        let message = "設定を保存しました"
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: "OK") {
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ナビゲーションバー透過
        self.navigationController!.navigationBar.tintColor = UIColor.blue
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        let categoryArray = ["芸術 & 娯楽","飲食店","ナイトライフ","アウトドア＆レクリエーション","ショッピング"]
        
        form +++ Section("検索設定")
            <<< LocationRow(){
                $0.title = "場所"
                $0.value = CLLocation(latitude: CLLocationDegrees(self.userDefault.float(forKey: "lat")), longitude: CLLocationDegrees(self.userDefault.float(forKey: "lng")))
                }.onChange{ row in
                    let location = row.value
                    let lati = location?.coordinate.latitude
                    let longi = location?.coordinate.longitude
                    self.userDefault.setValue(lati, forKey: "lat")
                    self.userDefault.setValue(longi, forKey: "lng")
            }

            <<< SliderRow() {
                $0.title = "半径"
                $0.value = self.userDefault.float(forKey: "distance")
                $0.maximumValue = 10.0
                $0.minimumValue = 1.0
                $0.steps = 18
                }.onChange{ row in
                    self.userDefault.setValue(row.value, forKey: "distance")
                }
            <<< SegmentedRow<Float>() {
                $0.title = "ランク"
                $0.options = [3.0, 3.5, 4.0,4.5]
                $0.value = self.userDefault.float(forKey: "level")
                }.onChange{ row in
                    self.userDefault.setValue(row.value, forKey: "level")
                }
            <<< PickerInputRow<String>("カテゴリ"){
                $0.title = "カテゴリ"
                $0.options = categoryArray
                $0.value = $0.options.first
                }.onChange{ row in
//                    self.userDefault.setValue(row.value, forKey: "category")
                }
            
    
//        form +++ Section()
//            <<< ButtonRow("プロフィールの変更") { (row: ButtonRow) -> () in
//                row.title = row.tag
//                row.presentationMode = .segueName(segueName: "ProfileSegue", onDismiss: nil)
//            }
            
        +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "利用規約"
                }
                .onCellSelection { [weak self] (cell, row) in
                }
        

        
        
    }
}
