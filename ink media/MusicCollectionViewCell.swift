//
//  MusicCollectionViewCell.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/17/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit
import CoreData

class MusicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumThumbnail: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumThumbnail.layer.cornerRadius = CGFloat(2.0)
        albumThumbnail.clipsToBounds = true
        albumName.layer.cornerRadius = CGFloat(2.0)
        albumName.clipsToBounds = true
        
        self.contentView.layer.shadowColor = UIColor.grayColor().CGColor
        self.contentView.layer.shadowOpacity = 0.6
        self.contentView.layer.shadowRadius = 2.0
        self.contentView.layer.shadowOffset = CGSizeMake(0.6, 0.6)
    }
    internal var album: Album? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.albumName.text = self.album?.name
                if let thumbnailData = self.album?.thumbnailData
                {
                    self.albumThumbnail.image = UIImage(data: thumbnailData)
                }
            }
            
        }
    }

}
