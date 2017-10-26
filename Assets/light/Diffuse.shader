Shader "Sigma/Light/Diffuse"
{
	Properties
	{
		_MainTint("Main Tint", Color) = (1,1,1,1)
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

			fixed4 _MainTint;

			struct a2v
			{
				float4 pos : POSITION;
				fixed4 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.pos);
				o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _MainTint.rgb * saturate(dot(i.worldNormal, worldLight));
				return fixed4(diffuse + ambient, 1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}