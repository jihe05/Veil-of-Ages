﻿Shader "Custom/Water"
{
    Properties
    {
        _MainTex("Albedo (RGB)", Color) = (0, 0, 0, 1) // Color property for Albedo
        _Metallic("Metallic", Range(0, 1)) = 0.0
        _Glossiness("Smoothness", Range(0, 1)) = 0.5
        _BumpMap("Normal Map", 2D) = "bump" {}
        _OcclusionMap("Occlusion", 2D) = "white" {}
        _DetailMask("Detail Mask", 2D) = "black" {}
        _EmissionColor("Emission", Color) = (0, 0, 0)
        _WaveSpeed("Wave Speed", Float) = 0.1
        _WaveHeight("Wave Height", Float) = 0.1
        _BumpMap2("Water Bump2", 2D) = "bump" {}
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Overlay" } // Set render type to Transparent
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard alpha:fade vertex:vert
        #pragma target 3.0

        // Texture Samplers
        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _OcclusionMap;
        sampler2D _DetailMask;
        sampler2D _BumpMap2;

        // Material Properties
        float _Glossiness;
        float _Metallic;
        float _WaveSpeed;
        float _WaveHeight;
        float3 _EmissionColor;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_OcclusionMap;
            float2 uv_DetailMask;
            float2 uv_BumpMap2;
            float3 worldPos;  // World coordinates
            float3 viewDir;   // View direction
            float4 screenPos;
        };

        // Vertex function for wave effect
        void vert(inout appdata_full v)
        {
            v.vertex.y += sin(v.texcoord.x * 3.0 + _Time.y * _WaveSpeed) * _WaveHeight;
        }

        // Surface shader function
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Apply Albedo color
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;

            // Apply Normal Map
            if (tex2D(_BumpMap, IN.uv_BumpMap).r != 1.0)
                o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

            // Apply Metallic and Smoothness
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;

            // Apply Occlusion Map
            if (tex2D(_OcclusionMap, IN.uv_OcclusionMap).r != 1.0)
                o.Occlusion = tex2D(_OcclusionMap, IN.uv_OcclusionMap).r;

            // Apply Detail Mask
            if (tex2D(_DetailMask, IN.uv_DetailMask).r != 0.0)
                o.Albedo *= tex2D(_DetailMask, IN.uv_DetailMask).r;

            // Calculate second Normal (for additional bump mapping)
            float3 fNormal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + float2(_Time.y * 0.07, 0.0f)));
            float3 fNormal2 = UnpackNormal(tex2D(_BumpMap2, IN.uv_BumpMap2 - float2(_Time.y * 0.05, 0.0f)));
            o.Normal = normalize((fNormal1 + fNormal2) / 2);

            // Set Emission Color
            o.Emission = _EmissionColor;

            // Apply transparency based on view direction and normal (rim lighting effect)
            float fRim = dot(IN.viewDir, o.Normal);
            o.Alpha = saturate(pow(1 - fRim, 3));
        }
        ENDCG
    }

    FallBack "Diffuse"
}
