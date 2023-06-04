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
		let attributeArray = localizedAttributes()
		for attributes in attributeArray {
			if let featureTypeIdentifier = attributes[kCTFontFeatureTypeIdentifierKey] as? Int {
				print("Feature Type ID: \(featureTypeIdentifier)")
			}
			if let featureTypeNameID = attributes["CTFeatureTypeNameID" as CFString] as? Int {
				print("Feature Type Name ID: \(featureTypeNameID)")
			}
			if let featureTypeName = attributes[kCTFontFeatureTypeNameKey] as? String {
				print("Feature Type Name: \(featureTypeName)")
			}
			
			if let openTypeFeatureTag = attributes[kCTFontOpenTypeFeatureTag] as? String {
				print("OpenType Feature Tag: \(openTypeFeatureTag)")
			}
			
			if let featureTypeExclusive = attributes[kCTFontFeatureTypeExclusiveKey] as? Bool, featureTypeExclusive == true {
				print("Is exclusive: YES")
			}
			else {
				print("Is exclusive: NO")
			}
			
			if let sampleText = attributes[kCTFontFeatureSampleTextKey] as? String {
				print("Sample: \(sampleText)")
			}
			
			if let featureTypeSelectors = attributes[kCTFontFeatureTypeSelectorsKey] as? LocalizedAttributeArray {
				print("Feature selectors:")
				
				for selector in featureTypeSelectors {
					if let selectorID = selector[kCTFontFeatureSelectorIdentifierKey] as? Int {
						print("  Selector ID: \(selectorID)")
					}
					if let selectorNameID = selector["CTFeatureSelectorNameID" as CFString] as? Int {
						print("  Selector Name ID: \(selectorNameID)")
					}
					if let selectorName = selector[kCTFontFeatureSelectorNameKey] as? String {
						print("  Selector Name: \(selectorName)")
					}
					if let openTypeFeatureTag = selector[kCTFontOpenTypeFeatureTag] as? String {
						print("  OpenType Feature Tag: \(openTypeFeatureTag)")
					}
					if let openTypeFeatureValue = selector[kCTFontOpenTypeFeatureValue] as? Int {
						print("  OpenType Feature Value: \(openTypeFeatureValue)")
					}
					if let isDefaultSelector = selector[kCTFontFeatureSelectorDefaultKey] as? Bool, isDefaultSelector == true {
						print("  Is default: YES")
					}
					else {
						print("  Is default: NO")
					}
					
					print("\n")
				}
			}
			
			if let tooltip = attributes[kCTFontFeatureTooltipTextKey] as? String {
				print("Tooltip: \(tooltip)")
			}
			
			print("---------------------------")
			
			// kCTFontFeatureSelectorSettingKey (Boolean) は CTFontDescriptorCreateCopyWithAttributes() で使うもの？
			// https://developer.apple.com/documentation/coretext/kctfontfeatureselectorsettingkey
		}
	}
	
	
	// MARK: -
	
	// More info: SFNTLayoutTypes.h
		
	func addCapitalFormsFeature() -> NSFontDescriptor {
		addTypographicFeatures([
			.init(type: kCaseSensitiveLayoutType, selector: kCaseSensitiveLayoutOnSelector)
		])
	}	
}
