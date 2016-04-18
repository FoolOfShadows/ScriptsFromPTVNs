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
	@IBOutlet weak var directoryLabel: NSTextField!
	@IBOutlet var resultsView: NSTextView!

	
	//Create an NSFileManager to use with the file enumeration we'll be doing later
	let fileManager = NSFileManager.defaultManager()


	func applicationDidFinishLaunching(aNotification: NSNotification) {
		//Create a path to the users home directory
		let basePath = NSHomeDirectory()
		//Addend the path to the WPCMSharedFiles folder for the office machines to create a default selection.
		//This requires all the computers this code runs on to have a folder named WPCMSharedFiles
		//in their home directory.
		directoryLabel.stringValue = "\(basePath)/WPCMSharedFiles/zDoctor Review/06 Dummy Files"
		//let newOrigin = NSPoint(x: -10.0, y: 100.0)
		//resultsView.setFrameOrigin(newOrigin)
	}

	@IBAction func takeSetDirectory(sender: AnyObject) {
		let panel = NSOpenPanel()
		panel.canChooseDirectories = true
		panel.canChooseFiles = false
		
		panel.beginSheetModalForWindow(self.window!, completionHandler: {(returnCode) -> Void in
			if returnCode == NSModalResponseOK {
				var message = panel.directoryURL!.path!
				self.directoryLabel.stringValue = message
			}
		})
	}
	
	func processTheDirectory() -> [NSURL] {
		var theFileNames = [NSURL]()
		let originFolderURL = NSURL(fileURLWithPath: directoryLabel.stringValue)
		let enumeratorOptions: NSDirectoryEnumerationOptions = [.SkipsHiddenFiles, .SkipsPackageDescendants]
		if let theEnumerator = fileManager.enumeratorAtURL(originFolderURL, includingPropertiesForKeys: nil, options: enumeratorOptions, errorHandler: nil) {
			
			for item in theEnumerator.allObjects {
				if let itemURL = item as? NSURL {
					if itemURL.absoluteString.containsString("PTVN") {
						//if let theFileName = itemURL.URLByDeletingPathExtension {
							theFileNames.append(itemURL)
						//}
					}
				}
			}
		}
		print(theFileNames)
		return theFileNames
	}
	
	func getNameInfo(theText:String) -> String {
		var nameInfo = ""
		
		let separatedText = theText.componentsSeparatedByString("\n")
		print(separatedText)
		nameInfo = separatedText[0].stringByTrimmingLeadingAndTrailingWhitespace()
		
		return nameInfo
	}
	
	func getDOBInfo(theText:String) -> String {
		var dobInfo = ""
		
		let rawDOBInfo = regexTheText(theText, startOfText: "DOB:", endOfText: "Age:")
		let badBits = ["DOB:", "Age:"]
		dobInfo = cleanTheSections(rawDOBInfo, badBits: badBits)
		dobInfo = dobInfo.stringByTrimmingLeadingAndTrailingWhitespace()
		return dobInfo
	}
	
	func getRxInfo(theText:String) -> String {
		var rxInfo = ""
		let rawNeededScripts = regexTheText(theText, startOfText: "\\*\\*Rx\\*\\*", endOfText: "O\\(PE\\):")
		print("the rawNeededScripts is \(rawNeededScripts)")
		let badBits = ["**Rx**", "O(PE):"]
		rxInfo = cleanTheSections(rawNeededScripts, badBits: badBits)
		rxInfo = rxInfo.stringByTrimmingLeadingAndTrailingWhitespace()
		return rxInfo
	}
	
	func getMarkedLines(theText:String) -> String {
		var markedLines = [String]()
		var results = String()
		let theLines = theText.componentsSeparatedByString("\n")
		for line in theLines {
			if line.containsString("^^") {
				let cleanLine = cleanTheSections(line, badBits: ["^^"])
				markedLines.append(cleanLine)
			}
		}
		results = markedLines.joinWithSeparator("\n")
		return results
	}
	
	func processTheFiles(theFiles:[NSURL]?) -> String {
		var neededRxs = [""]
		var results = ""
		if let thePTVNText = theFiles {
			for file in thePTVNText {
					print("Starting the DO clause for \(file) in processTheFiles")
					do {
						let ptvnContents = try String(contentsOfURL: file, encoding: NSUTF8StringEncoding)
						
						let rxResults = getRxInfo(ptvnContents)
						let dobResults = getDOBInfo(ptvnContents)
						let nameResults = getNameInfo(ptvnContents)
						let markedResults = getMarkedLines(ptvnContents)
						if (rxResults != "") && (markedResults != "") {
						neededRxs.append("\(nameResults) (DOB \(dobResults)) - \(rxResults)\n\(markedResults)")
						} else if (rxResults != "") || (markedResults != "") {
							neededRxs.append("\(nameResults) (DOB \(dobResults)) - \(rxResults)\(markedResults)")
						}
					} catch {
						print("Ended up in the CATCH clause")
					}
				}
			if neededRxs != [""] {
				results = neededRxs.joinWithSeparator("\n\n")
			}
		}
		
			print(results)
			return results
		}
	
	@IBAction func takeFind(sender: AnyObject) {
		let theFileURLs = processTheDirectory()
		let theResults = processTheFiles(theFileURLs)
		let theUserFont:NSFont = NSFont.systemFontOfSize(18)
		let fontAttributes = NSDictionary(object: theUserFont, forKey: NSFontAttributeName)
		resultsView.typingAttributes = fontAttributes as! [String : AnyObject]
		resultsView.string = "NEEDED SCRIPTS\n\(theResults)"
		resultsWindow.makeKeyAndOrderFront(self)
	}
	func takePrintAction() {
		let printerInfo = NSPrintInfo()
	}
	
	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
	
func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		return true
	}

}

