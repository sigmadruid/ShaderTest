Shader "VF/BitangentColor"
{
    Properties
    {
        _MainTint("Main Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _MainTint;

            struct appdata
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.pos);
//                float3 bitangent = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                o.color.rgb = v.normal * 0.5 + 0.5;
                o.color.a = 1;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                return _MainTint * i.color;
            }


            ENDCG
        }
    }

}