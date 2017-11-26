// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Sigma/LightAdvance/LightAtten"
{
	Properties
	{
		_MainTint("Main Tint", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(1, 4)) = 2
	}
	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			fixed4 _MainTint;
			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;

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
				float3 worldNormal : TEXCOORD1;
				float3 worldLight : TEXCOORD2;
				float3 worldView : TEXCOORD3;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				float3 worldPos = mul(unity_ObjectToWorld, i.pos);
				o.worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				o.worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _MainTint;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 * dot(i.worldNormal, i.worldLight) + 0.5);
				fixed3 halfDir = normalize(i.worldView + i.worldLight);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * (pow(saturate(dot(i.worldNormal, halfDir)), _Gloss));
				fixed atten = 1.0;
				return fixed4(ambient + (diffuse + specular) * atten,1);
			}

			ENDCG
		}

		Pass
		{
			Tags{"LightMode"="ForwardAdd"}
			Blend One One

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd

			fixed4 _MainTint;
			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;

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
				float3 worldNormal : TEXCOORD1;
				float3 worldLight : TEXCOORD2;
				float3 worldView : TEXCOORD3;
				float3 worldPos : TEXCOORD4;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				o.worldPos = mul(unity_ObjectToWorld, i.pos);
				o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
				o.worldView = normalize(UnityWorldSpaceViewDir(o.worldPos));
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _MainTint;
				fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 * dot(i.worldNormal, i.worldLight) + 0.5);
				fixed3 halfDir = normalize(i.worldView + i.worldLight);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * (pow(saturate(dot(i.worldNormal, halfDir)), _Gloss));
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					float lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
					fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif
				return fixed4((diffuse + specular) * atten,1);
			}

			ENDCG
		}

	}
}
