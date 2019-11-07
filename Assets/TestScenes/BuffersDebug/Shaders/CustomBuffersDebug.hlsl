#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

void SampleCustomBuffers_float( float2 uv, out float4 color, out float depth )
{
    depth = LinearEyeDepth( SampleCustomDepth(uv), _ZBufferParams );
    color = SampleCustomColor(uv);
}