Shader "Sigma/PostEffectEdgeDetect" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeOnly ("Edge Only", Range(0,1)) = 0.5
		_EdgeThreshold("Edge Threshold", Range(0, 1)) = 0.7
		_EdgeColor ("Edge Color", Color) = (0,0,0,1)
		_BackgroundColor("Background Color", Color) = (1,1,1,1)
	}
	SubShader 
	{
		Pass
		{
			ZWrite Off
			ZTest Always
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			fixed _EdgeOnly;
			fixed _EdgeThreshold;
			fixed4 _EdgeColor;
			fixed4 _BackgroundColor;

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed2 uv[9] : TEXCOORD0;
			};

			v2f vert(appdata_img i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				fixed2 uv = i.texcoord;

				o.uv[0] = uv + _MainTex_TexelSize.xy * fixed2(-1, -1);
				o.uv[1] = uv + _MainTex_TexelSize.xy * fixed2(0, -1);
				o.uv[2] = uv + _MainTex_TexelSize.xy * fixed2(1, -1);
				o.uv[3] = uv + _MainTex_TexelSize.xy * fixed2(-1, 0);
				o.uv[4] = uv + _MainTex_TexelSize.xy * fixed2(0, 0);
				o.uv[5] = uv + _MainTex_TexelSize.xy * fixed2(1, 0);
				o.uv[6] = uv + _MainTex_TexelSize.xy * fixed2(-1, 1);
				o.uv[7] = uv + _MainTex_TexelSize.xy * fixed2(0, 1);
				o.uv[8] = uv + _MainTex_TexelSize.xy * fixed2(1, 1);

				return o;
			}

			fixed luminance(fixed4 color)
			{
				return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
			}

			half Sobel(v2f i)
			{
				const half Gx[9] = {-1, -2, -1,
									0, 0, 0,
									1, 2, 1};
				const half Gy[9] = {-1, 0, 1,
									-2, 0, 2,
									-1, 0, 1};

				half texColor;
				half edgeX = 0;
				half edgeY = 0;
				for(int j = 0; j < 9; ++j)
				{
					texColor = luminance(tex2D(_MainTex, i.uv[j]));
//					texColor = tex2D(_MainTex, i.uv[j]);
					edgeX += texColor * Gx[j];
					edgeY += texColor * Gy[j];
				}
				half edge = 1 - abs(edgeX) - abs(edgeY);
				return edge;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				half edge = Sobel(i);

				if (edge > _EdgeThreshold) edge = 1;

				fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
				fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
				return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
			}

			ENDCG
		}
	} 
	FallBack Off
}

