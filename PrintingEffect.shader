Shader "Custom/PrintingEffect" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_ConstructY("ConstructY", float) = 0.0
		_ConstructGap("ConstructGap", float) = 0.0
		_ConColor("construct Color", Color) = (1,1,0,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull Off
		CGPROGRAM

		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Custom fullforwardshadows
		#include "UnityPBSLighting.cginc"

		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos; // World pos
			float vface : VFACE; //-1 if backwards 
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float _ConstructY;
		float _ConstructGap;
		float4 _ConColor;
		float3 viewDir;

		int building;
		
		//Custom Lighting model
		inline half4 LightingCustom(SurfaceOutputStandard s, half3 lightDir, UnityGI gi)
		{
			if (building)
				return _ConColor;

			return LightingStandard(s, lightDir, gi);
		}

		inline void LightingCustom_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi);		
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
		
			//local pos
			//float3 localPos = IN.worldPos -  mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;
			
			//Cut the Geometry
			if(IN.worldPos.y > _ConstructY + _ConstructGap)
				discard;

			if(IN.worldPos.y < _ConstructY)
			{
				fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Alpha = c.a;
				building = 0;
			}

			else
			{
				o.Albedo = _ConColor.rgb;
 				o.Alpha  = _ConColor.a;
				building = 1;
			}

			//Color backFace
			if(IN.vface <= 0)
				building = 1;	

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
