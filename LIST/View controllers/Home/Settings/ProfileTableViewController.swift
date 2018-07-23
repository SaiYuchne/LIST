//
//  ProfileTableViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 06/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class ProfileTableViewController: UITableViewController, UITextFieldDelegate {

    let ref = Database.database().reference()
    
    lazy var user = LISTUser()
    let picker = UIDatePicker()
    private var alert = UIAlertController(title: "Birth date", message: "Edit your birth date:", preferredStyle: .alert)
    var newDate: String?
    
    private var infoTitle = ["Icon", "Username", "Gender", "Birth date", "Life motto", "Email"]
    var infoContent = [String]()
    var userName = String()
    var gender = String()
    var birthDate  = String()
    var motto = String()
    var email = String()

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let userRef = Database.database().reference().child("Profile").child(user.userID)
//        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let userInfo = snapshot.value as? [String: AnyObject] {
//                self.userName = userInfo["userName"] as! String
//                print(userInfo["userName"] as! String)
//                self.gender = userInfo["gender"] as! String
//                print(userInfo["gender"] as! String)
//                self.birthDate = userInfo["birthDate"] as! String
//                print(userInfo["birthDate"] as! String)
//                self.motto = userInfo["motto"] as! String
//                print(userInfo["motto"] as! String)
//                self.email = userInfo["email"] as! String
//                print(userInfo["email"] as! String)
//            }
//        })
//        
//        tableView.reloadData()
//    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoTitle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileInfoCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = infoTitle[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        if let text = cell.textLabel?.text {
            switch (text) {
            case "Icon":
                break
            case "Username":
                print("check")
                print("username is \(userName)")
                cell.detailTextLabel?.text = userName
            case "Gender":
                print("check")
                print("user gender is \(gender)")
                cell.detailTextLabel?.text = gender
            case "Birth date":
                print("check")
                print("user birth date is \(birthDate)")
                cell.detailTextLabel?.text = birthDate
            case "Life motto":
                print("check")
                print("user motto is \"\(motto)\"")
                cell.detailTextLabel?.text = motto
            case "Email":
                cell.accessoryType = .none
                print("check")
                print("user email is \(email)")
                cell.detailTextLabel?.text = email
            default:
                break
            }
        }
        return cell
    }

    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "backToHomePage", sender: sender)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
        case 0:
            // perform segue to show the user's profile icon
            performSegue(withIdentifier: "goToEditIcon", sender: self)
        // change the username
        case 1:
            let alert = UIAlertController(title: "Change", message: "Change your username:", preferredStyle: .alert)
            var newName: String?
            alert.addTextField { (textField) in
                textField.placeholder = "Type the new name here"
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let edit = UIAlertAction(title: "OK", style: .default) { (_) in
                newName = alert.textFields?[0].text
                if newName != nil {
                    // change the list name in database
                    self.user.userName = newName!
                    self.userName = newName!
                    print(newName!)
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.detailTextLabel?.text = newName!
                    }
                }
            }
            alert.addAction(cancel)
            alert.addAction(edit)
            present(alert, animated: true, completion: nil)
            tableView.reloadData()
        // change the gender
        case 2:
            let alert = UIAlertController(title: "Gender", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Male", style: .default, handler: { (action) in
                //update the priority level in the database
                self.user.gender = "Male"
                self.gender = "Male"
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "Male"
                }
            }))
            alert.addAction(UIAlertAction(title: "Female", style: .default, handler: { (action) in
                //update the priority level in the database
                self.user.gender = "Female"
                self.gender = "Female"
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = "Female"
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            tableView.reloadData()
        // change the birthdate
        case 3:
            if alert.actions.count == 0 {
                alert.addTextField(configurationHandler: { [weak self](textField) in
                    self?.createDatePicker(textField)
                    textField.delegate = self
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let edit = UIAlertAction(title: "OK", style: .default) { (_) in
                    self.alert.textFields?[0].text = self.newDate
                    if let newBirthDate = self.alert.textFields?[0].text {
                        // change the birth date in database
                        self.user.birthDate = newBirthDate
                        print("the new date is \(newBirthDate)")
                        if let cell = tableView.cellForRow(at: indexPath) {
                            cell.detailTextLabel?.text = newBirthDate
                        }
                    }
                }
                alert.addAction(cancel)
                alert.addAction(edit)
            }
            present(alert, animated: true, completion: nil)
            tableView.reloadData()
        // change the life motto
        case 4:
            let alert = UIAlertController(title: "Life motto", message: "Edit your life motto:", preferredStyle: .alert)
            var newMotto: String?
            alert.addTextField { (textField) in
                textField.placeholder = "Type your life motto here"
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let edit = UIAlertAction(title: "OK", style: .default) { (_) in
                newMotto = alert.textFields?[0].text
                if newMotto != nil {
                    // change the list name in database
                    self.user.motto = newMotto!
                    self.motto = newMotto!
                    print(newMotto!)
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.detailTextLabel?.text = "\"\(newMotto!)\""
                    }
                }
            }
            alert.addAction(cancel)
            alert.addAction(edit)
            present(alert, animated: true, completion: nil)
            tableView.reloadData()
        default:
            break
        }
    }

    // MARK: Set the date picker with a tool bar
    func createDatePicker(_ textField: UITextField){
        print("createDatePicker is called")
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        textField.inputAccessoryView = toolbar
        textField.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .date
    }
    
    @objc func donePressed() {
        print("donePressed is called")
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let formatterForDatabase = DateFormatter()
        formatterForDatabase.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: picker.date)
        
        newDate = "\(dateString)"
        print(newDate!)
        alert.textFields?[0].text = newDate!
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditIcon" {
            if let destination = segue.destination as? IconViewController {
                ref.child("Profile").child(user.userID).child("pic").observeSingleEvent(of: .value, with: {(snapshot) in
                    if let profileImageURL = snapshot.value as? String {
                        let url = URL(fileURLWithPath: profileImageURL)
                        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            DispatchQueue.main.async {
                                destination.iconImage.image = UIImage(data: data!)
                            }
                        }).resume()
                    }
                })
            }
        }
    }
}
