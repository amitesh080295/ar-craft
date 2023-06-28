import PlaygroundSupport
import SwiftUI
import RealityKit
import ARKit

enum Shape: String, CaseIterable {
    case cube, sphere
}

class ARViewCoordinator: NSObject, ARSessionDelegate {
    var arViewWrapper: ARViewWrapper
    @Binding var selectedShapeIndex: Int
    
    init(arViewWrapper: ARViewWrapper, selectedShapeIndex: Binding<Int>) {
        self.arViewWrapper = arViewWrapper
        self._selectedShapeIndex = selectedShapeIndex
    }
}

struct ARViewWrapper: UIViewRepresentable {
    @Binding var selectedShapeIndex: Int
    
    typealias UIViewType = ARView
    
    func makeCoordinator() -> ARViewCoordinator {
        return ARViewCoordinator(arViewWrapper: self, selectedShapeIndex: $selectedShapeIndex)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ARViewWrapper>) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        arView.enablePlacement()
        arView.session.delegate = context.coordinator
        
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
    
    func createModel(shape: Shape) -> ModelEntity {
        let mesh = shape == .cube ? MeshResource.generateBox(size: 0.2) : MeshResource.generateSphere(radius: 0.1)
        let material = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: true)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        guard let coordinator = self.session.delegate as? ARViewCoordinator else {
            print("Error obtaining coordinator")
            return
        }
        
        let location = recognizer.location(in: self)
        let results = self.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
                
        if let firstResult = results.first {
            let selectedShape = Shape.allCases[coordinator.selectedShapeIndex]
            let modelEntity = createModel(shape: selectedShape)
            let anchorEntity = AnchorEntity(world: firstResult.worldTransform)
            anchorEntity.addChild(modelEntity)
                            
            self.scene.addAnchor(anchorEntity)
        } else {
            print("No surface detected - Move around device")
        }
    }
}

struct ContentView: View {
    
    let objectShapes = Shape.allCases
    @State private var selectedShapeIndex = 0
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            ARViewWrapper(selectedShapeIndex: $selectedShapeIndex)
            
            Picker("Shapes", selection: $selectedShapeIndex) {
                ForEach(0..<objectShapes.count) { index in
                    Text(self.objectShapes[index].rawValue).tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
            .padding(10)
            .background(Color.black.opacity(0.5))
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
