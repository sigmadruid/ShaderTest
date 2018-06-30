Shader "Exercise/Exercise"
{
	Properties
	{
		_MainTint("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(1, 16)) = 4
		_Cubemap("Cube Map", Cube) = "_Skybox" {}
		_ReflectFactor("Reflect Factor", Range(0,1)) = 0.5
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "Autolight.cginc"
			
			fixed4 _MainTint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			fixed4 _Specular;
			float _Gloss;
			samplerCUBE _Cubemap;
			fixed _ReflectFactor;

			struct a2v
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 TtoW1 : TEXCOORD1;
				float4 TtoW2 : TEXCOORD2;
				float4 TtoW3 : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);

				float3 binormal = cross(i.normal, i.tangent.xyz).xyz * i.tangent.w;
				float3 worldPos = mul(unity_ObjectToWorld, i.pos).xyz;

				o.TtoW1 = float4(i.tangent.x, binormal.x, i.normal.x, worldPos.x);
				o.TtoW2 = float4(i.tangent.y, binormal.y, i.normal.y, worldPos.y);
				o.TtoW3 = float4(i.tangent.z, binormal.z, i.normal.z, worldPos.z);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float3 worldPos = float3(i.TtoW1.w, i.TtoW2.w, i.TtoW3.w);
				float3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));

				float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
				float3 worldNormal = normalize(float3(
					dot(i.TtoW1, normal),
					dot(i.TtoW2, normal),
					dot(i.TtoW3, normal)
				));
				fixed3 albedo = tex2D(_MainTex, i.uv) * _MainTint.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5 * dot(worldNormal, worldLight));
				float3 halfDir = normalize(worldLight + worldView);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

				float3 reflDir = reflect(-worldView, worldNormal);
				fixed3 refl = texCUBE(_Cubemap, reflDir);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(ambient + (lerp(diffuse, refl, _ReflectFactor) + specular) * atten, 1);
			}


			ENDCG
		}
	}
	Fallback "Specular"
}