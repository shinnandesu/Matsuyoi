//
//  ContactViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/09/14.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import UIKit
import Eureka


class ContactViewController:FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        form +++ Section("お問い合わせフォーム")
            
        <<< NameRow() {
                $0.title = "メールアドレス:"
                $0.placeholder = ""
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
        <<< TextAreaRow() {
                $0.placeholder = "本文"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
        }
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
