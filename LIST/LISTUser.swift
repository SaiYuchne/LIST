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
    var userID: String {
        return Auth.auth().currentUser!.uid
    }
    let ref = Database.database().reference()
    lazy var profileRef = ref.child("Profile")
    
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
            profileRef.child(userID).child("email").setValue(newValue)
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
            profileRef.child(userID).child("gender").setValue(newValue)
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
            profileRef.child(userID).child("birthDate").setValue(newValue)
        }
    }
    var createDate: Int {
        get{
            var createDate: Int?
            profileRef.child(userID).child("createDate").observe(.value, with: { (snapshot) in
                createDate = snapshot.value as? Int
            })
            return createDate ?? 0
        }
        set{
            profileRef.child(userID).child("createDate").setValue(newValue)
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
            profileRef.child(userID).child("userName").setValue(newValue)
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
            profileRef.child(userID).child("motto").setValue(newValue)
        }
    }
    var pic: String {
        get{
            var pic: String?
            profileRef.child(userID).child("pic").observe(.value, with: { (snapshot) in
                pic = snapshot.value as? String
            })
            return pic ?? ""
        }
        set{
            profileRef.child(userID).child("pic").setValue(newValue)
        }
    }
}
