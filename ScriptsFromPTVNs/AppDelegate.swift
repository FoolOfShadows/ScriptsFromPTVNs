//
//  AppDelegate.swift
//  ScriptsFromPTVNs
//
//  Created by Fool on 2/12/16.
//  Copyright © 2016 Fulgent Wake. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var resultsWindow: NSWindow!
	@IBOutlet var resultsView: NSTextView!
	@IBOutlet weak var timeSelectorMatrix: NSMatrix!
	@IBOutlet weak var currentDate: NSTextField!
	@IBOutlet weak var onDate: NSDatePicker!
	@IBOutlet weak var afterDate: NSDatePicker!
	@IBOutlet weak var betweenStartDate: NSDatePicker!
	@IBOutlet weak var betweenEndDate: NSDatePicker!

	
	//Create an NSFileManager to use with the file enumeration we'll be doing later
	let fileManager = FileManager.default

	var basePath = String()
	var selectorTag = Int()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		//Set a path to the users home directory
		basePath = NSHomeDirectory()
		let today = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "M/d/yy"
		currentDate.stringValue = formatter.string(from: today)
		onDate.dateValue = Date()
		afterDate.dateValue = Date()
		betweenStartDate.dateValue = Date()
		betweenEndDate.dateValue = Date()
	}
/*This section was deprecated as there are only two paths these files are stored in
	and the needed path can be determined by the new radio buttons for choosing date*/
//	@IBAction func takeSetDirectory(_ sender: AnyObject) {
//		let panel = NSOpenPanel()
//		panel.canChooseDirectories = true
//		panel.canChooseFiles = false
//		
//		panel.beginSheetModal(for: self.window!, completionHandler: {(returnCode) -> Void in
//			if returnCode == NSModalResponseOK {
//				let message = panel.directoryURL!.path
//				self.directoryLabel.stringValue = message
//			}
//		})
//	}
	
	func processTheDirectory() -> [URL] {
		if let theSelectorTab = timeSelectorMatrix.selectedCell()?.tag {
			selectorTag = theSelectorTab
			print("Current button selected is \(selectorTag)")
		}
		print("Current button selected is \(selectorTag)")
		var theFileNames = [URL]()
		/*Addend the path to the WPCMSharedFiles folder for the office machines to create a default selection.
		This requires all the computers this code runs on to have a folder named WPCMSharedFiles
		in their home directory.*/
		var originFolderURL: URL
		switch selectorTag {
		case 0:
			originFolderURL = URL(fileURLWithPath: "\(basePath)/WPCMSharedFiles/zDoctor Review/06 Dummy Files")
		default:
			originFolderURL = URL(fileURLWithPath: "\(basePath)/WPCMSharedFiles/zDonna Review/01 PTVN Files")
		}
	
		print("\(originFolderURL)")
		let enumeratorOptions: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
		let theEnumerator = fileManager.enumerator(at: originFolderURL, includingPropertiesForKeys: nil, options: enumeratorOptions, errorHandler: nil)
		for item in theEnumerator!.allObjects {
			if let itemURL = item as? URL {
				if itemURL.absoluteString.contains("PTVN") {
					theFileNames.append(itemURL)
				}
			}
		}
		//print(theFileNames)
		return theFileNames
	}
	
	@IBAction func takeFind(_ sender: AnyObject) {
		var theResults = String()
		let formatter = DateFormatter()
		formatter.dateFormat = "yyMMdd"
		let theFileURLs = processTheDirectory()
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
	

	
	
	func takePrintAction() {
		//let printerInfo = NSPrintInfo()
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

}

