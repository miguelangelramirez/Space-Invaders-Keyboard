//
//  KeyboardScene.swift
//  KeyboardShooter
//
//  Created by Steven Thompson on 2015-03-26.
//  Copyright (c) 2015 stevethomp. All rights reserved.
//

import SpriteKit
import CoreMotion
import GameplayKit

enum ColliderType: UInt32 {
    case Projectile = 1
    case Letter = 2
    case Kill = 4
}

enum ShipMovement {
    case Stop, Left, Right
}

enum ShipExplode {
    case Safe, Explode
}

//TODO: Scale letters as they fall
//TODO: Add star scene to background (emitter or just image?)
//TODO: Add motion control
//TODO: Only accept shot when letter is visible (when collision happens on screen?)
class KeyboardShooterScene: SKScene, SKPhysicsContactDelegate {
    let ship = SKSpriteNode(imageNamed:"Spaceship")
    let alphabetFrequency = ["q": 3, "w": 4, "e": 10, "r": 6, "t": 6, "y": 4, "u": 6, "i": 9, "o": 8, "p": 4, "a": 9, "s":4, "d": 6, "f": 4, "g": 5, "h": 4, "j": 4, "k": 4, "l": 6, "z": 3, "x": 3, "c": 4, "v": 4, "b": 4, "n": 6, "m": 6, "_": 5]
    var alphabet: [String] = []
    
    let shipYPos: CGFloat = 25.0
    var deleteXpos: CGFloat = 0
    var deleteYpos: CGFloat = 0
    var nextXpos: CGFloat = 0
    var nextYpos: CGFloat = 0
    let maxShipVelocity: CGFloat = 350
    let shipAcceleration: CGFloat = 100
    var shipMovementState = ShipMovement.Stop

    var lastSpawnTime: NSTimeInterval = 0.0
    var lastUpdateTime: NSTimeInterval = 0.0
    
    var shipExplodeState = ShipExplode.Safe
    let timeToExplode: NSTimeInterval = 2.0
    var lastExplodeTime: NSTimeInterval = 0.0
//    var lastUpdateTime: NSTimeInterval = 0.0
    
    weak var weakParent: KeyboardViewController?

