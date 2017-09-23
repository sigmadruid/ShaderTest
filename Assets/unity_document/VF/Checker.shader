// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "VF/Checker"
{
	Properties
	{
        _Density("Density", Range(1, 30)) = 10
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

            float _Density;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
			};

			v2f vert (float4 pos : POSITION, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(pos);
                o.uv = uv * _Density;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float2 c = floor(i.uv) / 2;
                fixed4 col = frac(c.x + c.y) * 2;
				return col;
			}
			ENDCG
		}
	}
}
