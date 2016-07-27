//
//  CustomImageRoundCorners.swift
//  facebook-clone-app
//
//  Created by Quinto Cossio on 25/7/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import UIKit


class CustomImageRoundCorners: UIImageView {
    
    override func awakeFromNib() {
        
        layer.cornerRadius = frame.size.width / 2
        clipsToBounds = true
        
        //TODO : Put shadows to the picture and a placeholder
        
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = frame.size.width / 2
        

        
    }
}