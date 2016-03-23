varying     vec4        vClipSpace;
varying     vec3        vEyeNormal;
varying     vec2        vTexCoord;
varying     vec3        vLightDirection;


uniform     vec4        uColor;
uniform     sampler2D   uTextureRefle;
uniform     sampler2D   uTextureRefra;
uniform     sampler2D   uMapDuDv;
uniform     sampler2D   uMapNormal;
uniform     sampler2D   uMapDepth;
uniform     vec3        uSunColor;

uniform     float       uDuDvFactor;

const       float       WAVE_STRENGTH       = 0.04;
const       float       SHINE_DAMPER        = 40.0;
const       float       REFLECTIVITY        = 0.5;

const       float       NEAR                = 0.1;
const       float       FAR                 = 1000.0;
void main()
{
    vec2 ndc = (vClipSpace.xy / vClipSpace.w) / 2.0 + 0.5;

    vec2 refleTexCoord = vec2( ndc.x, -ndc.y );
    vec2 refraTexCoord = ndc.xy;

    float floorDepth = texture2D( uMapDepth, refraTexCoord ).r;
    float floorDist = 2.0 * NEAR * FAR / (FAR + NEAR - (2.0 * floorDepth - 1.0) * (FAR - NEAR));

    float waterDist = 2.0 * NEAR * FAR / (FAR + NEAR - (2.0 * gl_FragCoord.z - 1.0) * (FAR - NEAR));
    float waterDepth = floorDist - waterDist;

    vec2 distor = texture2D( uMapDuDv, vec2( vTexCoord.x + uDuDvFactor, vTexCoord.y ) ).rg * 0.1;
    distor = vTexCoord + vec2( distor.x, distor.y + uDuDvFactor );
    distor = (texture2D( uMapDuDv, distor ).rg * 2.0 - 1.0) * WAVE_STRENGTH;

    float depthClamp = clamp( waterDepth / 5, 0, 1 );

    refleTexCoord += distor * depthClamp;
    refleTexCoord.x = clamp( refleTexCoord.x, 0.001, 0.999 );
    refleTexCoord.y = clamp( refleTexCoord.y, -0.999, -0.001 );

    refraTexCoord += distor * depthClamp;
    refraTexCoord = clamp( refraTexCoord, 0.001, 0.999 );

    vec4 refleColor = texture2D( uTextureRefle, refleTexCoord );
    vec4 refraColor = texture2D( uTextureRefra, refraTexCoord );

    vec4 normalColor = texture2D( uMapNormal, distor );
    vec3 normal = normalize( vec3( normalColor.r * 2.0 - 1.0,
                                   normalColor.b * (3 + 2 * depthClamp),
                                   normalColor.g * 2.0 - 1.0 ) );

    vec3 viewVec = normalize( -vEyeNormal );
    float fresnl = dot( viewVec, normal );
    //fresnl = pow( fresnl, 1.1 );

    vec3 refleLight = reflect( normalize( vLightDirection ), normal );
    float specular = max( dot( refleLight, viewVec ), 0.0 );
    specular = pow( specular, SHINE_DAMPER );
    vec3 specHigh = uSunColor * specular * REFLECTIVITY * depthClamp;

    gl_FragColor = mix( refleColor, refraColor, fresnl );
    gl_FragColor = mix( gl_FragColor, vec4( 0, 0.3, 0.5, 1 ), 0.2 ) + vec4( specHigh, 0 );
    //gl_FragColor.a = depthClamp * 2.0 - 1.0;

    //gl_FragColor = vec4( clamp( waterDepth / 5, 0, 1 ) );

    //gl_FragColor = mix( gl_FragColor, uColor, 0 );
    //gl_FragColor = normalColor;
}