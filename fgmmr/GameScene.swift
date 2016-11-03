//
//  GameScene.swift
//  fgmmr
//
//  Created by Michael Behan on 28/10/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, UIGestureRecognizerDelegate {
    
    // game params
    var centerOnLargestMass = false
    var lineTrail = true
    var lineTrailFadeDuration = 2.5
    var collisionThreshold = CGFloat(2)
    let newPlanetPan = UIPanGestureRecognizer()
    
    var planets = [Planet]()
    
    override func didMove(to view: SKView) {
        
        let planet = Planet(radius: 10)
        planets.append(planet)
        self.addChild(planet.node)
        
        let camera = SKCameraNode()
        self.camera = camera
        
        self.addChild(camera)
        
        //set up gesture recognizers
        let pinchy = UIPinchGestureRecognizer()
        pinchy.addTarget(self, action: #selector(handlePinch(gesture:)))
        self.view?.addGestureRecognizer(pinchy)
        
        let panny = UIPanGestureRecognizer()
        panny.maximumNumberOfTouches = 2
        panny.minimumNumberOfTouches = 2
        panny.addTarget(self, action: #selector(handlePan(gesture:)))
        self.view?.addGestureRecognizer(panny)
        
        newPlanetPan.maximumNumberOfTouches = 1
        newPlanetPan.addTarget(self, action: #selector(handleNewPlanetPan(gesture:)))
        self.view?.addGestureRecognizer(newPlanetPan)
        
        newPlanetPan.delegate = self
        panny.delegate = self
        pinchy.delegate = self
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
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
            }
        }
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

    
    // MARK:- Touch Handling
    
    var timeAtTouchDown = Date.timeIntervalSinceReferenceDate
    var locationOfTouchDown = CGPoint()
    
    func handleNewPlanetPan(gesture: UIPanGestureRecognizer) {
        
        var touchLocation = gesture.location(in: gesture.view)
        touchLocation = self.convertPoint(fromView: touchLocation)
        
        switch gesture.state {
        case .began:
            timeAtTouchDown = Date.timeIntervalSinceReferenceDate
            locationOfTouchDown = touchLocation
        case .ended, .failed:
            let durationOfPress = Date.timeIntervalSinceReferenceDate - timeAtTouchDown
            let radiusOfNewPlanet = CGFloat(durationOfPress * 5.0)
            
            let planet = Planet(radius:radiusOfNewPlanet)
            planet.node.position = touchLocation
            
            planets.append(planet)
            
            self.addChild(planet.node)
            
            let panVector = sub(a: locationOfTouchDown, b: touchLocation)
            
            planet.node.physicsBody?.velocity = CGVector(dx:panVector.x,dy:panVector.y)
            
        default: break
        }
        
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
    
    func handlePan(gesture:UIPanGestureRecognizer){
        
        if gesture.state == .changed {
        
            var touchLocation = gesture.location(in: gesture.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            
            var translation = gesture.translation(in: gesture.view!)
            translation = CGPoint(x: -translation.x, y: translation.y)
            
            let position = self.camera!.position
            
            self.camera!.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            
            gesture.setTranslation(CGPoint(), in: gesture.view)
            
        }
    }
    
    // MARK:- Gesture Recognizer Delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == newPlanetPan || otherGestureRecognizer == newPlanetPan {
            return false
        }
        
        return true
    }
}
