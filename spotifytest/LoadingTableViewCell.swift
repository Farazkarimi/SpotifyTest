//
//  LoadingTableViewCell.swift
//  spotifytest
//
//  Created by Faraz on 7/10/19.
//  Copyright © 2019 Siavash. All rights reserved.
//

import UIKit

protocol NetworkErrorAware {
    func configure(mode: WaitingMode)
    func getMode() -> WaitingMode
}
enum WaitingMode {
    case retry
    case wait
}
class LoadingTableViewCell: UITableViewCell, NetworkErrorAware {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var retryButton: UIButton!
    
    var mode: WaitingMode = .wait
    var searcher: SearcherDelegate?
    func configure(mode: WaitingMode) {
        self.mode = mode
        switch mode {
        case .retry:
            indicator.stopAnimating()
            indicator.isHidden = true
            retryButton.isHidden = false
        case .wait:
            indicator.startAnimating()
            indicator.isHidden = false
            retryButton.isHidden = true
        }
    }
    
    func getMode() -> WaitingMode {
        return mode
    }
    
    @IBAction func retry(_ sender: Any) {
        configure(mode: .wait)
        searcher?.performSearch()
    }
}
