Shader "Sigma/PostEffect/EdgeDetectWithDepthNormal" 
{
	Properties 
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_EdgeColor ("Edge Color", Color) = (1,1,1,1)
		_BackgroundColor ("Background Color", Color) = (1,1,1,1)
		_EdgeOnly ("Edge Only", Range(0, 1)) = 0.5
		_SampleDistance ("Sample Distance", Float) = 1
		_SensitiveDepth ("Sensitive Depth", Float) = 1
		_SensitiveNormal ("Sensitive Normal", Float) = 1

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

		sampler2D _CameraDepthNormalsTexture;
		sampler2D _MainTex;
		fixed4 _MainTex_TexelSize;
		fixed4 _EdgeColor;
		fixed4 _BackgroundColor;
		fixed _EdgeOnly;
		float _SampleDistance;
		float _SensitiveDepth;
		float _SensitiveNormal;

		struct v2f
		{
			float4 pos : SV_POSITION;
			fixed2 uv[5] : TEXCOORD0;
		};

		half CheckSame(half4 sampleA, half4 sampleB)
		{
			half2 normalA = sampleA.xy;
			float depthA = DecodeFloatRG(sampleA.zw);
			half2 normalB = sampleB.xy;
			float depthB = DecodeFloatRG(sampleB.zw);

			half2 diffNormal = abs(normalA - normalB) * _SensitiveNormal;
			int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;

			float diffDepth = abs(depthA - depthB) * _SensitiveDepth;
			int isSameDepth = diffDepth < 0.1 * depthA;

			return isSameNormal * isSameDepth ? 1.0 : 0;
		}

		v2f vert(appdata_img i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);

			half2 uv = i.texcoord;
			o.uv[0] = uv;

			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				uv.y = 1 - uv.y;
			#endif

			o.uv[1] = i.texcoord + _MainTex_TexelSize.xy * fixed2(1, 1) * _SampleDistance;
			o.uv[2] = i.texcoord + _MainTex_TexelSize.xy * fixed2(-1, -1) * _SampleDistance;
			o.uv[3] = i.texcoord + _MainTex_TexelSize.xy * fixed2(-1, 1) * _SampleDistance;
			o.uv[4] = i.texcoord + _MainTex_TexelSize.xy * fixed2(1, -1) * _SampleDistance;

			return o;
		}

		fixed4 frag(v2f i) : SV_TARGET
		{
			half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
			half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
			half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
			half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

			half edge = 1;
			edge *= CheckSame(sample1, sample2);
			edge *= CheckSame(sample3, sample4);

			fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
			fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
			return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
		}

		ENDCG
	} 
	FallBack Off
}

