//
//  ViewController.swift
//  VariableFont
//
//  Created by usagimaru on 2019/11/12.
//  Copyright © 2019 usagimaru. All rights reserved.
//

import Cocoa
import CoreText

class ViewController: NSViewController {
	
	@IBOutlet var textView: NSTextView!
	@IBOutlet var optionPanel: NSStackView!
	
	struct VariationAxisTags {
		static let weight = "Weight"
		static let width = "Width"
		static let slant = "Slant"
		static let opticalSize = "Optical Size"
		static let italic = "Italic"
		
		static let grade = "GRAD"
		static let monospace = "Monospace"
		static let casual = "Casual"
	}
	
	class FontAxis: Any {
		var fontFamilyName: String?
		var fontName: String!
		
		var identifier: Int = 0
		var name: String = ""
		var defaultValue: CGFloat = 0
		var minimumValue: CGFloat = 0
		var maximumValue: CGFloat = 0
		var isHidden: Bool = false
		
		var customValue: CGFloat = 0.0 {
			didSet {
				customValue = min(max(customValue, minimumValue), maximumValue)
			}
		}
	}
	
	private var font: NSFont? {
		didSet {
			self.textView.font = font
		}
	}
	
	private var fontSize: CGFloat = NSFont.systemFontSize
	private var fontAxes = [String : FontAxis]()
	
	
	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		initFont()
		self.fontAxes = getFontVariationAxes() ?? [:]
		
