Shader "Light/PhongSpecular"
{
	Properties
	{
		_MainTint("Main Tint", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(1, 16)) = 16
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
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				o.worldPos = mul(unity_ObjectToWorld, i.pos).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = _MainTint.rgb * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLightDir));

				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 reflectDir = normalize(reflect(-worldLightDir, i.worldNormal));
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0, dot(reflectDir, worldViewDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1);
			}

			ENDCG
		}
	}
	FallBack "Specular"

}