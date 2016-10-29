//
//  GameScene.swift
//  fgmmr
//
//  Created by Michael Behan on 28/10/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import SpriteKit

let gravitationalConstant : CGFloat = 0.1

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

// Makes a vector have a length of 1
func normalize(a:CGPoint)->CGPoint{
    let l = length(a: a)
    return CGPoint(x: a.x / l, y: a.y / l)
}

func distance(p1:CGPoint, p2:CGPoint) -> CGFloat {
    return CGFloat(hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y)))
}

class GravitationalSystem {
    var bodies = [SKShapeNode]()
    
    func update(){
        for thisBody in bodies {
            
            for otherBody in bodies {
             
               // let forceBetweenBodies =
            }
        }
    }
}

struct Planet : Equatable {
    
    let node : SKNode
    var position : CGPoint {
        didSet {
            node.position = self.position
        }
    }
    
    let mass : CGFloat
    
    init(mass m : CGFloat? = nil) {
        
        if let m = m {
            mass = m
        } else {
            mass = CGFloat(arc4random_uniform(20)) + 1.0
        }
        let planet = SKShapeNode.init(circleOfRadius: mass/10.0)
        let body = SKPhysicsBody(circleOfRadius: mass)
        
        body.affectedByGravity = false
        body.allowsRotation = true
        
        planet.physicsBody = body
        body.collisionBitMask = 0
        
        node = planet
        position = node.position
        
        
    }
    
    static func ==(lhs:Planet, rhs:Planet) -> Bool { // Implement Equatable
        return lhs.node.position == rhs.node.position && lhs.mass == rhs.mass
    }
}

class GameScene: SKScene {
    
    var planets = [Planet]()
    
    var added2 = false
    
    override func didMove(to view: SKView) {
        
        let planet = Planet()
        planets.append(planet)
        
        self.addChild(planet.node)
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        var planet = Planet()
        planet.position = pos
        
        planets.append(planet)
        self.addChild(planet.node)
        
        added2 = true
    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if added2 {
            
           
            
            func applyGravitationalForce(planet1:Planet, planet2:Planet) {
                let offset = sub(a: planet1.node.position, b: planet2.node.position)
                let direction = normalize(a: offset)
                
                let d = distance(p1: planet1.node.position, p2: planet2.node.position)
                let force = gravitationalConstant * ((planet1.mass * planet2.mass)/d)
                
                let amount = mult(a: direction, b: force)
                
                let forceVector = CGVector(dx: amount.x, dy: amount.y)
                
                //print(forceVector)
                
                planet2.node.physicsBody?.applyForce(forceVector)
            }
            
            var planetsToKill = [Planet]()
            var planetsToAdd = [Planet]()
            
            for planet1 in planets {
                for planet2 in planets {
                    if planet1.position != planet2.position {
                        
                        if distance(p1: planet1.node.position, p2: planet2.node.position) < 2 {
                            planetsToKill.append(planet1)
                            
                            var v1 = CGFloat((4.0 / 3.0) * M_PI)
                            v1 = v1 * (planet1.mass * planet1.mass * planet1.mass)
                            
                            var v2 = CGFloat((4.0 / 3.0) * M_PI)
                            v2 = v2 * (planet2.mass * planet2.mass * planet2.mass)
                            
                            let v3 = v1 + v2
                            
                            var newR = (v3 / CGFloat(M_PI)) * CGFloat(3.0 / 4.0)
                            newR = pow(newR, 1.0/3.0)
                            
                            let reducingFactor = CGFloat(0.2)
                            
                            let newVelocity = CGVector(dx: reducingFactor * planet1.node.physicsBody!.velocity.dx + reducingFactor * planet2.node.physicsBody!.velocity.dx, dy: reducingFactor * planet1.node.physicsBody!.velocity.dy + reducingFactor * planet2.node.physicsBody!.velocity.dy)
                            
                            var newPlanet = Planet(mass: newR)
                            newPlanet.position = CGPoint(x: (planet1.node.position.x + planet2.node.position.x) / 2.0, y:(planet1.node.position.y + planet2.node.position.y) / 2.0)
                            
                            newPlanet.node.physicsBody?.velocity = newVelocity
                            
                            if !planetsToAdd.contains(newPlanet) {
                                planetsToAdd.append(newPlanet)
                            }
                            
                            
                        } else {
                        
                            applyGravitationalForce(planet1: planet1, planet2: planet2)
                        }
                    }
                }
            }
            
            if planetsToKill.count > 0 {
            
                planets = planets.filter {
                    if planetsToKill.contains($0) {
                        $0.node.removeFromParent()
                        return false
                    }
                    return true
                }
                
                
                for planet in planetsToAdd {
                    self.addChild(planet.node)
                    planets.append(planet)
                }
                
            }
        }
    }
}
