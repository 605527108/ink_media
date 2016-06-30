//
//  CartoonDetailTableViewCell.swift
//  Movie
//
//  Created by Syn Ceokhou on 6/19/16.
//  Copyright © 2016 Syn Ceokhou. All rights reserved.
//

import UIKit

class CartoonDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var subGroupLabel: UILabel!
    @IBOutlet weak var nowAirLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nowEpisodeLabel: UILabel!
    @IBOutlet weak var downloadTimesLabel: UILabel!
    
    internal var cartoon: Cartoon? {
        didSet {
            updateUI()
        }
    }

    func updateUI()
    {
        nameLabel.text = cartoon?.name
        if let thumbnailData = cartoon?.thumbnailData
        {
            thumbnailImageView.image = UIImage(data: thumbnailData)
        }

        if let cartoonInfo = cartoon?.info
        {
            subGroupLabel.text = "字幕组 : " + (cartoonInfo["字幕组"] == nil ? " " : cartoonInfo["字幕组"]!)
            nowAirLabel.text = "当前状态 : " + (cartoonInfo["当前状态"] == nil ? " " : cartoonInfo["当前状态"]!)
            nowEpisodeLabel.text =  "当前集数 : " + (cartoonInfo["当前集数"] == nil ? " " : cartoonInfo["当前集数"]!)
            downloadTimesLabel.text =  "下载量 : " + (cartoonInfo["下载量"] == nil ? " " : cartoonInfo["下载量"]!)
        }
    }
}
