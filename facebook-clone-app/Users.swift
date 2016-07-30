//
//  Users.swift
//  facebook-clone-app
//
//  Created by Quinto Cossio on 28/7/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import Firebase

class Users{
    
    private var _profileImageUrl:String!    //ProfileImage obligatoria, sino q sea un placeholder
    private var _username:String!
    private var _userOrigin:String?
    
    
    var profileImageUrl:String{
        return _profileImageUrl
    }
    
    var username:String{
        return _username
    }
    
    var userOrigin:String?{
        return _userOrigin
    }
    
    init(username:String, profileImageUrl:String, userOrigin: String?){
        
        self._username = username
        self._userOrigin = userOrigin
        self._profileImageUrl = profileImageUrl
        
    }
    
    
    
    
    
    
    
}