Shader "Unlit/mask"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_MaskOpacity("Mask Opacity", Range(0,1)) = 1
		_Color("Color", Color) = (0,0,0,0)
		_Color2("Color", Color) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _MaskTex;
			float _MaskOpacity;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _Color2;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 col = tex2D(_MainTex, i.uv) *_Color;

				//Y alpha
				//float mask = tex2D(_MaskTex, float2(i.uv.x,i.uv.y + _Time.y/9)).a *(_MaskOpacity * (1 - i.uv.y));

				float mask = tex2D(_MaskTex, float2(i.uv.x,i.uv.y + _Time.y/9)).a *(_MaskOpacity);
				col.rgb = col.rgb * (1-mask) + _Color2 * mask;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}
			ENDCG
		}
	}
}
