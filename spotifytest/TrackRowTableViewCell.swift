//
//  TrackRowTableViewCell.swift
//  spotifytest
//
//  Created by Faraz on 7/10/19.
//  Copyright © 2019 Siavash. All rights reserved.
//

import UIKit

class TrackRowTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    override func prepareForReuse() {
        //self.trackImage.image = UIImage(named: "headphone")
    }
}
