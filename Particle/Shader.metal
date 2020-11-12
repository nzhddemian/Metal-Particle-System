////
////  Shader.metal
////  Particle
////
////  Created by Demian on 06.11.2020.
////  Copyright © 2020 Demian. All rights reserved.
////
//
//#include <metal_stdlib>
//using namespace metal;
//
//struct Particle {
//    float2 center;
//    float radius;
//};
//float distanceToParticle(float2 point, Particle p) {
//    return length(point - p.center) - p.radius;
//}
//kernel void comp(ushort2 gid [[thread_position_in_grid]], texture2d<float, access::write> output [[texture(0)]], constant float &time [[buffer(0)]]){
//    float width = output.get_width();
//      float height = output.get_height();
//      float2 uv = float2(gid) / float2(width, height);
//      float aspect = width / height;
//      uv.x *= aspect;
//    float2 center = float2(aspect / 2, time);
//    float radius = 0.05;
//    
//    float stop = 1 - radius;
//    if (time >= stop) { center.y = stop; }
//    else center.y = time;
//    Particle p = Particle{center, radius};
//    float distance = distanceToParticle(uv, p);
//    float4 color = float4(1, 0.7, 0, 1);
//    if (distance > 0) { color = float4(0.2, 0.5, 0.7, 1); }
//    output.write(float4(color), gid);
//}
//





#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
   // float2 textureCoorinates [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
  //  float2 textureCoorinates;
};

struct Particle {
    float4x4 initial_matrix;
    float4x4 matrix;
    float4 color;
};
float rand(float2 co)
{
    return fract(sin(dot(co.xy ,float2(12.9898,78.236))) * 43758.5453);
}
vertex VertexOut vertex_main(const VertexIn vertex_in [[stage_in]],
                             constant Particle *particles [[buffer(1)]],
                             uint instanceid [[instance_id]], constant float &time [[buffer(2)]]) {
    VertexOut vertex_out;
    Particle particle = particles[instanceid];
   // float2 p = particle.matrix * vertex_in.position;
    vertex_out.position = particle.matrix * vertex_in.position;
  //  vertex_out.position.x+=sin(time)/1;
    float2 uv = vertex_in.position.xy/100.;
    float2 pos = vertex_in.position.xy;
    float2 lightPos = float2(sin(time)*.5,cos(time)*.5);
    pos*= 2;
    pos+=lightPos;
    float light = length(pos);
    vertex_out.color.rgb = float3(light);
   //  VertexOut.textureCoorinates = vertexData.textureCoorinates.xy;
    return vertex_out;
}

fragment float4 fragment_main(VertexOut vertex_in [[stage_in]], constant float &time [[buffer(2)]]) {
    
    float2 uv = vertex_in.position.xy;
    //uv-=550.5;
    float4 col = rand(uv*time);//float4(smoothstep(0.5,1.0,length(uv/300.)));
    return vertex_in.color*col*2.;
}
