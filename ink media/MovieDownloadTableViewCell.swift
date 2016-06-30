//
//  MovieDownloadTableViewCell.swift
//  HalfTunes
//
//  Created by Ken Toh on 13/7/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit

protocol MovieDownloadTableViewCellDelegate {
    func pauseTapped(cell: MovieDownloadTableViewCell)
    func resumeTapped(cell: MovieDownloadTableViewCell)
    func cancelTapped(cell: MovieDownloadTableViewCell)
    func downloadTapped(cell: MovieDownloadTableViewCell)
}

class MovieDownloadTableViewCell: UITableViewCell {
  
    var delegate: MovieDownloadTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!

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
