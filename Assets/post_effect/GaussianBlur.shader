Shader "Sigma/PostEffect/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1
	}
	SubShader
	{
		Pass
		{
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM

			#pragma vertex vertVertical
			#pragma fragment frag

			ENDCG
		}

		Pass
		{
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM

			#pragma vertex vertHorizontal
			#pragma fragment frag

			ENDCG
		}

		CGINCLUDE
		
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		fixed4 _MainTex_TexelSize;
		float _BlurSize;

		struct v2f
		{
			float4 pos : SV_POSITION;
			fixed2 uv[5] : TEXCOORD0;
		};

		v2f vertVertical (appdata_img i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);

			fixed2 uv = i.texcoord;
			o.uv[0] = uv;
			o.uv[1] = uv + fixed2(0, _MainTex_TexelSize.y) * _BlurSize;
			o.uv[2] = uv - fixed2(0, _MainTex_TexelSize.y) * _BlurSize;
			o.uv[3] = uv + fixed2(0, _MainTex_TexelSize.y * 2) * _BlurSize;
			o.uv[4] = uv - fixed2(0, _MainTex_TexelSize.y * 2) * _BlurSize;

			return o;
		}

		v2f vertHorizontal (appdata_img i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);

			fixed2 uv = i.texcoord;
			o.uv[0] = uv;
			o.uv[1] = uv + fixed2(_MainTex_TexelSize.x, 0) * _BlurSize;
			o.uv[2] = uv - fixed2(_MainTex_TexelSize.x, 0) * _BlurSize;
			o.uv[3] = uv + fixed2(_MainTex_TexelSize.x * 2, 0) * _BlurSize;
			o.uv[4] = uv - fixed2(_MainTex_TexelSize.x * 2, 0) * _BlurSize;

			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			fixed weight[3] = {0.4026, 0.2442, 0.0545};

			fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
			sum += tex2D(_MainTex, i.uv[1]).rgb * weight[1];
			sum += tex2D(_MainTex, i.uv[2]).rgb * weight[1];
			sum += tex2D(_MainTex, i.uv[3]).rgb * weight[2];
			sum += tex2D(_MainTex, i.uv[4]).rgb * weight[2];

			return fixed4(sum, 1);
		}

		ENDCG
	}
	Fallback Off
}
