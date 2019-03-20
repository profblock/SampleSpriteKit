//
//  SampleScene.swift
//  SampleSpriteKit
//
//  Created by Aaron Block on 2/4/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

//Testing Change
//No change made
import UIKit
import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Ball   : UInt32 = 0b1       // 1
    static let Ground: UInt32 = 0b10      // 2
    static let Coin: UInt32 = 0b100      // 4
    static let Wall: UInt32 = 0b1000      // 8
    static let Field: UInt32 = 0b10000      // 16
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
    private let normalGravity = CGVector(dx: 0, dy: -9.8)
    private let noGravity = CGVector(dx: 0, dy: 0)
    private var oldSpeed = CGVector.zero

    private var par1:ParallaxBackground?
    private var par2:ParallaxBackground?
//    private var par3:ParallaxBackground?
    
    private var leftScreen: SKShapeNode!
    private var rightScreen: SKShapeNode!
    private var pauseButton: SKShapeNode!
    private var isFlipped = false
    private var isLauncherOnScreen = false;

    // Time of last frame
    private var lastFrameTime : TimeInterval = 0
    
    // Time since last frame
    private var deltaTime : TimeInterval = 0
    
    private var stamina : CGFloat?
    // The max value of stamina that should
    // be allowed to be consumed at any one time
    let maxShot = CGFloat(25.0);
    // The max value of stamina that can
    // ever be held at one time
    let max = CGFloat(100);

    private var launcher : Launcher?
    
    
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
        
        // Initializing stamina at max value
        stamina = max;
        
        par1 = ParallaxBackground(spriteName: "Parallax-Diamonds-1", gameScene: self, heightOffset: 0, zPosition: -1)
        par2 = ParallaxBackground(spriteName: "Parallax-Diamonds-2", gameScene: self, heightOffset: 0, zPosition: -2)
//        par3 = ParallaxBackground(spriteName: "ParallaxBack3", gameScene: self, heightOffset: 100, zPosition: -3)

        mainNode = SKNode()
        launcher = Launcher(mainNode: mainNode)
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
        ball?.physicsBody?.fieldBitMask = PhysicsCategory.Field
        
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
        leftLine?.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        if let par1 = par1 {
            if let sprite = par1.sprite{
                mainNode?.addChild(sprite)
            } else {
                debugPrint("Error: Sprite Doesn't exists")
            }
        } else {
            debugPrint("Error Par1 doesn't exist")
        }
        mainNode?.addChild(par2!.sprite!)
//        mainNode?.addChild(par3!.sprite!)
        
        mainNode?.addChild(par1!.spriteNext!)
        
        mainNode?.addChild(par2!.spriteNext!)
//        mainNode?.addChild(par3!.spriteNext!)

        // Add the two nodes to the scene
        mainNode?.addChild(self.ball!)
