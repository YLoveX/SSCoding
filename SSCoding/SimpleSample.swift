//
//  SimpleSample.swift
//  SSCoding
//
//  Created by 崔 明辉 on 16/1/7.
//  Copyright © 2016年 swift. All rights reserved.
//

import Foundation

struct SimpleStruct: SSCoding {
    
    let anInt: Int
    
    init(anInt: Int) {
        self.anInt = anInt
    }
    
    init?(coder aDecoder: SSCoder) {
        guard let anInt = aDecoder.intValues["anInt"] else {
            return nil
        }
        self.anInt = anInt
    }
    
    func arrayItems() -> [String : [SSCoding]] {
        return [:]
    }
    
    func dictionaryItems() -> [String : [String : SSCoding]] {
        return [:]
    }
    
}

func runSimpleSample() {
    
    let simple = SimpleStruct(anInt: 123)
    let data = NSKeyedArchiver.archivedDataWithRootStruct(simple)
    
    if let decodeSimple = NSKeyedUnarchiver.unarchiveStructWithData(data) as? SimpleStruct {
        print(decodeSimple.anInt)
    }
    
}