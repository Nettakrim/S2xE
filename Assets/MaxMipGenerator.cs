using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MaxMipGenerator : ScriptableWizard
{
    public Texture2D heightMap;
    public int mipLevels = 7;
    public int width = 1024;
    public int height = 1024;

    void Awake() {
        heightMap = (Texture2D)AssetDatabase.LoadAssetAtPath("Assets/MapHeight.png", typeof(Texture2D));
    }

    [MenuItem("Tools/Max Mip Generator")]
    private static void CreateWizard() => DisplayWizard<MaxMipGenerator>("Generate");

    public void OnWizardCreate() {
        Texture2D generated = new Texture2D(width, height, TextureFormat.R8, mipLevels, true);
        generated.filterMode = FilterMode.Point;
        generated.wrapMode = TextureWrapMode.Clamp;
        generated.name = "HeightMap";

        for (int u = 0; u < width; u++) {
            for (int v = 0; v < height; v++) {
                Color color = heightMap.GetPixel((int)(u/(float)width * heightMap.width), (int)(v/(float)height * heightMap.height));
                generated.SetPixel(u, v, new Color(color.r, 0, 0), 0);
            }
        }

        for (int mip = 0; mip < mipLevels-1; mip++) {
            width /= 2;
            height /= 2;

            for (int u = 0; u < width; u++) {
                for (int v = 0; v < height; v++) {
                    int u2 = u*2;
                    int v2 = v*2;
                    float a = generated.GetPixel(u2,   v2,   mip).r;
                    float b = generated.GetPixel(u2+1, v2,   mip).r;
                    float c = generated.GetPixel(u2,   v2+1, mip).r;
                    float d = generated.GetPixel(u2+1, v2+1, mip).r;
                    generated.SetPixel(u,v, new Color(Mathf.Max(Mathf.Max(a,b),Mathf.Max(c,d)), 0, 0), mip+1);
                }
            }      
        }
        
        CreateOrReplaceAsset(generated, "Assets/HeightMap.asset");
        AssetDatabase.SaveAssets();
    }

    //https://discussions.unity.com/t/assetdatabase-replacing-an-asset-but-leaving-reference-intact/6549/4
    private T CreateOrReplaceAsset<T>(T asset, string path) where T : Object
    {
        T existingAsset = AssetDatabase.LoadAssetAtPath<T>(path);

        if (existingAsset == null)
        {
            AssetDatabase.CreateAsset(asset, path);
        }
        else
        {
            if (typeof(Mesh).IsAssignableFrom(typeof(T))) { (existingAsset as Mesh)?.Clear(); }
            EditorUtility.CopySerialized(asset, existingAsset);
            existingAsset = asset;
        }

        return existingAsset;
    }
}
