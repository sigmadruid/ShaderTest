using UnityEngine;
using System.Collections;

public class EdgeDetect : BasePostEffect
{
    [Range(0, 1f)]
    public float edgeOnly = 0.5f;
    [Range(0, 1f)]
    public float edgeThreshold = 0.5f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    protected override void OnRender()
    {
        material.SetFloat("_EdgeOnly", edgeOnly);
        material.SetFloat("_EdgeThreshold", edgeThreshold);
        material.SetColor("_EdgeColor", edgeColor);
        material.SetColor("_BackgroundColor", backgroundColor);
    }
}

