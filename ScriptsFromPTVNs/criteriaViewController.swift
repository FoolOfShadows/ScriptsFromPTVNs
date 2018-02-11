//
//  criteriaViewController.swift
//  ScriptsFromPTVNs
//
//  Created by Fool on 2/8/18.
//  Copyright © 2018 Fulgent Wake. All rights reserved.
//

import Cocoa

class criteriaViewController: NSViewController {

	@IBOutlet weak var window: NSWindow!
	
	@IBOutlet weak var timeSelectorMatrix: NSMatrix!
	@IBOutlet weak var currentDate: NSTextField!
	@IBOutlet weak var onDate: NSDatePicker!
	@IBOutlet weak var afterDate: NSDatePicker!
	@IBOutlet weak var betweenStartDate: NSDatePicker!
	@IBOutlet weak var betweenEndDate: NSDatePicker!
	
	
	//Create an NSFileManager to use with the file enumeration we'll be doing later
	let fileManager = FileManager.default
	
	var basePath = NSHomeDirectory()
	var selectorTag = Int()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//basePath = NSHomeDirectory()
		let today = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "M/d/yy"
		currentDate.stringValue = formatter.string(from: today)
		onDate.dateValue = Date()
		afterDate.dateValue = Date()
		betweenStartDate.dateValue = Date()
		betweenEndDate.dateValue = Date()
    }
    
}
