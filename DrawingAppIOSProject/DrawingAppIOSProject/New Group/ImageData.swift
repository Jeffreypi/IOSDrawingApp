//
//  ImageData.swift
//  DrawingAppIOSProject
//
//  Created by Jeffrey Pincombe on 2025-04-12.
//

import UIKit

class ImageData: NSObject {
    var ID : Int?
    var DrawingData : Data?
    var Timestamp : String?
    var Title : String?
    
    func initWithData(theRow i: Int, theDrawing d: Data, theTimestamp t: String, theTitle ti:String) {
           ID = i
           DrawingData = d
           Timestamp = t
        Title = ti
       }
}
