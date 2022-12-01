//
//  ViewController.swift
//  DistanceCalculationApp
//
//  Created by Jessi Febria on 22/11/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = .showFeaturePoints
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation: CGPoint = touches.first?.location(in: sceneView),
           let hitTestResult: ARHitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint).first {
            
            let nodePosition: SCNVector3 = SCNVector3(
                hitTestResult.worldTransform.columns.3.x,
                hitTestResult.worldTransform.columns.3.y,
                hitTestResult.worldTransform.columns.3.z)
            
            addPyramidNode(position: nodePosition)
        }
    }
    
    private var nodes: [SCNNode] = []
}

private extension ViewController {
    func addPyramidNode(position: SCNVector3) {
        let pyramidGeometry: SCNPyramid = SCNPyramid(width: 0.03,
                                                     height: 0.03,
                                                     length: 0.03)
        let pyramidNode: SCNNode = createSCNNode(geometry: pyramidGeometry,
                                                 position: position,
                                                 color: .brown)
        nodes.append(pyramidNode)
        
        sceneView.scene.rootNode.addChildNode(pyramidNode)
        
        if nodes.count % 2 == 0 {
            calculateDistance()
        }
    }
    
    func createSCNNode(geometry: SCNGeometry, position: SCNVector3, color: UIColor, scale: SCNVector3? = nil) -> SCNNode {
        let material: SCNMaterial = SCNMaterial()
        material.diffuse.contents = color
        
        geometry.materials = [material]
        
        let node: SCNNode = SCNNode(geometry: geometry)
        node.position = position
        
        if let scale = scale {
            node.scale = scale
        }
        
        return node
    }
    
    func calculateDistance() {
        let endNode: SCNNode = nodes[nodes.count - 1]
        let startNode: SCNNode = nodes[nodes.count - 2]
        
        let distance: Float = sqrt(
            pow(endNode.position.x - startNode.position.x, 2) +
            pow(endNode.position.y - startNode.position.y, 2) +
            pow(endNode.position.z - startNode.position.z, 2)
        )
        
        updateDistanceView(distance: distance, endNodePos: endNode.position)
    }
    
    func updateDistanceView(distance: Float, endNodePos: SCNVector3) {
        // add distance text
        let textGeometry = SCNText(string: String(distance), extrusionDepth: 1.0)
        let textNode: SCNNode = createSCNNode(geometry: textGeometry,
                                              position: SCNVector3(endNodePos.x, endNodePos.y + 0.01, endNodePos.z),
                                              color: .black,
                                              scale: SCNVector3(0.005, 0.005, 0.005))
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
