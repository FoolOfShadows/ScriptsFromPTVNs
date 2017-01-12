//
//  Functions.swift
//  Chart Parsing
//
//  Created by Fool on 6/17/15.
//  Copyright (c) 2015 Fulgent Wake. All rights reserved.
//

import Cocoa
import Foundation




func getNameInfo(_ theText:String) -> String {
	var nameInfo = ""
	
	let separatedText = theText.components(separatedBy: "\n")
	print(separatedText)
	nameInfo = separatedText[0].removeWhiteSpace()
	
	return nameInfo
}

func getDOBInfo(_ theText:String) -> String {
	var dobInfo = ""
	guard let rawDOBInfo = theText.findRegexMatchBetween("DOB:", and: "Age:") else { return "" }
	dobInfo = rawDOBInfo.removeWhiteSpace()
	return dobInfo
}

func getRxInfo(_ theText:String) -> String {
	var rxInfo = ""
	guard let rawNeededScripts = theText.findRegexMatchBetween("\\*\\*Rx\\*\\*", and: "O\\(PE\\):") else { return "" }
	rxInfo = rawNeededScripts.removeWhiteSpace()
	return rxInfo
}

func getMarkedLines(_ theText:String) -> String {
	var markedLines = [String]()
	var results = String()
	let theLines = theText.components(separatedBy: "\n")
	for line in theLines {
		if line.contains("^^") {
			let cleanLine = cleanTheSections(line, badBits: ["^^"])
			markedLines.append(cleanLine)
		}
	}
	results = markedLines.joined(separator: "\n")
	return results
}

func processTheFiles(_ theFiles:[URL]?) -> String {
	var neededRxs = [""]
	var results = ""
	if let thePTVNText = theFiles {
		for file in thePTVNText {
			//print("Starting the DO clause for \(file) in processTheFiles")
			do {
				let ptvnContents = try String(contentsOf: file, encoding: .utf8)
				let rxResults = getRxInfo(ptvnContents)
				let dobResults = getDOBInfo(ptvnContents)
				let nameResults = getNameInfo(ptvnContents)
				let markedResults = getMarkedLines(ptvnContents)
				if (rxResults != "") && (markedResults != "") {
					neededRxs.append("\(nameResults) (DOB \(dobResults)) \n \(addCharactersToFront(rxResults, theCharacters: "- "))\n\(addCharactersToFront(markedResults, theCharacters: "- "))")
				} else if (rxResults != "") || (markedResults != "") {
					neededRxs.append("\(nameResults) (DOB \(dobResults)) \n \(addCharactersToFront(rxResults, theCharacters: "- "))\(addCharactersToFront(markedResults, theCharacters: "- "))")
				}
			} catch {
				print("Ended up in the CATCH clause")
			}
		}
		if neededRxs != [""] {
			results = neededRxs.joined(separator: "\n\n")
		}
	}
	
	print(results)
	return results
}

func getDateStringsMatching(_ theDate:String, from files:[URL]) -> [URL] {
	let results = files.filter({$0.absoluteString.contains(theDate)})
	return results
}

func getFilesAfterDate(_ theDate: String, from files:[URL]) -> [URL] {
	var results = [URL]()
	
	//convert the date string into an integer
	guard let checkDateAsInteger = Int(theDate) else { return results }

	//get the date element from each URL, convert it to an integer
	//and check it against the requested date
	for file in files {
		let fileWithoutPercentEncoding = file.deletingPathExtension().absoluteString.removingPercentEncoding
		guard let nameComponents = fileWithoutPercentEncoding?.components(separatedBy: " ") else { continue }
		//print(nameComponents)
		if let dateBit = Int(nameComponents.last!) {
			print("Check date \(dateBit)")
			if dateBit >= checkDateAsInteger {
			results.append(file)
			}
		}
	}
	
	return results
}

func getFilesBetweenDates(_ start:String, and end:String, from files:[URL]) -> [URL] {
	var results = [URL]()
	
	//Convert the date strings to integers
	guard let startDateAsInteger = Int(start) else { return results }
	guard let endDateAsInteger = Int(end) else { return results }
	
	for file in files {
		let fileWithoutPercentEncoding = file.deletingPathExtension().absoluteString.removingPercentEncoding
		guard let nameComponents = fileWithoutPercentEncoding?.components(separatedBy: " ") else { continue }
		//print(nameComponents)
		if let dateBit = Int(nameComponents.last!) {
			print("Check date \(dateBit)")
			if dateBit >= startDateAsInteger && dateBit <= endDateAsInteger {
				results.append(file)
			}
		}
	}
	
	return results
}

//Clean extraneous text from the sections
func cleanTheSections(_ theSection:String, badBits:[String]) -> String {
	var cleanedText = theSection.removeWhiteSpace()
	for theBit in badBits {
		cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "")
	}
	cleanedText = cleanedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	return cleanedText
}


//Adjust visit date values based on how far the visit is scheduled into the future
func addingDays (_ theDate: Date, daysToAdd: Int) -> Date {
	let components:DateComponents = DateComponents()
	(components as NSDateComponents).setValue(daysToAdd, forComponent: .day)
	let newDate = Calendar.current.date(byAdding: components, to: theDate)
	return newDate!
}

//Add specific characters to the beginning of each line
func addCharactersToFront(_ theText:String, theCharacters:String) ->String {
	var returnText = ""
	var newTextArray = [String]()
	let textArray = theText.components(separatedBy: "\n")
	let cleanedTextArray = textArray.filter({!$0.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty })
	for line in cleanedTextArray {
		let newLine = theCharacters + line
		newTextArray.append(newLine)
	}
	
	returnText = newTextArray.joined(separator: "\n")
	
	return returnText
}

//Parse a string containing a full name into it's components and returns
//the version of the name we use to label files
func getFileLabellingName(_ name: String) -> String {
	var fileLabellingName = String()
	var ptFirstName = ""
	var ptLastName = ""
	var ptMiddleName = ""
	var ptExtraName = ""
	let extraNameBits = ["Sr", "Jr", "II", "III", "IV", "MD"]
	
	func checkForMatchInSets(_ arrayToCheckIn: [String], arrayToCheckFor: [String]) -> Bool {
		var result = false
		for item in arrayToCheckIn {
			if arrayToCheckFor.contains(item) {
				result = true
				break
			}
		}
		return result
	}
	
	let nameComponents = name.components(separatedBy: " ")
	
	let extraBitsCheck = checkForMatchInSets(nameComponents, arrayToCheckFor: extraNameBits)
	
	if extraBitsCheck == true {
		ptLastName = nameComponents[nameComponents.count-2]
		ptExtraName = nameComponents[nameComponents.count-1]
	} else {
		ptLastName = nameComponents[nameComponents.count-1]
		ptExtraName = ""
	}
	
	if nameComponents.count > 2 {
	if nameComponents[nameComponents.count - 2] == "Van" {
		ptLastName = "Van " + ptLastName
	}
	}
	
	//Get first name
	ptFirstName = nameComponents[0]
	
	//Get middle name
	if (nameComponents.count == 3 && extraBitsCheck == true) || nameComponents.count < 3 {
		ptMiddleName = ""
	} else {
		ptMiddleName = nameComponents[1]
	}
	
	fileLabellingName = "\(ptLastName)\(ptFirstName)\(ptMiddleName)\(ptExtraName)"
	fileLabellingName = fileLabellingName.replacingOccurrences(of: " ", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: "-", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: "'", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: "(", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: ")", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: "\"", with: "")
	
	
return fileLabellingName
}
	
