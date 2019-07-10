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
    var items : [Items]? = nil
    let spotify = Spotify.sharedInstance
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        self.searchBar.returnKeyType = .done
        searchBar.showsScopeBar = false
        tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "TrackRowTableViewCell", bundle: nil), forCellReuseIdentifier: "TrackRowCell")
        self.tableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestAuthorizationBearerToken(_:)), name: NSNotification.Name(rawValue: Constants.afterLoginNotificationKey), object: nil)
        _ = spotify.getTokenIfNeeded()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let text = self.searchBar.text{
            spotify.search(searchQuery: text) { response, error in
                if let error = error{
                    
                }else if let response = response{
                    self.items = response.tracks?.items
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc fileprivate func requestAuthorizationBearerToken(_ notification: NSNotification){
        if let url = (notification.userInfo?["url"] as? URL){
            spotify.getCodeFromUrlParams(url: url)
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

        if var items = self.items{
            if let text = self.searchBar.text{
                spotify.search(searchQuery: text) { response, error in
                    if let error = error{
                        
                    }else if let response = response,
                        let newItems = response.tracks?.items {
                        print(newItems.count)
                        items.append(contentsOf: newItems)
                        self.items = items
                        self.tableView.reloadData()
                    }
                }
            }
            return items.count + 1
        }
        return 0
        

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == items?.count{
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingTableViewCell
            return loadingCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackRowCell", for: indexPath) as! TrackRowTableViewCell
        guard let item = items?[indexPath.row] else {
            return cell
        }
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
        spotify.search(searchQuery: searchText) { response, error in
            if let error = error{
                
            }else if let response = response{
                self.items = response.tracks?.items
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
