//
//  ForcePanGestureRecognizer.swift
//  fgmmr
//
//  Created by Michael Behan on 11/11/2016.
//  Copyright © 2016 Michael Behan. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class ForcePanGestureRecognizer : UIPanGestureRecognizer {
    
    private(set) var force = CGFloat(0) {
        didSet {
            if force > maxForce {
                maxForce = force
            }
        }
    }
    private(set) var maxForce = CGFloat(0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        maxForce = CGFloat(0)
        force = touches.first!.force
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        force = touches.first!.force
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        force = touches.first!.force
        super.touchesEnded(touches, with: event)
    }
}
