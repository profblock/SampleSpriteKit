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
    private var mainNode:SKNode?

    // Shape node might be approriate for ball and maybe approriate for other shapes, but
    // too many can impact performance
    private var ball : SKShapeNode?
    private var ball2 : SKShapeNode?
    private var chargeValue:CGFloat!
    private var startPoint:CGPoint?
    private var myCamera:SKCameraNode!
    
    private var leftLine:SKShapeNode?
    private var wallX:CGFloat!
    
    
    func createSpline(startPoint:CGPoint, numberOfPoints:Int)->[CGPoint]{
        let horizMin = 40
        let horizMax = 100
        let vertMin = -2
        let vertMax = 50
        
        var splinePoints = [CGPoint]()
        splinePoints.append(startPoint)
        
        var lastPoint = startPoint
        for _ in 0 ..< numberOfPoints {
            let horizDelta = CGFloat(Int.random(in: horizMin ..< horizMax))
            let vertDelta = CGFloat(Int.random(in: vertMin ..< vertMax))
            lastPoint = CGPoint(x: lastPoint.x + horizDelta, y: lastPoint.y + vertDelta)
            splinePoints.append(lastPoint)
        }
        
        return splinePoints
    }
    
    func createCeilingSpline(floorPoints:[CGPoint])->[CGPoint]{
        let horizMin = -10 // Should be related to the min spacing above.
        let horizMax = 20
        let vertMin = 400
        let vertMax = 500
        
        var splinePoints = [CGPoint]()
        
        let firstPoint = CGPoint(x: floorPoints.first!.x,
                                 y: floorPoints.first!.y + CGFloat(Int.random(in: vertMin ..< vertMax)))
        splinePoints.append(firstPoint)
        
        var count = 1
        while count < floorPoints.count-1{
            let point = CGPoint(x: floorPoints[count].x + CGFloat(Int.random(in: horizMin ..< horizMax)),
                                y: floorPoints[count].y + CGFloat(Int.random(in: vertMin ..< vertMax)))
            splinePoints.append(point)
            count+=1
        }
        
        let lastPoint = CGPoint(x: floorPoints.last!.x,
                                 y: floorPoints.last!.y + CGFloat(Int.random(in: vertMin ..< vertMax)))
        splinePoints.append(lastPoint)
        
        return splinePoints
    }
    
    //didMove is the method that is called when the system is loaded.
    override func didMove(to view: SKView) {
        
        mainNode = SKNode()
        chargeValue = 0.0
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
//        var hexagonPoints = [CGPoint(x: 0, y: -20),
//                             CGPoint(x: -19, y: -6),
//                             CGPoint(x: -12, y: 16),
//                             CGPoint(x: 12, y: 16),
//                             CGPoint(x: 19, y: -6),
//                             CGPoint(x: 0, y: -20)]
        
        self.ball = SKShapeNode(ellipseOf: CGSize(width: w/2.0, height: w/2.0))
        //self.ball = SKShapeNode(points: &hexagonPoints, count: 6)
        self.ball?.position = CGPoint(x: 320, y: 320)
        self.ball?.fillColor = UIColor.red
        //self.ball?.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
        self.ball?.physicsBody = SKPhysicsBody(polygonFrom: self.ball!.path!)
        self.ball?.physicsBody?.usesPreciseCollisionDetection = true
        self.ball?.physicsBody?.friction = 1.0
        self.ball?.strokeColor = UIColor.red
        let gradientShader = SKShader(source: "void main() {" +
            "float normalisedPosition = v_path_distance / u_path_length;" +
            "gl_FragColor = vec4(normalisedPosition, normalisedPosition, 0.0, 0.5);" +
            "}")
        ball?.fillColor = .blue
        ball?.lineWidth = 4
        ball?.strokeShader = gradientShader
        
        
        self.ball2 = SKShapeNode(ellipseOf: CGSize(width: w, height: w))
        self.ball2?.position = CGPoint(x: 200, y: 320)
        self.ball2?.fillColor = UIColor.blue
        self.ball2?.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
        self.ball2?.physicsBody?.usesPreciseCollisionDetection = true
        self.ball2?.physicsBody?.friction = 1.0

        
        // Create the ground node and physics body
//        var splinePoints = [CGPoint(x: 0, y: 500),
//                            CGPoint(x: 100, y: 50),
//                            CGPoint(x: 400, y: 110),
//                            CGPoint(x: 640, y: 20)]
        
        let baseCornerPoint = CGPoint(x: 0, y: 0)
        var splinePoints = createSpline(startPoint: baseCornerPoint, numberOfPoints: 500)
        
        
        let ground = SKShapeNode(splinePoints: &splinePoints,
                                 count: splinePoints.count)
        ground.lineWidth = 5
        ground.physicsBody = SKPhysicsBody(edgeChainFrom: ground.path!)
        ground.physicsBody?.restitution = 0.3
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.friction = 1.0
        
        var ceilingPoints = createCeilingSpline(floorPoints: splinePoints)
        let ceiling = SKShapeNode(splinePoints: &ceilingPoints,
                                 count: ceilingPoints.count)
        ceiling.lineWidth = 5
        ceiling.physicsBody = SKPhysicsBody(edgeChainFrom: ceiling.path!)
        ceiling.physicsBody?.restitution = 0.0
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.friction = 1.0
        ceiling.strokeColor = UIColor.yellow

        
        let upperBoundPoint = CGPoint(x: baseCornerPoint.x, y: baseCornerPoint.y+10000)
        var linePoints = [baseCornerPoint,upperBoundPoint]
        leftLine = SKShapeNode(points: &linePoints, count: linePoints.count)
        wallX = linePoints.first!.x
        
        leftLine?.lineWidth = 5
        leftLine?.physicsBody = SKPhysicsBody(edgeChainFrom: leftLine!.path!)
        leftLine?.physicsBody?.restitution = 0.0
        leftLine?.physicsBody?.isDynamic = false
        leftLine?.physicsBody?.friction = 1.0
        leftLine?.strokeColor = UIColor.red

        
        // Add the two nodes to the scene
        mainNode?.addChild(self.ball!)
        mainNode?.addChild(self.ball2!)
        mainNode?.addChild(ground)
        mainNode?.addChild(ceiling)
        mainNode?.addChild(leftLine!)
        
        
        self.addChild(mainNode!)
        myCamera = SKCameraNode()
        self.camera = myCamera
        self.addChild(myCamera)
        
        //self.addChild(self.ball!)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches started")
            startPoint = touch.location(in: self)
            print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches moved")
            print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let startPoint = self.startPoint{
            print("Touches ENDED")

            let endPoint = touch.location(in: self)
            print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")

            let factor : CGFloat = 1.0
            let charge = CGVector(dx: factor*(startPoint.x - endPoint.x), dy: factor*(startPoint.y - endPoint.y))
            ball?.physicsBody?.applyImpulse(charge)
        }
        
    }
    
    override func didFinishUpdate() {
        let xPos =  ball!.position.x
        let yPos = ball!.position.y
        self.camera?.position = CGPoint(x: xPos, y: yPos)
        
        moveWall()
        
/* self.camera?.xScale = self.camera!.xScale * 2.0
 self.camera?.yScale = self.camera!.yScale * 2.0
 */
    }
    
    func moveWall() {
//        leftLine!.position.x += wallX
        SKAction.move(by: CGVector(dx: 1, dy: 0), duration: 5) // Not sure why neither work
//        print("WE BE MOVIN: \(leftLine!.position.x)")
    }
//    
}
