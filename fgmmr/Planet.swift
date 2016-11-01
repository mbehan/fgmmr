//
//  Planet.swift
//  fgmmr
//
//  Created by Michael Behan on 01/11/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import SpriteKit

let gravitationalConstant : CGFloat = 0.001

class Planet : Equatable {
    
    let mass : CGFloat
    let node : SKNode
    
    /// A planet's position is its node's position
    var position : CGPoint {
        get {
            return node.position
        }
    }
    
    /// Use to store the planet's last recorded position
    var lastPosition : CGPoint?
    
    init(mass m : CGFloat? = nil) {
        
        if let m = m {
            mass = m
        } else {
            mass = CGFloat(arc4random_uniform(20)) + 1.0
        }
        let radius = mass/10.0
        let planet = SKShapeNode.init(circleOfRadius: radius)
        let body = SKPhysicsBody(circleOfRadius: radius)
        
        body.affectedByGravity = false //heh
        body.allowsRotation = false
        
        planet.physicsBody = body
        body.collisionBitMask = 0
        
        node = planet
    }
    
    class func byColliding(_ planet1 : Planet, with planet2 : Planet) -> Planet {
        //calcs over multiple lines because Swift
        var vol1 = CGFloat((4.0 / 3.0) * M_PI)
        vol1 = vol1 * (planet1.mass * planet1.mass * planet1.mass)
        
        var vol2 = CGFloat((4.0 / 3.0) * M_PI)
        vol2 = vol2 * (planet2.mass * planet2.mass * planet2.mass)
        
        let vol3 = vol1 + vol2
        
        var newMass = (vol3 / CGFloat(M_PI)) * CGFloat(3.0 / 4.0)
        newMass = pow(newMass, 1.0/3.0)
        
        let reducingFactor = CGFloat(0.01) // the momentum that is lost in the collision
        
        let p1Mass = planet1.mass
        let p2Mass = planet2.mass
        
        let p1Factor = p1Mass * reducingFactor
        let p2Factor = p2Mass * reducingFactor
        
        let p1Velocity = planet1.node.physicsBody!.velocity
        let p2Velocity = planet2.node.physicsBody!.velocity
        
        let newVelocity = CGVector(dx: p1Factor * p1Velocity.dx + p2Factor * p2Velocity.dx, dy: p1Factor * p1Velocity.dy + p2Factor * p2Velocity.dy)
        
        let newPlanet = Planet(mass: newMass)
        newPlanet.node.position = CGPoint(x: (planet1.node.position.x + planet2.node.position.x) / 2.0, y:(planet1.node.position.y + planet2.node.position.y) / 2.0)
        
        newPlanet.node.physicsBody?.velocity = newVelocity
        
        return newPlanet
    }
    
    class func applyGravitationalAttraction(between planet1:Planet, and planet2:Planet) {
        let offset = sub(a: planet1.node.position, b: planet2.node.position)
        let direction = normalize(a: offset)
        
        let d = distance(p1: planet1.node.position, p2: planet2.node.position)
        let force = gravitationalConstant * ((planet1.mass * planet2.mass) / d )
        
        let amount = mult(a: direction, b: force)
        
        let forceVector = CGVector(dx: amount.x, dy: amount.y)
        
        
        planet2.node.physicsBody?.applyForce(forceVector)
    }
    
    
    //MARK:- Equatable
    static func ==(lhs:Planet, rhs:Planet) -> Bool {
        return lhs.node.position == rhs.node.position && lhs.mass == rhs.mass
    }
}
