//--------------------------------------------------------------------------------------
// File: Tutorial06.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

cbuffer ConstantBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;
    float4 vLightDir[1];
    float4 vLightColor[1];
    float4 vOutputColor;
    float3 cameraPosition;
}

struct VS_INPUT
{
    float4 Pos : POSITION;
    float3 Norm : NORMAL;
};

struct PS_INPUT
{
    float4 Pos : SV_POSITION;
    float3 Norm : TEXCOORD0;
    float3 WorldPos : WORLDPOS; // Мировая позиция
};

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS(VS_INPUT input)
{
    PS_INPUT output = (PS_INPUT)0;
    output.Pos = mul(input.Pos, World);
    output.Pos = mul(output.Pos, View);
    output.Pos = mul(output.Pos, Projection);
    output.Norm = mul(float4(input.Norm, 0.0f), World).xyz; // Необходимо нормализовать в Vertex Shader
    return output;
}

float4 PS(PS_INPUT input) : SV_Target
{
    // Normalize the light direction
    float3 lightDir = normalize(vLightDir[0].xyz);

    // Normalize the normal from the input
    float3 normal = normalize(input.Norm);

    // Calculate the view direction (camera to object)
    float3 viewDir = normalize(cameraPosition - input.WorldPos);

    // Calculate the reflection vector
    float3 reflectDir = reflect(-lightDir, normal);

    // Calculate the angle between the view direction and the reflection vector
    float NdotH = saturate(dot(viewDir, reflectDir));

    // Calculate specular component
    float specularPower = 4.0f; // Коэффициент блеска
    float specular = pow(NdotH, specularPower);

    // Debug output: visualize intermediate values
    // You can visualize these values by returning them as color
    // Uncomment these lines to debug
    // return float4(normal, 1.0f); // To visualize normal
    // return float4(lightDir, 1.0f); // To visualize light direction
    // return float4(viewDir, 1.0f); // To visualize view direction
    // return float4(reflectDir, 1.0f); // To visualize reflection direction
    // return float4(NdotH, NdotH, NdotH, 1.0f); // To visualize NdotH

    // Final color calculation with only specular lighting

    //float4 tempColor = float4(vLightColor[0].rgb, 1.0f) * specular; // Apply specular only to RGB
    //float4 finalColor = float4(tempColor.rgb, vLightColor[0].a);

    float4 finalColor = specular * vLightColor[0]; // Итоговое освещение

    return finalColor;
}

//--------------------------------------------------------------------------------------
// PSSolid - render a solid color
//--------------------------------------------------------------------------------------
float4 PSSolid(PS_INPUT input) : SV_Target
{
    return vOutputColor;
}
