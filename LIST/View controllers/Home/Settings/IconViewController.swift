//
//  IconViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 18/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import Firebase

class IconViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var iconImage: UIImageView!
    let storageRef = Storage.storage().reference()
    let databaseRef = Database.database().reference()
    var userID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func iconEditTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedimage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedimage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            iconImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        let storedImage = storageRef.child("ProfileImage").child(userID!)
        
        if let uploadData = UIImagePNGRepresentation(iconImage.image!) {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString {
                        self.databaseRef.child("Profile").child(self.userID!).child("pic").setValue(urlText)
                    }
                })
            })
        }
    }
    
}