		self.textView.string = "Variable fonts works on macOS native apps."
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		setFontAxes()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		self.view.window?.title = self.font!.displayName ?? self.font!.familyName ?? self.font!.fontName
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
	}
	
	override func viewDidDisappear() {
		super.viewDidDisappear()
	}
	
	
	// MARK: -
	
	private func initFont() {
		//let fontName = ".SFNSDisplay"
		//let fontName = ".SFNSRounded-Regular"
		//let fontName = "Montserrat"
		//let fontName = "Recursive Beta 1.022"
		//let fontName = "ヒラギノ角ゴシック"
		//self.font = NSFont(name: fontName, size: self.fontSize)
		self.font = NSFont.systemFont(ofSize: self.fontSize)
		
		self.fontAxes.removeAll()
	}
	
	private func getFontVariationAxes() -> [String : FontAxis]? {
		guard let font = self.font else {
			return nil
		}
		
		self.optionPanel.arrangedSubviews.forEach {
			self.optionPanel.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}
		
		// フォントサイズ
		makeAxisSliderView("Size", title: "Size", min: 1.0, max: 200.0, currentValue: self.fontSize)
		
		// 指定フォントから有効な Axis を判定して、パラメータ調整スライダを作成
		if let axes = CTFontCopyVariationAxes(font as CTFont) as? [[String : Any]] {
			var fontAxes = [String : FontAxis]()
			
			for axis in axes {
				guard let axisIdentifier = axis[kCTFontVariationAxisIdentifierKey as String] as? Int else {
					continue
				}
				
				let axisName = axis[kCTFontVariationAxisNameKey as String] as? String ?? ""
				let axisDefaultValue = axis[kCTFontVariationAxisDefaultValueKey as String] as? CGFloat ?? 0.0
				let axisMinimumValue = axis[kCTFontVariationAxisMinimumValueKey as String] as? CGFloat ?? 0.0
				let axisMaximumValue = axis[kCTFontVariationAxisMaximumValueKey as String] as? CGFloat ?? 0.0
				let axisHidden = axis[kCTFontVariationAxisHiddenKey as String] as? Bool ?? false
				
				let fontAxis = FontAxis()
				fontAxis.fontFamilyName = font.familyName
				fontAxis.fontName = font.fontName
				fontAxis.identifier = axisIdentifier
				fontAxis.name = axisName
				fontAxis.defaultValue = axisDefaultValue
				fontAxis.minimumValue = axisMinimumValue
				fontAxis.maximumValue = axisMaximumValue
				fontAxis.isHidden = axisHidden
				fontAxis.customValue = axisDefaultValue
				
				fontAxes[axisName] = fontAxis
				
				makeAxisSliderView(axisName, title: axisName, min: axisMinimumValue, max: axisMaximumValue, currentValue: fontAxis.customValue)
			}
			
			return fontAxes
		}
		
		if let variation = CTFontCopyVariation(font as CTFont) {
			print("\(variation)")
		}
		
		return nil
	}
	
	private func makeAxisSliderView(_ axisTag: String, title: String, min: CGFloat, max: CGFloat, currentValue: CGFloat) {
		let axisSliderView = FontAxisSliderParameterView.fromNib()
		axisSliderView.axisTag = axisTag
		axisSliderView.titleLabel.stringValue = title
		axisSliderView.slider.minValue = Double(min)
		axisSliderView.slider.maxValue = Double(max)
		axisSliderView.value = Double(currentValue)
		axisSliderView.target = self
		axisSliderView.sliderAction = #selector(parameterAction(_:))
		axisSliderView.resetAction = #selector(resetParameter(_:))
		
		self.optionPanel.addArrangedSubview(axisSliderView)
	}
	
	@objc private func parameterAction(_ sender: FontAxisSliderParameterView) {
		if sender.axisTag == "Size" {
			self.fontSize = CGFloat(sender.value)
		}
		else {
			let fontAxis = self.fontAxes[sender.axisTag]
			fontAxis?.customValue = CGFloat(sender.value)
		}
		setFontAxes()
	}
	
	@objc private func resetParameter(_ sender: FontAxisSliderParameterView) {
		if sender.axisTag == "Size" {
			self.fontSize = NSFont.systemFontSize
			sender.value = Double(self.fontSize)
		}
		else if let fontAxis = self.fontAxes[sender.axisTag] {
			fontAxis.customValue = fontAxis.defaultValue
			sender.value = Double(fontAxis.defaultValue)
		}
		setFontAxes()
	}
	
	private func setFontAxes() {
		if let originFontDescriptor = self.font?.fontDescriptor {
			var nextFontDescriptor = originFontDescriptor as CTFontDescriptor
			
			// Axisを更新
			for fontAxisKey in self.fontAxes.keys {
				guard let fontAxis = self.fontAxes[fontAxisKey] else {
					continue
				}
				
				let axisIdentifier = NSNumber(value: fontAxis.identifier) as CFNumber
				let axisValue = fontAxis.customValue
				nextFontDescriptor = CTFontDescriptorCreateCopyWithVariation(nextFontDescriptor,
																			 axisIdentifier,
																			 axisValue)
			}

			if let newFont = NSFont(descriptor: nextFontDescriptor, size: self.fontSize) {
				self.font = newFont
			}
		}
	}
	
	// ----------------------------------------------------
	// Axis Patterns
	
	/*
	(
			{
			NSCTVariationAxisDefaultValue = 400;
			NSCTVariationAxisIdentifier = 2003265652;
			NSCTVariationAxisMaximumValue = 1000;
			NSCTVariationAxisMinimumValue = 1;
			NSCTVariationAxisName = Weight;
		}
	)
	*/
	
	/*
	(
			{
			NSCTVariationAxisDefaultValue = 400;
			NSCTVariationAxisIdentifier = 1196572996;
			NSCTVariationAxisMaximumValue = 1000;
			NSCTVariationAxisMinimumValue = 400;
			NSCTVariationAxisName = GRAD;
		},
			{
			NSCTVariationAxisDefaultValue = 400;
			NSCTVariationAxisIdentifier = 2003265652;
			NSCTVariationAxisMaximumValue = 1000;
			NSCTVariationAxisMinimumValue = 1;
			NSCTVariationAxisName = Weight;
		}
	)
	*/
	
	/*
	(
			{
			NSCTVariationAxisDefaultValue = 0;
			NSCTVariationAxisIdentifier = 1297043023;
			NSCTVariationAxisMaximumValue = 1;
			NSCTVariationAxisMinimumValue = 0;
			NSCTVariationAxisName = Monospace;
		},
			{
			NSCTVariationAxisDefaultValue = 0;
			NSCTVariationAxisIdentifier = 1128354636;
			NSCTVariationAxisMaximumValue = 1;
			NSCTVariationAxisMinimumValue = 0;
			NSCTVariationAxisName = Casual;
		},
			{
			NSCTVariationAxisDefaultValue = 300;
			NSCTVariationAxisIdentifier = 2003265652;
			NSCTVariationAxisMaximumValue = 1000;
			NSCTVariationAxisMinimumValue = 300;
			NSCTVariationAxisName = Weight;
		},
			{
			NSCTVariationAxisDefaultValue = 0;
			NSCTVariationAxisIdentifier = 1936486004;
			NSCTVariationAxisMaximumValue = 0;
			NSCTVariationAxisMinimumValue = "-15";
			NSCTVariationAxisName = Slant;
		},
			{
			NSCTVariationAxisDefaultValue = "0.5";
			NSCTVariationAxisIdentifier = 1769234796;
			NSCTVariationAxisMaximumValue = 1;
			NSCTVariationAxisMinimumValue = 0;
			NSCTVariationAxisName = Italic;
		}
	)
	*/


}

