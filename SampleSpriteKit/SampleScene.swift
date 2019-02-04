//
//  SampleScene.swift
//  SampleSpriteKit
//
//  Created by Aaron Block on 2/4/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

import UIKit
import SpriteKit



/* Todo */
// - 1. Set up basic scene
// - 2. Add ball
// 3. Move ball
// 4. bounce ball on edge
// 5. bounce ball on object
// 7. Bounce ball add gravity
// 8. Detect Touch
// 9. Detect drag
// 10. increase accelleration to ball with drag
// 11. Increase acceleration in direction with drag.

//SKScenes are the "view" equivalant for sprite kit.
class SampleScene: SKScene {

    // Shape node might be approriate for ball and maybe approriate for other shapes, but
    // too many can impact performance
    private var ball : SKShapeNode?
    private var ball2 : SKShapeNode?
    
    //didMove is the method that is called when the system is loaded.
    override func didMove(to view: SKView) {
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.ball = SKShapeNode(ellipseOf: CGSize(width: w, height: w))
        self.ball?.position = CGPoint(x: 320, y: 320)
        self.ball?.fillColor = UIColor.red
        self.ball?.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
        self.ball?.physicsBody?.usesPreciseCollisionDetection = true
        self.ball?.physicsBody?.friction = 0.0

        
        self.ball2 = SKShapeNode(ellipseOf: CGSize(width: w, height: w))
        self.ball2?.position = CGPoint(x: 200, y: 320)
        self.ball2?.fillColor = UIColor.blue
        self.ball2?.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
        self.ball2?.physicsBody?.usesPreciseCollisionDetection = true
        self.ball2?.physicsBody?.friction = 0.0

        
        // Create the ground node and physics body
        var splinePoints = [CGPoint(x: 0, y: 500),
                            CGPoint(x: 100, y: 50),
                            CGPoint(x: 400, y: 110),
                            CGPoint(x: 640, y: 20)]
        
        let ground = SKShapeNode(splinePoints: &splinePoints,
                                 count: splinePoints.count)
        ground.lineWidth = 5
        ground.physicsBody = SKPhysicsBody(edgeChainFrom: ground.path!)
        ground.physicsBody?.restitution = 0.75
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.friction = 0.0
        
        // Add the two nodes to the scene
        self.addChild(self.ball!)
        self.addChild(self.ball2!)
        self.addChild(ground)
        
        
        //self.addChild(self.ball!)
        
        
//
//        let moveUp = SKAction.moveBy(x: 50, y: 200, duration: 2)
//
//        let sequence = SKAction.sequence([moveUp, moveUp.reversed()])
//
//        ball?.run(SKAction.repeatForever(sequence), withKey:  "movingUpRightAndBack")
        
//
//
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
    }
    
}
