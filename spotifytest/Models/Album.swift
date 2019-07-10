/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Album : Codable {
	let total_tracks : Int?
	let artists : [Artists]?
	let available_markets : [String]?
	let release_date_precision : String?
	let images : [Images]?
	let name : String?
	let uri : String?
	let id : String?
	let type : String?
	let album_type : String?
	let href : String?
	let release_date : String?
	let external_urls : External_urls?

	enum CodingKeys: String, CodingKey {

		case total_tracks = "total_tracks"
		case artists = "artists"
		case available_markets = "available_markets"
		case release_date_precision = "release_date_precision"
		case images = "images"
		case name = "name"
		case uri = "uri"
		case id = "id"
		case type = "type"
		case album_type = "album_type"
		case href = "href"
		case release_date = "release_date"
		case external_urls = "external_urls"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		total_tracks = try values.decodeIfPresent(Int.self, forKey: .total_tracks)
		artists = try values.decodeIfPresent([Artists].self, forKey: .artists)
		available_markets = try values.decodeIfPresent([String].self, forKey: .available_markets)
		release_date_precision = try values.decodeIfPresent(String.self, forKey: .release_date_precision)
		images = try values.decodeIfPresent([Images].self, forKey: .images)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		uri = try values.decodeIfPresent(String.self, forKey: .uri)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		type = try values.decodeIfPresent(String.self, forKey: .type)
		album_type = try values.decodeIfPresent(String.self, forKey: .album_type)
		href = try values.decodeIfPresent(String.self, forKey: .href)
		release_date = try values.decodeIfPresent(String.self, forKey: .release_date)
		external_urls = try values.decodeIfPresent(External_urls.self, forKey: .external_urls)
	}

}