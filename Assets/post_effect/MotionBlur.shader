Shader "MotionBlur" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurAmount("Blur Amount", Float) = 1.0
	}
	SubShader 
	{
		ZTest Always
		ZWrite Off
		Cull Off

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragRGB

			ENDCG
		}

		Pass
		{
			Blend One Zero
			ColorMask A

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragA

			ENDCG
		}

		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		fixed _BlurAmount;

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD;
		};

		v2f vert(appdata_img i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = i.texcoord;
			return o;
		}

		fixed4 fragRGB(v2f i) : SV_TARGET
		{
			return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
		}

		fixed4 fragA(v2f i) : SV_TARGET
		{
			return tex2D(_MainTex, i.uv);
		}

		ENDCG
	} 
	FallBack Off
}

