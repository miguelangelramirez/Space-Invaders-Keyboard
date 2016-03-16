//
//  GameScene.swift
//  KeyboardShooter
//
//  Created by Steven Thompson on 2015-03-26.
//  Copyright (c) 2015 stevethomp. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let sprite = SKSpriteNode(imageNamed:"Spaceship")
        
        sprite.xScale = 0.5
        sprite.yScale = 0.5
        sprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
//        let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//        
//        sprite.runAction(SKAction.repeatActionForever(action))
        
        self.addChild(sprite)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            if location.x < frame.size.width/2 {
                //left
                
            } else {
                //right
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
