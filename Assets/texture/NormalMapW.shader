Shader "Sigma/Texture/NormalMapW"
{
	Properties
	{
		_MainTint("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_NormalMap("Normal Map", 2D) = "white"{}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(1, 16)) = 4
	}
	SubShader
	{
		Tags{"LightMode" = "ForwardBase"}

		Pass
		{

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			float4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 pos : POSITION;
				float4 texcoord : TEXCOORD0;
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
				o.uv.xy = TRANSFORM_TEX(i.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(i.texcoord, _NormalMap);

				float3 worldPos = mul(unity_ObjectToWorld, i.pos).xyz;
				float3 worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				float3 worldTangent = normalize(UnityObjectToWorldDir(i.tangent.xyz));
				float3 worldBinormal = normalize(cross(worldNormal, worldTangent) * i.tangent.w);

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
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 * dot(worldNormal, worldLightDir) + 0.5);

				fixed3 h = normalize(worldLightDir + worldViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(h, worldNormal)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1);
			}

			ENDCG
		}
	}
	Fallback "Specular"
}
