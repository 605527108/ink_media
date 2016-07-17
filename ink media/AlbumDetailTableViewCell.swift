//
//  AlbumDetailTableViewCell.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/15/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

class AlbumDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var albumThumbnail: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artist: UILabel!
    
    var album: Album? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI()
    {
        if album != nil
        {
            albumName.text = album!.name!
            artist.text = album!.artist!
            if let thumbnailData = album?.thumbnailData
            {
                albumThumbnail.image = UIImage(data: thumbnailData)
            }
        }
        
    }
}
