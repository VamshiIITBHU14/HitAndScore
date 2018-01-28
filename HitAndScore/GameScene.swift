//
//  GameScene.swift
//  HitAndScore
//
//  Created by Vamshi Krishna on 26/01/18.
//  Copyright © 2018 Vamshi Krishna. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var coinMan : SKSpriteNode?
    var coinTimer : Timer?
    var bombTimer:Timer?
    var ceil : SKSpriteNode?
    var yourScoreLabel : SKLabelNode?
    var finalScoreLabel : SKLabelNode?
    var scoreLabel : SKLabelNode?
    
    let coinManCategory : UInt32 = 0x1 << 1
    let coinCategory : UInt32 = 0x1 << 2
    let bombCategory : UInt32 = 0x1 << 3
    let groundAndCeilCategory : UInt32 = 0x1 << 4
    
    var score = 0
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        coinMan?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        coinMan?.physicsBody?.collisionBitMask = groundAndCeilCategory
        var coinManRun : [SKTexture] = []
        for number in 1...5 {
            coinManRun.append(SKTexture(imageNamed: "frame-\(number)"))
        }
        coinMan?.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.09)))
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.collisionBitMask = coinManCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
       startTimers()
        createGrass()
    }
    
    func createGrass() {
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width / sizingGrass.size.width) + 1
        for number in 0...numberOfGrass {
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = groundAndCeilCategory
            grass.physicsBody?.collisionBitMask = coinManCategory
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.isDynamic = false
            addChild(grass)
            
            let grassX = -size.width / 2 + grass.size.width / 2 + grass.size.width * CGFloat(number)
            grass.position = CGPoint(x: grassX, y: -size.height / 2 + grass.size.height / 2 - 18)
            let speed = 100.0
            let firstMoveLeft = SKAction.moveBy(x: -grass.size.width - grass.size.width * CGFloat(number), y: 0, duration: TimeInterval(grass.size.width + grass.size.width * CGFloat(number)) / speed)
            
            let resetGrass = SKAction.moveBy(x: size.width + grass.size.width, y: 0, duration: 0)
            let grassFullMove = SKAction.moveBy(x: -size.width - grass.size.width, y: 0, duration: TimeInterval(size.width + grass.size.width) / speed)
            let grassMovingForver = SKAction.repeatForever(SKAction.sequence([grassFullMove,resetGrass]))
            
            grass.run(SKAction.sequence([firstMoveLeft,resetGrass,grassMovingForver]))
        }
    }
    
    func startTimers() {
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createCoin()
        })
        
        bombTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.createBomb()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scene?.isPaused == false {
            coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
        }
        
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)
            
            for node in theNodes {
                if node.name == "play" {
                    score = 0
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    startTimers()
                }
            }
        }
    }
    
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        addChild(coin)
        
        let maxY = size.height / 2 - coin.size.height / 2
        let minY = -size.height / 2 + coin.size.height / 2
        let range = maxY - minY
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        coin.position = CGPoint(x: size.width / 2 + coin.size.width / 2, y: coinY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - coin.size.width, y: 0, duration: 4)
        
        coin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func createBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory 
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        addChild(bomb)
        
        let maxY = size.height / 2 - bomb.size.height / 2
        let minY = -size.height / 2 + bomb.size.height / 2
        let range = maxY - minY
        let bombY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bomb.position = CGPoint(x: size.width / 2 + bomb.size.width / 2, y: bombY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width, y: 0, duration: 4)
        
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == coinCategory {
            contact.bodyA.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        if contact.bodyB.categoryBitMask == coinCategory {
            contact.bodyB.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        
        if contact.bodyA.categoryBitMask == bombCategory {
            contact.bodyA.node?.removeFromParent()
           gameOver()
        }
        
        if contact.bodyB.categoryBitMask == bombCategory {
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
    }
    
    func gameOver() {
        scene?.isPaused = true
        
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        
        yourScoreLabel = SKLabelNode(text: "Your Score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.zPosition = 1
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        }
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.zPosition = 1
        if finalScoreLabel != nil {
            addChild(finalScoreLabel!)
        }
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
    }
    
}