    override func didMoveToView(view: SKView) {
//        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.075)
        physicsWorld.contactDelegate = self
        
        deleteXpos = self.frame.width - 20
        deleteYpos = self.frame.height - 20
        nextXpos = 20
        nextYpos = self.frame.height - 20

        for (letter, value) in alphabetFrequency {
            for var i = 0 ; i < value; i++ {
                alphabet.append(letter)
            }
        }
        
        ship.xScale = 0.11
        ship.yScale = 0.11
        ship.position = CGPoint(x: view.frame.size.width/2, y: shipYPos)
        ship.zPosition = 100.0
        
        let shipY = SKConstraint.positionY(SKRange(constantValue: shipYPos))
        let shipX = SKConstraint.positionX(SKRange(lowerLimit: 0 + ship.frame.size.width/2, upperLimit: self.frame.width - ship.size.width/2))
        ship.constraints = [shipY, shipX]

        ship.physicsBody = SKPhysicsBody(texture: ship.texture!, size: ship.frame.size)
        ship.physicsBody?.collisionBitMask = 0
        ship.physicsBody?.contactTestBitMask = 0
        ship.physicsBody?.categoryBitMask = 0
        self.addChild(ship)
        
        let exhaustEmitter = SKEmitterNode(fileNamed: "ExhaustEmitter.sks")
        exhaustEmitter!.position = CGPoint(x: 0, y: -170)
        exhaustEmitter!.targetNode = self.scene
        exhaustEmitter!.xScale = 5.0
        exhaustEmitter!.yScale = 5.0
        ship.addChild(exhaustEmitter!)
        
        let deleteNode = SKLabelNode(text: "␡")
        deleteNode.fontColor = UIColor.whiteColor()
        deleteNode.position = CGPoint(x: deleteXpos, y: deleteYpos)
        deleteNode.physicsBody = SKPhysicsBody(rectangleOfSize: deleteNode.frame.size)
        deleteNode.physicsBody?.categoryBitMask = ColliderType.Letter.rawValue
        deleteNode.physicsBody?.contactTestBitMask = ColliderType.Projectile.rawValue
        deleteNode.physicsBody?.collisionBitMask = 0
        deleteNode.physicsBody?.affectedByGravity = false
        
//        let deletePosition = SKConstraint.positionX(SKRange(constantValue: deleteXpos), y: SKRange(constantValue: deleteYpos))
        let deleteZ = SKConstraint.zRotation(SKRange(constantValue: 0))
        deleteNode.constraints = [deleteZ]
        self.addChild(deleteNode)
        
        let nextKeyboardNode = SKLabelNode(text: "⌨")
        nextKeyboardNode.fontColor = UIColor.whiteColor()
        nextKeyboardNode.fontSize = 20.0
        nextKeyboardNode.position = CGPoint(x: nextXpos, y: nextYpos)
        nextKeyboardNode.physicsBody = SKPhysicsBody(rectangleOfSize: nextKeyboardNode.frame.size)
        nextKeyboardNode.physicsBody?.categoryBitMask = ColliderType.Letter.rawValue
        nextKeyboardNode.physicsBody?.contactTestBitMask = ColliderType.Projectile.rawValue
        nextKeyboardNode.physicsBody?.collisionBitMask = 0
        nextKeyboardNode.physicsBody?.affectedByGravity = false
        
//        let nextKeyboardPosition = SKConstraint.positionX(SKRange(constantValue: nextXpos), y: SKRange(constantValue: nextYpos))
        let nextkeyboardZ = SKConstraint.zRotation(SKRange(constantValue: 0))
        nextKeyboardNode.constraints = [nextkeyboardZ]
        self.addChild(nextKeyboardNode)
        
//        let killVolume = SKShapeNode(rect: CGRect(x: -10, y: 0 - 40, width: self.frame.width + 20, height: 40))
//        killVolume.physicsBody = SKPhysicsBody(rectangleOfSize: killVolume.frame.size, center: CGPoint(x: CGRectGetMidX(killVolume.frame), y: CGRectGetMidY(killVolume.frame)))
//        killVolume.physicsBody?.categoryBitMask = ColliderType.Kill.rawValue
//        killVolume.physicsBody?.contactTestBitMask = ColliderType.Letter.rawValue
//        killVolume.physicsBody?.collisionBitMask = 0
//        killVolume.physicsBody?.affectedByGravity = false
//        self.addChild(killVolume)
        
//        let killPosition = SKConstraint.positionX(SKRange(constantValue: killVolume.position.x), y: SKRange(constantValue: killVolume.position.y))
//        killVolume.constraints = [killPosition]

        dropLetter()
        dropLetter()
        dropLetter()
        dropLetter()
        
        startMotionMonitoring()
    }
    
    func fire() {
        let random = arc4random_uniform(3)
        var imageName: String
        switch random {
        case 0:
            imageName = "greenBeam"
        case 1:
            imageName = "redBeam"
        case 2:
            imageName = "purpleBeam"
        default:
            imageName = "greenBeam"
        }
        let projectile = SKSpriteNode(imageNamed: imageName)
        projectile.physicsBody = SKPhysicsBody(rectangleOfSize: projectile.frame.size)
        projectile.physicsBody?.linearDamping = 0.0
        projectile.physicsBody?.angularDamping = 0.0
        projectile.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        projectile.physicsBody?.categoryBitMask = ColliderType.Projectile.rawValue
        projectile.physicsBody?.contactTestBitMask = ColliderType.Letter.rawValue
        projectile.physicsBody?.collisionBitMask = ColliderType.Letter.rawValue
        
        let projectileRotation = SKConstraint.zRotation(SKRange(constantValue: 0))
        projectile.constraints = [projectileRotation]
        
        projectile.position = CGPoint(x: ship.position.x, y: ship.position.y/2)
        projectile.xScale = 0.1
        projectile.yScale = 0.1
        self.addChild(projectile)
    }
    
    func dropLetter() {
        //TODO: Trails
        //TODO: Colours?
        let count = UInt32(alphabet.count)
        let random: Int = Int(arc4random_uniform(count))
        let letter = alphabet[random]
        
        let x = arc4random_uniform(UInt32(self.frame.width))
        
        let letterNode = SKLabelNode(text: letter)
        letterNode.fontColor = UIColor.whiteColor()
        letterNode.position = CGPoint(x: Int(x), y: Int(self.frame.size.height) + 20)
        letterNode.physicsBody = SKPhysicsBody(rectangleOfSize: letterNode.frame.size)
        letterNode.physicsBody?.categoryBitMask = ColliderType.Letter.rawValue
        letterNode.physicsBody?.contactTestBitMask = ColliderType.Projectile.rawValue
        letterNode.physicsBody?.collisionBitMask = ColliderType.Projectile.rawValue
        
        self.addChild(letterNode)
    }
    
