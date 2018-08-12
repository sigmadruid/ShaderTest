Shader "Bloom" 
{
	Properties 
	{
		_MainTex("Main Tex", 2D) = "white"{}
		_Bloom("Bloom", 2D) = "white"{}
		_LuminanceThreshod("Luminance Threshod", Float) = 0.5
		_BlurSize("Blur Size", Float) = 1
	}
	SubShader 
	{
		ZTest Always
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM

			#pragma vertex vertExtractBright
			#pragma fragment fragExtractBright

			ENDCG
		}

		UsePass "Sigma/PostEffect/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"
		UsePass "Sigma/PostEffect/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

		Pass
		{
			CGPROGRAM

			#pragma vertex vertBloom
			#pragma fragment fragBloom

			ENDCG
		}

		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _Bloom;
		float _LuminanceThreshod;
		float _BlurSize;

		struct v2fExtract
		{
			float4 pos : SV_POSITION;
			fixed2 uv : TEXCOORD0;	
		};
		v2fExtract vertExtractBright(appdata_img i)
		{
			v2fExtract o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = i.texcoord;
			return o;
		}
		fixed luminance(fixed4 color)
		{
			return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
		}
		fixed4 fragExtractBright(v2fExtract i) : SV_TARGET
		{
			fixed4 c = tex2D(_MainTex, i.uv);
			fixed val = clamp(luminance(c) - _LuminanceThreshod, 0, 1);
			return c * val;
		}

		struct v2fBloom
		{
			float4 pos : SV_POSITION;
			half4 uv : TEXCOORD;
		};
		v2fBloom vertBloom(appdata_img i)
		{
			v2fBloom o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv.xy = i.texcoord;
			o.uv.zw = i.texcoord;

			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv.w = 1 - o.uv.w;
			#endif 
		}
		fixed4 fragBloom(v2fBloom i) : SV_TARGET
		{
			return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
		}


		ENDCG
	} 
	FallBack Off
}

