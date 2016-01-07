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
    var teachers: [Teacher] = []
    
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
        if let teachers = aDecoder.requestStructs("teachers") {
            self.teachers = teachers.filter({ (item) -> Bool in
                item is Teacher
            }).map({ (item) -> Teacher in
                item as! Teacher
            })
        }
    }
    
    func collectionItems() -> [String: [SSCoding]] {
        return [
            "teachers": self.teachers.map({ (item) -> SSCoding in
                return item as SSCoding
            })
        ]
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
    
    func collectionItems() -> [String : [SSCoding]] {
        return [:]
    }
    
}

let teacher = Teacher(name: "Pony", age: 26)
var school = School(name: "True Light Middle School", area: 4670.9394, teacher: teacher)
school.teachers = [
    Teacher(name: "Dennies", age: 32),
    Teacher(name: "Tom", age: 36),
]

let encodedData = NSKeyedArchiver.archivedDataWithRootStruct(school)

if let decodedScholl = NSKeyedUnarchiver.unarchiveStructWithData(encodedData) as? School {
    print("Now printing school")
    print(decodedScholl.name)
    print(decodedScholl.area)
    print("Now printing teacher")
    print(decodedScholl.teacher.name)
    print(decodedScholl.teacher.age)
    print("Now printing teachers")
    for teacher in decodedScholl.teachers {
        print(teacher.name)
        print(teacher.age)
    }
}



