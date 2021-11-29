Shader "Custom/3DSmoothPixelShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

            CGPROGRAM
            // Physically based Standard lighting model, and enable shadows on all light types
            #pragma surface surf Standard fullforwardshadows
            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 3.0

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float4 texturePointSmooth(sampler2D tex, float2 uvs)
            {
                float2 size;
                size.x = _MainTex_TexelSize.z;
                size.y = _MainTex_TexelSize.w;

                float2 pixel = float2(1.0, 1.0) / size;

                uvs -= pixel * float2(0.5, 0.5);
                float2 uv_pixels = uvs * size;
                float2 delta_pixel = frac(uv_pixels) - float2(0.5, 0.5);

                float2 ddxy = fwidth(uv_pixels);
                float2 mip = log2(ddxy) - 0.5;

                float2 clampedUV = uvs + (clamp(delta_pixel / ddxy, 0.0, 1.0) - delta_pixel) * pixel;

                float scale = exp2(min(mip.x, mip.y));

                return tex2Dlod(tex, float4(clampedUV, 0, min(mip.x, mip.y)));
            }

           

            struct Input
            {
                float2 uv_MainTex;
            };

            struct FragOut
            {
                float4 color : COLOR;
            };

            half _Glossiness;
            half _Metallic;
            fixed4 _Color;

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)


            void surf(Input IN, inout SurfaceOutputStandard o)
            {

                fixed4 c = texturePointSmooth(_MainTex, IN.uv_MainTex);
                // Albedo comes from a texture tinted by color
               // fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

                o.Albedo = c.rgb;
                // Metallic and smoothness come from slider variables
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Alpha = c.a;
            }

            ENDCG
        
    }
    FallBack "Diffuse"
}
