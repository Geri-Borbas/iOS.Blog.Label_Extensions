//
//  UILabel+Observer.swift
//  UILabel_Typography_Extensions
//
//  Copyright © 2020. Geri Borbás. All rights reserved.
//  https://twitter.com/Geri_Borbas
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit


extension UILabel {
	
	fileprivate struct Keys {
		static var observer: UInt8 = 0
	}
	
	var observer: Observer? {
		get {
			objc_getAssociatedObject(self, &Keys.observer) as? Observer
		}
		set {
			objc_setAssociatedObject(self, &Keys.observer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	func observeIfNeeded() {
		guard observer == nil else {
			return
		}
		
		observer = Observer(
			for: self,
			onTextChange: { [weak self] text in
				
				/// This is needed every time after the `text` property updated
				/// in order to render a consistent baseline offset.
				self?.attributedText = self?.attributedText
			}
		)
	}
}


class Observer: NSObject {
	
	typealias TextChangeAction = (_ text: String?) -> Void
	let onTextChange: TextChangeAction
	private var observer: NSKeyValueObservation?
	
	init(for label: UILabel, onTextChange: @escaping TextChangeAction) {
		self.onTextChange = onTextChange
		super.init()
		observe(label)
	}
	
	func observe(_ label: UILabel) {
		observer = label.observe(
			\.text,
			options:  [.new, .old],
			changeHandler: { [weak self] _, change in
				self?.onTextChange(change.newValue ?? nil)
			}
		)
	}
	
	deinit {
		observer?.invalidate()
	}
}
