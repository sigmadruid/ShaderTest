Shader "Sigma/NPR/Toon"
{
	Properties
	{
		_OutlineColor ("Outline Color", Color) = (1,1,1,1)
		_OutlineWidth ("Outline Width", Range(0, 3)) = 1

		_MainTex ("Texture", 2D) = "white" {}
		_RampTex ("Ramp Texture", 2D) = "white" {}
		_Specular ("Spec Color", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(0, 0.1)) = 0.05
	}
	SubShader
	{
		Pass
		{
			NAME "OUTLINE"

			Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _OutlineColor;
			float _OutlineWidth;

			struct a2v
			{
				float4 pos : POSITION;
				fixed2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MV, i.pos);
				o.uv = i.uv;
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, i.normal);
				normal.z = -0.5;
				o.pos = o.pos + float4(normalize(normal), 0) * _OutlineWidth;
				o.pos = mul(UNITY_MATRIX_P, o.pos);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				return fixed4(_OutlineColor.rgb, 1);
			}

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _RampTex;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 pos : POSITION;
				fixed2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				float3 worldLight : TEXCOORD1;
				float3 worldView : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld, i.pos).xyz;
				o.worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				o.worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed diff = 0.5 + 0.5 * dot(i.worldLight, i.worldNormal);
				fixed3 ramp = tex2D(_RampTex, fixed2(diff, diff)).rgb;
				fixed3 albedo =  tex2D(_MainTex, i.uv).rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo * ramp;

				fixed spec = dot(i.worldNormal, normalize(i.worldView + i.worldLight));
				fixed w = fwidth(spec) * 2;
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _Gloss - 1)) * step(0.0001, _Gloss);

				return fixed4(ambient + diffuse + specular, 1);
			}

			ENDCG
		}

	}
	Fallback "Diffuse"
}
