#pragma once

#include "GLHandle.h"

#include <istream>

class GLShader
{
public:
    using ptr_t = std::shared_ptr< GLShader >;

    enum Type {
        FRAGMENT = GL_FRAGMENT_SHADER,
        VERTEX = GL_VERTEX_SHADER,
    };

    GLHandle    glHandle;

    GLShader( Type type, std::istream& source );

    GLShader( GLShader&& move );
    GLShader& operator =( GLShader&& move );

    void compile();


    struct Exception
        : GLException
    {
        enum Type {
            INIT, READ, COMPILE
        };

        Type type;
        status_t status;

        Exception( const GLShader& shader, Type type, status_t status = 0 )
            : GLException( shader.glHandle )
            , type( type )
            , status( status )
        {
        }
    };
};

