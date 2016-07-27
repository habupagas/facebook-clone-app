//
//  ViewController.swift
//  facebook-clone-app
//
//  Created by Quinto Cossio on 23/5/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextFld: CustomTextField!
    @IBOutlet weak var passwordTextFld: CustomTextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    
    @IBAction func attemptLoginBtnPressed(sender: AnyObject) {
        
        if let email = emailTextFld.text where email != "", let password = passwordTextFld.text where password != ""{
            
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { user, error in
                
                //INTENTO DE LOGIN
                
                if error != nil {
                    //Agregar errores tipo: Si la account ya se creo o si se escribio mal las pass o mail o la account no existe o error en internet
                    
                    print("Account created \(error)")
                    
                    if error!.code == STATUS_ACCOUNT_NONEXIST{
                        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { user, error in
                            
                            //CREACION NUEVO USER (SIGNUP)
                            
                            if error != nil{
                                //Handle errors tipo: Password demasiado corta, el mail esta mal, etc. Conviene cheuar mas errores
                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Please try a different way")
                                print(error)
                                
                            }else{
                                print("Successfuly create account")
                                //Guardo el uid en la app
                                NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                                
                                //Creo el usuario en la database de Firebase con un UID como user y provider. Ver como sigue DataService
                                let userData = ["provider" : "email"]
                                DataService.ds.createFirebaseUser(user!.uid, user: userData)
                                
                                self.performSegueWithIdentifier(SEGUE_NEW_USER_CREATED, sender: nil)
                                
                            }
                            
                        })
                    }
                    else{
                        self.showErrorAlert("Could not login", msg: "Please check you email or password")
                    }
                    
                }else{
                    print("logged in")
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    
                }
                
            })
            
        }else{
            
            self.showErrorAlert("Email and Password required", msg: "You must enter an email and apassword")
        }
    
    }
    
    @IBAction func fbButtonPressed(sender:UIButton){
        let facebooklogin = FBSDKLoginManager()
        
        facebooklogin.logInWithReadPermissions(["email"]) { (facebookResult, facebookError) -> Void in
            
            if facebookError != nil{
                
                print("Facebook login failed. Error \(facebookError)")
                
            }else{
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully login with FB. \(accessToken)")
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    
                    if error != nil{
                        print("Login Failed. \(error)")
                    }else{
                        
                        print("Logged In. \(user)")
                        
                        //Creo un usuario de Firebase.  Se deberia hacer con un If let user = ...
                        let userData = ["provider" : credential.provider]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData)
                        
                        NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_NEW_USER_CREATED, sender: nil)
                    }
                    
                })
                
            }
        }
    }
    
    
    
    
    
    func showErrorAlert(title: String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    /*  Para agregar esto poner FBSDKLoginButtonDelegate y loginButton.delegate = self
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
            loginButton.readPermissions = ["email", "public_profile", "user_friends"]
        
        
            if error != nil{
                
                print("Facebook Login Failed \(error)")
                
            }else{
                
                print("Successful Login")
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    
                    if error != nil {
                        print("LogIn Failed \(error)")
                    }else{
                        
                        print("You are Logged In \(user)")
                    }
                }
            }
    }
    
    
  
    

   */
        
        
    
    
        
        
    

     

}

