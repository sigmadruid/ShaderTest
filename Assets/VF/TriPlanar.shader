Shader "VF/TriPlanar"
{
	Properties
	{
        _TexX("TexX", 2D) = "white"{}
        _Tiling("Tiling", Range(0, 20)) = 1
        _OcclusionMap("Occlusion", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

            sampler2D _TexX;
            sampler2D _OcclusionMap;
            float _Tiling;

			struct v2f
			{
				float3 objNormal : TEXCOORD0;
                float3 coords : TEXCOORD1;
                float2 uv : TEXCOORD2;
				float4 pos : SV_POSITION;
			};

			
			v2f vert (float4 pos : POSITION, float3 normal : NORMAL, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, pos);
                o.coords = pos.xyz * _Tiling;
                o.objNormal = normal;
                o.uv = uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                half3 blend = abs(i.objNormal);
                blend /= dot(blend, 1);
                fixed4 cx = tex2D(_TexX, i.coords.yz);
                fixed4 cy = tex2D(_TexX, i.coords.xz);
                fixed4 cz = tex2D(_TexX, i.coords.xy);
                fixed4 c;
                if (blend.x > blend.z && blend.x > blend.y)
                    c = cx;
                else if ( blend.z > blend.x && blend.z > blend.y)
                    c = cz;
                else
                    c = cy;
//                c = cx * blend.x + cy * blend.y + cz * blend.z;
                c *= tex2D(_OcclusionMap, i.uv);
				return c;
			}
			ENDCG
		}
	}
}
