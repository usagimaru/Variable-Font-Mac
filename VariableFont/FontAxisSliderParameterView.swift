//
//  FontAxisSliderParameterView.swift
//  VariableFont
//
//  Created by usagimaru on 2019/11/12.
//  Copyright © 2019 usagimaru. All rights reserved.
//

import Cocoa
import NibInstantiater

class FontAxisSliderParameterView: NSView, NibInstantiatable {
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var valueLabel: NSTextField!
	@IBOutlet weak var slider: NSSlider!
	@IBOutlet weak var resetButton: NSButton!
	
	var axisTag: String = ""
	var target: Any?
	var sliderAction: Selector?
	var resetAction: Selector?
	
	var value: Double = 0 {
		didSet {
			self.slider.doubleValue = value
			self.valueLabel.doubleValue = value
		}
	}
    
	@IBAction func sliderAction(_ sender: NSSlider) {
		self.value = sender.doubleValue
		
		if let sliderAction = self.sliderAction {
			NSApp.sendAction(sliderAction, to: self.target, from: self)
		}
	}
	
	@IBAction func reset(_ sender: NSButton) {
		if let resetAction = self.resetAction {
			NSApp.sendAction(resetAction, to: self.target, from: self)
		}
	}
}
