//
//  Launcher.swift
//  SampleSpriteKit
//
//  Created by Zachary Aamold on 3/19/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

import UIKit
import SpriteKit

class Launcher {
    
    var mainNode : SKNode?
    
    var firstTouch : SKShapeNode?
    var secondTouch : SKShapeNode?
    var mainCircle : SKShapeNode?
    
    var touchLine : SKShapeNode?

    init(mainNode : SKNode?) {
        self.mainNode = mainNode
    }
    
    func create(tap : CGPoint, stamina : CGFloat) {
        
        if(mainCircle != nil) { return }
        
        mainCircle = SKShapeNode(circleOfRadius: stamina)
        mainCircle?.position = tap
        
        firstTouch = SKShapeNode(circleOfRadius: 7)
        firstTouch?.fillColor = .white
        firstTouch?.position = tap
        
        mainNode?.addChild(mainCircle!)
        mainNode?.addChild(firstTouch!)
        
    }
    
    // Repaints just the big circle; called in update()
    func repaint(stamina : CGFloat) {
        if(stamina <= 0) {
            destroy()
            return
        }
        let circlePos : CGPoint = mainCircle!.position
        mainCircle?.removeFromParent()
        mainCircle = SKShapeNode(circleOfRadius: stamina)
        mainCircle?.position = circlePos
        mainNode?.addChild(mainCircle!)
    }
    
    // Repaints the big circle around everything and the second touch
    func repaint(curTap : CGPoint, stamina : CGFloat) {
        // Hardcoded for now; changing radius requires setting up mainCircle with a path
//        mainCircle?.xScale *= 0.9
//        mainCircle?.yScale *= 0.9
        
        repaint(stamina: stamina)
        
        if(secondTouch == nil) {
            secondTouch = SKShapeNode(circleOfRadius: 7)
            secondTouch?.fillColor = .white
            mainNode?.addChild(secondTouch!)
        }
        
        secondTouch?.position = curTap
        drawLine()
        
        

    }
    
    func destroy() {
        mainCircle?.removeFromParent()
        firstTouch?.removeFromParent()
        secondTouch?.removeFromParent()
        touchLine?.removeFromParent()
        mainCircle = nil
        firstTouch = nil
        secondTouch = nil
        touchLine = nil
    }
    
    func drawLine() {
        guard
            let firstTouch = firstTouch,
            let secondTouch = secondTouch else {
            return
        }
        if(touchLine == nil) {
            touchLine = SKShapeNode()
            touchLine?.strokeColor = SKColor.white
            touchLine?.lineWidth = 5
            mainNode?.addChild(touchLine!)
        }
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: firstTouch.position)
        pathToDraw.addLine(to: secondTouch.position)
        touchLine?.path = pathToDraw
        
    }
    
}
