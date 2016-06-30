//
//  TrackCell.swift
//  HalfTunes
//
//  Created by Ken Toh on 13/7/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit

protocol CartoonDownloadTableViewCellDelegate {
    func pauseTapped(cell: CartoonDownloadTableViewCell)
    func resumeTapped(cell: CartoonDownloadTableViewCell)
    func cancelTapped(cell: CartoonDownloadTableViewCell)
    func downloadTapped(cell: CartoonDownloadTableViewCell)
}

class CartoonDownloadTableViewCell: UITableViewCell {
  
    var delegate: CartoonDownloadTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
  
  @IBAction func pauseOrResumeTapped(sender: AnyObject) {
    if(pauseButton.titleLabel!.text == "Pause") {
      delegate?.pauseTapped(self)
    } else {
      delegate?.resumeTapped(self)
    }
  }
  
  @IBAction func cancelTapped(sender: AnyObject) {
    delegate?.cancelTapped(self)
  }
  
  @IBAction func downloadTapped(sender: AnyObject) {
    delegate?.downloadTapped(self)
  }
}
