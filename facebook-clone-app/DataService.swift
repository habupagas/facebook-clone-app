//
//  DataService.swift
//  facebook-clone-app
//
//  Created by Quinto Cossio on 26/5/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()
let STORAGE_REF = FIRStorage.storage().reference()


class DataService{
    
    static let ds = DataService()
    
    //DB References
    private var _REF_BASE = URL_BASE
    private var _REF_POSTS = URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("users")
    
    //Storage references
    private var _REF_POST_IMAGES = STORAGE_REF.child("post-pics")
    //private var _REF_PROFILE_IMAGES = STORAGE_REF.child("")
    
    
    var REF_BASE:FIRDatabaseReference{
        return _REF_BASE
    }
    
    var REF_POSTS:FIRDatabaseReference{
        return _REF_POSTS
    }
    
    var REF_USERS:FIRDatabaseReference{
        return _REF_USERS
    }
    
    var REF_POST_IMAGES: FIRStorageReference{
        return _REF_POST_IMAGES
    }
    
    //Agarramos el usuario que esta actualmente usando la app
    var REF_USERS_CURRENT:FIRDatabaseReference{
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = REF_USERS.child(uid)
        
        return user
    }
    
    //Para tomar el AuthId y guardarlo en el JSON child "users"
    func createFirebaseUser(uid: String, user: Dictionary<String, String>){
        REF_USERS.child(uid).setValue(user)
    }
}