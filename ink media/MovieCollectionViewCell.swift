//
//  MovieCollectionViewCell.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/16/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var movieThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        movieThumbnail.layer.cornerRadius = CGFloat(2.0)
        movieThumbnail.clipsToBounds = true
        movieName.layer.cornerRadius = CGFloat(2.0)
        movieName.clipsToBounds = true
        
        self.contentView.layer.shadowColor = UIColor.grayColor().CGColor
        self.contentView.layer.shadowOpacity = 0.6
        self.contentView.layer.shadowRadius = 2.0
        self.contentView.layer.shadowOffset = CGSizeMake(0.6, 0.6)
    }
    
    internal var movie: Movie? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.movieName.text = self.movie?.name
                if let thumbnailData = self.movie?.thumbnailData
                {
                    self.movieThumbnail.image = UIImage(data: thumbnailData)
                }
            }
        }
    }
}
