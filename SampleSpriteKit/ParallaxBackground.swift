//
//  ParallaxObject.swift
//  SampleSpriteKit
//
//  Created by Zachary Aamold on 2/22/19.
//  Copyright © 2019 Aaron Block. All rights reserved.
//

import UIKit
import SpriteKit

class ParallaxBackground {
    
    public var sprite:SKSpriteNode?
    public var spriteNext:SKSpriteNode?
    private var offset:CGFloat?
    private var offsetNext:CGFloat?
    
    init(spriteName: String, gameScene: SKScene, heightOffset: CGFloat, zPosition: CGFloat) {
        self.sprite = SKSpriteNode(imageNamed: spriteName);
//        self.spriteNext = spriteNext
        sprite?.position = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2 + heightOffset)
        
        spriteNext = sprite?.copy() as? SKSpriteNode
        spriteNext?.position = CGPoint(x: CGFloat((sprite?.position.x)!) + (sprite?.size.width)!, y: (sprite?.position.y)!)
        
        sprite?.zPosition = zPosition
        spriteNext?.zPosition = zPosition
        offset = 0
        offsetNext = 0
    }
    
    func updateCamera(camera: SKCameraNode) {
        sprite?.position.x = camera.position.x + offset!
        sprite?.position.y = camera.position.y
        spriteNext?.position.x = camera.position.x + offsetNext!
        spriteNext?.position.y = camera.position.y
    }
    
    // Move a pair of sprites leftward based on a speed value;
    // when either of the sprites goes off-screen, move it to the
    // right so that it appears to be seamless movement
    // Pulled from: http://radar.oreilly.com/2015/08/parallax-scrolling-for-ios-with-swift-and-sprite-kit.html
    func move(scene: SKScene, speed : Float, deltaTime: TimeInterval) {
        var newPosition = CGPoint.zero

        // For both the sprite and its duplicate:
        for spriteToMove in [self.sprite, self.spriteNext] {

            // Shift the sprite leftward based on the speed
            newPosition = (spriteToMove?.position)!
            newPosition.x -= CGFloat(speed * Float(deltaTime))
            spriteToMove?.position = newPosition
            
            if(spriteToMove == self.sprite) {
                offset! -= CGFloat(speed * Float(deltaTime))
            } else {
                offsetNext! -= CGFloat(speed * Float(deltaTime))
            }

            // If this sprite is now offscreen (i.e., its rightmost edge is
            // farther left than the scene's leftmost edge):
            if (spriteToMove?.frame.maxX)! < scene.frame.minX {

                // Shift it over so that it's now to the immediate right
                // of the other sprite.
                // This means that the two sprites are effectively
                // leap-frogging each other as they both move.
                spriteToMove!.position =
                    CGPoint(x: spriteToMove!.position.x +
                        spriteToMove!.size.width * 2,
                            y: spriteToMove!.position.y)
                
                if(spriteToMove == self.sprite) {
                    offset = 0
                } else {
                    offsetNext = 0
                }
                
            }

        }
    }

}
