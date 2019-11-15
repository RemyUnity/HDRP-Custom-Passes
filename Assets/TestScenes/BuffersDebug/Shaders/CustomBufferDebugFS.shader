Shader "FullScreen/CustomBufferDebugFS"
{
    Properties
    {
        _Size( "Size", Range(0.025,0.5) ) = 0.25
    }

    HLSLINCLUDE

    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    // The PositionInputs struct allow you to retrieve a lot of useful information for your fullScreenShader:
    // struct PositionInputs
    // {
    //     float3 positionWS;  // World space position (could be camera-relative)
    //     float2 positionNDC; // Normalized screen coordinates within the viewport    : [0, 1) (with the half-pixel offset)
    //     uint2  positionSS;  // Screen space pixel coordinates                       : [0, NumPixels)
    //     uint2  tileCoord;   // Screen tile coordinates                              : [0, NumTiles)
    //     float  deviceDepth; // Depth from the depth buffer                          : [0, 1] (typically reversed)
    //     float  linearDepth; // View space Z coordinate                              : [Near, Far]
    // };

    // To sample custom buffers, you have access to these functions:
    // But be careful, on most platforms you can't sample to the bound color buffer. It means that you
    // can't use the SampleCustomColor when the pass color buffer is set to custom (and same for camera the buffer).
    // float4 SampleCustomColor(float2 uv);
    // float4 LoadCustomColor(uint2 pixelCoords);
    // float LoadCustomDepth(uint2 pixelCoords);
    // float SampleCustomDepth(float2 uv);

    // There are also a lot of utility function you can use inside Common.hlsl and Color.hlsl,
    // you can check them out in the source code of the core SRP package.

    float _Size;

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        
        float2 uv_color = 0;
        float2 uv_depth = 0;
        
        uv_color = uv_depth = posInput.positionNDC / _Size;
        
        uv_color.y = uv_depth.y -= 1/_Size - 1;
        uv_depth.x -= 1/_Size - 1;

        float3 color = SampleCustomColor(uv_color);
        float bufferDepth = SampleCustomDepth(uv_depth);
        depth = Linear01Depth( bufferDepth, _ZBufferParams );
        
        float3 depth_colorized = 0;
        float depth5 = depth * 5;
        depth_colorized.x = saturate( 2 - depth5 );
        depth_colorized.y = saturate( 2 - abs(depth5-2) );
        depth_colorized.z = saturate( 1.5 - abs(depth5-3.5) );
        
        float fracDepth = frac( LinearEyeDepth(bufferDepth, _ZBufferParams) );
        float l = lerp( 0.48, 0.45, depth );
        float t = lerp( 0.001, 0.01, depth );
        depth_colorized *= smoothstep( l+t, l-t, abs( fracDepth - 0.5 ) );
        depth_colorized *= fracDepth * 0.5 + 0.5;
        
        float alpha_color = 1;
        alpha_color = uv_color.x > 0 & uv_color.x < 1 & uv_color.y > 0 & uv_color.y < 1; 
        
        float alpha_depth = 1;
        alpha_depth = uv_depth.x > 0 & uv_depth.x < 1 & uv_depth.y > 0 & uv_depth.y < 1; 

        return float4( lerp( color, depth_colorized, alpha_depth ) , alpha_color + alpha_depth);
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Custom Pass 0"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
                #pragma fragment FullScreenPass
            ENDHLSL
        }
    }
    Fallback Off
}