//        mainNode?.addChild(self.ball2!) // Removing ball2 for testing "Game Over"
        mainNode?.addChild(self.coin!)
        mainNode?.addChild(ground)
        mainNode?.addChild(ceiling)
        mainNode?.addChild(leftLine!)
        
        
        
        
        
        
        self.addChild(mainNode!)
        myCamera = SKCameraNode()
        self.camera = myCamera
        self.addChild(myCamera)
        
        
        let screenRegionXBound = (self.view?.bounds.maxX)!/2
        let screenRegionYBound = (self.view?.bounds.maxY)!
        leftScreen = SKShapeNode(rect: CGRect(x: 0, y: 0, width: screenRegionXBound-1, height: screenRegionYBound))
        leftScreen.fillColor = .clear
        leftScreen.lineWidth = 0
        leftScreen.position = CGPoint(x: -screenRegionXBound, y: -(screenRegionYBound/2))
        myCamera.addChild(leftScreen)
        
        rightScreen = SKShapeNode(rect: CGRect(x: 0, y: 0, width: screenRegionXBound-1, height: screenRegionYBound))
        rightScreen.fillColor = .clear
        rightScreen.lineWidth = 1
        rightScreen.strokeColor = .purple
        rightScreen.position = CGPoint(x: 1, y: -(screenRegionYBound/2))
        myCamera.addChild(rightScreen)
        
        pauseButton = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 30, height: 30))
        pauseButton.fillColor = .purple
        pauseButton.lineWidth = 0
        pauseButton.position = CGPoint(x: -screenRegionXBound + 20, y: (screenRegionYBound/2) - 40)
        myCamera.addChild(pauseButton)
        
        
        
        let field = SKFieldNode.dragField()
        field.strength = 0.2
        field.categoryBitMask = PhysicsCategory.Field
        self.addChild(field)
        
        //physicsWorld.gravity = CGVector(dx:0, dy: 0);
        
        //let gravityVector = vector_float3(0,-1,0);
        
        //let gravityNode = SKFieldNode.linearGravityField(withVector: gravityVector)
        //let gravityNode = SKFieldNode.radialGravityField()
        //ball?.physicsBody?.charge = 1.0
        //let gravityNode = SKFieldNode.magneticField()
        
        //gravityNode.position = CGPoint(x: 400, y: 320)
        
        //gravityNode.strength = 0.2
        
        //addChild(gravityNode)
        //gravityNode.zRotation = CGFloat.pi // Flip gravity.

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
    
    //This kills Gravity and decreaes the speed to a crall. This SHOULD work for SHORT times as long as you don't collide with anything.
    //TODO: Find better approach or fix this when collisions occur (old velocity will be very wrong in that case
    func lightPause(){
//        self.physicsWorld.speed = 0.0
        self.camera?.run(SKAction.scale(by: 1.2, duration: 5.0))

        guard ball != nil && ball?.physicsBody?.velocity != nil else {
            return
        }
        oldSpeed = ball!.physicsBody!.velocity
        self.physicsWorld.gravity = noGravity
        let slowFactor = CGFloat(0.1)
        let slowSpeed = CGVector(dx: oldSpeed.dx * slowFactor, dy: oldSpeed.dy * slowFactor)
        ball?.physicsBody?.velocity = slowSpeed
    }
    
    func normalSpeed(){
//        self.physicsWorld.speed = 1.0
        self.camera?.run(SKAction.scale(to: 1.0, duration: 1.0))

        self.physicsWorld.gravity = self.normalGravity
        guard ball != nil && ball?.physicsBody?.velocity != nil else {
            return
        }
        //True if BOTH are different directions. If current velicty has flipped, then flip old speed
        var dx = oldSpeed.dx
        var dy = oldSpeed.dy
        if ball!.physicsBody!.velocity.dx * oldSpeed.dx < 0 {

            dx = -dx
        }
        if ball!.physicsBody!.velocity.dy * oldSpeed.dy < 0 {

            dy = -dy
        }
        ball?.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: Figure out how to remember where the touch started
        if let touch = touches.first{
            print("Touches started")
            // We can adjust the speed using this, BUT it makes it jittery 
            //physicsWorld.speed = 0.0
            if(pauseButton.contains(touch.location(in: self.myCamera))){
                print("Pause")
                if(self.isPaused == false){
                    self.isPaused = true
                } else{
                    self.isPaused = false
                }
                
            } else if(leftScreen.contains(touch.location(in: self.myCamera))){
                lightPause()
                startPoint = touch.location(in: self.view)
                launcher?.create(tap: touch.location(in: self), stamina: stamina!)
                isLauncherOnScreen = true;
            } else if(rightScreen.contains(touch.location(in: self.myCamera))){
                if(self.isFlipped == false){
                    self.isFlipped = true
                    rightScreen.strokeColor = .blue
                } else if(self.isFlipped == true){
                    self.isFlipped = false
                    rightScreen.strokeColor = .purple
                }
            }
            
            
            
            //print("x:\(touch.location(in: self).x),y:\(touch.location(in: self).y) ")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            print("Touches moved")
            if(pauseButton.contains(touch.location(in: self.myCamera))){
                print("Pause")
            } else if(leftScreen.contains(touch.location(in: self.myCamera))){
                print("Left")
                print("x:\(touch.location(in: self.view).x),y:\(touch.location(in: self.view).y) ")
                if(isLauncherOnScreen == true){
                    launcher?.repaint(curTap: touch.location(in: self), stamina: stamina!)
                }
            } else if(rightScreen.contains(touch.location(in: self.myCamera))){
                print("Right")
            }
            
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let startPoint = self.startPoint{
            if(pauseButton.contains(touch.location(in: self.myCamera))){
                print("Pause")
            } else if(leftScreen.contains(touch.location(in: self.myCamera))){
                //physicsWorld.speed = 1
                if(isLauncherOnScreen == true){
                    normalSpeed()
                    launcher?.destroy()
                    isLauncherOnScreen = false;
                    
                    let endPoint = touch.location(in: self.view)
                    let dx = startPoint.x - endPoint.x
                    let dy = startPoint.y - endPoint.y
                    let mag = pow(pow(dx, 2.0) + pow(dy, 2.0),0.5)
                    let minVel = CGFloat(20.0) //made this up
                    let maxVel = CGFloat(50.0) //made this up
                    let scalingFactor = CGFloat(0.5) //made this up
                    let uncappedNewMag = scalingFactor*mag + minVel
                    let newVelMag = uncappedNewMag <= maxVel ? uncappedNewMag : maxVel
                    
                    let newDX = dx/mag * newVelMag
                    let newDY = dx/mag * newVelMag
                    
                    
                    
                    let charge = CGVector(dx: newDX, dy: newDY)
                    
                    
                    
                    ball?.physicsBody?.applyImpulse(charge)
                }
            
            } else if(rightScreen.contains(touch.location(in: self.myCamera))){
                if(isLauncherOnScreen == true){
                    normalSpeed()
                    launcher?.destroy()
                    isLauncherOnScreen = false;
                }
            }

            
        }
        
    }
    
    // Helpfully pulled from: http://radar.oreilly.com/2015/08/parallax-scrolling-for-ios-with-swift-and-sprite-kit.html
    override func update(_ currentTime: TimeInterval) {
        // First, update the delta time values:
        
        // If we don't have a last frame time value, this is the first frame,
        // so delta time will be zero.
        if lastFrameTime <= 0 {
            lastFrameTime = currentTime
        }
        
        // Update delta time
        deltaTime = currentTime - lastFrameTime

        // Set last frame time to current time
        lastFrameTime = currentTime

        // TODO: Put back once we figure out how to add video to SKVideoNode
        let speedBoost:Float = 2
        var backSpeed = Float(speedBoost)
        for parallax in [par1, par2] { // , par3

            parallax?.updateCamera(camera: myCamera)
            parallax?.move(scene: self, speed: (backSpeed * Float((ball?.speed)!)), deltaTime: deltaTime)
            backSpeed += speedBoost
        }

    }
    
    override func didFinishUpdate() {
        //Moved update to didSimulatePhysics() Seems a better place to have it
        moveWall()
    }
    
    func moveWall(){
        // Moves the "death wall" forward
        leftLine!.position.x += 1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
//        print("A collision")
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
                // _ here is the ball, but we never reference it
            if let _ = firstBody.node as? SKShapeNode, let
                coin = secondBody.node as? SKShapeNode {
//                print("A collision between the ball and coin")
                //coin.removeFromParent()
                return // No need for more collision checks if we accomplished our goal
                
//                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Wall != 0)) {
//            print("Ball hit wall")
//            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
//    func didEnd(_ contact: SKPhysicsContact) {
//        print("It ended")
//    }
//
}

