using UnityEngine;
using System.Collections;

public class HeightFog : BasePostEffect
{
    public Color FogColor;
    public float FogHeightTop;
    public float FogHeightBottom;
    public float FogDensity;

    void OnEnalbe()
    {
        _camera.depthTextureMode = DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        float near = _camera.nearClipPlane;
        float halfHeight = near * Mathf.Tan(_camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        float halfWidth = halfHeight * _camera.aspect;

        Vector3 bottomLeft = _camera.transform.forward * near - _camera.transform.up * halfHeight - _camera.transform.right * halfWidth;
        float scale = bottomLeft.magnitude / near;
        bottomLeft = bottomLeft.normalized * scale;

        Vector3 bottomRight = _camera.transform.forward * near - _camera.transform.up * halfHeight + _camera.transform.right * halfWidth;
        bottomRight = bottomRight.normalized * scale;

        Vector3 topRight = _camera.transform.forward * near + _camera.transform.up * halfHeight + _camera.transform.right * halfWidth;
        topRight = topRight.normalized * scale;

        Vector3 topLeft = _camera.transform.forward * near + _camera.transform.up * halfHeight - _camera.transform.right * halfWidth;
        topLeft = topLeft.normalized * scale;

        Matrix4x4 frustrumCorners = Matrix4x4.identity;
        frustrumCorners.SetRow(0, bottomLeft);
        frustrumCorners.SetRow(1, bottomRight);
        frustrumCorners.SetRow(2, topRight);
        frustrumCorners.SetRow(3, topLeft);

        material.SetMatrix("_FrustrumCorners", frustrumCorners);
        material.SetColor("_FogColor", FogColor);
        material.SetFloat("_FogHeightTop", FogHeightTop);
        material.SetFloat("_FogHeightBottom", FogHeightBottom);
        material.SetFloat("_FogDensity", FogDensity);

        Graphics.Blit(src, dest, material);
    }
}

