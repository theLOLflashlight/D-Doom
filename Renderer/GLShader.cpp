#include "GLShader.h"

#include <string>

using std::string;
using std::istream;

GLShader::GLShader( Type type, istream& source )
    : glHandle( glCreateShader( GLenum( type ) ) )
{
    using itr_t = std::istreambuf_iterator< char >;

    if ( source.fail() )
        throw Exception( *this, Exception::READ );

    const string shader_source( (itr_t( source )), itr_t() );
    const GLchar* src = shader_source.c_str();

    glShaderSource( glHandle, 1, &src, NULL );
    compile();
}

GLShader::GLShader( GLShader&& move )
    : glHandle( std::move( move.glHandle ) )
{
}

GLShader& GLShader::operator=( GLShader&& move )
{
    glHandle = std::move( move.glHandle );
    return *this;
}

void GLShader::compile()
{
    glCompileShader( glHandle );

    Exception::status_t status;
    glGetShaderiv( glHandle, GL_COMPILE_STATUS, &status );

    if ( status == GL_FALSE )
    {
        int logLength;
        glGetShaderiv( glHandle, GL_INFO_LOG_LENGTH, &logLength );

        GLchar* log = new GLchar[ logLength ];
        glGetShaderInfoLog( glHandle, logLength, &logLength, log );
        printf_s( "Shader compile log: %s\n", log, logLength );
        delete log;

        throw Exception( *this, Exception::COMPILE, status );
    }
}
