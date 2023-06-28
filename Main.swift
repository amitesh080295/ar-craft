import PlaygroundSupport
import SwiftUI
import RealityKit

struct ARViewWrapper: UIViewRepresentable {
    typealias UIViewType = ARView
    
    func makeUIView(context: UIViewRepresentableContext<ARViewWrapper>) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        arView.enablePlacement()
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: UIViewRepresentableContext<ARViewWrapper>) {
    
    }
}

extension ARView {
    func enablePlacement() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        let results = self.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
                
        if let firstResult = results.first {
            let mesh = MeshResource.generateBox(size: 0.2)
            let material = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: true)
            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            let anchorEntity = AnchorEntity(world: firstResult.worldTransform)
            anchorEntity.addChild(modelEntity)
                            
            self.scene.addAnchor(anchorEntity)
        } else {
            print("No surface detected - Move around device")
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            ARViewWrapper()
            Text("Hello World")
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())