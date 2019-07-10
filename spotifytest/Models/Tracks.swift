/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Tracks : Codable {
	let items : [Items]?
	let offset : Int?
	let href : String?
	let limit : Int?
	let total : Int?
	let next : String?
	let previous : String?

	enum CodingKeys: String, CodingKey {

		case items = "items"
		case offset = "offset"
		case href = "href"
		case limit = "limit"
		case total = "total"
		case next = "next"
		case previous = "previous"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		items = try values.decodeIfPresent([Items].self, forKey: .items)
		offset = try values.decodeIfPresent(Int.self, forKey: .offset)
		href = try values.decodeIfPresent(String.self, forKey: .href)
		limit = try values.decodeIfPresent(Int.self, forKey: .limit)
		total = try values.decodeIfPresent(Int.self, forKey: .total)
		next = try values.decodeIfPresent(String.self, forKey: .next)
		previous = try values.decodeIfPresent(String.self, forKey: .previous)
	}

}