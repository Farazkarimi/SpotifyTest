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

class Constants {
    static let clientID = "ba05b9cd59634cefa8493ac961d76ed6"
    static let clientSecret = "80b7235a88264654a105a989f6775a59"
    static let redirectURI = "dpg://mydigipay/"
    static let loginURL = "https://accounts.spotify.com/authorize"
    static let afterLoginNotificationKey = "SpotifyLoginNotification"
    static let searchUrl = "https://api.spotify.com/v1/search"
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
        self.getTokenIfNeeded()
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
        
        networking.request(url: URL(string: "https://accounts.spotify.com/api/token")!, method: "POST", headers: nil, urlParameters: nil, bodyParameters: params) { data, error in
            if let error = error{
                
            }else if let data = data{
                guard let json = try? JSON(data: data) else {
                    return
                }
                if let accessToken = json["access_token"].string{
                    UserDefaults.standard.set(accessToken, forKey: "access_token")
                }
                print(json)
            }
        }
    }
    
    func search(searchQuery: String, completion: ((_ response: SpotifySearchResponse?, _ error: Error?) -> ())?){
        if let accessToken = getTokenIfNeeded() {

            var headers = [String:String]()
            headers["Authorization"] = "Bearer \(accessToken)"
            headers["Content-Type"] = "application/json"
            headers["Accept"] = "application/json"
            
            if let searchOffset = searchOffset {
                if searchOffset.query == searchQuery {
                    self.searchOffset?.offset = searchOffset.offset + limit
                } else {
                    self.searchOffset?.offset = 0
                }
            } else {
                self.searchOffset = (query: searchQuery, offset: 0)
            }
            
            var params = [String:String]()
            params["q"] = searchQuery
            params["limit"] = String(self.limit)
            params["offset"] = String(searchOffset?.offset ?? 0)
            params["type"] = "track"
            
            Networking.sharedInstance.request(url: URL(string: Constants.searchUrl)!, method: "GET", headers: headers, urlParameters: params, bodyParameters: nil) { (data, error) in
                
                if let error = error{
                    if let completion = completion{
                        completion(nil,error)
                    }
                }else if let data = data{
                    let jsonDecoder = JSONDecoder()
                    guard let responseModel = try? jsonDecoder.decode(SpotifySearchResponse.self, from: data)else{
                        return
                    }
                    if let completion = completion{
                        DispatchQueue.main.async {
                            completion(responseModel,nil)
                        }
                    }
                    print(responseModel)
                }
            }
        }
        
    }
}
