Shader "Sigma/TextureAdvance/CubemapRefract"
{
	Properties
	{
		_MainTint ("Main Tint", Color) = (1,1,1,1)
		_RefractTint("Refract Tint", Color) = (1,1,1,1)
		_RefractFactor("Refract Factor", Range(0, 1)) = 0.5
		_RefractRatio("Refract Ratio", Range(0.1, 1)) = 0.5
		_Cubemap("Cubemap", Cube) = "_Skybox" {}
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldLight : TEXCOORD2;
				float3 worldRefr : TEXCOORD3;
			};

			fixed4 _MainTint;
			fixed4 _RefractTint;
			float _RefractFactor;
			float _RefractRatio;
			samplerCUBE _Cubemap;
			
			v2f vert (a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.worldPos = mul(unity_ObjectToWorld, i.pos).xyz;
				o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
				float3 worldView = normalize(UnityWorldSpaceViewDir(o.worldPos));
				o.worldRefr = refract(-normalize(worldView), normalize(o.worldNormal), _RefractRatio);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _MainTint.rgb;

				fixed3 diffuse = _LightColor0.rgb * _MainTint.rgb * (0.5 + 0.5 * dot(i.worldLight, i.worldNormal));

				fixed3 refl = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractTint.rgb;

				return fixed4(ambient + lerp(diffuse, refl, _RefractFactor), 1);
			}
			ENDCG
		}
	}
}
