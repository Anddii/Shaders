Shader "Custom/Subsurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Distortion("Distoration", float) = 0.0
		_Power("Power", float) = 0.0
		_LocalThickness("Thickness", 2D) = "white"{}
	}
	SubShader {
		
		Tags {"RenderType"="TransparentCutout" 
		"Queue"="alphatest"
		"IgnoreProjector"="True"  }
		LOD 200
		Cull Off

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma target 3.0
		#pragma surface surf StandardTranslucent fullforwardshadows
		#include "UnityPBSLighting.cginc"

		struct Input {
			float2 uv_MainTex;
			float3 viewDir;
		};
		sampler2D _LocalThickness;
		fixed3 viewDir;
		float _Distortion;
		float _Power;
		float thickness;

		//Custom Lighting model
		inline half4 LightingStandardTranslucent(SurfaceOutputStandard s, half3 lightDir, UnityGI gi)
		{
			fixed4 pbr = LightingStandard(s, lightDir, gi);

			float3 L = gi.light.dir; //Light direction 
			float3 V = viewDir; //View direction
			float3 N = s.Normal; //Face normal

			float3 H = normalize(L + N * _Distortion);
			float I = pow(saturate(dot(V,-H)),_Power) * thickness;

			pbr.rgb = pbr.rgb + gi.light.color * I;
			return pbr;
		}

		inline void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi);		
		}

		// Use shader model 3.0 target, to get nicer looking lighting

		sampler2D _MainTex;

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			viewDir = IN.viewDir;
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			thickness = tex2D(_LocalThickness, IN.uv_MainTex).r;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
