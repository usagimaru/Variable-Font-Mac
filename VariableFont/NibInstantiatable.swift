//
//  NibInstantiatable.swift
//
//  Created by Satori Maru on 2018/11/26.
//  Copyright © 2018 usagimaru. All rights reserved.
//

import Cocoa

protocol NibInstantiatable: class {

	/*
	必要なら実装クラスで以下を定義してください
	static var nibName: String {
		return "<#Nib Name#>"
	}
	*/

	/// Nib 名を返す
	static var nibName: String {get}

	static func nib(inBundle bundle: Bundle?) -> NSNib
	static func fromNib(inBundle bundle: Bundle?, filesOwner: Any?) -> Self

}

extension NibInstantiatable {

	static var nibName: String {
		return "\(Self.self)"
	}

	static func nib(inBundle bundle: Bundle?) -> NSNib {
		return NSNib(nibNamed: NSNib.Name("\(self.nibName)") , bundle: bundle)!
	}

	static func fromNib(inBundle bundle: Bundle? = nil, filesOwner: Any? = nil) -> Self {
		// topLevelObjects に First Responder Object (NSApplication) も含まれてくるので、それを排除する
		
		var objs: NSArray?
		let nib = self.nib(inBundle: bundle)
		nib.instantiate(withOwner: filesOwner, topLevelObjects: &objs)
		if let objs = objs {
			let objs_ = objs.filter {$0 is Self == true} as NSArray
			return objs_.lastObject as! Self
		}
		
		assert(false, "nib からロードできません")
	}

}

