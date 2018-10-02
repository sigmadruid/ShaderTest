Shader "Sigma/PostEffectHeightFog" 
{
	Properties 
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_FogColor("Fog Color", Color) = (1,1,1,1)
		_FogDensity("Fog Density", Range(0, 1)) = 0.5
		_FogHeightTop("Fog Height Top", Float) = 2
		_FogHeightBottom("Fog Height Bottom", Float) = 1
	}
	SubShader 
	{
		ZTest Always
		ZWrite Off
		Cull Off

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}

		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		sampler2D _CameraDepthTexture;
		fixed4 _FogColor;
		float4x4 _FrustrumCorners;
		float _FogDensity;
		float _FogHeightTop;
		float _FogHeightBottom;

		struct v2f
		{
			float4 pos : SV_POSITION;
			fixed2 uv : TEXCOORD0;
			float4 interpolatedRay : TEXCOORD1;
		};

		v2f vert(appdata_img i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = i.texcoord;

			int index = 0;
			if (i.texcoord.x < 0.5 && i.texcoord.y < 0.5)
			{
				index = 0;
			}
			else if (i.texcoord.x > 0.5 && i.texcoord.y < 0.5)
			{
				index = 1;
			}
			else if (i.texcoord.x > 0.5 && i.texcoord.y > 0.5)
			{
				index = 2;
			}
			else
			{
				index = 3;
			}
			o.interpolatedRay = _FrustrumCorners[index];
			return o;
		}

		fixed4 frag(v2f i) : SV_TARGET
		{
			float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));
			float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

			float fog = (_FogHeightTop - worldPos.y) / (_FogHeightTop - _FogHeightBottom);
			fog = saturate(fog * _FogDensity);

			fixed4 finalColor = tex2D(_MainTex, i.uv);
			finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fog);
			return finalColor;
		}

		ENDCG
	} 
	FallBack Off
}

