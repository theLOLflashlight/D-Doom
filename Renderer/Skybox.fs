varying     vec3            vCubeCoord;

uniform     samplerCube     uCube;

void main()
{
    gl_FragColor = texture( uCube, vCubeCoord );
}