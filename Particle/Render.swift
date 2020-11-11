

import MetalKit

public class Render: NSObject, MTKViewDelegate {
    
    public var device: MTLDevice!
    var queue: MTLCommandQueue!
    var firstState: MTLComputePipelineState!
    var secondState: MTLComputePipelineState!
    var particleBuffer: MTLBuffer!
    let particleCount = 1000
    var particles = [Particle]()
    let side = 1200
    
   struct Particle {
        var position: float2
        var velocity: float2
    }
    
    init(_ mtlView:MTKView ) {

        self.device = MTLCreateSystemDefaultDevice()
        queue = device.makeCommandQueue()
        super.init()
        mtlView.device = self.device
        mtlView.delegate = self
        mtlView.framebufferOnly = false
        
        initializeMetal()
       initializeBuffers()
    }
    
    func initializeBuffers() {
          for _ in 0 ..< particleCount {
                 let particle = Particle(position: float2(Float(arc4random() %  UInt32(side)), Float(arc4random() % UInt32(side))), velocity: float2((Float(arc4random() %  10) - 5) / 10, (Float(arc4random() %  10) - 5) / 10))
                 particles.append(particle)
             }
             let size = particles.count * MemoryLayout<Particle>.size
             particleBuffer = device.makeBuffer(bytes: &particles, length: size, options: [])
    }
    
    func initializeMetal() {
        do {
          
            let library = try! device.makeDefaultLibrary()
            guard let firstPass = library!.makeFunction(name: "firstPass") else { return }
            firstState = try device.makeComputePipelineState(function: firstPass)
            guard let secondPass = library!.makeFunction(name: "secondPass") else { return }
            secondState = try device.makeComputePipelineState(function: secondPass)
        } catch let e { print(e) }
    }
    
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {  }
    
    public func draw(in view: MTKView) {
        if let drawable = view.currentDrawable,
        let commandBuffer = queue.makeCommandBuffer(),
        let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
         // first pass
            let tex = drawable.texture
         commandEncoder.setComputePipelineState(firstState)
         commandEncoder.setTexture(drawable.texture, index: 0)
         let w = firstState.threadExecutionWidth
         let h = firstState.maxTotalThreadsPerThreadgroup / w
        // let threadsPerGroup = MTLSizeMake(w, h, 1)
         //var threadsPerGrid = MTLSizeMake(side, side, 1)
            
            
            let threadGroupCount = MTLSizeMake(16, 16, 1)
            let threadGroups = MTLSizeMake(tex.width/threadGroupCount.width , tex.height/threadGroupCount.height , 1)
            
          commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
         //commandEncoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
         // second pass
         commandEncoder.setComputePipelineState(secondState)
         commandEncoder.setTexture(tex, index: 0)
         commandEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
            let threadGroupCount2 = MTLSizeMake(16, 1, 1)
        let threadsPerGrid = MTLSizeMake(particleCount, 1, 1)
         commandEncoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadGroupCount2)
         commandEncoder.endEncoding()
         commandBuffer.present(drawable)
         commandBuffer.commit()
    }
}
}
