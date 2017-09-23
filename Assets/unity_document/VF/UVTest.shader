// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "VF/UVTest"
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

            struct appdata
            {
                float4 pos : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.uv = float4(v.uv.xy, 0, 0);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float4 col = frac(i.uv);
                if (any(saturate(i.uv) - i.uv))
                    col.b = 0.5;
                return col;
            }

            ENDCG
        }
	}
}
