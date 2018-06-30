using UnityEngine;
using System.Collections;

public class Brightness_Saturation_Contrast : BasePostEffect
{
    [Range(0, 3f)]
    public float Brightness = 1f;

    [Range(0, 3f)]
    public float Saturation = 1f;

    [Range(0, 3f)]
    public float Contrast = 1f;

    protected override void OnRender()
    {
        material.SetFloat("_Brightness", Brightness);
        material.SetFloat("_Saturation", Saturation);
        material.SetFloat("_Contrast", Contrast);
    }
}

