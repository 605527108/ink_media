//
//  CartoonCollectionViewCell.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/18/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

class CartoonCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cartoonName: UILabel!
    @IBOutlet weak var cartoonThumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cartoonThumbnailImageView.layer.cornerRadius = CGFloat(2.0)
        cartoonThumbnailImageView.clipsToBounds = true
        cartoonName.layer.cornerRadius = CGFloat(2.0)
        cartoonName.clipsToBounds = true
        
        self.contentView.layer.shadowColor = UIColor.grayColor().CGColor
        self.contentView.layer.shadowOpacity = 0.6
        self.contentView.layer.shadowRadius = 2.0
        self.contentView.layer.shadowOffset = CGSizeMake(0.6, 0.6)
    }
    
    internal var cartoon: Cartoon? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.cartoonName.text = self.cartoon?.name
                if let thumbnailData = self.cartoon?.thumbnailData
                {
                    self.cartoonThumbnailImageView.image = UIImage(data: thumbnailData)
                }
            }
        }
    }
}
