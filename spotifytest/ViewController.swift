//
//  ViewController.swift
//  spotifytest
//
//  Created by Faraz on 7/9/19.
//  Copyright © 2019 Faraz. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    var tracks: Tracks? = nil
    var items = [Items]()
    let spotify = Spotify.sharedInstance
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 10000
        self.configTableView()
        self.configSearchBar()
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestAuthorizationBearerToken(_:)), name: NSNotification.Name(rawValue: Constants.afterLoginNotificationKey), object: nil)
        _ = spotify.getTokenIfNeeded()
        
    }
    
    fileprivate func configSearchBar(){
        self.searchBar.returnKeyType = .done
        self.searchBar.showsScopeBar = false
        self.searchBar.delegate = self
    }
    
    fileprivate func configTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "TrackRowTableViewCell", bundle: nil), forCellReuseIdentifier: "TrackRowCell")
        self.tableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
    }
    
    @objc fileprivate func requestAuthorizationBearerToken(_ notification: NSNotification){
        if let url = (notification.userInfo?["url"] as? URL){
            spotify.getCodeFromUrlParams(url: url)
        }
        
    }
    
    fileprivate func performTrackSearch() {
        if let searchText = searchBar.text, searchText != "" {
            spotify.trackSearch(searchQuery: searchText, currentTracks: self.tracks) { [weak self](newTracks, error, searchWasSuccessful) in
                if (searchWasSuccessful) {
                    if let newTracks = newTracks {
                        if let newItems = newTracks.items {
                            self?.items.append(contentsOf: newItems)
                        }
                        self?.tracks = newTracks
                        self?.tableView.reloadData()
                    }
                }
            }
        } else {
            self.tracks = nil
            self.items = [Items]()
            self.tableView.reloadData()
        }
    }
    
    
    
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83
    }
    
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tracks = self.tracks {
            let hasMore = tracks.next != nil
            return self.items.count + (hasMore ? 1 : 0)
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.items.count{
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingTableViewCell
            performTrackSearch()
            loadingCell.indicator.startAnimating()
            return loadingCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackRowCell", for: indexPath) as! TrackRowTableViewCell
        let item = items[indexPath.row]
        guard let artists = item.artists else {
            return cell
        }
        guard let albumName = item.album?.name else {
            return cell
        }
        
        guard let imageUrl = item.album?.images?.first?.url else{
            return cell
        }
        
        guard let title = item.name else {
            return cell
        }
        
        let artistsName = artists.map({$0.name!})
        cell.artistLabel.text = artistsName.joined(separator: " - ")
        cell.albumLabel.text = albumName
        cell.titleLabel.text = title
        cell.trackImage.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "headphone"))
        
        return cell
        
    }
    
    
}

extension ViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tracks = nil
        self.items = [Items]()
        performTrackSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}
