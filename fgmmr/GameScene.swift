//
//  GameScene.swift
//  fgmmr
//
//  Created by Michael Behan on 28/10/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // game params
    var centerOnLargestMass = false
    var lineTrail = true
    var lineTrailFadeDuration = 2.5
    var particleTrail = false
    var collisionThreshold = CGFloat(2)
    
    var planets = [Planet]()
    
    override func didMove(to view: SKView) {
        
        let planet = Planet(mass: 100)
        planets.append(planet)
        
        self.addChild(planet.node)
        
        let camera = SKCameraNode()
        self.camera = camera
        
        self.addChild(camera)
        
        if particleTrail {
            addParticleTrail(to: planet, in: self)
        }
        
        let pinchy = UIPinchGestureRecognizer()
        pinchy.addTarget(self, action: #selector(handlePinch(gesture:)))
        self.view?.addGestureRecognizer(pinchy)
    }
    
    var cameraScaleAtStartOfPinch = CGFloat(1.0)
    
    func handlePinch(gesture:UIPinchGestureRecognizer){
        
        switch gesture.state {
        case .began:
            cameraScaleAtStartOfPinch = self.camera!.xScale
        default:
            self.camera!.setScale((1.0 / gesture.scale) * cameraScaleAtStartOfPinch)
        }
    }
    
    func addParticleTrail(to planet:Planet, in target:SKNode) {
        let emitter = SKEmitterNode(fileNamed: "testParticle")!
        emitter.targetNode = target
        planet.node.addChild(emitter)
    }
    
    func addTrailSegment(for planet:Planet) {
        if let lastPosition = planet.lastPosition {
            let path = CGMutablePath()
            path.move(to: lastPosition)
            path.addLine(to: planet.node.position)
            
            let lineSeg = SKShapeNode(path: path)
            lineSeg.strokeColor = planet.color
            lineSeg.fillColor = planet.color
            self.addChild(lineSeg)
            
            lineSeg.run(SKAction.sequence([SKAction.fadeOut(withDuration: lineTrailFadeDuration), SKAction.removeFromParent()]))
        }
        
        
        planet.lastPosition = planet.node.position
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
            
        var mergedPlanets = [Planet]()
        var newPlanets = [Planet]()
        
        var maxMass = CGFloat(0.0)
            
        for planet1 in planets {
            
            if lineTrail {
                addTrailSegment(for: planet1)
            }
            
            if centerOnLargestMass {
                if planet1.mass > maxMass {
                    maxMass = planet1.mass
                    camera?.position = planet1.node.position
                }
            }
            
            for planet2 in planets {
                if planet1 != planet2 {
                    if distance(p1: planet1.node.position, p2: planet2.node.position) < collisionThreshold {
                        mergedPlanets.append(planet1)
                        
                        let newPlanet = Planet.byColliding(planet1, with: planet2)
                        
                        if !newPlanets.contains(newPlanet) { // prevents both p1xp2 and p2xp1 being added
                            newPlanets.append(newPlanet)
                        }
                    } else {
                        Planet.applyGravitationalAttraction(between: planet1, and: planet2)
                    }
                }
            }
        }
        
        if mergedPlanets.count > 0 {
            planets = planets.filter {
                if mergedPlanets.contains($0) {
                    $0.node.removeFromParent()
                    return false
                }
                return true
            }
            
            for planet in newPlanets {
                self.addChild(planet.node)
                planets.append(planet)
                
                if particleTrail {
                    addParticleTrail(to: planet, in: self)
                }
            }
        }
    }
    
    var timeAtTouchDown = Date.timeIntervalSinceReferenceDate
    var locationOfTouchDown = CGPoint()
    
    // MARK:- Touch Handling
    func touchDown(atPoint pos : CGPoint) {
        timeAtTouchDown = Date.timeIntervalSinceReferenceDate
        locationOfTouchDown = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let durationOfPress = Date.timeIntervalSinceReferenceDate - timeAtTouchDown
        let massOfNewPlanet = CGFloat(durationOfPress * 50.0)
        
        let planet = Planet(mass:massOfNewPlanet)
        planet.node.position = pos
        
        planets.append(planet)
        self.addChild(planet.node)
        
        if particleTrail {
            addParticleTrail(to: planet, in: self)
        }
        
        let panVector = sub(a: locationOfTouchDown, b: pos)
        
        planet.node.physicsBody?.velocity = CGVector(dx:panVector.x,dy:panVector.y)
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
}
