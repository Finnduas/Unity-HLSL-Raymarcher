Shader "Unlit/RayMarching"
{
    Properties
    {
        height ("height", Float) = 6
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

            #include "UnityCG.cginc"

            float height;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.ro = _WorldSpaceCameraPos;
                o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            

            float2 smin( in float a, in float b, in float k )
{
    float f1 = exp2( -k*a );
    float f2 = exp2( -k*b );
    return float2(-log2(f1+f2)/k,f2);
}


float sdTorus( float3 p, float2 t )
{
  float2 q = float2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

            float GetDist(float3 p)
            {
                float ballOne = length(p) -2;
                float ballTwo = length(p - float3(0.0, -19, 2)) -2;
                float floor = p.y + 2.*(sin(p.x * 0.05) + sin(p.z * 0.05)) + 2*(sin(p.x * 0.1) + sin((p.z +80) * 0.1));
                return sdTorus(p + float3(0,height,0), float2(12,5));
            }

            float shadow( in float3 ro, in float3 rd, float mint, float maxt , float k)
{
    float t = mint * -rd;
    float res = 1.0;
    for( int i=0; i<96 && t<maxt; i++ )
    {
        
        float h = GetDist(ro + rd*t);
        if( h<0.001 )
            return 0.0;

            res = min( res, k*h/t );
        t += h;
    }
    return res;
}

 float2 GetColorAndDist(float3 p)
            {
                                return smin(length(p) -2, length(p - float3(0.0, .3, 7)) -2, .4);
            }
            float3 GetNormals(float3 p)
            {
                float2 idk = float2(0.01, 0.0);
                float3 n = GetDist(p) - float3(
                    GetDist(p-idk.xyy),
                    GetDist(p-idk.yxy),
                    GetDist(p-idk.yyx)
                    );
                    return n * 10;
            }
          
            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir = normalize(float3(-0.1,1.,2.0));

                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - ro);
                float dt = 0.0;
                float3 p = 0.0;
                float ds = 0.0;
                float steps = 0.0;
                for(int i = 0.0; i<256; ++i)
                {
                    p = ro + rd * (dt + 0.01);
                    ds = GetDist(p);
                    dt += ds;
                    steps += 1.0;
                    if(ds<0.01 || ds > 1000.0) break;
                }
                fixed4 col = 0.0;
                float3 n = GetNormals(p);
              if(ds >= 100.0)
              {
                  discard;
              }
             
                col.rgb = shadow(p, lightDir, 80.0, 40.0, .9) + 0.18;
                //col.gb = steps * .005;
                return col;
            }
            ENDCG
        }
    }
}
