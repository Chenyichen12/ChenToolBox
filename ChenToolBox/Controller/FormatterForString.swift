//
//  FormatterForString.swift
//  ChenToolBox
//
//  Created by 陈依澄 on 2023/10/2.
//

import SwiftUI

class FormatterForNilString: Formatter {
    override func string(for obj: Any?) -> String? {
        return obj as? String
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = string as AnyObject
        return true
    }
}

