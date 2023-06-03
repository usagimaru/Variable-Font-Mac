//
//  FontAxisOnOffParameterView.swift
//  VariableFont
//
//  Created by usagimaru on 2019/11/12.
//  Copyright © 2019 usagimaru. All rights reserved.
//

import Cocoa
import NibInstantiater

class FontAxisOnOffParameterView: NSView, NibInstantiatable {
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var checkBox: NSButton!
	@IBOutlet weak var resetButton: NSButton!
	
	var axisTag: String = ""
	var target: Any?
	var checkAction: Selector?
	var resetAction: Selector?
	
	var value: Bool = false {
		didSet {
			self.checkBox.state = value ? .on : .off
		}
	}
	
	@IBAction func check(_ sender: NSButton) {
		if let checkAction = self.checkAction {
			NSApp.sendAction(checkAction, to: self.target, from: self)
		}
	}
	
	@IBAction func reset(_ sender: NSButton) {
		if let resetAction = self.resetAction {
			NSApp.sendAction(resetAction, to: self.target, from: self)
		}
	}
	
}
