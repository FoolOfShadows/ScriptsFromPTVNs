//
//  DataProcessingModel.swift
//  ScriptsFromPTVNs
//
//  Created by Fool on 2/8/18.
//  Copyright © 2018 Fulgent Wake. All rights reserved.
//

import Cocoa

enum TimeMatched:String {
	case on
	case before
	case after
	case between
}

func getFileNamesFrom(_ files: [URL], forDate date:(start:Date, end:Date?), status:TimeMatched) -> [String] {
	//Convert URL array to String array using compactMap (which replaces flatMap) to filter out nil values
	let filesAsStrings = files.compactMap {$0.urlIntoCleanString()}
	let formatter = DateFormatter()
	formatter.dateFormat = "yyMMdd"
	var results = [String]()
	
	switch status {
	case .on: results = filesAsStrings.filter{$0.contains(formatter.string(from: date.start))}
	case .before: results = [""]
	case .after:
		for item in files {
			guard let itemDate = item.splitFileNameIntoComponents()?.last,
				  let dateInt = Int(itemDate),
				  let startInt = Int(formatter.string(from: date.start)) else { continue }
			if dateInt >= startInt {
				results.append(item.absoluteString)
			}
		}
	case .between:
		for item in files {
			guard let itemDate = item.splitFileNameIntoComponents()?.last,
				let dateInt = Int(itemDate),
				let startInt = Int(formatter.string(from: date.start)),
				let endInt = Int(formatter.string(from: date.end!)) else { continue }
			if dateInt >= startInt && dateInt <= endInt {
				results.append(item.urlIntoCleanString()!)
			}
		}
	}
	
	return results
}



struct dataProcessing {

	
//	mutating func takeFind() {
//		var theResults = String()
//		let formatter = DateFormatter()
//		formatter.dateFormat = "yyMMdd"
//		let theFileURLs = getURLsFromDirectory()
//		switch selectorTag {
//		case 0:
//			theResults = processTheFiles(theFileURLs)
//		case 1:
//			let formattedDate = formatter.string(from: onDate.dateValue)
//			print(formattedDate)
//			theResults = processTheFiles(getDateStringsMatching(formattedDate, from: theFileURLs))
//		case 2:
//			let formattedDate = formatter.string(from: afterDate.dateValue)
//			theResults = processTheFiles(getFilesAfterDate(formattedDate, from: theFileURLs))
//		case 3:
//			let formattedStartDate = formatter.string(from: betweenStartDate.dateValue)
//			let formattedEndDate = formatter.string(from: betweenEndDate.dateValue)
//			theResults = processTheFiles(getFilesBetweenDates(formattedStartDate, and: formattedEndDate, from: theFileURLs))
//		default:
//			return
//		}
//
//		let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
//		let fontAttributes = NSDictionary(object: theUserFont, forKey: NSFontAttributeName as NSCopying)
//		resultsView.typingAttributes = fontAttributes as! [String : AnyObject]
//		resultsView.string = "NEEDED SCRIPTS\n\(theResults)"
//		resultsWindow.makeKeyAndOrderFront(self)
//	}
}
