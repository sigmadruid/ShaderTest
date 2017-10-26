Shader "Sigma/Transparent/AlphaTest"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "black"{}
		_Alpha("Alpha Threshold", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags
		{
			"LightMode"="ForwardBase"
			"Queue"="AlphaTest"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
		}
		Cull Off
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Alpha;

			struct a2v
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed3 worldLight : TEXCOORD1;
				fixed3 worldNormal : TEXCOORD2;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				float3 worldPos = mul(unity_ObjectToWorld, i.pos);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				o.worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);

				clip(albedo.a - _Alpha);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * (0.5 + 0.5 * dot(i.worldNormal, i.worldLight));

				return fixed4(ambient + diffuse, 1);
			}

			ENDCG
		}
	}
	Fallback "Transparent/VertexLit"
}
