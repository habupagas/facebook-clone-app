//
//  PostCell.swift
//  facebook-clone-app
//
//  Created by Quinto Cossio on 31/5/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg:UIImageView!
    @IBOutlet weak var postImg:UIImageView!
    @IBOutlet weak var descriptionText:UITextView!
    @IBOutlet weak var likesLbl:UILabel!
    @IBOutlet weak var likeImage:UIImageView!
    @IBOutlet weak var usernameLbl:UILabel!
    
    var post: Post!
    var user: Users!
    var request:Request?
    var likeReference: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Vamos a hacer que una imagen sea apretable en una tableView. En tableviews no se puede usar el tap del storyboard. Si o si hacerlo por codigo
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
        
    }
    
    override func drawRect(rect: CGRect) {
        //Esto pasa despues de que la imagen tiene frame y size
        
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
    }

    
    func configureCell(post:Post, img:UIImage?){
        
        self.postImg.image = nil
        self.post = post
        
        
        //Esto es como decir: url_base/users/likes/(key del post)
        likeReference = DataService.ds.REF_USERS_CURRENT.child("likes").child(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        //Download Profile Images and usernames
        
        /*
        
        let profileImgRef = FIRStorage.storage().referenceForURL(user.profileImageUrl!)
            
        profileImgRef.dataWithMaxSize(1 * 1024 * 1024 , completion: { (data, error) in
                
            if error != nil{
                print(error)
                print("Unable to download image from Firebase")

            }else{
                print("Image was download from Firebase")
                    
                if let imgData = data{
                    if let img = UIImage(data: imgData){
                        self.profileImg.image = img
                            
                        //FeedVC.imageCache.setObject(img, forKey: post.profileImageUrl)
                    }
                }
            }
        })
            
       */
        
        
        
        
        
        
        /*
        //Download Post Images con Firebase
        
        if img != nil{
            
            postImg.image = img
        }else{
            //Use the cached image if there is one, otherwise download the image
            
            let ref = FIRStorage.storage().referenceForURL(post.imageUrl!)
            ref.dataWithMaxSize(2 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil{
                    print("Unable to download image from Firebase")
                    
                }else{
                    
                    print("Image was download from Firebase")
                    
                    if let imgData = data{
                        if let img = UIImage(data: imgData){
                            self.postImg.image = img
                            
                            //Agrego las imagenes descargadas al cache
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl!)
                        }
                    }
                }
            })
            
        }
        */
        
        
        
        //Download Post Images con AlamoFire
        
        
         if post.imageUrl != nil{
            
            //Si hay un imageUrl
            //Use the cached image if there is one, otherwise download the image

             if img != nil{
                postImg.image = img!
             }else{
                //Se hace la request a internet con Alamofire
                
                 request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                     if err == nil {
                         let img = UIImage(data: data!)!  //Hacer un if let
                         self.postImg.image = img
                         //La agrego al cache
                         FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                    
                })

            }
        }
 
       
        parseLikes()
        setUserProfile()
        
        
        
    }
    
    //Setea la foto de perfil y el nombre de usuario
    func setUserProfile(){
        
        DataService.ds.REF_USERS.child(self.post.user_Id).observeEventType(.Value, withBlock: { (snapshot) in
            
            if let user = snapshot.value as? Dictionary<String, AnyObject>{
                
                    
                self.user = Users(username: (user["username"] as? String)!, profileImageUrl: (user["profileImageUrl"] as? String)!, userOrigin: nil)
                
                
                self.usernameLbl.text = self.user.username
                
                let imgUrl = self.user.profileImageUrl
                
                if imgUrl == ""{
                    self.profileImg.image = UIImage(named:"placeholder")
                }else{
                        
                    //Download Profile Image    TODO: Un cache de las profile Img
                        
                    let profileImgRef = FIRStorage.storage().referenceForURL(self.user.profileImageUrl)
                    profileImgRef.dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
                            
                        if error != nil{
                            print(error)
                        }else{
                                
                            if let imgData = data{
                                if let img = UIImage(data: imgData){
                                        
                                    self.profileImg.image = img
                                }
                            }
                                
                        }
                    })
                    
                }
                
            }
            
            
        })
        
    }
    
    
    
    
    
    
    //Hay q chequear si el usuario ya likeo el post o no. Para eso chequeamos si el usuario en la database tiene la key del post (Cada post tiene una key)
    func parseLikes(){
        
        //Esto se fija si existe el like, en cierto post
        //Solo se va ejecutar una vez. Diferente al que esta en FeedVC que se ejecuta cuando hay cambios en la data.
        
        likeReference.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // snapshot.value agarra la data. Entonces, en firebase si no hay data en .value (osea no existe)es un NSNull (NO nil).
            if let doesNotExist = snapshot.value as? NSNull{
                
                //Si no existe el like, tenemos que mostrar el corazon vacio.
                self.likeImage.image = UIImage(named: "heart-empty")
                
            }else{
                self.likeImage.image = UIImage(named: "heart-full")
            }
            
        })
        
        
    }
    
    
    
    func likeTapped(sender:UITapGestureRecognizer){
        
        likeReference.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull{
                
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)         //Agregamos un like
                self.likeReference.setValue(true)   //Si no existe el like, con setValue(true), crea el like para ese post en la database.
                
            }else{
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)       //Sacamos un like
                self.likeReference.removeValue()   //Borro el like de la database

            }
            
        })
        
    }

}
