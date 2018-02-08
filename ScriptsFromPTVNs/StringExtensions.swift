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
		let startMatch = startRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
		let endMatch = endRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
		
		let startRange = startMatch[0].range
		let endRange = endMatch[0].range
		
		let r = self.index(self.startIndex, offsetBy: startRange.location) ..< self.index(self.startIndex, offsetBy: endRange.location + endRange.length)
		
		return self.substring(with: r)
	}
	
	
	func findRegexMatchBetween(_ start: String, and end: String) -> String? {
		guard let startRegex = try? NSRegularExpression(pattern: start, options: []) else { return nil }
		Swift.print(startRegex)
		guard let endRegex = try? NSRegularExpression(pattern: end, options: []) else {return nil }
		Swift.print(endRegex)
		
		let startMatch = startRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
		Swift.print(startMatch)
		let endMatch = endRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
		Swift.print(endMatch)
		
		if !startMatch.isEmpty && !endMatch.isEmpty {
			
			let startRange = startMatch[0].range
			Swift.print(startRange)
			let endRange = endMatch[0].range
			Swift.print(endRange)
			
			if startRange.location > endRange.location {
				return "There is a formatting error in this patients PTVN."
			} else {
				let r = self.index(self.startIndex, offsetBy: startRange.location + startRange.length) ..< self.index(self.startIndex, offsetBy: endRange.location)
				
				return self.substring(with: r)
			}
		} else {
			return "There was no match for either '\(start)' or '\(end)' in the text."
		}
		
	}
	
	
	func removeWhiteSpace() -> String {
		return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
	}
}
