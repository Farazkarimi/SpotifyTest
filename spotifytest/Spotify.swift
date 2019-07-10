//
//  Spotify.swift
//  spotifytest
//
//  Created by Faraz on 7/10/19.
//  Copyright © 2019 Siavash. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

struct Constants {
    static let clientID = "ba05b9cd59634cefa8493ac961d76ed6"
    static let clientSecret = "80b7235a88264654a105a989f6775a59"
    static let redirectURI = "dpg://mydigipay/"
    static let loginURL = "https://accounts.spotify.com/authorize"
    static let afterLoginNotificationKey = "SpotifyLoginNotification"
    static let searchUrl = "https://api.spotify.com/v1/search"
    static let searchLimit = 10
}


class Spotify{
    static let sharedInstance = Spotify()
    
    let limit: Int = 20
    var searchOffset: (query:String,offset:Int)? = nil
    
    func getTokenIfNeeded() -> String?{
        if UserDefaults.standard.value(forKey: "access_token") == nil{
            initiateLogin()
            return nil
        }
        return UserDefaults.standard.value(forKey: "access_token") as? String
    }
    func forceFetchToken(){
        UserDefaults.standard.set(nil, forKey: "access_token")
        _ = self.getTokenIfNeeded()
    }
    
    func initiateLogin(){

        let components = URLComponents.init(string: Constants.loginURL)
        if var components = components{
            var params = [String:String]()
            params["response_type"] = "code"
            params["client_id"] = Constants.clientID
            params["scope"] = "user-read-private user-read-email"
            params["redirect_uri"] = Constants.redirectURI
            var parts = [String]()
            
            for (key,value) in params {
                let parameter = "\(key)=\(value)"
                parts.append(parameter)
            }
            components.query = parts.joined(separator: "&")
            let url = components.url
            if let url = url{
                UIApplication.shared.open(url)
            }
        }
        
    }
    
    func getCodeFromUrlParams(url: URL){
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems = components.queryItems!
        components.query = nil
        let items = queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        let networking = Networking()
        var params = [String:String]()
        params["grant_type"] = "authorization_code"
        params["code"] = items["code"]!
        params["redirect_uri"] = Constants.redirectURI
        params["client_id"] = Constants.clientID
        params["client_secret"] = Constants.clientSecret
        
        networking.request(url: URL(string: "https://accounts.spotify.com/api/token")!, method: "POST", headers: nil, urlParameters: nil, bodyParameters: params) { data, error, authenticationError in
            if authenticationError {
                self.forceFetchToken()
                return
            }
            if let _ = error {
                //handle errors?
                return
            } else if let data = data{
                guard let json = try? JSON(data: data) else {
                    return
                }
                if let accessToken = json["access_token"].string{
                    UserDefaults.standard.set(accessToken, forKey: "access_token")
                }
            }
        }
    }
    
    func trackSearch(searchQuery: String, currentTracks: Tracks?, completion: ((Tracks?, Error?, Bool) -> ())?){
        
        if let tracks = currentTracks,
            tracks.next == nil {
            if let completion = completion{
                DispatchQueue.main.async {
                    completion(nil, nil, false)
                }
            }
            return
        }
        
        if let accessToken = getTokenIfNeeded() {

            var headers = [String:String]()
            headers["Authorization"] = "Bearer \(accessToken)"
            headers["Content-Type"] = "application/json"
            headers["Accept"] = "application/json"
            var searchOffset = 0
            if let offset = currentTracks?.offset {
                searchOffset = offset + limit
            }
            
            var params = [String:String]()
            params["q"] = searchQuery
            params["limit"] = "\(Constants.searchLimit)"
            params["offset"] = "\(searchOffset)"
            params["type"] = "track"
            
            Networking.sharedInstance.request(url: URL(string: Constants.searchUrl)!, method: "GET", headers: headers, urlParameters: params, bodyParameters: nil) { (data, error, authenticationError) in
                
                if authenticationError {
                    self.forceFetchToken()
                    return
                }
                
                if let error = error{
                    if let completion = completion{
                        DispatchQueue.main.async {
                            completion(nil, error, false)
                        }
                    }
                }else if let data = data{
                    let jsonDecoder = JSONDecoder()
                    guard let responseModel = try? jsonDecoder.decode(SpotifySearchResponse.self, from: data)else{
                        if let completion = completion{
                            DispatchQueue.main.async {
                                completion(nil, nil, false)
                            }
                        }
                        return
                    }
                    if let completion = completion{
                        DispatchQueue.main.async {
                            completion(responseModel.tracks, nil, true)
                        }
                    }
                }
            }
        }
        
    }
}
