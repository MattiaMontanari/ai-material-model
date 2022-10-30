Shader "GeoSpark/D3Plot"
{
    Properties
    {
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        // See: https://github.com/chavaloart/urp-multi-pass
        Pass
        {
            Name "Depth"
            Tags
            {
                "RenderType" = "Opaque"
                "Queue" = "Geometry+1"
                "RenderPipeline" = "UniversalRenderPipeline"
                "LightMode" = "UniversalForward"
            }
            ZWrite On
            ColorMask 0
            Blend One Zero
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct vertex_attributes {
                uint id : SV_VertexID;
            };

            struct vertex_out {
                float4 position : SV_POSITION;
            };

            struct vertex_in {
                float3 pos;
                int material_index;
            };

            uniform float4x4 xform;
            StructuredBuffer<vertex_in> verts3d;

            vertex_out vert(const vertex_attributes IN) {
                vertex_out OUT;
                const float4 pos = mul(xform, float4(verts3d[IN.id].pos, 1.0));
                OUT.position = TransformObjectToHClip(pos.xyz);
                return OUT;
            }

            half4 frag(vertex_out IN) : SV_Target {
                return half4(0.0, 0.0, 0.0, 1.0);
            }
            ENDHLSL
        }

        Pass
        {
            Name "Diffuse"
            Tags
            {
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
                "RenderPipeline" = "UniversalRenderPipeline"
            }
            Blend One OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // We can use these for simple lighting. But we need to set up normals and other stuff first.
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitForwardPass.hlsl"
            
            struct vertex_attributes {
                uint id : SV_VertexID;
            };

            struct vertex_out {
                float4 position : SV_POSITION;
                float4 colour : COLOR0;
            };

            struct geom_out {
                float4 position_hcs : SV_POSITION;
                float4 colour : COLOR0;
                noperspective float3 distance : EDGE_DISTANCE;
            };

            struct vertex_in {
                float3 pos;
                int material_index;
            };

            StructuredBuffer<vertex_in> verts3d;

            uniform float4x4 xform;
            uniform float4 part_colours[3];
            uniform float2 win_scale;
            uniform float4 line_colour;
            uniform float line_width;
            uniform float part_transparency;

            vertex_out vert(const vertex_attributes IN) {
                vertex_out OUT;
                const float4 pos = mul(xform, float4(verts3d[IN.id].pos, 1.0));
                OUT.position = TransformObjectToHClip(pos.xyz);
                OUT.colour = part_colours[verts3d[IN.id].material_index];
                OUT.colour.a = part_transparency;
                return OUT;
            }

            // See: https://strattonbrazil.blogspot.com/2011/09/single-pass-wireframe-rendering_10.html
            // https://strattonbrazil.blogspot.com/2011/09/single-pass-wireframe-rendering_11.html
            // http://developer.download.nvidia.com/whitepapers/2007/SDK10/SolidWireframe.pdf
            [maxvertexcount(3)]
            void geom(triangle vertex_out input[3], inout TriangleStream<geom_out> output_stream) {
                const float2 p0 = win_scale * input[0].position.xy / input[0].position.w;
                const float2 p1 = win_scale * input[1].position.xy / input[1].position.w;
                const float2 p2 = win_scale * input[2].position.xy / input[2].position.w;
                const float2 v0 = p2 - p1;
                const float2 v1 = p2 - p0;
                const float2 v2 = p1 - p0;
                const float area = abs(v1.x * v2.y - v1.y * v2.x);
                geom_out gsout;

                gsout.position_hcs = input[0].position;
                gsout.colour = input[0].colour;
                gsout.distance = float3(area / length(v0), 0.0, 0.0);
                output_stream.Append(gsout);

                gsout.position_hcs = input[1].position;
                gsout.colour = input[1].colour;
                gsout.distance = float3(0.0, area / length(v1), 0.0);
                output_stream.Append(gsout);

                gsout.position_hcs = input[2].position;
                gsout.colour = input[2].colour;
                gsout.distance = float3(0.0, 0.0, area / length(v2));
                output_stream.Append(gsout);
            }

            half4 frag(geom_out v) : SV_Target {
                const float nearest_d = min(min(v.distance[0], v.distance[1]), v.distance[2]);
                // Map the computed distance to the [0,2] range on the border of the line.
                const float dist = clamp((nearest_d - (0.5 * line_width - 1)), 0, 2);
                const float edge_intensity = exp2(-1.0 * dist * dist);
                // float4 edge = float4(line_colour.xyz, edge_intensity);
                // float a = min(edge_intensity, v.colour.a);
                float4 c = (edge_intensity * line_colour) + ((1.0 - edge_intensity) * v.colour);

                return half4(c);
            }
            ENDHLSL
        }
    }
}