Shader "Custom/DepthScan"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _ScanColor ("Scan Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
        Cull Off
        ZWrite Off
        ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

            float4 _CameraWS;
            float4 _MainTex_TexelSize;

			struct v2f
			{
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_depth : TEXCOORD1;
			};

            sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
            float4 _ScanColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.uv.xy;
                o.uv_depth = v.uv.xy;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
                float linear01Depth = Linear01Depth(depth);

				return linear01Depth;
			}
			ENDCG
		}
	}
}
