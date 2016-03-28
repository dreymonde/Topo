//
//  Convertible.swift
//  Topo
//
//  Created by Oleg Dreyman on 27.03.16.
//  Copyright © 2016 Oleg Dreyman. All rights reserved.
//

import Foundation
#if os(Linux)
    import InterchangeData
#endif

public protocol Convertible {
    static func fromCustomInterchangeData(value: InterchangeData) -> Self?
}

public enum ConvertibleError: ErrorProtocol {
    case cantBindToNeededType
}

extension Int: Convertible {
    public static func fromCustomInterchangeData(value: InterchangeData) -> Int? {
        switch value {
        case .numberValue(let number):
            return Int(number)
        default:
            return nil
        }
    }
}