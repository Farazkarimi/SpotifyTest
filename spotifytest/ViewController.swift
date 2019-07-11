//
//  ViewController.swift
//  spotifytest
//
//  Created by Faraz on 7/9/19.
//  Copyright © 2019 Faraz. All rights reserved.
//

import UIKit
import Kingfisher
import Reachability

protocol SearcherDelegate {
    func performSearch()
}
class ViewController: UIViewController, SearcherDelegate {
    var tracks: Tracks? = nil
    var items = [Items]()
    let spotify = Spotify.sharedInstance
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var networkErrorAware: NetworkErrorAware? = nil
    var currenWaintingtMode: WaitingMode = .wait
    var searchWasFailed = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 10000
        self.configTableView()
        self.configSearchBar()
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestAuthorizationBearerToken(_:)), name: NSNotification.Name(rawValue: Constants.afterLoginNotificationKey), object: nil)
        _ = spotify.getTokenIfNeeded()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let reachability = Reachability()!
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
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
    
    func performSearch() {
        if currenWaintingtMode == .retry {
            return
        }
        self.networkErrorAware?.configure(mode: .wait)
        if let searchText = searchBar.text, searchText != "" {
            spotify.trackSearch(searchQuery: searchText, currentTracks: self.tracks) { [weak self](newTracks, error, searchWasSuccessful) in
                self?.searchWasFailed = false
                if let _ = error {
                    self?.networkErrorAware?.configure(mode: .retry)
                    self?.searchWasFailed = true
                    return
                }
                if (searchWasSuccessful) {
                    self?.networkErrorAware?.configure(mode: .wait)
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
            self.searchWasFailed = false
            self.tracks = nil
            self.items = [Items]()
            self.networkErrorAware = nil
            self.tableView.reloadData()
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        reachability.whenReachable = { [weak self] _ in
            self?.currenWaintingtMode = .wait
            self?.networkErrorAware?.configure(mode: .wait)
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.currenWaintingtMode = .retry
            self?.tableView.reloadData()
            if self?.searchWasFailed ?? false {
                self?.performSearch()
            }
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
        return (currenWaintingtMode == .retry ? 1 : 0)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.items.count{
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingTableViewCell
            performSearch()
            loadingCell.configure(mode: currenWaintingtMode)
            loadingCell.searcher = self
            self.networkErrorAware = loadingCell
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
        
        guard let images = item.album?.images else{
            return cell
        }
    
        guard let title = item.name else {
            return cell
        }
        
        let artistsName = artists.map({$0.name!})
        cell.artistLabel.text = artistsName.joined(separator: " - ")
        cell.albumLabel.text = albumName
        cell.titleLabel.text = title
        chooseAndSetImage(images: images, imageView: cell.trackImage)
        return cell
        
    }
        
        func chooseAndSetImage(images: [Images], imageView: UIImageView) {

            let imageUrl: String?
            if images.count > 2 {
                imageUrl = images[1].url
            } else {
                imageUrl = images.last?.url
            }
            if let imageUrl = imageUrl {
                let processor = DownsamplingImageProcessor(size: imageView.frame.size)
                let options: [KingfisherOptionsInfoItem] = [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.3))
                ]
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(
                    with: URL(string: imageUrl),
                    placeholder: UIImage(named: "headphone"),
                    options: options)
                
            } else {
                imageView.image = UIImage(named: "headphone")
            }
        }
    
    
}

extension ViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tracks = nil
        self.items = [Items]()
        self.networkErrorAware = nil
        self.tableView.reloadData()
        performSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}
