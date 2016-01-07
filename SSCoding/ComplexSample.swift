//
//  ComplexSample.swift
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
        if let teachers = aDecoder.requestStructs(arrayKey: "teachers") {
            self.teachers = teachers.filter({ (item) -> Bool in
                item is Teacher
            }).map({ (item) -> Teacher in
                item as! Teacher
            })
        }
    }
    
    func arrayItems() -> [String: [SSCoding]] {
        return [
            "teachers": self.teachers.map({ (item) -> SSCoding in
                return item as SSCoding
            })
        ]
    }
    
    func dictionaryItems() -> [String : [String : SSCoding]] {
        return [:]
    }
    
}

struct Teacher: SSCoding {
    
    let name: String
    let age: Int
    var honors: [String: Honor] = [:]
    
    init(name: String, age: Int, honors: [String: Honor] = [:]) {
        self.name = name
        self.age = age
        self.honors = honors
    }
    
    init?(coder aDecoder: SSCoder) {
        guard let name = aDecoder.stringValues["name"], let age = aDecoder.intValues["age"] else {
            return nil
        }
        self.name = name
        self.age = age
        self.honors = {
            if let honors = aDecoder.requestStructs(dictionaryKey: "honors") {
                var items: [String: Honor] = [:]
                for (k, v) in honors {
                    if let v = v as? Honor {
                        items[k] = v
                    }
                }
                return items
            }
            return [:]
            }()
    }
    
    func arrayItems() -> [String : [SSCoding]] {
        return [:]
    }
    
    func dictionaryItems() -> [String : [String : SSCoding]] {
        return [
            "honors": {
                var dict: [String : SSCoding] = [:]
                for (k, v) in self.honors {
                    dict[k] = (v as SSCoding)
                }
                return dict
                }()
        ]
    }
    
}

struct Honor: SSCoding {
    
    let name: String
    let level: Int
    
    init(name: String, level: Int) {
        self.name = name
        self.level = level
    }
    
    init?(coder aDecoder: SSCoder) {
        guard let name = aDecoder.stringValues["name"], let level = aDecoder.intValues["level"] else {
            return nil
        }
        self.name = name
        self.level = level
    }
    
    func arrayItems() -> [String : [SSCoding]] {
        return [:]
    }
    
    func dictionaryItems() -> [String : [String : SSCoding]] {
        return [:]
    }
    
}

func runComplexSample() {
    
    let teacher = Teacher(name: "Pony", age: 26)
    var school = School(name: "True Light Middle School", area: 4670.9394, teacher: teacher)
    school.teachers = [
        Teacher(name: "Dennies", age: 32),
        Teacher(name: "Tom", age: 36, honors: ["nobel": Honor(name: "Nobel Prize", level: 1)]),
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
            if teacher.honors.count > 0 {
                for (k, v) in teacher.honors {
                    print("\(teacher.name)'s honor: \(k), \(v.name), \(v.level)")
                }
            }
        }
    }
    
}