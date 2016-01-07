//
//  SSCoding.swift
//  SSCoding
//
//  Created by 崔 明辉 on 16/1/7.
//  Copyright © 2016年 swift. All rights reserved.
//

import Foundation

let SSCodingPrefix = "Default."

var SSCodingDefines: [String: SSCoding.Type] = [
    "\(SSCodingPrefix)School": School.self,
    "\(SSCodingPrefix)Teacher": Teacher.self,
    "\(SSCodingPrefix)Honor": Honor.self,
]

protocol SSCoding {
    
    init?(coder aDecoder: SSCoder)
    
    func arrayItems() -> [String: [SSCoding]]
    func dictionaryItems() -> [String: [String: SSCoding]]
    
}

struct SSCoder {
    
    let values: [String: AnyObject]
    
    init(values: [String: AnyObject]) {
        self.values = values
    }
    
    func requestStruct(rootKey: String) -> SSCoding? {
        if let value = values[rootKey] as? [String: AnyObject] {
            return SSCodingHelper.decodeDictionary(value)
        }
        else {
            return nil
        }
    }
    
    func requestStructs(arrayKey rootKey: String) -> [SSCoding]? {
        guard let values = self.values[rootKey] as? [[String: AnyObject]] else {
            return nil
        }
        var decodeStructs: [SSCoding] = []
        for value in values {
            if let decodeStruct = SSCodingHelper.decodeDictionary(value) {
                decodeStructs.append(decodeStruct)
            }
        }
        return decodeStructs
    }
    
    func requestStructs(dictionaryKey rootKey: String) -> [String: SSCoding]? {
        guard let values = self.values[rootKey] as? [String: [String: AnyObject]] else {
            return nil
        }
        var decodeStructs: [String: SSCoding] = [:]
        for (k, v) in values {
            if let decodeStruct = SSCodingHelper.decodeDictionary(v) {
                decodeStructs[k] = decodeStruct
            }
        }
        return decodeStructs
    }
    
}

extension SSCoder {
    
    var stringValues: [String: String] {
        var values: [String: String] = [:]
        for (key, value) in self.values {
            if let value = value as? String {
                values[key] = value
            }
        }
        return values
    }
    
    var intValues: [String: Int] {
        var values: [String: Int] = [:]
        for (key, value) in self.values {
            if let value = value as? Int {
                values[key] = value
            }
        }
        return values
    }
    
    var doubleValues: [String: Double] {
        var values: [String: Double] = [:]
        for (key, value) in self.values {
            if let value = value as? Double {
                values[key] = value
            }
        }
        return values
    }
    
    var floatValues: [String: CGFloat] {
        var values: [String: CGFloat] = [:]
        for (key, value) in self.values {
            if let value = value as? CGFloat {
                values[key] = value
            }
        }
        return values
    }
    
    var boolValues: [String: Bool] {
        var values: [String: Bool] = [:]
        for (key, value) in self.values {
            if let value = value as? Bool {
                values[key] = value
            }
        }
        return values
    }
    
    var dataValues: [String: NSData] {
        var values: [String: NSData] = [:]
        for (key, value) in self.values {
            if let value = value as? NSData {
                values[key] = value
            }
        }
        return values
    }
    
}

struct SSCodingHelper {
    
    static func encodedData(rootStruct: SSCoding) -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(encodeDictionary(rootStruct))
    }
    
    static func encodeDictionary(rootStruct: SSCoding) -> [String: AnyObject] {
        var dict: [String: AnyObject] = ["_SSCodingType": "\(SSCodingPrefix)\(rootStruct.dynamicType)"]
        let mir = Mirror(reflecting: rootStruct)
        for child in mir.children {
            if let label = child.label, let value = child.value as? SSCoding {
                dict[label] = encodeDictionary(value)
            }
            else if let label = child.label, let value = child.value as? AnyObject {
                dict[label] = value
            }
        }
        for (collectionKey, collectionValues) in rootStruct.arrayItems() {
            dict[collectionKey] = collectionValues.map({ (childStruct) -> [String: AnyObject] in
                encodeDictionary(childStruct)
            })
        }
        for (collectionKey, collectionValues) in rootStruct.dictionaryItems() {
            var tmpDict: [String: AnyObject] = [:]
            for (k, v) in collectionValues {
                tmpDict[k] = encodeDictionary(v)
            }
            dict[collectionKey] = tmpDict
        }
        return dict
    }
    
    static func decodeDictionary(dict: [String: AnyObject]) -> SSCoding? {
        guard let typeKey = dict["_SSCodingType"] as? String, let structType = SSCodingDefines[typeKey] else {
            return nil
        }
        return structType.init(coder: SSCoder(values: dict))
    }
    
}

extension NSKeyedArchiver {
    
    static func archivedDataWithRootStruct(rootStruct: SSCoding) -> NSData {
        return SSCodingHelper.encodedData(rootStruct)
    }
    
}

extension NSKeyedUnarchiver {
    
    static func unarchiveStructWithData(data: NSData) -> SSCoding? {
        guard let rootObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: AnyObject] else {
            return nil
        }
        return SSCodingHelper.decodeDictionary(rootObject)
    }
    
}