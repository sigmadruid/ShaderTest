Shader "Sigma/Transparent/AlphaBlend"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags 
		{ 
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
		}

		Pass
		{
			Cull Front
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldLight : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * (0.5 + 0.5 * dot(i.worldNormal, i.worldLight));

				return fixed4(ambient + diffuse, albedo.a);
			}
			ENDCG
		}

		Pass
		{
			Cull Back
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldLight : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * (0.5 + 0.5 * dot(i.worldNormal, i.worldLight));

				return fixed4(ambient + diffuse, albedo.a);
			}
			ENDCG
		}
	}
}
