Shader "Brightness_Saturation_Contrast" 
{
	Properties 
	{
		_MainTex("Main Tex", 2D) = "white"{}
		_Brightness("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}
	SubShader 
	{
		Pass
		{
			ZTest Always
			ZWrite Off
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _Brightness;
			float _Saturation;
			float _Contrast;

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			v2f vert(appdata_img i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = i.texcoord;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 texColor = tex2D(_MainTex, i.uv);

				//brightness
				fixed3 finalColor = texColor * _Brightness;

				//saturation
				fixed luminance = 0.2125 * texColor.r + 0.7154 * texColor.g + 0.0721 * texColor.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);

				//contrast
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);

				return fixed4(finalColor, 1);
			}

			ENDCG
		}
	} 
	FallBack Off
}

