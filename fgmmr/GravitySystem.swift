//
//  GravitySystem.swift
//  fgmmr
//
//  Created by Michael Behan on 11/11/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import SpriteKit

class GravitySystem : SKNode {
    
    var drawTrails = true
    var collisionThreshold = CGFloat(2)
    var largestMass : Planet?
    
    private(set) var planets = [Planet]()
    private var lineTrailFadeDuration = 2.5
    
    func add(planet : Planet) {
        planets.append(planet)
        self.addChild(planet.node)
    }
    
    func update() {
        var mergedPlanets = [Planet]()
        var newPlanets = [Planet]()
        
        var maxMass = CGFloat(0.0)
        
        for planet1 in planets {
            
            if drawTrails {
                addTrailSegment(for: planet1)
            }
            
            // calculate the largest mass
            if planet1.mass > maxMass {
                maxMass = planet1.mass
                largestMass = planet1
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
            }
        }
        
    }
    
    private func addTrailSegment(for planet:Planet) {
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
    
}
