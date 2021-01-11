//
//  UIViewExtensions.swift
//  SoundDataTrasfer
//
//  Created by Admin on 05/01/21.
//
import UIKit
import Foundation

extension UIView {

@IBInspectable var cornerRadius: Double {
    get {
        return Double(self.layer.cornerRadius)
    }set {
        self.layer.cornerRadius = CGFloat(newValue)
    }
}
}
