//
//  ViewController.swift
//  ARkit-HitGame
//
//  Created by Dhruvil Patel on 7/5/18.
//  Copyright © 2018 Dhruvil. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController {

    @IBOutlet weak var SceneView: ARSCNView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var play: UIButton!
    
    
    var timer = Each(1).seconds
    var countdown = 10
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.SceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.SceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }

    @IBAction func playBtn(_ sender: Any) {
        self.setTimer()
        self.addNode()
        self.play.isEnabled = false
    }
    
    @IBAction func resetBtn(_ sender: Any) {
        self.timer.stop()
        self.restoreTimer()
        self.play.isEnabled = true
        SceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.SceneView.session.pause()
        self.SceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "model.scnassets/Jellyfish.scn")
        let jellyfishNode = jellyFishScene?.rootNode.childNode(withName: "Jellyfish", recursively: true)
        jellyfishNode?.position = SCNVector3(randomNumber(firstNum: -1, secoundNum: 1),randomNumber(firstNum: -0.5, secoundNum: 0.5), randomNumber(firstNum: -1, secoundNum: 1))
        self.SceneView.scene.rootNode.addChildNode(jellyfishNode!)
    }
    
    @objc func handleTap (sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("Didn't touch anything")
        } else {
            if countdown > 0{
            let result = hitTest.first!
            let node = result.node
            if node.animationKeys.isEmpty {
                SCNTransaction.begin()
                self.animateNode(node: node)
                SCNTransaction.completionBlock = {
                    node.removeFromParentNode()
                    self.addNode()
                    self.restoreTimer()
                }
                SCNTransaction.commit()
                }
            }
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2, node.presentation.position.y - 0.2, node.presentation.position.z - 0.2)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position ")
    }
    
    func randomNumber(firstNum: CGFloat, secoundNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secoundNum) + min(firstNum, secoundNum)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLbl.text = String(self.countdown)
            if self.countdown == 0 {
                self.timerLbl.text = "you lose"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        self.countdown = 10
        self.timerLbl.text = String(self.countdown)
        
    }
}



