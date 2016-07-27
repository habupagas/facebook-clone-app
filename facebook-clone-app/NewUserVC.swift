//
//  NewUserVC.swift
//  facebook-clone-app
//
//  Created by Quinto Cossio on 25/7/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import Firebase


class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg: CustomImageRoundCorners!
    @IBOutlet weak var usernameTxtFld: CustomTextField!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var descTxtFld: CustomTextField!
    
    var imagepicker: UIImagePickerController!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        imagepicker.allowsEditing = true
    }

    @IBAction func addImagePressed(sender: AnyObject) {
        
        presentViewController(imagepicker, animated: true, completion: nil)
        
    }
    @IBAction func finishButtonPressed(sender: AnyObject) {
        
        //Se sube la imagen, el usuario y descripcion a Firebase. Dsps se hace un segue. Acordarse de handle errors.
        
        //Subimos la imagen a Google Storage diferente a Google Database
        let imageName = NSUUID().UUIDString  //Le da un nombre unico a la imagen
        
        let profileImgRef = STORAGE_REF.child("profileImages/\(imageName).jpg")
        
        //HACER ERRORS HANDLINGS. SI NO HAY IMAGEN/USERNAME/ORIGIN PASA....(Ver otras apps)
        //AGREGAR UN SPINNER MIENTRAS CARGA
        
        if let uploadData = UIImageJPEGRepresentation(profileImg.image!, 0.2){
            
            profileImgRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    
                    print(error)
                    
                }else{
                    
                    //Sube la url de la imagen, el username y el origin a la Database en la root del user
                    
                    
                        var userInfo: Dictionary<String,AnyObject> = [
                        
                            "username" : self.usernameTxtFld.text!,
                            "userOrigin": self.descTxtFld.text!
                    
                        ]
                        
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString where metadata?.downloadURL()?.absoluteString != nil {
                            
                            userInfo["profileImageUrl"] = profileImageUrl
                            print(metadata?.downloadURL())
                        }
                    
                        let userReference = DataService.ds.REF_USERS_CURRENT
                        userReference.setValue(userInfo)
                        
                        self.performSegueWithIdentifier(SEGUE_TO_FEEDVC, sender: nil)
                }
                
            })
        }
        
    }
    
    func showErrorAlert(title: String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        //Para agarrar la imagen de la variable info (que es un dictionary)
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            
            profileImg.image = selectedImage
            addImageBtn.enabled = false
        }
        
        imagepicker.dismissViewControllerAnimated(true, completion: nil)
    }

}
