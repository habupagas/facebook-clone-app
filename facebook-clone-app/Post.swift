//
//  Post.swift
//  facebook-clone-app
//
//  Created by Quinto Cossio on 8/6/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _postDescription:String!
    private var _imageUrl:String?
    private var _likes:Int!
    private var _username:String!
    private var _postKey:String!
    private var _postReference:FIRDatabaseReference!
    
    var postDescription:String{
        return _postDescription
    }
    
    var imageUrl:String?{
        return _imageUrl
    }
    
    var likes:Int{
        return _likes
    }
    
    var username:String{
        return _username
    }
    
    var postKey:String{
        return _postKey
    }
    
    
    init(username: String, description:String, imageUrl: String?){
        self._username = username
        self._postDescription = description
        self._imageUrl = imageUrl
    }
    
    //Initializer que se usa para bajar data de Firebase
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int{
            self._likes = likes
        }
        
        if let desc = dictionary["description"] as? String{
            self._postDescription = desc
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String{
            self._imageUrl = imageUrl
        }
        
        //Para guardar el cambio de likes en Firebase. Primero hacemos una referencia al url post
        
        self._postReference = DataService.ds.REF_POSTS.child(self._postKey)
    }
    
    
    func adjustLikes(addLike:Bool){
        
        if addLike{
            _likes = _likes + 1
        }else{
            _likes = _likes - 1
        }
        
        //Se guarda a Firebase. Agarramos la key de los likes. Tomamos los likes q hay ahora y con set value lo reemplazas con la cntidad nueva.
        _postReference.child("likes").setValue(_likes)
    }
    
    
    
    
}