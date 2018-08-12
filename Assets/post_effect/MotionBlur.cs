using UnityEngine;
using System.Collections;

public class MotionBlur : BasePostEffect
{
    [Range(0, 0.9f)]
    public float BlurAmount = 0.5f;

    private RenderTexture accumulationTexture;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(accumulationTexture == null || accumulationTexture.width != src.width || accumulationTexture.height != src.height)
        {
            DestroyImmediate(accumulationTexture);
            accumulationTexture = new RenderTexture(src.width, src.height, 0);
            accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit(src, accumulationTexture);
        }

        accumulationTexture.MarkRestoreExpected();

        material.SetFloat("_BlurAmount", 1f - BlurAmount);
        Graphics.Blit(src, accumulationTexture, material);
        Graphics.Blit(accumulationTexture, dest);
    }

    void OnDisalbe()
    {
        DestroyImmediate(accumulationTexture);
    }
}

