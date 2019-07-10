//
//  Networking.swift
//  spotifytest
//
//  Created by Faraz on 7/9/19.
//  Copyright © 2019 Faraz. All rights reserved.
//

import Foundation

struct UrlParameters {
    
    let baseUrl: URL?
    let allParameters: [String:String]?
    
    init(url: URL, parameters: [String:String]?) {
        var parametersInUrl = url.queryParameters
        if (parametersInUrl != nil) {
            if let parameters = parameters {
                for (key, value) in parameters {
                    parametersInUrl![key] = value
                }
            }
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.query = nil
            baseUrl = components.url
        } else {
            if let parameters = parameters {
                parametersInUrl = parameters
            }
            baseUrl = url
        }
        allParameters = parametersInUrl
    }
    
    func urlWithParameters() -> URL? {
        var query : String? = nil
        if let allParameters = allParameters {
            var parts = [String]()
            for (key, value) in allParameters {
                let parametersString = "\(key)=\(value)"
                parts.append(parametersString)
            }
            query = parts.joined(separator: "&")
        }
        if let url = baseUrl {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.query = query
            return components?.url
        }
        
        return nil
    }
}

class Networking {
    
    static let sharedInstance = Networking()
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func request(url: URL, method: String, headers: [String:String]?, urlParameters: [String:String]?, bodyParameters: [String:String]?, completion: ((Data?, Error?) -> ())?){
        dataTask?.cancel()
        var internalHeaders = [String:String]()
        internalHeaders["Content-Type"] = "application/x-www-form-urlencoded"
        if let headers = headers{
            internalHeaders = internalHeaders.merging(headers) { (_, new) in new }
        }
        let urlParameters = UrlParameters(url: url, parameters: urlParameters)
        if let urlWithParameters = urlParameters.urlWithParameters() {
            print(urlWithParameters)
            var request = URLRequest(url: urlWithParameters)
            request.httpMethod = method
            request.allHTTPHeaderFields = internalHeaders
            
            if let bodyParameters = bodyParameters,
                method.lowercased() == "post" {
                var data: Data? = nil
                if (internalHeaders["Content-Type"] == "application/x-www-form-urlencoded") {
                    var parts = [String]()
                    for (key, value) in bodyParameters {
                        let parameter = "\(key)=\(value)"
                        parts.append(parameter)
                    }
                    data = parts.joined(separator: "&").data(using: String.Encoding.utf8)
                } else if internalHeaders["Content-Type"] == "application/json" {
                    data = try? JSONSerialization.data(withJSONObject: bodyParameters)
                }
                request.httpBody = data
            }
            dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    
                }else if let response = response as? HTTPURLResponse{
                    if let data = data, response.statusCode == 200 {
                        
                    }else if response.statusCode == 401{
                        Spotify.sharedInstance.forceFetchToken()
                    }
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                }
                if let completion = completion{
                    completion(data,error)
                }
            })
            dataTask?.resume()
        }
    }
    
}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}