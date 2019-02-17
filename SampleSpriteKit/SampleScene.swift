//
//  SampleScene.swift
//  SampleSpriteKit
//
//  Created by Aaron Block on 2/4/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

import UIKit
import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Ball   : UInt32 = 0b1       // 1
    static let Ground: UInt32 = 0b10      // 2
    static let Coin: UInt32 = 0b100      // 4
    static let Wall: UInt32 = 0b1000      // 8
}




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
class SampleScene: SKScene, SKPhysicsContactDelegate {
    private var mainNode:SKNode?

    // Shape node might be approriate for ball and maybe approriate for other shapes, but
    // too many can impact performance
    private var ball : SKShapeNode?
    private var ball2 : SKShapeNode?
    private var coin: SKShapeNode?
    
    private var previousPosition: CGPoint!
    
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
        
        physicsWorld.contactDelegate = self
        
        
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
        previousPosition = ball!.position
        
        
        self.ball2 = SKShapeNode(ellipseOf: CGSize(width: w, height: w))
        self.ball2?.position = CGPoint(x: 200, y: 320)
        self.ball2?.fillColor = UIColor.blue
        self.ball2?.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
        self.ball2?.physicsBody?.usesPreciseCollisionDetection = true
        self.ball2?.physicsBody?.friction = 1.0

        self.coin = SKShapeNode(ellipseOf: CGSize(width: w/2, height: 3*w))
        self.coin?.position = CGPoint(x: 400, y: 320)
        self.coin?.fillColor = UIColor.yellow
        self.coin?.physicsBody = SKPhysicsBody(edgeLoopFrom: self.coin!.path!)
        self.coin?.physicsBody?.usesPreciseCollisionDetection = true
        self.coin?.physicsBody?.isDynamic = false
        
        coin?.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        coin?.physicsBody?.categoryBitMask = PhysicsCategory.Coin
        coin?.physicsBody?.collisionBitMask = PhysicsCategory.None
        
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
        
        ball?.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        ball?.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball?.physicsBody?.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Ground | PhysicsCategory.Wall
        
        ball2?.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        ball2?.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball2?.physicsBody?.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Ground | PhysicsCategory.Wall
        
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        
        var ceilingPoints = createCeilingSpline(floorPoints: splinePoints)
        let ceiling = SKShapeNode(splinePoints: &ceilingPoints,
                                 count: ceilingPoints.count)
        ceiling.lineWidth = 5
        ceiling.physicsBody = SKPhysicsBody(edgeChainFrom: ceiling.path!)
        ceiling.physicsBody?.restitution = 0.0
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.friction = 1.0
        ceiling.strokeColor = UIColor.yellow
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.Ground


        
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
        
        leftLine?.physicsBody?.categoryBitMask = PhysicsCategory.Wall

        
        // Add the two nodes to the scene
        mainNode?.addChild(self.ball!)
        mainNode?.addChild(self.ball2!)
        mainNode?.addChild(self.coin!)
        mainNode?.addChild(ground)
        mainNode?.addChild(ceiling)
        mainNode?.addChild(leftLine!)
        
        
        self.addChild(mainNode!)
        myCamera = SKCameraNode()
        self.camera = myCamera
        self.addChild(myCamera)
        


        
        //self.addChild(self.ball!)
        
        
    }
    
    func centerOnBall() {
        //Trying something here that should smooth out the camera motion
        //move camera using lerp
        //http://www.learn-to-code-london.co.uk/blog/2016/04/smoother-camera-motion-in-spritekit-using-lerp/
        guard ball != nil else {
            return
        }
        //TODO: Update constants with real values
        let currentPosition = ball!.position
        let x = (weightedFactor(previous: previousPosition.x, current: currentPosition.x, currentWeight: 0.03) + 200)
        let y = (weightedFactor(previous: previousPosition.y, current: currentPosition.y, currentWeight: 0.03) + 75)
        previousPosition = currentPosition;
    
        self.camera?.run(SKAction.move(to: CGPoint(x: x, y: y), duration: 0.01))
        
    }

    /* This is allso called a propertial intergral controller (PI)
     * It's a very dumb one because it only works on one data point (the previous).
     * This weights the preivous value some fraction (1-currentWeight) and the current (currentWeight)
     * if weight is less than 0 or greater than 1, then just return current
 */
    func weightedFactor(previous: CGFloat, current:CGFloat, currentWeight:CGFloat)->CGFloat{
        if currentWeight >= 0 && currentWeight <= 1.0 {
            return (1 - currentWeight) * previous + currentWeight * current;
        } else {
             return current
        }
        
    }
    
    
    override func didSimulatePhysics() {
        //print("Physics simulation")
        //        let xPos =  ball!.position.x
        //        let yPos = ball!.position.y
        //        self.camera?.position = CGPoint(x: xPos, y: yPos)

        centerOnBall()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            //print("Touches started")
            // We can adjust the speed using this, BUT it makes it jittery 
            //physicsWorld.speed = 0.0
            startPoint = touch.location(in: self)
            //print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            //print("Touches moved")
            //print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let startPoint = self.startPoint{
            //print("Touches ENDED")
            physicsWorld.speed = 1

            let endPoint = touch.location(in: self)
            //print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")

            let factor : CGFloat = 1.0
            let charge = CGVector(dx: factor*(startPoint.x - endPoint.x), dy: factor*(startPoint.y - endPoint.y))
            ball?.physicsBody?.applyImpulse(charge)
        }
        
    }
    
    override func didFinishUpdate() {
        
        //print("The velocity is \(ball?.physicsBody!.velocity)")
        //Moved update to didSimulatePhysics() Seems a better place to have it

        moveWall()
        
/* self.camera?.xScale = self.camera!.xScale * 2.0
 self.camera?.yScale = self.camera!.yScale * 2.0
 */
    }
    
    func moveWall(){
        leftLine!.position.x += 1
//        SKAction.move(by: CGVector(dx: 1, dy: 0), duration: 5) // Not sure why neither work
//        print("WE BE MOVIN: \(leftLine!.position.x)")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        print("A collision")
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Coin != 0)) {
            print("Contact")
            
            if let ball = firstBody.node as? SKShapeNode, let
                coin = secondBody.node as? SKShapeNode {
                print("A collision between the ball and coin")
                coin.removeFromParent()
//                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
    
//    func didEnd(_ contact: SKPhysicsContact) {
//        print("It ended")
//    }
//
}

