//
//  Packable.swift
//  Sporti
//
//  Created by prcela on 11/05/16.
//  Copyright © 2016 minus5. All rights reserved.
//

import Foundation

protocol Packable
{
    init(value:MessagePackValue)
    func messagePackValue() -> MessagePackValue
}

protocol PackableDic: Packable {
    func identifier() -> Int
}

struct Point: Packable {
    
    var id: Int64
    var x: Double
    var y: Double
    
    init(id: Int64, x: Double, y: Double)
    {
        self.id = id
        self.x = x
        self.y = y
    }
    
    init(value: MessagePackValue)
    {
        var gen = value.arrayValue!.generate()
        
        id = gen.next()!.integerValue!
        x = gen.next()!.doubleValue!
        y = gen.next()!.doubleValue!
    }
    
    func messagePackValue() -> MessagePackValue
    {
        let value: MessagePackValue = [
            MessagePackValue(id),
            MessagePackValue(x),
            MessagePackValue(y)
        ]
        return value
  }
}

struct Triangle: Packable {
    
    let id: Int64
    let points: [Point]
    
    init(id: Int64, points: [Point])
    {
        self.id = id
        self.points = points
    }
    
    init(value: MessagePackValue)
    {
        var gen = value.arrayValue!.generate()
        
        id = gen.next()!.integerValue!
        points = gen.next()!.arrayValue!.map { (value) -> Point in
            return Point(value: value)
        }
    }
    
    func messagePackValue() -> MessagePackValue
    {
        let value: MessagePackValue = [
            MessagePackValue(id),
            MessagePackValue(points.map { (p) -> MessagePackValue in
                return p.messagePackValue()
                })
        ]
        return value
    }
}

func testPackable()
{
    let p0 = Point(id: 1, x: 2, y: 3)
    let p1 = Point(id: 2, x: 5, y: 6)
    let p2 = Point(id: 3, x: 5, y: 7)
    let t = Triangle(id: 7, points: [p0,p1,p2])
    
    let packed = pack(t.messagePackValue())
    let data = packed.withUnsafeBufferPointer({ buffer in
        return NSData(bytes: buffer.baseAddress, length: buffer.count)
    })
    
    do {
        let bytes = data.bytes()
        let value = try unpack(bytes)
        let triangle = Triangle(value: value)
        print("y of last pont in tringle: \(triangle.points.last!.y)")
    } catch let e as NSError
    {
        print(e.description)
    }
    
    
}