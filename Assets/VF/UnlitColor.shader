Shader "VF/UnlitColor"
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
                float4 vertex : POSITION;
            };

            float4 vert(appdata v) : SV_POSITION
            {
                return mul(UNITY_MATRIX_MVP, v.vertex);
            }

            fixed4 frag() : SV_TARGET
            {
                return _MainTint;
            }

            ENDCG
        }
    }
}