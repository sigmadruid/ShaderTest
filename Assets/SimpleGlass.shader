Shader "Custom/SimpleGlass" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
        _SpecColor ("SpecColor", Color) = (1,1,1,1)
        _Emission ("Emission", Color) = (0, 0, 0, 0)
        _Shininess ("Shiness", Range(0.01, 1)) = 0.7
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
        Tags { "RenderType"="Transparent" "IgnoreProjector" = "True"}
        Lighting Off
        Material
        {
            Diffuse[_Color]
            Ambient[_Color]
            Shininess[_Shininess]
            Specular[_SpecColor]
            Emission[_Emission]
        }

        Lighting On
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Cull Front
            SetTexture[_MainTex]
            {
                Combine Primary * Texture
            }
        }
        Pass
        {
            Cull Back
            SetTexture[_MainTex]
            {
                Combine Primary * Texture
            }
        }
	}
	FallBack "Diffuse"
}
