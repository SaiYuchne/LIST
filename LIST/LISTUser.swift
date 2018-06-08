//
//  LISTUser.swift
//  LIST
//
//  Created by 蔡雨倩 on 02/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class LISTUser {
    let userID: String
    let ref = Database.database().reference()
    lazy var profileRef = ref.child("pofile").childByAutoId()
    
    // MARK: Retrieve and update user's info 
    var email: String {
        // todo: email should be fixed once initialized
        get{
            var email: String?
            profileRef.child(userID).child("email").observe(.value, with: { (snapshot) in
                email = snapshot.value as? String
            })
            return email ?? ""
        }
        set{
            profileRef.child("users/\(userID)/email").setValue(newValue)
        }
    }
    var gender: String {
        get{
            var gender: String?
            profileRef.child(userID).child("gender").observe(.value, with: { (snapshot) in
                gender = snapshot.value as? String
            })
            return gender ?? ""
        }
        set{
            profileRef.child("users/\(userID)/gender").setValue(newValue)
        }
    }
    var birthDate: String {
        get{
            var birthDate: String?
            profileRef.child(userID).child("birthDate").observe(.value, with: { (snapshot) in
                birthDate = snapshot.value as? String
            })
            return birthDate ?? ""
        }
        set{
            profileRef.child("users/\(userID)/birthDate").setValue(newValue)
        }
    }
    var userName: String {
        get{
            var userName: String?
            profileRef.child(userID).child("userName").observe(.value, with: { (snapshot) in
                userName = snapshot.value as? String
            })
            return userName ?? ""
        }
        set{
            profileRef.child("users/\(userID)/userName").setValue(newValue)
        }
    }
    var motto: String {
        get{
            var motto: String?
            profileRef.child(userID).child("motto").observe(.value, with: { (snapshot) in
                motto = snapshot.value as? String
            })
            return motto ?? ""
        }
        set{
            profileRef.child("users/\(userID)/motto").setValue(newValue)
        }
    }
    
    init(){
        userID = (Auth.auth().currentUser?.uid)!
    }
}
