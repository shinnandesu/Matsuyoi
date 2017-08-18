//
//  CustomOverlayView.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/08/01.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "check"
private let overlayLeftImageName = "batu"

class CustomOverlayView: OverlayView {
    
    @IBOutlet lazy var overlayImageView: UIImageView? = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView?.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView?.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView?.image = nil
            }
            
        }
    }
    
}

