//
//  Person.swift
//  TestDemo
//
//  Created by ULDD on 2020/6/10.
//  Copyright © 2020 ULDD. All rights reserved.
//

import Foundation

@objc class Person: NSObject {
    var name = ""
    var age = 0
    
    
    init(name:String, age:Int) {
        self.name = name
        self.age = age
    }
}
