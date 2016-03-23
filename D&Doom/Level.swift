//
//  Level.swift
//  D&Doom
//
//  Created by Andrew Meckling on 2016-03-09.
//  Copyright © 2016 Andrew Meckling. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import OpenGLES

class Vertex
{
    var mPos = GLKVector3()
    var mNorm = GLKVector3()
    var mTexCoord = GLKVector2()
    
    init( pos : GLKVector3, norm : GLKVector3, coord : GLKVector2 )
    {
        mPos = pos
        mNorm = norm
        mTexCoord = coord
    }

}

enum ShaderAttribute : GLuint
{
    case Position
    case Normal
    case TexCoord
}

enum ShaderUniforms : Int
{
    case MVPMatrix
    case NormalMatrix
    case LightDirection
    case Matrix
    case Sampler
}

func setupTexture( filename: String ) -> GLuint
{
    let spriteImage = UIImage( named: filename )!.CGImage
    if spriteImage == nil
    {
        print( "Failed to load image \(filename)" )
        exit( 1 )
    }
    
    let width = CGImageGetWidth( spriteImage )
    let height = CGImageGetHeight( spriteImage )
    let width_f = CGFloat( width )
    let height_f = CGFloat( height )
    
    let spriteData = UnsafeMutablePointer< GLubyte >( calloc( width * height * 4, sizeof( GLubyte ) ) )
    
    let spriteContext = CGBitmapContextCreate( spriteData,
        width, height, 8, width * 4, CGImageGetColorSpace( spriteImage ),
        CGImageAlphaInfo.PremultipliedLast.rawValue )
    
    CGContextDrawImage( spriteContext, CGRectMake( 0, 0, width_f, height_f ), spriteImage )
    
    //CGContextRelease(spriteContext);
    
    var texName : GLuint = 0
    glGenTextures( 1, &texName )
    glBindTexture( GLenum( GL_TEXTURE_2D ), texName )
    //glTexStorage3D( GLenum( GL_TEXTURE_2D_ARRAY ), 1, GL_RGBA8, GLsizei( width ), GLsizei( height ), # )
    
    glTexParameteri( GLenum( GL_TEXTURE_2D ), GLenum( GL_TEXTURE_MIN_FILTER ), GL_NEAREST );
    
    glTexImage2D( GLenum( GL_TEXTURE_2D ), 0, GL_RGBA,
        GLsizei( width ), GLsizei( height ), 0,
        GLenum( GL_RGBA ), GLenum( GL_UNSIGNED_BYTE ), spriteData );
    
    free( spriteData )
    
    return texName;
}

func readFile( name: String, ext: String ) -> [String]?
{
    if let path = NSBundle.mainBundle().pathForResource( name, ofType: ext )
    {
        do {
            return try String( contentsOfFile: path ).componentsSeparatedByString( "\n" )
        }
        catch
        {
        }
    }
    return nil
}

struct Face
{
    var a : (Int, Int, Int)
    var b : (Int, Int, Int)
    var c : (Int, Int, Int)
    var texture : GLuint
    
    init( _ a: (Int, Int, Int), _ b: (Int, Int, Int), _ c: (Int, Int, Int), texture: GLuint = 0 )
    {
        self.a = a
        self.b = b
        self.c = c
        self.texture = texture
    }
}

class Level
{
    var mVertices = [Vertex]()
    var mTextures = [(GLuint, Int, Int)]()
    
    var mShader : GLShader
    
    var mVertexBuffer = GLuint()
    var mIndexBuffer = GLuint()
    var mModelMatrix = GLKMatrix4()
    //var mLightDirection : GLKVector3
    
