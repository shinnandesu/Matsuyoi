//
//  BackgroundKolodaAnimator.swift
//  Matsuyoi
//
//  Created by shinkatayama on 2017/07/29.
//  Copyright © 2017年 shinkatayama. All rights reserved.
//

import Foundation
import Koloda
import pop

class BackgroundKolodaAnimator: KolodaViewAnimator {
    
    override func applyScaleAnimation(_ card: DraggableCardView, scale: CGSize, frame: CGRect, duration: TimeInterval, completion: AnimationCompletionBlock) {
        
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation?.springBounciness = 9
        scaleAnimation?.springSpeed = 16
        scaleAnimation?.toValue = NSValue(cgSize: scale)
        card.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
        
        let frameAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        frameAnimation?.springBounciness = 9
        frameAnimation?.springSpeed = 16
        frameAnimation?.toValue = NSValue(cgRect: frame)
        if let completion = completion {
            frameAnimation?.completionBlock = { _, finished in
                completion(finished)
            }
        }
        card.pop_add(frameAnimation, forKey: "frameAnimation")
    }
    
}

