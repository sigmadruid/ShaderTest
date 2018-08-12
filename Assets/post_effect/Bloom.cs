using UnityEngine;
using System.Collections;

public class Bloom : BasePostEffect
{
    [Range(0, 4)]
    public int iteration = 2;

    [Range(0.2f, 3f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;

    [Range(0, 4f)]
    public float lunminanceThreshold = 0.6f;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        material.SetFloat("_LuminanceThreshod", lunminanceThreshold);

        int rtW = src.width / downSample;
        int rtH = src.height / downSample;

        RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
        buffer0.filterMode = FilterMode.Bilinear;

        Graphics.Blit(src, buffer0, material, 0);

        material.SetFloat("_BlurSize", 1 + blurSpread);
        for(int i = 0; i < iteration; ++i)
        {
            RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

            Graphics.Blit(buffer0, buffer1, material, 1);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
            buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

            Graphics.Blit(buffer0, buffer1, material, 2);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }

        material.SetTexture("_Bloom", buffer0);
        Graphics.Blit(src, dest, material, 3);

        RenderTexture.ReleaseTemporary(buffer0);
    }
}

