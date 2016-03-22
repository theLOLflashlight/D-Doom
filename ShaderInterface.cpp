#include "ShaderInterface.h"

#include <cstdio>
#include <cstdlib>

char* load( const char* path )
{
    FILE* currFile;
    if ( errno_t r = fopen_s( &currFile, path, "rt" ) )
    {
        printf( "Could not open the file: %s %d\n", path, r );
        return nullptr;
    }

    fseek( currFile, 0, SEEK_END );
    int count = (int) ftell( currFile );

    rewind( currFile );
    char* data = new char[ count + 1 ];
    count = (int) fread( data, 1, count, currFile );
    data[ count ] = '\0';

    fclose( currFile );
    return data;
}

ShaderInterface::ShaderInterface( const char* vs, const char* fs )
    : vertexStr( load( vs ) )
    , fragmentStr( load( fs ) )
    , shader( std::make_shared< ShaderLoader >( vertexStr, fragmentStr ) )
    #define ATTRIBUTE( name ) name( glGetAttribLocation( shader->program, #name ) )
    #define UNIFORM( name ) name( glGetUniformLocation( shader->program, #name ) )
    , ATTRIBUTE( aPosition )
    //, ATTRIBUTE( aWorld )
    , UNIFORM( uColor )
    #undef UNIFORM
    #undef ATTRIBUTE
{
    delete[] vertexStr;
    delete[] fragmentStr;
}

ShaderInterface::~ShaderInterface()
{
}
