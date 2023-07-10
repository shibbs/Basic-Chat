//
//  TableViewCell.swift
//
//  Created by Arjun on 6/11/23.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var peripheralLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
