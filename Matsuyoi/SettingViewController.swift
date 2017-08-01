//
//  SettingViewController.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/07/31.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import UIKit
import Eureka
import CoreLocation


class SettingViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .blue }
        LabelRow.defaultCellUpdate = { cell, row in cell.detailTextLabel?.textColor = .orange  }
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orange }
        DateRow.defaultRowInitializer = { row in row.minimumDate = Date() }
        
        form +++ Section()
            
            <<< LabelRow () {
                $0.title = "LabelRow"
                $0.value = "tap the row"
                }
                .onCellSelection { cell, row in
                    row.title = (row.title ?? "") + " 🇺🇾 "
                    row.reload() // or row.updateCell()
            }
    }
}
