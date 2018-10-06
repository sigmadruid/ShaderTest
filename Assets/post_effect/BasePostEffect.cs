using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class BasePostEffect : MonoBehaviour 
{
    public Shader shader;

    protected Camera _camera;

    void Awake()
    {
        _camera = GetComponent<Camera>();
    }

    void Start()
    {
        if (!CheckSupport() || !CheckResrouce())
        {
            Debug.LogError("can't use post effect");
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

}
