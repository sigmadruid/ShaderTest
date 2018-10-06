using UnityEngine;
using System.Collections;

public class EdgeDetectWithDepthNormal : BasePostEffect
{
    public Color EdgeColor = Color.black;
    public Color BackgroundColor = Color.white;

    [Range(0, 1)]
    public float EdgeOnly = 0.5f;

    public float SampleDistance = 1f;
    public float SensitiveDepth = 1f;
    public float SensitiveNormal = 1f;

    void OnEnable()
    {
        _camera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        material.SetColor("_EdgeColor", EdgeColor);
        material.SetColor("_BackgroundColor", BackgroundColor);
        material.SetFloat("_EdgeOnly", EdgeOnly);
        material.SetFloat("_SampleDistance", SampleDistance);
        material.SetFloat("_SensitiveDepth", SensitiveDepth);
        material.SetFloat("_SensitiveNormal", SensitiveNormal);
        Graphics.Blit(src, dest, material);
    }
}

