//
//  main.swift
//  SSCoding
//
//  Created by 崔 明辉 on 16/1/7.
//  Copyright © 2016年 swift. All rights reserved.
//

import Foundation

struct School: SSCoding {
    
    let name: String
    let area: Double
    
    let teacher: Teacher
    
    init(name: String, area: Double, teacher: Teacher) {
        self.name = name
        self.area = area
        self.teacher = teacher
    }
    
    init?(coder aDecoder: SSCoder) {
        guard let name = aDecoder.stringValues["name"],
            let area = aDecoder.doubleValues["area"],
            let teacher = aDecoder.requestStruct("teacher") as? Teacher else {
            return nil
        }
        self.name = name
        self.area = area
        self.teacher = teacher
    }
    
}

struct Teacher: SSCoding {
    
    let name: String
    let age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    init?(coder aDecoder: SSCoder) {
        guard let name = aDecoder.stringValues["name"], let age = aDecoder.intValues["age"] else {
            return nil
        }
        self.name = name
        self.age = age
    }
    
}

let teacher = Teacher(name: "Pony", age: 26)
let school = School(name: "True Light Middle School", area: 4670.9394, teacher: teacher)

let encodedData = NSKeyedArchiver.archivedDataWithRootStruct(school)

if let decodedScholl = NSKeyedUnarchiver.unarchiveStructWithData(encodedData) as? School {
    print("Now printing school")
    print(decodedScholl.name)
    print(decodedScholl.area)
    print("Now printing teacher")
    print(decodedScholl.teacher.name)
    print(decodedScholl.teacher.age)
}



