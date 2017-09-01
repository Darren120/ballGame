//
//  GameScene.swift
//  spriteKitFirstGame
//
//  Created by Darren on 8/11/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ball: SKSpriteNode!
    var ballArray = [SKSpriteNode]()
    var boxArray = [SKSpriteNode]()
    var box: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var balls = ["ballGreen", "ballBlue", "ballCyan", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    var ballAmountLabel: SKLabelNode!
    var ballAmount: Int = 5 {
        didSet {
            ballAmountLabel.text = "Ball Left: \(ballAmount)"
        }
    }
    
    
    var score: Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }

    var editingLabel: SKLabelNode!
    
    var editMode: Bool = false {
        didSet{
            if editMode == true{
                editingLabel.text = "Done"
            } else {
                editingLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        //SKSpriteNode creates an object you want to add. You can get the object by either creating one or picking a picture
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        // zPosition means at what layer should this object be, -1 means the very last layer since it is the background.
        background.zPosition = -1
        // blend mode is the alpha(coloration) .replace is usally the okay way to go
        background.blendMode = .replace
        addChild(background)
        // makes an edge around the canvas so the boxes don't fall through.
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        // normally swift takes care of the contactDelegate but we want to do it manually so we set the delegate to ourself whenever a contact occurs
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlots(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlots(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlots(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlots(at: CGPoint(x: 896, y: 0), isGood: false)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editingLabel = SKLabelNode(fontNamed: "Chalkduster")
        editingLabel.text = "Edit"
        editingLabel.horizontalAlignmentMode = .left
        editingLabel.position = CGPoint(x: 128, y: 700)
        addChild(editingLabel)
        
        ballAmountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballAmountLabel.text = "Ball left: 5"
        ballAmountLabel.horizontalAlignmentMode = .left
        ballAmountLabel.position = CGPoint(x: 128, y: 400)
        addChild(ballAmountLabel)
        
        let line = SKSpriteNode(color: UIColor.brown, size: CGSize(width: 1024, height: 5))
        line.position = CGPoint(x:512, y: 150)
        addChild(line)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let object = nodes(at: location)
            // when the user taps the editing label and taps somehwere else it will re-rerun the whole function. each time the user taps it re-runs..
            if object.contains(editingLabel){
                // the ! sign means flip the bool value so our property observer can know that it has been changed
                editMode = !editMode
                
            } else {
                if editMode == true {
                    for node in object {
                        if node.name == "box" {
                        node.removeFromParent()
                            return
                        } else {
                            let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(),height: 16)
                            box = SKSpriteNode(color: RandomColor(), size: size)
                            box.position = location
                            box.zRotation = RandomCGFloat(min: 0, max: 3)
                            box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                            box.physicsBody?.isDynamic = false
                            box.name = "box"
                            box.physicsBody!.contactTestBitMask = box.physicsBody!.collisionBitMask
                            addChild(box)
                            boxArray.append(box)
                            
                        }
                    
                    }
                 
                    
                } else {
                    if location.y < 150 {
                        return
                    }
                    var number = RandomInt(min: 0, max: 6)
                    ball = SKSpriteNode(imageNamed: balls[number])
                    ball.name = "ball"
                    // adds gravity to the object allowing it to fall (basically adding physics)
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0 )
                    //collisionBitMask is basically saying "which nodes should I bump into" and is default set to everything while contactTestBitMask is a collection of contacts the node has bumped into and by setting them equal to each other we can get the contact filled.
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    // scale from 0.0 - 1.0 which determines the bouncness
                    ball.physicsBody?.restitution = 0.4
                  
                    ball.position = location
                    addChild(ball)
                    ballArray.append(ball)

                }
                
            }
            
            
            
        }
        
    }
    
    func makeBouncer(at position: CGPoint){
        
        let bouncer = SKSpriteNode(imageNamed: "bouncer.png")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
       
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
        
        
    }
    
    func makeSlots(at position: CGPoint, isGood: Bool){
        var slotBase: SKSpriteNode
        var glowBase: SKSpriteNode
        
        if isGood == true {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood.png")
            glowBase = SKSpriteNode(imageNamed: "slotGlowGood.png")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad.png")
            glowBase = SKSpriteNode(imageNamed: "slotGlowBad.png")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        glowBase.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        // isDynamic means it will not move when it is hit
        slotBase.physicsBody?.isDynamic = false
        
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        glowBase.run(spinForever)
        
        addChild(slotBase)
        addChild(glowBase)
        
        
    }
    
    func destroy (object: SKNode){
        
        if let effect = SKEmitterNode(fileNamed: "FireParticles.sks"){
            effect.position = object.position
            addChild(effect)
        }
        object.removeFromParent()
    }
    
    func collisionBetween(ball: SKNode, object: SKNode){
        if object.name == "good" {
            destroy(object: ball)
            score += 1
            ballAmount += 1
            
        } else if object.name == "bad" {
            destroy(object: ball)
            score -= 1
            ballAmount -= 1
        } else if object.name == "box" {
            destroy(object: object)
        }
        
        if ballAmount < 1 {
            let ac = UIAlertController(title: "Game Over! All balls used!", message: "Your score was \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Restart", style: .default) { [unowned self]
                (UIAlertAction) in
                if self.box != nil {
                    for boxes in self.boxArray{
                        boxes.removeFromParent()
                    }
                }
                if self.ball != nil {
                    for ballss in self.ballArray {
                        ballss.removeFromParent()
                    }
                }
                self.score = 0
                self.scoreLabel.text = "Score: 0"
                self.ballAmount = 5
                self.ballAmountLabel.text = "Balls left: 5"
                
            })
            self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)

            
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // checks if the contacting stuff is named ball if it is, then run the following code:
        if contact.bodyA.node?.name == "ball"{
            // when we are sure the ball IS named "ball" we then use the collisionBetween method to check if the object is either named "good" or "bad". We set the name for each already to identify them.
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name  == "ball"{
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
        
    }
    
    
    
    

}
