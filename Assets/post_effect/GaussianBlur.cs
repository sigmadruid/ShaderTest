using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : BasePostEffect 
{
    [Range(0, 4)]
    public int BlurTimes;

    [Range(0.2f, 3f)]
    public float BlurSpread;

    [Range(1, 8)]
    public int DownSample;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        int rtW = src.width;
        int rtH = src.height;

        RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH);
        Graphics.Blit(src, buffer0);

        for (int i = 1; i < BlurTimes; ++i)
        {
            material.SetFloat("_BlurSize", 1 + i * BlurSpread);

            RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH);

            Graphics.Blit(buffer0, buffer1, material, 0);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
            buffer1 = RenderTexture.GetTemporary(rtW, rtH);

            Graphics.Blit(buffer0, buffer1, material, 1);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }

        Graphics.Blit(buffer0, dest);
        RenderTexture.ReleaseTemporary(buffer0);
    }
}
