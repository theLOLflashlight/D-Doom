#include "GLProgram.h"

#include <string>
#include <fstream>
#include <streambuf>

using std::string;
using std::vector;

GLProgram::GLProgram( GLProgram&& move )
    : glHandle( std::move( move.glHandle ) )
{
}

GLProgram& GLProgram::operator=( GLProgram&& move )
{
    glHandle = std::move( move.glHandle );
    return *this;
}

void GLProgram::link( GLShader* vert_shader, GLShader* frag_shader  )
{
    glAttachShader( glHandle, vert_shader->glHandle );
    glAttachShader( glHandle, frag_shader->glHandle );

    glLinkProgram( glHandle );

    //glDetachShader( glHandle, vert_shader->glHandle );
    //glDetachShader( glHandle, frag_shader->glHandle );

    Exception::status_t status;
    glGetProgramiv( glHandle, GL_LINK_STATUS, &status );

    if ( status == GL_FALSE )
    {
        int logLength;
        glGetProgramiv( glHandle, GL_INFO_LOG_LENGTH, &logLength );

        GLchar* log = new GLchar[ logLength ];
        glGetProgramInfoLog( glHandle, logLength, &logLength, log );
        printf_s( "Shader link log: %s\n", log, logLength );
        delete log;

        throw Exception( *this, Exception::LINK, status );
    }
}

bool GLProgram::validate()
{
    glValidateProgram( glHandle );

    Exception::status_t status;
    glGetProgramiv( glHandle, GL_VALIDATE_STATUS, &status );

    if ( status == GL_FALSE )
    {
        int logLength;
        glGetProgramiv( glHandle, GL_INFO_LOG_LENGTH, &logLength );
        GLchar* log = new GLchar[ logLength ];

        glGetProgramInfoLog( glHandle, logLength, &logLength, log );
        printf_s( "Shader validate log: %s\n", log, logLength );
        delete log;

        throw Exception( *this, Exception::INIT, status );
    }

    return true;
}

void GLProgram::bind()
{
    glUseProgram( glHandle );
}
