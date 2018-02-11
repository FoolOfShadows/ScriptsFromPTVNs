//
//  DataProcessingModel.swift
//  ScriptsFromPTVNs
//
//  Created by Fool on 2/8/18.
//  Copyright © 2018 Fulgent Wake. All rights reserved.
//

import Cocoa

struct dataProcessing {
	
	
	
	
	/*Addend the path to the WPCMSharedFiles folder for the office machines to create a default selection.
	This requires all the computers this code runs on to have a folder named WPCMSharedFiles
	in their home directory.*/
	var originFolderURL: URL
	
	
	mutating func getURLsFromDirectory(_ tag: Int) -> [URL] {
		//Array to hold the matching superset of URLs
		var theFileURLs = [URL]()
		//Create an NSFileManager to use with the file enumeration we'll be doing later
		let fileManager = FileManager.default
		let basePath = NSHomeDirectory()
		
		switch tag {
		case 0:
			originFolderURL = URL(fileURLWithPath: "\(basePath)/WPCMSharedFiles/zDoctor Review/06 Dummy Files")
		default:
			originFolderURL = URL(fileURLWithPath: "\(basePath)/WPCMSharedFiles/zDonna Review/01 PTVN Files")
		//What if the user selects Between and enters the current date as the start date?
		}
		
		let enumeratorOptions: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
		let theEnumerator = fileManager.enumerator(at: originFolderURL, includingPropertiesForKeys: nil, options: enumeratorOptions, errorHandler: nil)
		
		for item in theEnumerator!.allObjects {
			if let itemURL = item as? URL {
				if itemURL.absoluteString.contains("PTVN") {
					theFileURLs.append(itemURL)
				}
			}
		}
		
		return theFileURLs
	}
	
	mutating func takeFind() {
		var theResults = String()
		let formatter = DateFormatter()
		formatter.dateFormat = "yyMMdd"
		let theFileURLs = getURLsFromDirectory()
		switch selectorTag {
		case 0:
			theResults = processTheFiles(theFileURLs)
		case 1:
			let formattedDate = formatter.string(from: onDate.dateValue)
			print(formattedDate)
			theResults = processTheFiles(getDateStringsMatching(formattedDate, from: theFileURLs))
		case 2:
			let formattedDate = formatter.string(from: afterDate.dateValue)
			theResults = processTheFiles(getFilesAfterDate(formattedDate, from: theFileURLs))
		case 3:
			let formattedStartDate = formatter.string(from: betweenStartDate.dateValue)
			let formattedEndDate = formatter.string(from: betweenEndDate.dateValue)
			theResults = processTheFiles(getFilesBetweenDates(formattedStartDate, and: formattedEndDate, from: theFileURLs))
		default:
			return
		}
		
		let theUserFont:NSFont = NSFont.systemFont(ofSize: 18)
		let fontAttributes = NSDictionary(object: theUserFont, forKey: NSFontAttributeName as NSCopying)
		resultsView.typingAttributes = fontAttributes as! [String : AnyObject]
		resultsView.string = "NEEDED SCRIPTS\n\(theResults)"
		resultsWindow.makeKeyAndOrderFront(self)
	}
}
