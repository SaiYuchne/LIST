//
//  ViewListViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 11/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class ViewListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableViewData = [cellData]()
    
    var byPriority = false
    var byDeadline = false
    var byTag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(byPriority){
            tableViewData = [
                cellData(opened: false, title: "⭐️⭐️⭐️⭐️⭐️", sectionData: ["Cell1", "Cell2", "Cell3"]),
                cellData(opened: false, title: "⭐️⭐️⭐️⭐️", sectionData: ["Cell1", "Cell2", "Cell3"]),
                cellData(opened: false, title: "⭐️⭐️⭐️", sectionData: ["Cell1", "Cell2", "Cell3"]),
                cellData(opened: false, title: "⭐️⭐️", sectionData: ["Cell1", "Cell2", "Cell3"]),
                cellData(opened: false, title: "⭐️", sectionData: ["Cell1", "Cell2", "Cell3"])]
            byPriority = !byPriority
        } else if (byDeadline){
            tableViewData = [
                cellData(opened: false, title: "2018-07-01", sectionData: ["Cell1", "Cell2", "Cell3"]),
                cellData(opened: false, title: "2018-06-29", sectionData: ["Cell1", "Cell2", "Cell3"])]
            byDeadline = !byDeadline
        } else {
            tableViewData = [
                cellData(opened: false, title: "animal", sectionData: ["Cell1", "Cell2", "Cell3"]),
                cellData(opened: false, title: "books", sectionData: ["Cell1", "Cell2", "Cell3"])]
            byTag = !byTag
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true{
            return tableViewData[section].sectionData.count + 1
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "listNameCell") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].title
            return cell
        } else {
            let dataIndex = indexPath.row - 1
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "listNameCell") else {return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if tableViewData[indexPath.section].opened == true {
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
    }
}

struct cellData{
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
}
