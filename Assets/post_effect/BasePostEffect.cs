using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class BasePostEffect : MonoBehaviour 
{
    public Shader shader;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (CheckSupport() && CheckResrouce())
        {
            OnRender();
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    protected bool CheckSupport()
    {
        return SystemInfo.supportsImageEffects;
    }

    protected bool CheckResrouce()
    {
        return shader != null && material != null;
    }

    private Material mat;
    protected Material material
    {
        get
        {
            if (mat == null)
            {
                mat = new Material(shader);
                mat.hideFlags = HideFlags.DontSave;
            }
            return mat;
        }
    }

    protected virtual void OnRender()
    {
    }
}
