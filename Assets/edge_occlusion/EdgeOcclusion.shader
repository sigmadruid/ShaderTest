Shader "Custom/Edge"
{
	Properties
	{
        _MainTint("Main Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _EdgeTint("Edge Tint", Color) = (1, 1, 1, 1)
        _Multiplier("Multiplier", Range(0.01, 0.5)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

        Pass
        {
            ZTest Greater
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _EdgeTint;
            float _Multiplier;

            struct v2f
            {
                float4 pos : POSITION;
                float3 normal : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _EdgeTint * (1 - dot(i.viewDir,  i.normal) * _Multiplier);
                return col;
            }
            ENDCG
        }

		Pass
		{
            ZTest Less

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			float4 _MainTint;
            sampler2D _MainTex;
			
			v2f_img vert (appdata_base v)
			{
				v2f_img o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.texcoord;
				return o;
			}
			
			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _MainTint;
				return col;
			}
			ENDCG
		}
	}
}
