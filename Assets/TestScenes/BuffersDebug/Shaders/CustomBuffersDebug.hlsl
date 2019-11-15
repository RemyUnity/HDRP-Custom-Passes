#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

void SampleCustomBuffers_float( float2 uv, out float4 color, out float depth )
{
#if SHADERGRAPH_PREVIEW == 1
    color = float4(0, 0, 0, 1);
    depth = 0;
#else
    depth = LinearEyeDepth( SampleCustomDepth(uv), _ZBufferParams );
    color = SampleCustomColor(uv);
#endif
}