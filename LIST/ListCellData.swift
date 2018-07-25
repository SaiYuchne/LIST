//
//  ListCellData.swift
//  LIST
//
//  Created by 蔡雨倩 on 24/07/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import Foundation

class ListCellData {
    var opened = Bool()
    
    var itemID = String()
    var title = String()
    var isGoalFinished = Bool()
    
    var subgoalID = [String]()
    var sectionData = [String]()
    var isSubgoalFinished = [Bool]()
    
    init(opened: Bool, itemID: String, title: String, isGoalFinished: Bool, subgoalID: [String], sectionData: [String], isSubgoalFinished: [Bool]) {
        self.opened = opened
        self.itemID = itemID
        self.title = title
        self.isGoalFinished = isGoalFinished
        self.subgoalID = subgoalID
        self.sectionData = sectionData
        self.isSubgoalFinished = isSubgoalFinished
    }
}
