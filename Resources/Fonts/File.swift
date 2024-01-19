//
//  File.swift
//  PayPal
//
//  Created by Stephanie Chiu on 1/17/24.
//

import UIKit

enum RegisterFontError: Error {
    case invalidFontFile
    case fontPathNotFound
    case initFontError
    case registerFailed
}

class GetBundle {}

extension UIFont {
    static func register(path: String, fileNameString: String, type: String) throws {
        let frameworkBundle = Bundle(for: GetBundle.self)

        guard let resourceBundleURL = frameworkBundle.path(forResource: path + "/" + fileNameString, ofType: type) else {
            throw RegisterFontError.fontPathNotFound
        }

        guard let fontData = NSData(contentsOfFile: resourceBundleURL),
              let dataProvider = CGDataProvider.init(data: fontData) else {
            throw RegisterFontError.invalidFontFile
        }

        guard let fontRef = CGFont.init(dataProvider) else {
            throw RegisterFontError.initFontError
        }
        var errorRef: Unmanaged<CFError>? = nil

        guard CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) else {
            throw RegisterFontError.registerFailed
        }
    }}
