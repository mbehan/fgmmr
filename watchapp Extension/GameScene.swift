//
//  GameScene.swift
//  watchapp Extension
//
//  Created by Michael Behan on 15/11/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import SpriteKit
import WatchKit

class GameScene: SKScene {
    
    let gravitySystem = GravitySystem()
    
    override func sceneDidLoad() {
        gravitySystem.drawTrails = false
        self.addChild(gravitySystem)
        
        let planet = Planet(radius: 10)
        gravitySystem.add(planet: planet)
        
        let camera = SKCameraNode()
        self.camera = camera
        
        self.addChild(camera)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        gravitySystem.update()
        
        if let camera = camera, let largest = gravitySystem.largestMass, false{
            camera.position = largest.position
        }
        
        // if we're mid new planet placement, update the indication of the new planet size
        if let placerLine = placerLine {
            let durationOfPress = Date.timeIntervalSinceReferenceDate - timeAtTouchDown
            placerLine.lineWidth = CGFloat(durationOfPress)
        }

    }
    
    var timeAtTouchDown = Date.timeIntervalSinceReferenceDate
    var locationOfTouchDown = CGPoint()
    var placerLine : SKShapeNode?
    
    func handlePan(gesture:WKPanGestureRecognizer) {
        
        var touchLocation = gesture.locationInObject()
        touchLocation = CGPoint(x: -(self.size.width/2.0) + (touchLocation.x * 2.0) ,y: (self.size.height/2.0) - (touchLocation.y * 2.0))
        
        switch gesture.state {
        case .began:
            timeAtTouchDown = Date.timeIntervalSinceReferenceDate
            locationOfTouchDown = touchLocation
            
        case .changed:
            if placerLine != nil {
                placerLine!.removeFromParent()
                placerLine = nil
            }
            
            let placementPath = CGMutablePath()
            placementPath.move(to: locationOfTouchDown)
            placementPath.addLine(to: touchLocation)
            
            placerLine = SKShapeNode(path: placementPath)
            placerLine!.lineCap = .round
            placerLine!.alpha = 0.5
            self.addChild(placerLine!)

            
        case .ended, .failed:
            let durationOfPress = Date.timeIntervalSinceReferenceDate - timeAtTouchDown
            let radiusOfNewPlanet = CGFloat(durationOfPress * 5.0)
            
            let planet = Planet(radius:radiusOfNewPlanet)
            planet.node.position = touchLocation
            
            gravitySystem.add(planet: planet)
            
            let panVector = sub(a: locationOfTouchDown, b: touchLocation)
            
            planet.node.physicsBody?.velocity = CGVector(dx:panVector.x,dy:panVector.y)
            
            placerLine?.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3),SKAction.removeFromParent()]))
            
            
        default: break
        }

        
    }
}
