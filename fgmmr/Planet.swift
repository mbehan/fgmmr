//
//  Planet.swift
//  fgmmr
//
//  Created by Michael Behan on 01/11/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import SpriteKit

class Planet : Equatable {
    
    let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    
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
            mass = max(1.0,m)
        } else {
            mass = CGFloat(arc4random_uniform(20)) + 1.0
        }
        let radius = mass/10.0
        let planet = SKShapeNode.init(circleOfRadius: radius)
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.mass = mass
        body.affectedByGravity = false //heh
        body.allowsRotation = false
        
        planet.physicsBody = body
        body.collisionBitMask = 0
        
        planet.fillColor = self.color
        
        node = planet
    }
    
    class func byColliding(_ planet1 : Planet, with planet2 : Planet) -> Planet {
        
        //calc the combined raduis by adding the volumes of the planets
        let r1 = planet1.mass / 10.0
        let r2 = planet2.mass / 10.0
        let newRadius = pow(pow(r1,3) + pow(r2,3), 1/3.0)

        let p1Mass = planet1.mass
        let p2Mass = planet2.mass
        let reducingFactor = CGFloat(0.01) // lose a chunk of momentum in the collision
        let p1Factor = p1Mass * reducingFactor
        let p2Factor = p2Mass * reducingFactor
        
        let p1Velocity = planet1.node.physicsBody!.velocity
        let p2Velocity = planet2.node.physicsBody!.velocity
        
        let newVelocity = CGVector(dx: p1Factor * p1Velocity.dx + p2Factor * p2Velocity.dx, dy: p1Factor * p1Velocity.dy + p2Factor * p2Velocity.dy)
        
        let newPlanet = Planet(mass: newRadius * 10.0)
        newPlanet.node.position = CGPoint(x: (planet1.node.position.x + planet2.node.position.x) / 2.0, y:(planet1.node.position.y + planet2.node.position.y) / 2.0)
        
        newPlanet.node.physicsBody?.velocity = newVelocity
        
        return newPlanet
    }
    
    class func applyGravitationalAttraction(between planet1:Planet, and planet2:Planet) {
        let gravitationalConstant : CGFloat = 100.0 // is really 6.67408 × 10^-11, but then we'd need awfully large numbers for mass and then the distances would be way off ...
        let offset = sub(a: planet1.node.position, b: planet2.node.position)
        let direction = normalize(a: offset)
        
        let d = distance(p1: planet1.node.position, p2: planet2.node.position)
        let force = gravitationalConstant * ((planet1.mass * planet2.mass) / (d) ) //in real life we'd divide by d^2, but that was making it less fun / harder to make stable systems. Prob just need to tweak other stuff to get it just right
        
        let amount = mult(a: direction, b: force)
        
        let forceVector = CGVector(dx: amount.x, dy: amount.y)
        
        
        planet2.node.physicsBody?.applyForce(forceVector)
    }
    
    //MARK:- Equatable
    static func ==(lhs:Planet, rhs:Planet) -> Bool {
        return lhs.node.position == rhs.node.position && lhs.mass == rhs.mass
    }
}
