Shader "Sigma/LightAdvance/LightShadow"
{
	Properties
	{
		_MainTint("Main Tint", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		Pass
		{
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase

			#include "Autolight.cginc"
			#include "Lighting.cginc"

			fixed4 _MainTint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldLight : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _MainTint.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5 * dot(i.worldNormal, i.worldLight));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
//				fixed3 shadow = SHADOW_ATTENUATION(i);

				return fixed4(ambient + diffuse * atten, 1);
			}

			ENDCG
		}

		Pass
		{
			Tags { "LightMode"="ForwardAdd" }

			Blend One One

			CGPROGRAM

			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag


			#include "Autolight.cginc"
			#include "Lighting.cginc"

			fixed4 _MainTint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldLight : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _MainTint.rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5 * dot(i.worldNormal, i.worldLight));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
//				fixed3 shadow = SHADOW_ATTENUATION(i);

				return fixed4(diffuse * atten, 1);
			}

			ENDCG
		}

	}
	Fallback "Specular"
}
