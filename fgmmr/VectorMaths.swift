//
//  VectorMaths.swift
//  fgmmr
//
//  Created by Michael Behan on 01/11/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import CoreGraphics

func sub(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x ,y: a.y - b.y)
}

func add(a: CGPoint, b: CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x ,y: a.y + b.y)
}

func mult(a: CGPoint, b: CGFloat) -> CGPoint {
    return CGPoint(x: a.x * b ,y: a.y * b)
}

func length(a: CGPoint) -> CGFloat {
    return sqrt(CGFloat(a.x * a.x) + CGFloat(a.y * a.y))
}

func normalize(a:CGPoint)->CGPoint{
    let l = length(a: a)
    return CGPoint(x: a.x / l, y: a.y / l)
}

func distance(p1:CGPoint, p2:CGPoint) -> CGFloat {
    return CGFloat(hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y)))
}
