//
//  LocationSettingViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/08/16.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

//import UIKit
//
//class LocationSettingViewController: UIViewController {
//
//        let userDefault = UserDefaults.standard
//        
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            
//            form +++ Section("プロフィール")
//                <<< NameRow() {
//                    $0.title =  "Name"
//                    $0.value = self.userDefault.string(forKey: "name")
//                    
//                    }.onChange{ row in
//                        self.userDefault.setValue(row.value, forKey: "name")
//                }
//                <<< NameRow() {
//                    $0.title =  "UserID"
//                    $0.value = self.userDefault.string(forKey: "userid")
//                    
//                    }.onChange{ row in
//                        self.userDefault.setValue(row.value, forKey: "userid")
//            }
//            
//        }
//}
