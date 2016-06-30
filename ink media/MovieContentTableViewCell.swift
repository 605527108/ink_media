//
//  MovieContentTableViewCell.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/17/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

class MovieContentTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var movieContentLabel: UILabel!
    internal var movieContent: String? {
        didSet {
            movieContentLabel.text = movieContent
        }
    }

}