    func startMotionMonitoring() {
        let motionManager = CMMotionManager()
        motionManager.gyroUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (motion, error) -> Void in
            let rotation = motion?.attitude.roll
            if rotation > 0 {
                self.shipMovementState = .Right
            } else if rotation < 0 {
                self.shipMovementState = .Left
            } else {
                self.shipMovementState = .Stop
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        var timeSinceLast = currentTime - lastSpawnTime
        lastUpdateTime = currentTime
        if timeSinceLast > 1 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTime = currentTime
        }
        
        lastSpawnTime += timeSinceLast
        
        if lastSpawnTime > 0.35 {
            lastSpawnTime = 0
            dropLetter()
        }
        
        switch shipMovementState {
        case .Left:
            if ship.physicsBody?.velocity.dx > -maxShipVelocity {
                let oldX = ship.physicsBody?.velocity.dx
                if let X = oldX {
                    var newXVelocity: CGFloat = X - shipAcceleration
                    if newXVelocity < -maxShipVelocity {
                        newXVelocity = -maxShipVelocity
                    }
                    ship.physicsBody?.velocity.dx = newXVelocity
                }
            }
            
        case .Right:
            if ship.physicsBody?.velocity.dx < maxShipVelocity {
                let oldX = ship.physicsBody?.velocity.dx
                if let X = oldX {
                    var newXVelocity: CGFloat = X + shipAcceleration
                    if newXVelocity > maxShipVelocity {
                        newXVelocity = maxShipVelocity
                    }
                    ship.physicsBody?.velocity.dx = newXVelocity
                }
            }

        case .Stop:
            ship.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
        
        if shipExplodeState == .Explode {
            var timeSinceLast = currentTime - lastExplodeTime
            if timeSinceLast > 1 {
                timeSinceLast = 1.0 / 60.0
                lastUpdateTime = currentTime
            }
            
            lastExplodeTime += timeSinceLast
            
            if lastExplodeTime > timeToExplode {
                explode()
            }
            
        } else {
            lastExplodeTime = 0.0
        }
    }
    
    func explode() {
        let explosionEmitter = SKEmitterNode(fileNamed: "ExplosionEmitter.sks")
//        explosionEmitter.zPosition = 200.0
        explosionEmitter!.targetNode = self.scene
//        explosionEmitter.xScale = 5.0
//        explosionEmitter.yScale = 5.0
        explosionEmitter!.position = ship.position
        self.addChild(explosionEmitter!)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.weakParent?.enter()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            if ship.containsPoint(location) {
                fire()
                shipExplodeState = .Explode
            } else if location.x < ship.position.x {
                shipMovementState = .Left
            } else {
                shipMovementState = .Right
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        shipMovementState = .Stop
        shipExplodeState = .Safe
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var letterNode: SKLabelNode
        
        if contact.bodyA.categoryBitMask == ColliderType.Letter.rawValue {
            //A is Letter
            contact.bodyB.node?.removeFromParent()
            letterNode = contact.bodyA.node! as! SKLabelNode
            
        } else {
            //B is Letter
            contact.bodyA.node?.removeFromParent()
            letterNode = contact.bodyB.node! as! SKLabelNode

        }
        
        if letterNode.text == "␡" {
            weakParent?.delete()
            
            return
        } else if letterNode.text == "⌨" {
            weakParent?.nextKeyboard()
            
            return
        }
        
        var xPos: Int
        if letterNode.position.x < self.frame.size.width/2 {
            xPos = 0
        } else {
            xPos = Int(self.frame.size.width)
        }
        
        let position = SKAction.moveTo(CGPoint(x: xPos, y: Int(self.frame.size.height)), duration: 1.0)
        let scale = SKAction.scaleBy(2.0, duration: 1.0)
        
        letterNode.runAction(position)
        letterNode.runAction(scale, completion: { () -> Void in
            letterNode.removeFromParent()
        })
        
        if letterNode.text == "_" {
            weakParent!.addLetter(" ")
        } else {
            weakParent!.addLetter(letterNode.text!)
        }
    }
}
