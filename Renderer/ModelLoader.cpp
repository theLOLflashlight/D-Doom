#include "ModelLoader.h"

#include "Material.h"

#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtx/transform.hpp"

#include <memory>
#include <string>
#include <map>

using std::map;
using std::vector;
using std::string;
using std::shared_ptr;
using std::make_shared;
using glm::vec3;
using glm::vec2; 

using Mtllib = map< string, shared_ptr< Material > >;

bool load_materials( const char* mtlname, Mtllib& mtllib );

ObjMesh::ObjMesh( std::string path )
{
    FILE* file;
    if ( errno_t r = fopen_s( &file, path.c_str(), "r" ) )
    {
        printf( "Could not open the file: %s %d\n", path.c_str(), r );
        return;
    }

    vector< vec3 > list_v;
    vector< vec3 > list_vn;
    vector< vec2 > list_vt;
    Mtllib         mtllib;

    char lineHeader[ 128 ];
    while ( fscanf_s( file, "%s", lineHeader, 128 ) != EOF )
    {
        const string tag = lineHeader;

        if ( !tag.empty() && tag.front() == '#' )
        {
            char buff[ 512 ];
            fgets( buff, 512, file );
        }
        else if ( tag == "v" )
        {
            vec3 v;
            fscanf_s( file, "%f %f %f\n", &v.x, &v.y, &v.z );
            list_v.push_back( v );
        }
        else if ( tag == "vn" )
        {
            vec3 vn;
            fscanf_s( file, "%f %f %f\n", &vn.x, &vn.y, &vn.z );
            list_vn.push_back( vn );
        }
        else if ( tag == "vt" )
        {
            vec2 vt;
            fscanf_s( file, "%f %f\n", &vt.x, &vt.y );
            list_vt.push_back( vt );
        }
        else if ( tag == "f" )
        {
            GLuint v[3], vt[3], vn[3];
            int matches = fscanf_s( file, "%d/%d/%d %d/%d/%d %d/%d/%d\n",
                    &v[ 0 ], &vt[ 0 ], &vn[ 0 ],
                    &v[ 1 ], &vt[ 1 ], &vn[ 1 ], 
                    &v[ 2 ], &vt[ 2 ], &vn[ 2 ] );
            if ( matches != 9 )
            {
                printf( "Error parsing file\n" );
                fclose( file );
                return;
            }

            reserve( size() + 3 );
            for ( int i = 0; i < 3; i++ )
                emplace_back(
                    list_v[ v[ i ] - 1 ],
                    list_vn[ vn[ i ] - 1 ],
                    list_vt[ vt[ i ] - 1 ] );
        }
        else if ( tag == "mtllib" )
        {
            char mtl[ 128 ];
            fscanf_s( file, "%s\n", mtl, 128 );

            load_materials( mtl, mtllib );
        }
        else if ( tag == "usemtl" )
        {
            if ( !textures.empty() )
                textures.back().finish( size() );

            char mtl[ 128 ];
            fscanf_s( file, "%s\n", mtl, 128 );

            textures.emplace_back( mtllib[ mtl ], size() );
        }
    }

    if ( !textures.empty() )
        textures.back().finish( size() );
}

bool load_materials( const char* mtlname, Mtllib& mtllib )
{
    FILE* mtlfile;
    if ( fopen_s( &mtlfile, mtlname, "r" ) )
    {
        printf( "Could not open the mtl file: %s\n", mtlname );
        return false;
    }

    shared_ptr< Material > currmat = nullptr;
    char lineHeader[ 128 ];

    while ( fscanf_s( mtlfile, "%s", lineHeader, 128 ) != EOF )
    {
        const std::string tag = lineHeader;

        if ( !tag.empty() && tag.front() == '#' )
        {
            char buff[ 512 ];
            fgets( buff, 512, mtlfile );
        }
        else if ( tag == "newmtl" )
        {
            currmat = make_shared< Material >();
            fscanf_s( mtlfile, "%s\n", currmat->Name, 32 );
            mtllib[ currmat->Name ] = currmat;
        }
        else if ( currmat != nullptr )
        {
            if ( tag == "Ka" )
            {
                fscanf_s( mtlfile, "%f %f %f\n",
                          &currmat->Ka.r, &currmat->Ka.g, &currmat->Ka.b );
            }
            else if ( tag == "Kd" )
            {
                fscanf_s( mtlfile, "%f %f %f\n",
                          &currmat->Kd.r, &currmat->Kd.g, &currmat->Kd.b );
            }
            else if ( tag == "Ks" )
            {
                fscanf_s( mtlfile, "%f %f %f\n",
                          &currmat->Ks.r, &currmat->Ks.g, &currmat->Ks.b );
            }
            else if ( tag == "Ns" )
            {
                fscanf_s( mtlfile, "%f\n", &currmat->Ns );
            }
            else if ( tag == "d" )
            {
                fscanf_s( mtlfile, "%f\n", &currmat->d );
            }
            else if ( tag == "Tr" )
            {
                GLfloat Tr = 0;
                fscanf_s( mtlfile, "%f\n", &Tr );
                currmat->d = 1 - Tr;
            }
            else if ( tag == "map_Ka" )
            {
                char path[ 64 ];
                fscanf_s( mtlfile, "%s\n", &path, 64 );
                currmat->map_Ka = make_shared< GLTexture >( string( path ) );
            }
            else if ( tag == "map_Kd" )
            {
                char path[ 64 ];
                fscanf_s( mtlfile, "%s\n", &path, 64 );
                currmat->map_Kd = make_shared< GLTexture >( string( path ) );
            }
            else if ( tag == "map_Ks" )
            {
                char path[ 64 ];
                fscanf_s( mtlfile, "%s\n", &path, 64 );
                currmat->map_Ks = make_shared< GLTexture >( string( path ) );
            }
            else if ( tag == "map_Ns" )
            {
                char path[ 64 ];
                fscanf_s( mtlfile, "%s\n", &path, 64 );
                currmat->map_Ns = make_shared< GLTexture >( string( path ) );
            }
            else if ( tag == "map_d" )
            {
                char path[ 64 ];
                fscanf_s( mtlfile, "%s\n", &path, 64 );
                currmat->map_d = make_shared< GLTexture >( string( path ) );
            }
            else if ( tag == "map_bump" )
            {
                char path[ 64 ];
                fscanf_s( mtlfile, "%s\n", &path, 64 );
                currmat->map_bump = make_shared< GLTexture >( string( path ) );
            }
        }
    }

    fclose( mtlfile );
    return true;
}