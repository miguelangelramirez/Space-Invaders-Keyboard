//
//  KeyboardViewController.swift
//  ShooterKeyboard
//
//  Created by Steven Thompson on 2015-03-26.
//  Copyright (c) 2015 stevethomp. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class KeyboardViewController: UIInputViewController {
    let portraitHeight:CGFloat = 256.0
    let landscapeHeight:CGFloat = 203.0

    var heightConstraint: NSLayoutConstraint?
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        //TODO: Landscape
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let skView = SKView(frame: view.frame)
        view.addSubview(skView)
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.showsPhysics = false
        skView.showsNodeCount = false
        skView.showsFPS = false
        
        let scene = KeyboardShooterScene()
        scene.size = skView.bounds.size
        scene.scaleMode = .AspectFill
        scene.weakParent = self
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }
    
    func addLetter(letter: String) {
        let proxy = self.textDocumentProxy 
        proxy.insertText(letter)
    }
    
    func delete() {
        let proxy = self.textDocumentProxy 
        proxy.deleteBackward()
    }
    
    func nextKeyboard() {
        advanceToNextInputMode()
    }
    
    func enter() {
        let proxy = self.textDocumentProxy 
        proxy.insertText("\n")
    }

}
