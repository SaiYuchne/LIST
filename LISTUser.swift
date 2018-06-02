//
//  LISTUser.swift
//  LIST
//
//  Created by 蔡雨倩 on 02/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class LISTUser {
    let userID: String
    let ref = Database.database().reference()
    lazy var profileRef = ref.child("pofile")
    
    // MARK: Retrieve and update user's info 
    var email: String {
        get{
            var email: String?
            profileRef.child(userID).child("email").observeSingleEvent(of: .value) { (snapshot) in
                email = snapshot.value as? String
            }
            return email ?? ""
        }
        set{
            profileRef.child(userID).child("email").setValue(newValue)
        }
    }
    var gender: String {
        get{
            var gender: String?
            profileRef.child(userID).child("gender").observeSingleEvent(of: .value) { (snapshot) in
                gender = snapshot.value as? String
            }
            return gender ?? ""
        }
        set{
            profileRef.child(userID).child("gender").setValue(newValue)
        }
    }
    var birthDate: String {
        get{
            var birthDate: String?
            profileRef.child(userID).child("birthDate").observeSingleEvent(of: .value) { (snapshot) in
                birthDate = snapshot.value as? String
            }
            return birthDate ?? ""
        }
        set{
            profileRef.child(userID).child("birthDate").setValue(newValue)
        }
    }
    var userName: String {
        get{
            var userName: String?
            profileRef.child(userID).child("userName").observeSingleEvent(of: .value) { (snapshot) in
                userName = snapshot.value as? String
            }
            return userName ?? ""
        }
        set{
            profileRef.child(userID).child("userName").setValue(newValue)
        }
    }
    var motto: String {
        get{
            var motto: String?
            profileRef.child(userID).child("motto").observeSingleEvent(of: .value) { (snapshot) in
                motto = snapshot.value as? String
            }
            return motto ?? ""
        }
        set{
            profileRef.child(userID).child("motto").setValue(newValue)
        }
    }
    
    init(){
        userID = (Auth.auth().currentUser?.uid)!
    }
}
