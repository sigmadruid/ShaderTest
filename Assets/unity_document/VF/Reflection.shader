Shader "VF/Reflection"
{
	Properties
	{
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                half3 worldRef : TEXCOORD0;
            };

            v2f vert(float4 pos : POSITION, float3 normal : NORMAL)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, pos);
                float3 worldPos = mul(_Object2World, pos).xyz;
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 worldNormal = UnityObjectToWorldNormal(normal);
                o.worldRef = reflect(-worldViewDir, worldNormal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRef);
                half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
                fixed4 c = 1;
                c.rgb = skyColor;
                return c;
            }

			ENDCG
		}
	}
}
