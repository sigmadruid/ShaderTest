Shader "Texture/NormalMapT"
{
	Properties
	{
		_MainTint("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_NormalMap("Normal Map", 2D) = "white"{}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(1,16)) = 4
	}
	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _MainTint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			fixed4 _Specular;
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
				float3 tLightDir : TEXCOORD1;
				float3 tViewDir : TEXCOORD2;
			};

			v2f vert(a2v i)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(i.pos);
				o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = i.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

				float3 binormal = cross(i.normal, i.tangent.xyz) * i.tangent.w;
				float3x3 rotation = float3x3(i.tangent.xyz, binormal, i.normal);

				o.tLightDir = mul(rotation, ObjSpaceLightDir(i.pos));
				o.tViewDir = mul(rotation, ObjSpaceViewDir(i.pos));

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _MainTint.rgb;
				fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv.zw));

				fixed3 lightDir = normalize(i.tLightDir);
				fixed3 viewDir = normalize(i.tViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 * dot(normal, lightDir) + 0.5);

				fixed3 h = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(h, normal)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1);
			}
			
			ENDCG
		}
	}
	Fallback "Specular"
}