//
//  GameScene.swift
//  fgmmr
//
//  Created by Michael Behan on 28/10/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, UIGestureRecognizerDelegate, GravitySystemCollisionDelegate {

    var centerOnLargestMass = true
    
    let newPlanetPan = ForcePanGestureRecognizer()
    let gravitySystem = GravitySystem()
    var forceTouch = false
    
    let smallVibe = UIImpactFeedbackGenerator(style: .light)
    let medVibe = UIImpactFeedbackGenerator(style: .medium)
    let bigVibe = UIImpactFeedbackGenerator(style: .heavy)
    
    override func didMove(to view: SKView) {
        
        gravitySystem.collisionDelegate = self
        
        forceTouch = view.traitCollection.forceTouchCapability == .available
        
        self.addChild(gravitySystem)
        
        let planet = Planet(radius: 10)
        gravitySystem.add(planet: planet)
        
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
    
    func collisionDetected(impactMass: CGFloat) {
        
        switch impactMass {
        case 0...100:
            smallVibe.impactOccurred()
            
        case 100...150:
            medVibe.impactOccurred()
            
        default:
            bigVibe.impactOccurred()
        }
        
        print(impactMass)
        smallVibe.impactOccurred()
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        gravitySystem.update()
        
        if let camera = camera, let largest = gravitySystem.largestMass, centerOnLargestMass {
            camera.position = largest.position
        }
        
        // if we're mid new planet placement, update the indication of the new planet size
        if let placerLine = placerLine, !forceTouch {
            let durationOfPress = Date.timeIntervalSinceReferenceDate - timeAtTouchDown
            placerLine.lineWidth = CGFloat(durationOfPress)
        }
    }

    
    // MARK:- Touch Handling
    var timeAtTouchDown = Date.timeIntervalSinceReferenceDate
    var locationOfTouchDown = CGPoint()
    var placerLine : SKShapeNode?
    
    @objc func handleNewPlanetPan(gesture: ForcePanGestureRecognizer) {
        
        var touchLocation = gesture.location(in: gesture.view)
        touchLocation = self.convertPoint(fromView: touchLocation)
        
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
            
            if forceTouch {
                placerLine!.lineWidth = gesture.maxForce
            }
            
        case .ended, .failed:
            let durationOfPress = Date.timeIntervalSinceReferenceDate - timeAtTouchDown
            let radiusOfNewPlanet = forceTouch ? (gesture.maxForce * 5.0) : CGFloat(durationOfPress * 5.0)
            
            let planet = Planet(radius:radiusOfNewPlanet)
            planet.node.position = touchLocation
            
            gravitySystem.add(planet: planet)
            
            let panVector = sub(a: locationOfTouchDown, b: touchLocation)
            
            planet.node.physicsBody?.velocity = CGVector(dx:panVector.x,dy:panVector.y)
            
            placerLine?.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3),SKAction.removeFromParent()]))
            
        default: break
        }
        
    }
    
    var cameraScaleAtStartOfPinch = CGFloat(1.0)
    
    @objc func handlePinch(gesture:UIPinchGestureRecognizer){
        switch gesture.state {
        case .began:
            cameraScaleAtStartOfPinch = self.camera!.xScale
        default:
            self.camera!.setScale((1.0 / gesture.scale) * cameraScaleAtStartOfPinch)
        }
    }
    
    @objc func handlePan(gesture:UIPanGestureRecognizer){
        
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
