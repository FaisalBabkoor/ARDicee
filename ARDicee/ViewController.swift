//
//  ViewController.swift
//  ARDicee
//
//  Created by Faisal Babkoor on 4/5/20.
//  Copyright © 2020 Faisal Babkoor. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet private var roll: UIBarButtonItem!
    
    var dices = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [.showFeaturePoints]
        // MAKE SPHARE
        //        let sphare = SCNSphere(radius: 0.2)
        //        let material = SCNMaterial()
        //        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        //        sphare.materials = [material]
        //        let node = SCNNode()
        //        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
        //        node.geometry = sphare
        //        sceneView.scene.rootNode.addChildNode(node)
        //
        
        
        //        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        //        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        //            diceNode.position = SCNVector3(0, 0, -0.1)
        //            sceneView.scene.rootNode.addChildNode(diceNode)
        //        }
        //        let person = SCNScene(named: "art.scnassets/D3D-P-BUS-11lo.scn")!
        //        if let personNode = person.rootNode.childNode(withName: "D3D-P-BUS-11lo", recursively: true) {
        //            personNode.position = SCNVector3(0, 0, -0.005)
        //            sceneView.scene.rootNode.addChildNode(personNode)
        //        }
        //        sceneView.automaticallyUpdatesLighting = true
        
        
        //        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //
        //        let material = SCNMaterial()
        //        material.diffuse.contents = UIColor.red
        //        cube.materials = [material]
        //        let node = SCNNode()
        //        node.position = SCNVector3(0, 0.1, -0.5)
        //        node.geometry = cube
        //        sceneView.scene.rootNode.addChildNode(node)
        //        sceneView.automaticallyUpdatesLighting = true
        
        //        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //        // Set the scene to the view
        //        sceneView.scene = scene
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touche = touches.first {
            let postion = touche.location(in: sceneView)
            let results = sceneView.hitTest(postion, types: .existingPlaneUsingExtent)
            if results.isNotEmpty {
                if let hitResult = results.first {
                    addDice(atLocation: hitResult)
                }
            } else {
                print("outside")
            }
        }
    }
    
    
    func addDice(atLocation location: ARHitTestResult) {
        let dice = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = dice.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z
            )
            sceneView.scene.rootNode.addChildNode(diceNode)
            dices.append(diceNode)
            roll(dice: diceNode)
        }
    }
    
    
    func rollAllDices() {
        guard dices.isNotEmpty else { return }
        for dice in dices {
            roll(dice: dice)
        }
    }
    
    
    func roll(dice: SCNNode) {
        let randomx = Float.random(in: 0...4) * (Float.pi / 2)
        let randomz = Float.random(in: 0...4) * (Float.pi / 2)
        
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomx) * 5,
                               y: 0,
                               z: CGFloat(randomz) * 5,
                               duration: 0.5
            )
        )
    }
    
    
    @IBAction private func rollAgain(_ sender: UIBarButtonItem) {
        rollAllDices()
    }
    
    
    @IBAction private func deleteAllDices(_ sender: Any) {
        guard dices.isNotEmpty else { return }
        for dice in dices {
            dice.removeFromParentNode()
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        createPlane(WithPlaneAnchor: planeAnchor, node: node)
    }
    
    
    func createPlane(WithPlaneAnchor planeAnchor: ARPlaneAnchor, node: SCNNode) {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [material]
        planeNode.geometry = plane
        node.addChildNode(planeNode)
    }
    
    
}


extension Array {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
