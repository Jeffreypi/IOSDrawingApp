//
//  ImageCell.swift
//  DrawingAppIOSProject
//
//  Created by Jeffrey Pincombe on 2025-04-12.
//

import UIKit

class ImageCell: UITableViewCell {

    @IBOutlet var myImageView : UIImageView!
    @IBOutlet var viewButton : UIButton!
    @IBOutlet var editButton : UIButton!
    @IBOutlet var IDLabel : UILabel!
    @IBOutlet var timeStampLabel : UILabel!
    @IBOutlet var titleLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
