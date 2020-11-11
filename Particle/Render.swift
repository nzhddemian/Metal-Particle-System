

import MetalKit

public class Render: NSObject, MTKViewDelegate {
    
    public var device: MTLDevice!
    var queue: MTLCommandQueue!
    var firstState: MTLComputePipelineState!
    var secondState: MTLComputePipelineState!
    var particleBuffer: MTLBuffer!
    let particleCount = 1000
    var particles = [Particle]()
   
    
   struct Particle {
        var position: float2
        var velocity: float2
        var scale:Float
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
    var width: UInt32{return UInt32(UIScreen.main.nativeBounds.width)}
    var height: UInt32{return UInt32(UIScreen.main.nativeBounds.height)}
    func initializeBuffers() {
          for _ in 0 ..< particleCount {
                 let particle = Particle(position: float2(Float(arc4random() %  width), Float(arc4random() % height)), velocity: float2((Float(arc4random() %  10) - 5) / 10, (Float(arc4random() %  10) - 5) / 10), scale: Float(UIScreen.main.nativeScale))
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
    var t = Float(0)
    public func draw(in view: MTKView) {
        t+=0.01
      
       view.drawableSize = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
        if let drawable = view.currentDrawable,
        let commandBuffer = queue.makeCommandBuffer(),
        let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
         // first pass
           
            let tex = drawable.texture
         commandEncoder.setComputePipelineState(firstState)
         commandEncoder.setTexture(drawable.texture, index: 0)
         let w = firstState.threadExecutionWidth
         let h = firstState.maxTotalThreadsPerThreadgroup / w
    
               
            
            let threadGroupCount = MTLSizeMake(16, 16, 1)
            let threadGroups = MTLSizeMake(tex.width/threadGroupCount.width , tex.height/threadGroupCount.height , 1)
            
          commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
       
         commandEncoder.setComputePipelineState(secondState)
         commandEncoder.setTexture(tex, index: 0)
            
         commandEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
//         commandEncoder.setBytes(&scale, length: MemoryLayout<Float>.stride, index: 0)
            let threadGroupCount2 = MTLSizeMake(16, 1, 1)
        let threadsPerGrid = MTLSizeMake(particleCount, 1, 1)
        
         commandEncoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadGroupCount2)
         commandEncoder.endEncoding()
         commandBuffer.present(drawable)
         commandBuffer.commit()
    }
}
}
