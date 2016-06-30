//
//  MovieDetailTableViewCell.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/17/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

class MovieDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieDirectorLabel: UILabel!
    @IBOutlet weak var movieTypeLabel: UILabel!
    @IBOutlet weak var movieLangLabel: UILabel!
    @IBOutlet weak var movieLengthLabel: UILabel!
    
    internal var movie: Movie? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI()
    {
        movieNameLabel.text = movie!.name
        
        if let thumbnailData = movie?.thumbnailData
        {
            thumbnailImageView.image = UIImage(data: thumbnailData)
        }
        if let movieInfo = movie?.info
        {
            movieDirectorLabel.text = "导演 : " + (movieInfo["导演"] == nil ? " " : movieInfo["导演"]!)
            movieTypeLabel.text = "类型 : " + (movieInfo["类型"] == nil ? " " : movieInfo["类型"]!)
            movieLangLabel.text =  "语言 : " + (movieInfo["语言"] == nil ? " " : movieInfo["语言"]!)
            movieLengthLabel.text = "片长 : " + (movieInfo["片长"] == nil ? " " : movieInfo["片长"]!)
        }
    }
}
