/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Items : Codable {
	let name : String?
	let type : String?
	let preview_url : String?
	let popularity : Int?
	let explicit : Bool?
	let is_local : Bool?
	let uri : String?
	let album : Album?
	let external_urls : External_urls?
	let duration_ms : Int?
	let external_ids : External_ids?
	let disc_number : Int?
	let artists : [Artists]?
	let id : String?
	let available_markets : [String]?
	let track_number : Int?
	let href : String?

	enum CodingKeys: String, CodingKey {

		case name = "name"
		case type = "type"
		case preview_url = "preview_url"
		case popularity = "popularity"
		case explicit = "explicit"
		case is_local = "is_local"
		case uri = "uri"
		case album = "album"
		case external_urls = "external_urls"
		case duration_ms = "duration_ms"
		case external_ids = "external_ids"
		case disc_number = "disc_number"
		case artists = "artists"
		case id = "id"
		case available_markets = "available_markets"
		case track_number = "track_number"
		case href = "href"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		type = try values.decodeIfPresent(String.self, forKey: .type)
		preview_url = try values.decodeIfPresent(String.self, forKey: .preview_url)
		popularity = try values.decodeIfPresent(Int.self, forKey: .popularity)
		explicit = try values.decodeIfPresent(Bool.self, forKey: .explicit)
		is_local = try values.decodeIfPresent(Bool.self, forKey: .is_local)
		uri = try values.decodeIfPresent(String.self, forKey: .uri)
		album = try values.decodeIfPresent(Album.self, forKey: .album)
		external_urls = try values.decodeIfPresent(External_urls.self, forKey: .external_urls)
		duration_ms = try values.decodeIfPresent(Int.self, forKey: .duration_ms)
		external_ids = try values.decodeIfPresent(External_ids.self, forKey: .external_ids)
		disc_number = try values.decodeIfPresent(Int.self, forKey: .disc_number)
		artists = try values.decodeIfPresent([Artists].self, forKey: .artists)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		available_markets = try values.decodeIfPresent([String].self, forKey: .available_markets)
		track_number = try values.decodeIfPresent(Int.self, forKey: .track_number)
		href = try values.decodeIfPresent(String.self, forKey: .href)
	}

}