Shader "GeoSpark/D3PlotLines"
{
    Properties
    {
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline"
        }

        Pass
        {
            Offset 0, -1
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct vertex_attributes {
                uint id : SV_VertexID;
            };

            struct vertex_out {
                float4 positionHCS : SV_POSITION;
                float4 colour : COLOR0;
            };

            struct vertex_in {
                float3 p;
                int materialIndex;
            };

            StructuredBuffer<vertex_in> verts3d;
            float4x4 xform;
            float4 line_colour;

            vertex_out vert(vertex_attributes IN) {
                vertex_out OUT;
                float4 v = mul(xform, float4(verts3d[IN.id].p, 1.0));
                OUT.positionHCS = TransformObjectToHClip(v.xyz);
                OUT.colour = line_colour;
                return OUT;
            }

            half4 frag(vertex_out v) : SV_Target {
                return v.colour;
            }
            ENDHLSL
        }
    }
}