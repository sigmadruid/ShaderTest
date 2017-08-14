using UnityEngine;
using System.Collections;

public class DepthScan : MonoBehaviour 
{
    public Material mat;

	void Start () 
    {
	    Camera.main.depthTextureMode = DepthTextureMode.Depth;
	}
	
	void Update () 
    {
	
	}

    void OnRenderImage(RenderTexture src, RenderTexture dstSrc)
    {
        Graphics.Blit(src, dstSrc, mat);
    }
}
