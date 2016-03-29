//
//  Mapper.swift
//  Topo
//
//  Created by Oleg Dreyman on 27.03.16.
//  Copyright © 2016 Oleg Dreyman. All rights reserved.
//

import InterchangeData

// MARK: - Main
public final class Mapper {
    
    public enum Error: ErrorProtocol {
        case cantInitFromRawValue
        case noInterchangeData(key: String)
        case rawIntNotSupported
    }
    
    public init(interchangeData: InterchangeData) {
        self.interchangeData = interchangeData
    }
    
    private let interchangeData: InterchangeData
    
}

// MARK: - General case

extension Mapper {

    public func from<T>(key: String) throws -> T {
        let value: T = try interchangeData.get(key)
        return value
    }
    
    public func from<T: Convertible>(key: String) throws -> T {
        if let nested = interchangeData[key] {
            return try unwrap(T(interchangeData: nested))
        }
        throw Error.noInterchangeData(key: key)
    }
    
    public func from<T: RawRepresentable>(key: String) throws -> T {
        guard T.self != Int.self else {
            throw Error.rawIntNotSupported
        }
        let rawValue: T.RawValue = try interchangeData.get(key)
        if let value = T(rawValue: rawValue) {
            return value
        }
        throw Error.cantInitFromRawValue
    }
    
    public func from<T: Mappable>(key: String) throws -> T {
        if let nestedInterchange = interchangeData[key] {
            return try T(map: Mapper(interchangeData: nestedInterchange))
        }
        throw Error.noInterchangeData(key: key)
    }
    
}

// MARK: - Arrays

extension Mapper {
    
    public func arrayFrom<T>(key: String) throws -> [T] {
        return try interchangeData.flatMapThrough(key) {
            do {
                let some: T = try $0.get()
                print("returning")
                return some
            } catch {
                print("incorrect")
                return nil
            }
        }
    }
    
    public func arrayFrom<T: Convertible>(key: String) throws -> [T] {
        return try interchangeData.flatMapThrough(key) { T.(interchangeData: $0) }
    }
    
    public func arrayFrom<T: RawRepresentable>(key: String) throws -> [T] {
        guard T.self != Int.self else {
            throw Error.rawIntNotSupported
        }
        return try interchangeData.flatMapThrough(key) {
            do {
                let rawValue: T.RawValue = try $0.get()
                print(rawValue)
                return T(rawValue: rawValue)
            } catch {
                return nil
            }
        }
    }
    
    public func arrayFrom<T: Mappable>(key: String) throws -> [T] {
        return try interchangeData.flatMapThrough(key) { T.from(interchangeData: $0) }
    }
    
}

// MARK: - Optionals

extension Mapper {
    
    public func optionalFrom<T>(key: String) -> T? {
        do {
            return try from(key)
        } catch {
            return nil
        }
    }
    
    public func optionalFrom<T: InterchangeDataConvertible where T == T.ConvertingTo>(key: String) -> T? {
        if let nested = interchangeData[key] {
            return T.from(customInterchangeData: nested)
        }
        return nil
    }
    
    public func optionalFrom<T: RawRepresentable>(key: String) -> T? {
        guard T.self != Int.self else {
            return nil
        }
        do {
            let rawValue: T.RawValue = try interchangeData.get(key)
            if let value = T(rawValue: rawValue) {
                return value
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public func optionalFrom<T: Mappable>(key: String) -> T? {
        do {
            if let nestedInterchange = interchangeData[key] {
                return try T(map: Mapper(interchangeData: nestedInterchange))
            }
            return nil
        } catch {
            return nil
        }
    }
    
}

// MARK: - Optional arrays

extension Mapper {
    
    public func optionalArrayFrom<T>(key: String) -> [T]? {
        do {
            let inter: [InterchangeData] = try interchangeData.get(key)
            return inter.flatMap {
                do {
                    let some: T = try $0.get()
                    return some
                } catch {
                    return nil
                }
            }
        } catch {
            return nil
        }
    }
    
    public func optionalArrayFrom<T: InterchangeDataConvertible where T == T.ConvertingTo>(key: String) -> [T]? {
        do {
            let inter: [InterchangeData] = try interchangeData.get(key)
            return inter.flatMap({ T.from(customInterchangeData: $0) })
        } catch {
            return nil
        }
    }
    
    public func optionalArrayFrom<T: RawRepresentable>(key: String) -> [T]? {
        guard T.self != Int.self else {
            return nil
        }
        do {
            let inter: [InterchangeData] = try interchangeData.get(key)
            return inter.flatMap {
                do {
                    let rawValue: T.RawValue = try $0.get()
                    return T(rawValue: rawValue)
                } catch {
                    return nil
                }
            }
        } catch {
            return nil
        }
    }
    
    public func optionalArrayFrom<T: Mappable>(key: String) -> [T]? {
        do {
            let inter: [InterchangeData] = try interchangeData.get(key)
            return inter.flatMap({ T.from(interchangeData: $0) })
        } catch {
            return nil
        }
    }
    
}

// MARK: - Unwrap

public enum UnwrapError: ErrorProtocol {
    case tryingToUnwrapNil
}

extension Mapper {
    
    private func unwrap<T>(optional: T?) throws -> T {
        if let nonoptional = optional {
            return nonoptional
        }
        throw UnwrapError.tryingToUnwrapNil
    }
    
}