Shader "VF/SimpleDiffuse"
{
	Properties
	{
        _MainTex ("Texture", 2D) = "white" {}
		_NormalMap ("Texture", 2D) = "white" {}
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
			#include "UnityLightingCommon.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

            sampler2D _MainTex;
			sampler2D _NormalMap;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.texcoord;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
                float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                float3 worldNormal = UnityObjectToWorldNormal(normal);
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                fixed4 diff = nl * _LightColor0;
                diff.rgb += ShadeSH9(half4(worldNormal, 1));
                col *= diff;
				return col;
			}
			ENDCG
		}
	}
}
