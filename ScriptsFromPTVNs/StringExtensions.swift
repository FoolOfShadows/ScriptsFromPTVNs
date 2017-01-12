//
//  StringExtensions.swift
//  PTVN to PF 2
//
//  Created by Fool on 1/10/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Foundation

extension String {
	func findRegexMatchFrom(_ start: String, to end:String) -> String? {
		guard let startRegex = try? NSRegularExpression(pattern: start, options: []) else { return nil }
		guard let endRegex = try? NSRegularExpression(pattern: end, options: []) else {return nil }
		let startMatch = startRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
		let endMatch = endRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
		
		let startRange = startMatch[0].range
		let endRange = endMatch[0].range
		
		let r = self.index(self.startIndex, offsetBy: startRange.location) ..< self.index(self.startIndex, offsetBy: endRange.location + endRange.length)
		
		return self.substring(with: r)
	}
	
	
	func findRegexMatchBetween(_ start: String, and end: String) -> String? {
		guard let startRegex = try? NSRegularExpression(pattern: start, options: []) else { return nil }
		guard let endRegex = try? NSRegularExpression(pattern: end, options: []) else {return nil }
		let startMatch = startRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
		let endMatch = endRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
		
		let startRange = startMatch[0].range
		let endRange = endMatch[0].range
		
		let r = self.index(self.startIndex, offsetBy: startRange.location + startRange.length) ..< self.index(self.startIndex, offsetBy: endRange.location)
		
		return self.substring(with: r)
		
	}
	
	
	func removeWhiteSpace() -> String {
		return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
	}
}
