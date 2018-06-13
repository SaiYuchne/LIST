//
//  ISPoint.swift
//  LIST
//
//  Created by 蔡雨倩 on 13/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit

class ISPoint {
    
    var title:String
    var description:String?
    var pointColor:UIColor
    var lineColor:UIColor
    var touchUpInside:Optional<(_ point:ISPoint) -> Void>
    var fill:Bool
    
    init(title:String, description:String, pointColor:UIColor, lineColor:UIColor, touchUpInside:Optional<(_ point:ISPoint) -> Void>, fill:Bool) {
        self.title = title
        self.description = description
        self.pointColor = pointColor
        self.lineColor = lineColor
        self.touchUpInside = touchUpInside
        self.fill = fill
    }
    
    convenience init(title:String, description:String, touchUpInside:Optional<(_ point:ISPoint) -> Void>) {
        let defaultColor = UIColor.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        self.init(title: title, description: description, pointColor: defaultColor, lineColor: defaultColor, touchUpInside: touchUpInside, fill: false)
    }
    
    convenience init(title:String, touchUpInside:Optional<(_ point:ISPoint) -> Void>) {
        self.init(title: title, description: "", touchUpInside: touchUpInside)
    }
    
    convenience init(title:String) {
        self.init(title: title, touchUpInside: nil)
    }
}
