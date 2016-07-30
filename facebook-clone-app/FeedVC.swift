//
//  FeedVC.swift
//  facebook-clone-app
//
//  Created by Quinto Cossio on 30/5/16.
//  Copyright © 2016 Quinto Cossio. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //TODO: MUY LENTO SE CARGA EL FEED. BUSCAR LA MANERA DE QUE SOLO SE CARGEN DE A 8
    

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var postTextFld: CustomTextField!
    @IBOutlet weak var imageSelector: UIImageView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    static var imageCache = NSCache()   //Static: Solo hace una instance global de la var
    //static var imageCache: Cache<NSString, UIImage> = Cache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        tableView.estimatedRowHeight = 358  //Para que varie la altura de la cell dependiendo que tiene adentro. Usar tmb func de tableview
        
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            //Esto solo se ejecuta si hay cambios en la data (.Value puede ser otro ->Fijarse Documentation)
            
            self.posts = [] //Vaciamos el array para que no se repita
            
            //Parseamos todos los arrays de "Posts", osea todos los posts
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshots{
                    print("SNAP : \(snap)")
                    //Convertimos todos los children posts a dictionarys (porque son eso)
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                        
                        
                    }
                }
                
            }
            
            self.tableView.reloadData()
        })
    }
    
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]

        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell{
            
            cell.request?.cancel() //Cancela la request para que no se repita la imagen
            
            var img:UIImage?
            
            
            //Si existe un url, agarra la imagen del cache. El cache es como un dictionary (keys y values). La url va a ser la key
            
            
            if let url = post.imageUrl{
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            
            
            cell.configureCell(post, img: img)
            
            return cell
            
            
 
        }else{
            
            return PostCell()
        }
    }
    //Le asigna una altura a cada celda
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil{
            return 150  //Ver si se puede hacer que tenga la height del text view
        }else{
            return tableView.estimatedRowHeight
        }
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        imageSelector.image = image
        imageSelected = true
    }

    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        //IMPORTANT: Nunca se guardan imagenes (tmb archivos) en una Database. Se postean/suben en forma de url a amazon s3 o imageshack o el de google, cuando tiene exito la subida, se agarra el url y lo guardas en la database. Cada vez que se quiere usar la imagen se agarra de internet con la url.
        
        //TODO : Spinner cuando piensa
        
        //With ImageShack
        
        if let txt = postTextFld.text where txt != ""{
            
            
            
            if let img = imageSelector.image where imageSelected == true{
                
                let urlStr = "https://post.imageshack.us/upload_api.php"    //Necesario para hacer la request
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!           //Para comprimir (0= muy comprimida, 1= nada comprimida) la imagen y que pese menos .jpeg. Ademas si o si se tiene que pasar a Data
                let keyData = "640IUWZQ52c00bf13235289602ac17df6cfe810a".dataUsingEncoding(NSUTF8StringEncoding)! //Transformamos el String en NSData
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                //Special Alamofire request (MultiPartFormData) porque tenemos que hacer una request de varias cosas de diferente formatos(Tenemos una image y dos strings). Para hacer esta request tenemos q pasar todo a NSData
                Alamofire.upload(.POST, url, multipartFormData: { MultipartFormData in
                    //Primera clousre: Agregamos los fields que la .POST request necesita
                    
                    MultipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg") //name = key del dictionary que dice en la api
                    MultipartFormData.appendBodyPart(data: keyData, name: "key")
                    MultipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }) { encodingResult in
                    //Segundo clousre: Aca vienen los resultados de la request cuando termina la subida (upload)
                        
                        switch encodingResult{
                            
                        case .Success(let upload, _, _):   //Si la subida es exitosa queremos tener la respuesta del server y guardarla 
                            
                            upload.responseJSON(completionHandler: {response in
                                
                                //Agarramos el link del JSON donde se guarda la imagen que subimos->"image_link"
                                
                                if let info = response.result.value as? Dictionary<String, AnyObject>{
                                    
                                    if let links = info["links"] as? Dictionary<String, AnyObject>{
                                        
                                        if let imgLink = links["image_link"] as? String{
                                            
                                            //Este va a ser el url/link que vamos a guardar en Firebase. Es el link de la imagen
                                            print("LINK: \(imgLink)")
                                            self.postToFireBase(imgLink)
                                        }
                                    }
                                }
                                
                            })
                        case .Failure(let error):
                            print(error)
                        }
                }
            }else{
                
                //Si no hay imagen en el post, solo texto
                self.postToFireBase(nil)
                
            }
        }
    }
    
    
    func postToFireBase(imgUrl: String?){         //imgUrl Opcional porque puede ser q no haya una imagen en el post
        
        //Hacemos un dictionary con el formato de la database de Firebase
        var post: Dictionary<String, AnyObject> = [
            
            "description": postTextFld.text!,
            "likes": 0,
            "user_Id": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID)!
        
        ]
        
        //Como no sabemos si va haber una imagen hacemos:
        if imgUrl != nil{
            //Si hay imagen, la agregamos al dictionary post
            post["imageUrl"] = imgUrl!
        }
        
        //Guardamos en firebase el post en la rama "posts". Haciendo un nuevo post con un id nuevo.
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        //Agarramos de la rama "posts" el postId y lo guardamos en la rama "users" adentro de el currentUser
        firebasePost.observeSingleEventOfType(.Value, withBlock: {snapshot in
            if let postId = snapshot.key as? String{
                DataService.ds.REF_USERS_CURRENT.child("posts").child(postId).setValue(true)
            }
        
        })
        
        
        
        postTextFld.text = ""
        imageSelector.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
        
    }
    
    
}
