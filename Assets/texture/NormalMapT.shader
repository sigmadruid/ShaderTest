Shader "Texture/NormalMapT"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white"{}
		_NormalMap("Normal Map", 2D) = "white"{}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(1, 16)) = 4
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 pos : POSITION;
				fixed3 normal : NORMAL;
				fixed4 tangent : TANGENT;
				fixed2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 tangentLight : TEXCOORD1;
				float3 tangentView : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

				TANGENT_SPACE_ROTATION;

				o.tangentLight = mul(rotation, ObjSpaceLightDir(v.pos)).xyz;
				o.tangentView = mul(rotation, ObjSpaceViewDir(v.pos)).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 albedo = tex2D(_MainTex, i.uv.xy);
				fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv.zw));

				fixed3 light = normalize(i.tangentLight);
				fixed3 view = normalize(i.tangentView);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * ((dot(light, normal)) * 0.5 + 0.5);

				fixed3 h = normalize(view + light);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(h, normal)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1);
			}

			ENDCG
		}
	}
	Fallback "Specular"
}