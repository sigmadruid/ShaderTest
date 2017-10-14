Shader "Texture/NormalMapW"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_MainTint ("Main Tint", Color) = (1,1,1,1)
		_NormalMap("Normal Map", 2D) = "white" {}
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(1, 16)) = 4
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _MainTint;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v
			{
				float4 pos : POSITION;
				fixed2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 T2W0 : TEXCOORD1;
				float4 T2W1 : TEXCOORD2;
				float4 T2W2 : TEXCOORD3;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = i.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
    			float3 worldPos = mul(unity_ObjectToWorld, i.pos).xyz;
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				fixed3 worldTangent = normalize(UnityObjectToWorldNormal(i.tangent.xyz));
				fixed3 worldBinormal = normalize(cross(worldNormal, worldTangent) * i.tangent.w);
				o.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, i.uv.xy);
				fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv.zw));
				fixed3 worldNormal = normalize(float3(
					dot(i.T2W0.xyz, normal),
					dot(i.T2W1.xyz, normal),
					dot(i.T2W2.xyz, normal)
					));

				float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 h = normalize(worldLight + worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * (0.5 * dot(worldNormal, worldLight) + 0.5);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(h, worldNormal)), _Gloss);

				return fixed4(ambient + diffuse + specular, 0);
			}
			ENDCG
		}
	}
	Fallback "Specular"
}