    init( name: String )
    {
        mShader = GLShader( shaderName: "Shader",
            attributes: [ "Position", "Normal", "TexCoordIn" ],
            uniforms: [ "ModelViewProjectionMatrix", "NormalMatrix", "FlashlightPosition", "DiffuseLightPosition", "DiffuseComponent", "Shininess", "SpecularComponent", "AmbientComponent" ] )
        
        var mtllib = [String : GLuint]()
        var v = [GLKVector3]()
        var vn = [GLKVector3]()
        var vt = [GLKVector2]()
        var f = [Face]()
        var mtl : GLuint = 0
        
        for line in readFile( name, ext: "obj" )!
        {
            if line.isEmpty || line[ line.startIndex ] == "#"
            {
                continue
            }
            
            let tokens = line.componentsSeparatedByString( " " )
            
            func vec3( tokens: [String] ) -> GLKVector3
            {
                let tidx = tokens.startIndex
                let x = NSString( string: tokens[ tidx.advancedBy( 1 ) ] ).floatValue
                let y = NSString( string: tokens[ tidx.advancedBy( 2 ) ] ).floatValue
                let z = NSString( string: tokens[ tidx.advancedBy( 3 ) ] ).floatValue
                return GLKVector3( v: (x, y, z) )
            }
            
            func vec2( tokens: [String] ) -> GLKVector2
            {
                let tidx = tokens.startIndex
                let x = NSString( string: tokens[ tidx.advancedBy( 1 ) ] ).floatValue
                let y = NSString( string: tokens[ tidx.advancedBy( 2 ) ] ).floatValue
                return GLKVector2( v: (x, y) )
            }
            
            func face( tokens: [String] ) -> Face
            {
                func vert( vertex : String ) -> (Int, Int, Int)
                {
                    let indices = vertex.componentsSeparatedByString( "/" )
                    let idx = indices.startIndex
                    
                    let v = NSString( string: indices[ idx.advancedBy( 0 ) ] ).integerValue - 1
                    let vt = NSString( string: indices[ idx.advancedBy( 1 ) ] ).integerValue - 1
                    let vn = NSString( string: indices[ idx.advancedBy( 2 ) ] ).integerValue - 1
                    return (v, vt, vn)
                    
                }
                
                let tidx = tokens.startIndex
                return Face(
                    vert( tokens[ tidx.advancedBy( 1 ) ] ),
                    vert( tokens[ tidx.advancedBy( 2 ) ] ),
                    vert( tokens[ tidx.advancedBy( 3 ) ] ),
                    texture: mtl )
            }
            
            switch tokens[ tokens.startIndex ]
            {
            case "v" :
                v.append( vec3( tokens ) )
                
            case "vn" :
                vn.append( vec3( tokens ) )
                
            case "vt" :
                vt.append( vec2( tokens ) )
                
            case "f" :
                f.append( face( tokens ) )
                
            case "mtllib" :
                var mtlname = tokens[ tokens.startIndex.advancedBy( 1 ) ]
                mtlname = mtlname.substringToIndex( mtlname.endIndex.advancedBy( -4 ) )
                mtllib[ mtlname ] = setupTexture( mtlname + ".jpg" )
                
            case "usemtl" :
                let mtlname = tokens[ tokens.startIndex.advancedBy( 1 ) ]
                mtl = mtllib[ mtlname ]!
                
            default :
                break
            }
        }
        
        var i = 0
        for face in f.sort( { $0.texture < $1.texture } )
        {
            mVertices.append(
                Vertex( pos: v[ face.a.0 ], norm: vn[ face.a.2 ], coord: vt[ face.a.1 ] ) )
            mVertices.append(
                Vertex( pos: v[ face.b.0 ], norm: vn[ face.b.2 ], coord: vt[ face.b.1 ] ) )
            mVertices.append(
                Vertex( pos: v[ face.c.0 ], norm: vn[ face.c.2 ], coord: vt[ face.c.1 ] ) )
            
            if i == 0 || mTextures.last?.0 != face.texture
            {
                if i != 0
                {
                    mTextures[ mTextures.endIndex - 1 ].2 = i
                }
                mTextures.append( (face.texture, i, v.count) )
            }
            i += 3
        }
        
        var indices = [Int]( count: mVertices.count, repeatedValue: 0 )
        for i in 1...indices.count
        {
            indices[ i - 1 ] = i - 1
        }
        
        glGenBuffers( 1, &mVertexBuffer )
        glBindBuffer( GLenum( GL_ARRAY_BUFFER ), mVertexBuffer )
        glBufferData( GLenum( GL_ARRAY_BUFFER ), sizeof( Vertex ) * mVertices.count, mVertices, GLenum( GL_STATIC_DRAW ) )
        
        glGenBuffers( 1, &mIndexBuffer )
        glBindBuffer( GLenum( GL_ELEMENT_ARRAY_BUFFER ), mIndexBuffer )
        glBufferData( GLenum( GL_ELEMENT_ARRAY_BUFFER ), sizeof( Int ) * indices.count, indices, GLenum( GL_STATIC_DRAW ) )

    }
    
    deinit
    {
        
    }
    
    func render( proj: GLKMatrix4 )
    {
        func setup( attr: ShaderAttribute, _ size: Int32, _ type: Int32,
                    _ stride: Int, _ offset: Int = 0, _ normalized: Bool = false )
            -> Int
        {
            glEnableVertexAttribArray( attr.rawValue )
            glVertexAttribPointer(
                attr.rawValue,
                GLint( size ),
                GLenum( type ),
                GLboolean( normalized ? 1 : 0 ),
                GLsizei( stride ),
                UnsafePointer( mVertices ) + offset )
            
            return offset + stride
        }
        
        // Use the level's shader
        glUseProgram( mShader.program )
        glBindBuffer( GLenum( GL_ARRAY_BUFFER ), mVertexBuffer )
        
        var offset = setup( .Position, 3, GL_FLOAT, sizeof( GLKVector3 ) )
        offset = setup( .Normal, 3, GL_FLOAT, sizeof( GLKVector3 ), offset )
        offset = setup( .TexCoord, 2, GL_FLOAT, sizeof( GLKVector2 ), offset )
        //offset = setup( .Texture, 1, GL_INT, sizeof( GLuint ), offset )
        
        //glUniformMatrix4fv(
        //    mShader.uniforms[ ShaderUniforms.MVPMatrix.rawValue ],
        //    1, GL_FALSE, proj.m )
        
        glBindBuffer( GLenum( GL_ELEMENT_ARRAY_BUFFER ), mIndexBuffer )
        for texture in mTextures
        {
            let off = UnsafePointer<()>( bitPattern: texture.1 * sizeof( GLuint ) )
            let num = GLsizei( texture.2 - texture.1 )
            
            glBindTexture( GLenum( GL_TEXTURE_2D ), texture.0 )
            glDrawElements( GLenum( GL_TRIANGLES ), num, GLenum( GL_UNSIGNED_INT ), off )
        }
    }
}



















