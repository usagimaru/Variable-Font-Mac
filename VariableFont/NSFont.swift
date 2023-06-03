//
//  NSFont.swift
//

import Cocoa

extension NSFont {
	
	var traits: [NSFontDescriptor.TraitKey : Any] {
		fontDescriptor.object(forKey: .traits) as? [NSFontDescriptor.TraitKey : Any] ?? [:]
	}
	
	var weight: NSFont.Weight {
		if let weightValue = traits[.weight] as? CGFloat {
			return NSFont.Weight(weightValue)
		}
		return .regular
	}
	
	var supportedLanguages: [String] {
		CTFontCopySupportedLanguages(self) as? [String] ?? []
	}
	
}

extension NSFontDescriptor {
	
	typealias LocalizedAttributeArray = [[CFString : AnyObject]]
	
	struct TypographicFeature {
		let type: Int
		let selector: Int
		
		func featureSetting() -> [NSFontDescriptor.FeatureKey : Int] {
			[
				NSFontDescriptor.FeatureKey.typeIdentifier : type,
				NSFontDescriptor.FeatureKey.selectorIdentifier : selector
			]
		}
	}
	
	func addTypographicFeatures(_ features: [TypographicFeature]) -> NSFontDescriptor {
		let featureSettings = features.map {
			$0.featureSetting()
		}
		let newDescriptor = self.addingAttributes(
			[
				NSFontDescriptor.AttributeName.featureSettings : featureSettings
			]
		)
		
		return newDescriptor
	}
	
	func addCapitalFormsFeature() -> NSFontDescriptor {
		addTypographicFeatures([
			TypographicFeature(type: kCaseSensitiveLayoutType, selector: kCaseSensitiveLayoutOnSelector)
		])
	}
	
	func localizedAttributes(_ lang: String? = nil) -> LocalizedAttributeArray {
		// Unmanaged<T>の扱いについて
		// Core Foundation の値は Swift だと Unmanaged で扱われる
		// http://seeku.hateblo.jp/entry/2014/06/20/205708
		// https://qiita.com/omochimetaru/items/2aa00c7cb0eef4e57999
		
		var languagePtr: UnsafeMutablePointer<Unmanaged<CFString>?>? = nil
		if let lang {
			let language: Unmanaged<CFString>? = Unmanaged<CFString>.passRetained(lang as CFString)
			languagePtr = unsafeBitCast(language, to: UnsafeMutablePointer<Unmanaged<CFString>?>.self)
		}
		
		let localizedAttribute = CTFontDescriptorCopyLocalizedAttribute(self, kCTFontFeaturesAttribute, languagePtr)
		return localizedAttribute as? LocalizedAttributeArray ?? LocalizedAttributeArray()
	}
	
	func printLocalizedAttributes() {
		// More info: SFNTLayoutTypes.h
		
		let attributeArray = localizedAttributes()
		for attributes in attributeArray {
			if let featureTypeIdentifier = attributes[kCTFontFeatureTypeIdentifierKey] as? Int {
				print("[kCTFontFeatureTypeIdentifierKey] | Feature Type ID: \(featureTypeIdentifier)")
			}
			if let featureTypeName = attributes[kCTFontFeatureTypeNameKey] as? String {
				print("[kCTFontFeatureTypeNameKey] | Feature Type Name: \(featureTypeName)")
			}
			
			if let openTypeFeatureTag = attributes[kCTFontOpenTypeFeatureTag] as? String {
				print("[kCTFontOpenTypeFeatureTag] | OpenType Feature Tag: \(openTypeFeatureTag)")
			}
			if let openTypeFeatureValue = attributes[kCTFontOpenTypeFeatureValue] {
				print("[kCTFontOpenTypeFeatureValue] | OpenType Feature Value: \(openTypeFeatureValue)")
			}
			
			if let featureTypeExclusive = attributes[kCTFontFeatureTypeExclusiveKey] as? Bool, featureTypeExclusive == true {
				print("[kCTFontFeatureTypeExclusiveKey] | Is exclusive: TRUE")
			}
			else {
				print("[kCTFontFeatureTypeExclusiveKey] | Is exclusive: FALSE")
			}
			
			if let sampleText = attributes[kCTFontFeatureSampleTextKey] as? String {
				print("[kCTFontFeatureSampleTextKey] | Sample: \(sampleText)")
			}
			
			if let featureTypeSelectors = attributes[kCTFontFeatureTypeSelectorsKey] as? LocalizedAttributeArray {
				print("[kCTFontFeatureTypeSelectorsKey] | Feature selectors:")
				
				for selector in featureTypeSelectors {
					if let selectorID = selector[kCTFontFeatureSelectorIdentifierKey] as? Int {
						print("  [kCTFontFeatureSelectorIdentifierKey] | Selector ID: \(selectorID)")
					}
					if let selectorNameID = selector["CTFeatureSelectorNameID" as CFString] as? Int {
						print("  [CTFeatureSelectorNameID] | Selector Name ID: \(selectorNameID)")
					}
					if let selectorName = selector[kCTFontFeatureSelectorNameKey] as? String {
						print("  [kCTFontFeatureSelectorNameKey] | Selector Name: \(selectorName)")
					}
					if let isDefaultSelector = selector[kCTFontFeatureSelectorDefaultKey] as? Bool, isDefaultSelector == true {
						print("  [kCTFontFeatureSelectorDefaultKey] | Is default: TRUE")
					}
					else {
						print("  [kCTFontFeatureSelectorDefaultKey] | Is default: FALSE")
					}
					
					print("\n")
				}
			}
			
			if let tooltip = attributes[kCTFontFeatureTooltipTextKey] as? String {
				print("[kCTFontFeatureTooltipTextKey] | Tooltip: \(tooltip)")
			}
			
			print("---------------------------")
		}
	}
	
}
