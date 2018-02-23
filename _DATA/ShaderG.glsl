﻿#version 430

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%【ルーチン】

vec4 CrossProduct( vec4 A_, vec4 B_ )
{
  vec4 Result;

  Result.x = A_.y * B_.z - A_.z * B_.y;
  Result.y = A_.z * B_.x - A_.x * B_.z;
  Result.z = A_.x * B_.y - A_.y * B_.x;
  Result.w = 0;

  return Result;
}

vec4 FaceNorm( vec4 P1_, vec4 P2_, vec4 P3_ )
{
  return CrossProduct( P2_ - P1_, P3_ - P1_ );
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%【共通定数】

layout( std140 ) uniform TViewerScal
{
  layout( row_major ) mat4 _ViewerScal;
};

layout( std140 ) uniform TCameraProj
{
  layout( row_major ) mat4 _CameraProj;
};

layout( std140 ) uniform TCameraPose
{
  layout( row_major ) mat4 _CameraPose;
};

layout( std140 ) uniform TShaperPose
{
  layout( row_major ) mat4 _ShaperPose;
};

//------------------------------------------------------------------------------

uniform sampler3D _Voxels;

uniform sampler2D _Imager;

//############################################################################## ■

layout( points ) in;

in TSenderVG
{
  ivec3 Pos;
}
_Sender[ 1 ];

//------------------------------------------------------------------------------

layout( triangle_strip, max_vertices = 15 ) out;

out TSenderGF
{
  vec4 Pos;
  vec4 Nor;
}
_Result;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%【型】

struct TPoin
{
  vec4 Pos;
  vec4 Nor;
};

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%【ルーチン】

void AddPoin( TPoin Poin_ )
{
  _Result.Pos =                     _ShaperPose     * Poin_.Pos;
  _Result.Nor = transpose( inverse( _ShaperPose ) ) * Poin_.Nor;

  gl_Position = _ViewerScal * _CameraProj * inverse( _CameraPose ) * _Result.Pos;

  EmitVertex();
}

//------------------------------------------------------------------------------

void AddFace( TPoin P1_, TPoin P2_, TPoin P3_ )
{
  AddPoin( P1_ );
  AddPoin( P2_ );
  AddPoin( P3_ );

  EndPrimitive();
}

//------------------------------------------------------------------------------

void AddFaceFlat( TPoin P1_, TPoin P2_, TPoin P3_ )
{
  vec4 N = FaceNorm( P1_.Pos, P2_.Pos, P3_.Pos );

  P1_.Nor = N;
  P2_.Nor = N;
  P3_.Nor = N;

  AddFace( P1_, P2_, P3_ );
}

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

struct TTrias
{
  int   TsN;
  ivec3 Ts[ 5 ];
};

const TTrias TRIASTABLE[ 256 ] = TTrias[ 256 ](
  TTrias( 0, ivec3[ 5 ]( ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  0,  4,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  0,  9,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9,  4,  8 ), ivec3(  6,  4,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  1, 10,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  1,  8,  0 ), ivec3( 10,  8,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  9,  6 ), ivec3(  4,  1, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  1,  9,  6 ), ivec3(  1, 10,  9 ), ivec3( 10,  8,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  6, 11,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6, 11,  1 ), ivec3(  0,  4,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0, 11,  1 ), ivec3(  9, 11,  0 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  4, 11,  1 ), ivec3(  4,  8, 11 ), ivec3(  8,  9, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6, 10,  4 ), ivec3( 11, 10,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  6,  8,  0 ), ivec3(  6, 11,  8 ), ivec3( 11, 10,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  0, 10,  4 ), ivec3(  0,  9, 10 ), ivec3(  9, 11, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9, 11,  8 ), ivec3(  8, 11, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  8,  5,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  5,  2 ), ivec3(  4,  5,  0 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9,  6,  0 ), ivec3(  2,  8,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  9,  5,  2 ), ivec3(  9,  6,  5 ), ivec3(  6,  4,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  4,  1, 10 ), ivec3(  8,  5,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  5,  1, 10 ), ivec3(  5,  2,  1 ), ivec3(  2,  0,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  6,  0,  9 ), ivec3(  4,  1, 10 ), ivec3(  2,  8,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  1, 10,  5 ), ivec3(  6,  1,  5 ), ivec3(  6,  5,  2 ), ivec3(  6,  2,  9 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6, 11,  1 ), ivec3(  2,  8,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  0,  5,  2 ), ivec3(  0,  4,  5 ), ivec3(  1,  6, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  0, 11,  1 ), ivec3(  0,  9, 11 ), ivec3(  2,  8,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2,  9, 11 ), ivec3(  2, 11,  4 ), ivec3(  2,  4,  5 ), ivec3(  1,  4, 11 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 10,  6, 11 ), ivec3( 10,  4,  6 ), ivec3(  8,  5,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  6, 11, 10 ), ivec3(  6, 10,  2 ), ivec3(  6,  2,  0 ), ivec3(  2, 10,  5 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2,  8,  5 ), ivec3(  0,  9,  4 ), ivec3(  9, 10,  4 ), ivec3(  9, 11, 10 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  5,  2,  9 ), ivec3(  5,  9, 10 ), ivec3( 10,  9, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  9,  2,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  4,  8 ), ivec3(  9,  2,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6,  2,  7 ), ivec3(  0,  2,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  2,  4,  8 ), ivec3(  2,  7,  4 ), ivec3(  7,  6,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9,  2,  7 ), ivec3(  4,  1, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  8,  1, 10 ), ivec3(  8,  0,  1 ), ivec3(  9,  2,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  6,  2,  7 ), ivec3(  6,  0,  2 ), ivec3(  4,  1, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2,  7,  6 ), ivec3(  2,  6, 10 ), ivec3(  2, 10,  8 ), ivec3( 10,  6,  1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9,  2,  7 ), ivec3(  6, 11,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  8,  0,  4 ), ivec3(  9,  2,  7 ), ivec3(  1,  6, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 11,  2,  7 ), ivec3( 11,  1,  2 ), ivec3(  1,  0,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2,  7, 11 ), ivec3(  8,  2, 11 ), ivec3(  8, 11,  1 ), ivec3(  8,  1,  4 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  6, 10,  4 ), ivec3(  6, 11, 10 ), ivec3(  7,  9,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  7,  9,  2 ), ivec3(  6, 11,  0 ), ivec3( 11,  8,  0 ), ivec3( 11, 10,  8 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  4,  0,  2 ), ivec3(  4,  2, 11 ), ivec3(  4, 11, 10 ), ivec3(  7, 11,  2 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  2,  7, 11 ), ivec3(  2, 11,  8 ), ivec3(  8, 11, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  8,  7,  9 ), ivec3(  5,  7,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  0,  7,  9 ), ivec3(  0,  4,  7 ), ivec3(  4,  5,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  8,  6,  0 ), ivec3(  8,  5,  6 ), ivec3(  5,  7,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6,  4,  7 ), ivec3(  7,  4,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  8,  7,  9 ), ivec3(  8,  5,  7 ), ivec3( 10,  4,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  9,  5,  7 ), ivec3(  9,  1,  5 ), ivec3(  9,  0,  1 ), ivec3( 10,  5,  1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  1, 10,  4 ), ivec3(  6,  0,  5 ), ivec3(  6,  5,  7 ), ivec3(  5,  0,  8 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  1, 10,  5 ), ivec3(  1,  5,  6 ), ivec3(  6,  5,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  7,  8,  5 ), ivec3(  7,  9,  8 ), ivec3(  6, 11,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  1,  6, 11 ), ivec3(  0,  4,  9 ), ivec3(  4,  7,  9 ), ivec3(  4,  5,  7 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 11,  1,  0 ), ivec3( 11,  0,  5 ), ivec3( 11,  5,  7 ), ivec3(  5,  0,  8 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 11,  1,  4 ), ivec3( 11,  4,  7 ), ivec3(  7,  4,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  6, 11,  4 ), ivec3(  4, 11, 10 ), ivec3(  7,  9,  8 ), ivec3(  7,  8,  5 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3( 11, 10,  0 ), ivec3( 11,  0,  6 ), ivec3( 10,  5,  0 ), ivec3(  9,  0,  7 ), ivec3(  5,  7,  0 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  5,  7,  0 ), ivec3(  5,  0,  8 ), ivec3(  7, 11,  0 ), ivec3(  4,  0, 10 ), ivec3( 11, 10,  0 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  5,  7, 11 ), ivec3( 10,  5, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3( 10,  3,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  8,  0,  4 ), ivec3(  5, 10,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  9,  6 ), ivec3(  5, 10,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  4,  9,  6 ), ivec3(  4,  8,  9 ), ivec3(  5, 10,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  3,  4,  1 ), ivec3(  5,  4,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  8,  3,  5 ), ivec3(  8,  0,  3 ), ivec3(  0,  1,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  4,  3,  5 ), ivec3(  4,  1,  3 ), ivec3(  6,  0,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  6,  1,  3 ), ivec3(  6,  3,  8 ), ivec3(  6,  8,  9 ), ivec3(  5,  8,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  1,  6, 11 ), ivec3( 10,  3,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  0,  4,  8 ), ivec3(  1,  6, 11 ), ivec3(  5, 10,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 11,  0,  9 ), ivec3( 11,  1,  0 ), ivec3( 10,  3,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  5, 10,  3 ), ivec3(  4,  8,  1 ), ivec3(  8, 11,  1 ), ivec3(  8,  9, 11 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  3,  6, 11 ), ivec3(  3,  5,  6 ), ivec3(  5,  4,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  8,  3,  5 ), ivec3(  0,  3,  8 ), ivec3(  0, 11,  3 ), ivec3(  0,  6, 11 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0,  5,  4 ), ivec3(  0, 11,  5 ), ivec3(  0,  9, 11 ), ivec3( 11,  3,  5 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  3,  5,  8 ), ivec3(  3,  8, 11 ), ivec3( 11,  8,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3( 10,  2,  8 ), ivec3(  3,  2, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 10,  0,  4 ), ivec3( 10,  3,  0 ), ivec3(  3,  2,  0 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  2, 10,  3 ), ivec3(  2,  8, 10 ), ivec3(  0,  9,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  9,  3,  2 ), ivec3(  9,  4,  3 ), ivec3(  9,  6,  4 ), ivec3(  4, 10,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  4,  2,  8 ), ivec3(  4,  1,  2 ), ivec3(  1,  3,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  1,  2 ), ivec3(  1,  3,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  9,  6,  0 ), ivec3(  2,  8,  1 ), ivec3(  2,  1,  3 ), ivec3(  1,  8,  4 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  9,  6,  1 ), ivec3(  9,  1,  2 ), ivec3(  2,  1,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 10,  2,  8 ), ivec3( 10,  3,  2 ), ivec3( 11,  1,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  6, 11,  1 ), ivec3(  0,  4,  3 ), ivec3(  0,  3,  2 ), ivec3(  3,  4, 10 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  8,  3,  2 ), ivec3(  8, 10,  3 ), ivec3(  9, 11,  0 ), ivec3( 11,  1,  0 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  3,  2,  4 ), ivec3(  3,  4, 10 ), ivec3(  2,  9,  4 ), ivec3(  1,  4, 11 ), ivec3(  9, 11,  4 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 11,  4,  6 ), ivec3( 11,  2,  4 ), ivec3( 11,  3,  2 ), ivec3(  8,  4,  2 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  6, 11,  3 ), ivec3(  6,  3,  0 ), ivec3(  0,  3,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  9, 11,  4 ), ivec3(  9,  4,  0 ), ivec3( 11,  3,  4 ), ivec3(  8,  4,  2 ), ivec3(  3,  2,  4 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9, 11,  3 ), ivec3(  2,  9,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  7,  9,  2 ), ivec3(  3,  5, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  9,  2,  7 ), ivec3(  8,  0,  4 ), ivec3(  3,  5, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  2,  6,  0 ), ivec3(  2,  7,  6 ), ivec3(  3,  5, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  3,  5, 10 ), ivec3(  2,  7,  8 ), ivec3(  7,  4,  8 ), ivec3(  7,  6,  4 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  3,  4,  1 ), ivec3(  3,  5,  4 ), ivec3(  2,  7,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  9,  2,  7 ), ivec3(  8,  0,  5 ), ivec3(  0,  3,  5 ), ivec3(  0,  1,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  1,  5,  4 ), ivec3(  1,  3,  5 ), ivec3(  0,  2,  6 ), ivec3(  2,  7,  6 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  7,  6,  8 ), ivec3(  7,  8,  2 ), ivec3(  6,  1,  8 ), ivec3(  5,  8,  3 ), ivec3(  1,  3,  8 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  6, 11,  1 ), ivec3(  7,  9,  2 ), ivec3( 10,  3,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  3,  5, 10 ), ivec3(  9,  2,  7 ), ivec3(  0,  4,  8 ), ivec3(  1,  6, 11 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 10,  3,  5 ), ivec3( 11,  1,  7 ), ivec3(  1,  2,  7 ), ivec3(  1,  0,  2 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  8,  1,  4 ), ivec3(  8, 11,  1 ), ivec3(  8,  2, 11 ), ivec3(  7, 11,  2 ), ivec3(  5, 10,  3 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  9,  2,  7 ), ivec3(  6, 11,  5 ), ivec3(  6,  5,  4 ), ivec3(  5, 11,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  0,  5,  8 ), ivec3(  0,  3,  5 ), ivec3(  0,  6,  3 ), ivec3( 11,  3,  6 ), ivec3(  9,  2,  7 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  5,  4, 11 ), ivec3(  5, 11,  3 ), ivec3(  4,  0, 11 ), ivec3(  7, 11,  2 ), ivec3(  0,  2, 11 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  3,  5,  8 ), ivec3(  3,  8, 11 ), ivec3(  2,  7,  8 ), ivec3(  7, 11,  8 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  7, 10,  3 ), ivec3(  7,  9, 10 ), ivec3(  9,  8, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  7, 10,  3 ), ivec3(  9, 10,  7 ), ivec3(  9,  4, 10 ), ivec3(  9,  0,  4 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0,  8, 10 ), ivec3(  0, 10,  7 ), ivec3(  0,  7,  6 ), ivec3(  3,  7, 10 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 10,  3,  7 ), ivec3( 10,  7,  4 ), ivec3(  4,  7,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  4,  9,  8 ), ivec3(  4,  3,  9 ), ivec3(  4,  1,  3 ), ivec3(  3,  7,  9 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  7,  9,  0 ), ivec3(  7,  0,  3 ), ivec3(  3,  0,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  1,  3,  8 ), ivec3(  1,  8,  4 ), ivec3(  3,  7,  8 ), ivec3(  0,  8,  6 ), ivec3(  7,  6,  8 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  7,  6,  1 ), ivec3(  3,  7,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  6, 11,  1 ), ivec3(  7,  9,  3 ), ivec3(  9, 10,  3 ), ivec3(  9,  8, 10 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  9,  3,  7 ), ivec3(  9, 10,  3 ), ivec3(  9,  0, 10 ), ivec3(  4, 10,  0 ), ivec3(  6, 11,  1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  1,  0,  7 ), ivec3(  1,  7, 11 ), ivec3(  0,  8,  7 ), ivec3(  3,  7, 10 ), ivec3(  8, 10,  7 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 10,  3,  7 ), ivec3( 10,  7,  4 ), ivec3( 11,  1,  7 ), ivec3(  1,  4,  7 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  9,  8,  3 ), ivec3(  9,  3,  7 ), ivec3(  8,  4,  3 ), ivec3( 11,  3,  6 ), ivec3(  4,  6,  3 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  7,  9,  0 ), ivec3(  7,  0,  3 ), ivec3(  6, 11,  0 ), ivec3( 11,  3,  0 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  8,  4 ), ivec3( 11,  3,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  7, 11,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  7,  3, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  4,  8 ), ivec3( 11,  7,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6,  0,  9 ), ivec3( 11,  7,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  9,  4,  8 ), ivec3(  9,  6,  4 ), ivec3( 11,  7,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3( 11,  7,  3 ), ivec3(  1, 10,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  1,  8,  0 ), ivec3(  1, 10,  8 ), ivec3(  3, 11,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  9,  6,  0 ), ivec3( 11,  7,  3 ), ivec3(  4,  1, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  7,  3, 11 ), ivec3(  9,  6, 10 ), ivec3(  9, 10,  8 ), ivec3( 10,  6,  1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  7,  1,  6 ), ivec3(  3,  1,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  1,  7,  3 ), ivec3(  1,  6,  7 ), ivec3(  0,  4,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  7,  0,  9 ), ivec3(  7,  3,  0 ), ivec3(  3,  1,  0 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  4,  8,  9 ), ivec3(  4,  9,  3 ), ivec3(  4,  3,  1 ), ivec3(  3,  9,  7 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 10,  7,  3 ), ivec3( 10,  4,  7 ), ivec3(  4,  6,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0, 10,  8 ), ivec3(  0,  7, 10 ), ivec3(  0,  6,  7 ), ivec3(  3, 10,  7 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  7,  3, 10 ), ivec3(  9,  7, 10 ), ivec3(  9, 10,  4 ), ivec3(  9,  4,  0 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  7,  3, 10 ), ivec3(  7, 10,  9 ), ivec3(  9, 10,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  2,  8,  5 ), ivec3(  7,  3, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  5,  0,  4 ), ivec3(  5,  2,  0 ), ivec3(  7,  3, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  0,  9,  6 ), ivec3(  2,  8,  5 ), ivec3( 11,  7,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 11,  7,  3 ), ivec3(  9,  6,  2 ), ivec3(  6,  5,  2 ), ivec3(  6,  4,  5 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  8,  5,  2 ), ivec3( 10,  4,  1 ), ivec3(  7,  3, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 11,  7,  3 ), ivec3(  1, 10,  2 ), ivec3(  1,  2,  0 ), ivec3(  2, 10,  5 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0,  9,  6 ), ivec3(  1, 10,  4 ), ivec3(  2,  8,  5 ), ivec3( 11,  7,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  6,  2,  9 ), ivec3(  6,  5,  2 ), ivec3(  6,  1,  5 ), ivec3( 10,  5,  1 ), ivec3( 11,  7,  3 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  7,  1,  6 ), ivec3(  7,  3,  1 ), ivec3(  5,  2,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0,  4,  2 ), ivec3(  2,  4,  5 ), ivec3(  1,  6,  7 ), ivec3(  1,  7,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  8,  5,  2 ), ivec3(  0,  9,  3 ), ivec3(  0,  3,  1 ), ivec3(  3,  9,  7 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  3,  1,  9 ), ivec3(  3,  9,  7 ), ivec3(  1,  4,  9 ), ivec3(  2,  9,  5 ), ivec3(  4,  5,  9 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2,  8,  5 ), ivec3(  7,  3,  4 ), ivec3(  7,  4,  6 ), ivec3(  4,  3, 10 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  2,  0, 10 ), ivec3(  2, 10,  5 ), ivec3(  0,  6, 10 ), ivec3(  3, 10,  7 ), ivec3(  6,  7, 10 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  9,  4,  0 ), ivec3(  9, 10,  4 ), ivec3(  9,  7, 10 ), ivec3(  3, 10,  7 ), ivec3(  2,  8,  5 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  5,  2,  9 ), ivec3(  5,  9, 10 ), ivec3(  7,  3,  9 ), ivec3(  3, 10,  9 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9,  3, 11 ), ivec3(  2,  3,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  9,  3, 11 ), ivec3(  9,  2,  3 ), ivec3(  8,  0,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  6,  3, 11 ), ivec3(  6,  0,  3 ), ivec3(  0,  2,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 11,  6,  4 ), ivec3( 11,  4,  2 ), ivec3( 11,  2,  3 ), ivec3(  8,  2,  4 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  3,  9,  2 ), ivec3(  3, 11,  9 ), ivec3(  1, 10,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  9,  2, 11 ), ivec3( 11,  2,  3 ), ivec3(  8,  0,  1 ), ivec3(  8,  1, 10 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  4,  1, 10 ), ivec3(  6,  0, 11 ), ivec3(  0,  3, 11 ), ivec3(  0,  2,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3( 10,  8,  6 ), ivec3( 10,  6,  1 ), ivec3(  8,  2,  6 ), ivec3( 11,  6,  3 ), ivec3(  2,  3,  6 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  9,  1,  6 ), ivec3(  9,  2,  1 ), ivec3(  2,  3,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  8,  0,  4 ), ivec3(  9,  2,  6 ), ivec3(  2,  1,  6 ), ivec3(  2,  3,  1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  2,  1 ), ivec3(  1,  2,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  4,  8,  2 ), ivec3(  4,  2,  1 ), ivec3(  1,  2,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  9,  2,  3 ), ivec3(  9,  3,  4 ), ivec3(  9,  4,  6 ), ivec3(  4,  3, 10 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  2,  3,  6 ), ivec3(  2,  6,  9 ), ivec3(  3, 10,  6 ), ivec3(  0,  6,  8 ), ivec3( 10,  8,  6 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 10,  4,  0 ), ivec3( 10,  0,  3 ), ivec3(  3,  0,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3( 10,  8,  2 ), ivec3(  3, 10,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  3,  8,  5 ), ivec3(  3, 11,  8 ), ivec3( 11,  9,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0,  4,  5 ), ivec3(  0,  5, 11 ), ivec3(  0, 11,  9 ), ivec3( 11,  5,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  8,  5,  3 ), ivec3(  0,  8,  3 ), ivec3(  0,  3, 11 ), ivec3(  0, 11,  6 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  3, 11,  6 ), ivec3(  3,  6,  5 ), ivec3(  5,  6,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  4,  1, 10 ), ivec3(  8,  5, 11 ), ivec3(  8, 11,  9 ), ivec3( 11,  5,  3 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3( 11,  9,  5 ), ivec3( 11,  5,  3 ), ivec3(  9,  0,  5 ), ivec3( 10,  5,  1 ), ivec3(  0,  1,  5 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  0, 11,  6 ), ivec3(  0,  3, 11 ), ivec3(  0,  8,  3 ), ivec3(  5,  3,  8 ), ivec3(  4,  1, 10 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  3, 11,  6 ), ivec3(  3,  6,  5 ), ivec3(  1, 10,  6 ), ivec3( 10,  5,  6 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  6,  3,  1 ), ivec3(  6,  8,  3 ), ivec3(  6,  9,  8 ), ivec3(  5,  3,  8 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  4,  5,  9 ), ivec3(  4,  9,  0 ), ivec3(  5,  3,  9 ), ivec3(  6,  9,  1 ), ivec3(  3,  1,  9 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  8,  5,  3 ), ivec3(  8,  3,  0 ), ivec3(  0,  3,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  3,  1,  4 ), ivec3(  5,  3,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  4,  6,  3 ), ivec3(  4,  3, 10 ), ivec3(  6,  9,  3 ), ivec3(  5,  3,  8 ), ivec3(  9,  8,  3 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  6,  9 ), ivec3(  5,  3, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 10,  4,  0 ), ivec3( 10,  0,  3 ), ivec3(  8,  5,  0 ), ivec3(  5,  3,  0 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3( 10,  5,  3 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  5, 11,  7 ), ivec3( 10, 11,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  5, 11,  7 ), ivec3(  5, 10, 11 ), ivec3(  4,  8,  0 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 11,  5, 10 ), ivec3( 11,  7,  5 ), ivec3(  9,  6,  0 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  7, 10, 11 ), ivec3(  7,  5, 10 ), ivec3(  6,  4,  9 ), ivec3(  4,  8,  9 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 11,  4,  1 ), ivec3( 11,  7,  4 ), ivec3(  7,  5,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 11,  0,  1 ), ivec3( 11,  5,  0 ), ivec3( 11,  7,  5 ), ivec3(  5,  8,  0 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0,  9,  6 ), ivec3(  4,  1,  7 ), ivec3(  4,  7,  5 ), ivec3(  7,  1, 11 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  7,  5,  1 ), ivec3(  7,  1, 11 ), ivec3(  5,  8,  1 ), ivec3(  6,  1,  9 ), ivec3(  8,  9,  1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  1,  5, 10 ), ivec3(  1,  6,  5 ), ivec3(  6,  7,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0,  4,  8 ), ivec3(  1,  6, 10 ), ivec3(  6,  5, 10 ), ivec3(  6,  7,  5 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  9,  7,  5 ), ivec3(  9,  5,  1 ), ivec3(  9,  1,  0 ), ivec3( 10,  1,  5 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  8,  9,  1 ), ivec3(  8,  1,  4 ), ivec3(  9,  7,  1 ), ivec3( 10,  1,  5 ), ivec3(  7,  5,  1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6,  7,  4 ), ivec3(  7,  5,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  8,  0,  6 ), ivec3(  8,  6,  5 ), ivec3(  5,  6,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  0,  9,  7 ), ivec3(  0,  7,  4 ), ivec3(  4,  7,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  8,  9,  7 ), ivec3(  5,  8,  7 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  2, 11,  7 ), ivec3(  2,  8, 11 ), ivec3(  8, 10, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  4,  2,  0 ), ivec3(  4, 11,  2 ), ivec3(  4, 10, 11 ), ivec3(  7,  2, 11 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  6,  0,  9 ), ivec3( 11,  7,  8 ), ivec3( 11,  8, 10 ), ivec3(  8,  7,  2 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  6,  4,  2 ), ivec3(  6,  2,  9 ), ivec3(  4, 10,  2 ), ivec3(  7,  2, 11 ), ivec3( 10, 11,  2 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2, 11,  7 ), ivec3(  8, 11,  2 ), ivec3(  8,  1, 11 ), ivec3(  8,  4,  1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3( 11,  7,  2 ), ivec3( 11,  2,  1 ), ivec3(  1,  2,  0 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  8,  7,  2 ), ivec3(  8, 11,  7 ), ivec3(  8,  4, 11 ), ivec3(  1, 11,  4 ), ivec3(  0,  9,  6 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3( 11,  7,  2 ), ivec3( 11,  2,  1 ), ivec3(  9,  6,  2 ), ivec3(  6,  1,  2 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2,  6,  7 ), ivec3(  2, 10,  6 ), ivec3(  2,  8, 10 ), ivec3( 10,  1,  6 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  6,  7, 10 ), ivec3(  6, 10,  1 ), ivec3(  7,  2, 10 ), ivec3(  4, 10,  0 ), ivec3(  2,  0, 10 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  8, 10,  7 ), ivec3(  8,  7,  2 ), ivec3( 10,  1,  7 ), ivec3(  9,  7,  0 ), ivec3(  1,  0,  7 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9,  7,  2 ), ivec3(  4, 10,  1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  2,  8,  4 ), ivec3(  2,  4,  7 ), ivec3(  7,  4,  6 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6,  7,  2 ), ivec3(  0,  6,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2,  8,  4 ), ivec3(  2,  4,  7 ), ivec3(  0,  9,  4 ), ivec3(  9,  7,  4 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  9,  7,  2 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  5,  9,  2 ), ivec3(  5, 10,  9 ), ivec3( 10, 11,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  0,  4,  8 ), ivec3(  9,  2, 10 ), ivec3(  9, 10, 11 ), ivec3( 10,  2,  5 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  6, 10, 11 ), ivec3(  6,  2, 10 ), ivec3(  6,  0,  2 ), ivec3(  2,  5, 10 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3( 10, 11,  2 ), ivec3( 10,  2,  5 ), ivec3( 11,  6,  2 ), ivec3(  8,  2,  4 ), ivec3(  6,  4,  2 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  2, 11,  9 ), ivec3(  2,  4, 11 ), ivec3(  2,  5,  4 ), ivec3(  1, 11,  4 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  0,  1,  5 ), ivec3(  0,  5,  8 ), ivec3(  1, 11,  5 ), ivec3(  2,  5,  9 ), ivec3( 11,  9,  5 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  0,  2, 11 ), ivec3(  0, 11,  6 ), ivec3(  2,  5, 11 ), ivec3(  1, 11,  4 ), ivec3(  5,  4, 11 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6,  1, 11 ), ivec3(  2,  5,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  1,  5, 10 ), ivec3(  6,  5,  1 ), ivec3(  6,  2,  5 ), ivec3(  6,  9,  2 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 5, ivec3[ 5 ]( ivec3(  6, 10,  1 ), ivec3(  6,  5, 10 ), ivec3(  6,  9,  5 ), ivec3(  2,  5,  9 ), ivec3(  0,  4,  8 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  5, 10,  1 ), ivec3(  5,  1,  2 ), ivec3(  2,  1,  0 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  5, 10,  1 ), ivec3(  5,  1,  2 ), ivec3(  4,  8,  1 ), ivec3(  8,  2,  1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  9,  2,  5 ), ivec3(  9,  5,  6 ), ivec3(  6,  5,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  8,  0,  6 ), ivec3(  8,  6,  5 ), ivec3(  9,  2,  6 ), ivec3(  2,  5,  6 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  2,  5 ), ivec3(  4,  0,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  8,  2,  5 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9,  8, 11 ), ivec3(  8, 10, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  0,  4, 10 ), ivec3(  0, 10,  9 ), ivec3(  9, 10, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  6,  0,  8 ), ivec3(  6,  8, 11 ), ivec3( 11,  8, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  6,  4, 10 ), ivec3( 11,  6, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  4,  1, 11 ), ivec3(  4, 11,  8 ), ivec3(  8, 11,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  0,  1, 11 ), ivec3(  9,  0, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  4,  1, 11 ), ivec3(  4, 11,  8 ), ivec3(  6,  0, 11 ), ivec3(  0,  8, 11 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  6,  1, 11 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 3, ivec3[ 5 ]( ivec3(  1,  6,  9 ), ivec3(  1,  9, 10 ), ivec3( 10,  9,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 4, ivec3[ 5 ]( ivec3(  1,  6,  9 ), ivec3(  1,  9, 10 ), ivec3(  0,  4,  9 ), ivec3(  4, 10,  9 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  1,  0,  8 ), ivec3( 10,  1,  8 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  1,  4, 10 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 2, ivec3[ 5 ]( ivec3(  9,  8,  4 ), ivec3(  6,  9,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  0,  6,  9 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 1, ivec3[ 5 ]( ivec3(  0,  8,  4 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) ),
  TTrias( 0, ivec3[ 5 ]( ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ), ivec3( -1, -1, -1 ) ) )
);

const ivec3 _VoxelsN = textureSize( _Voxels, 0 ) - ivec3( 1 );

float GetVoxel( int X, int Y, int Z )
{
  return texelFetch( _Voxels, ivec3( X, Y, Z ), 0 ).x;
}

float GetInterp( float X, float Y, float Z )
{
  return texture( _Voxels, vec3( X / _VoxelsN.x,
                                 Y / _VoxelsN.y,
                                 Z / _VoxelsN.z ) ).x;
}

vec4 GetGrad( vec3 P )
{
  vec4 Result;

  Result.x = GetInterp( P.x+1, P.y  , P.z   ) - GetInterp( P.x-1, P.y  , P.z   );
  Result.y = GetInterp( P.x  , P.y+1, P.z   ) - GetInterp( P.x  , P.y-1, P.z   );
  Result.z = GetInterp( P.x  , P.y  , P.z+1 ) - GetInterp( P.x  , P.y  , P.z-1 );
  Result.w = 0;

  return Result;
}

const int X0 = _Sender[ 0 ].Pos.x;  const int X1 = X0 + 1;
const int Y0 = _Sender[ 0 ].Pos.y;  const int Y1 = Y0 + 1;
const int Z0 = _Sender[ 0 ].Pos.z;  const int Z1 = Z0 + 1;

//          020---------021---------022
//          /|          /|          /|
//         / |         / |         / |
//        /  |        /  |        /  |
//      120---------121---------122  |
//      /|   |      /|   |      /|   |
//     / |  010----/-|--011----/-|--012
//    /  |  /|    /  |  /|    /  |  /|
//  220---------221---------222  | / |
//   |   |/  |   |   |/  |   |   |/  |
//   |  110------|--111------|--112  |
//   |  /|   |   |  /|   |   |  /|   |
//   | / |  000--|-/-|--001--|-/-|--002
//   |/  |  /    |/  |  /    |/  |  /
//  210---------211---------212  | /
//   |   |/      |   |/      |   |/
//   |  100------|--101------|--102
//   |  /        |  /        |  /
//   | /         | /         | /
//   |/          |/          |/
//  200---------201---------202

const float G000 = GetVoxel( X0, Y0, Z0 );
const float G001 = GetVoxel( X1, Y0, Z0 );
const float G010 = GetVoxel( X0, Y1, Z0 );
const float G011 = GetVoxel( X1, Y1, Z0 );
const float G100 = GetVoxel( X0, Y0, Z1 );
const float G101 = GetVoxel( X1, Y0, Z1 );
const float G110 = GetVoxel( X0, Y1, Z1 );
const float G111 = GetVoxel( X1, Y1, Z1 );

int CubeKind()
{
  int Result = 0;
  if ( G000 < 0 ) Result += 0x01;  // 00000001
  if ( G001 < 0 ) Result += 0x02;  // 00000010
  if ( G010 < 0 ) Result += 0x04;  // 00000100
  if ( G011 < 0 ) Result += 0x08;  // 00001000
  if ( G100 < 0 ) Result += 0x10;  // 00010000
  if ( G101 < 0 ) Result += 0x20;  // 00100000
  if ( G110 < 0 ) Result += 0x40;  // 01000000
  if ( G111 < 0 ) Result += 0x80;  // 10000000
  return Result;
}

TPoin MakePoin( int I_ )
{
  TPoin Result;

  float T;
  switch ( I_ )
  {
    case  0:
      T = G000 / ( G000 - G001 );
      Result.Pos = vec4( X0+T, Y0, Z0, 1 );
      break;
    case  1:
      T = G010 / ( G010 - G011 );
      Result.Pos = vec4( X0+T, Y1, Z0, 1 );
      break;
    case  2:
      T = G100 / ( G100 - G101 );
      Result.Pos = vec4( X0+T, Y0, Z1, 1 );
      break;
    case  3:
      T = G110 / ( G110 - G111 );
      Result.Pos = vec4( X0+T, Y1, Z1, 1 );
      break;
    case  4:
      T = G000 / ( G000 - G010 );
      Result.Pos = vec4( X0, Y0+T, Z0, 1 );
      break;
    case  5:
      T = G100 / ( G100 - G110 );
      Result.Pos = vec4( X0, Y0+T, Z1, 1 );
      break;
    case  6:
      T = G001 / ( G001 - G011 );
      Result.Pos = vec4( X1, Y0+T, Z0, 1 );
      break;
    case  7:
      T = G101 / ( G101 - G111 );
      Result.Pos = vec4( X1, Y0+T, Z1, 1 );
      break;
    case  8:
      T = G000 / ( G000 - G100 );
      Result.Pos = vec4( X0, Y0, Z0+T, 1 );
      break;
    case  9:
      T = G001 / ( G001 - G101 );
      Result.Pos = vec4( X1, Y0, Z0+T, 1 );
      break;
    case 10:
      T = G010 / ( G010 - G110 );
      Result.Pos = vec4( X0, Y1, Z0+T, 1 );
      break;
    case 11:
      T = G011 / ( G011 - G111 );
      Result.Pos = vec4( X1, Y1, Z0+T, 1 );
      break;
  }

  Result.Nor = GetGrad( Result.Pos.xyz );

  Result.Pos = vec4( Result.Pos.xyz / 100.0, 1 );

  return Result;
}

void main()
{
  const int K = CubeKind();

  TPoin P1, P2, P3;

  for( int I = 0; I < TRIASTABLE[ K ].TsN; I++ )
  {
    ivec3 P = TRIASTABLE[ K ].Ts[ I ];

    P1 = MakePoin( P.x );
    P2 = MakePoin( P.y );
    P3 = MakePoin( P.z );

    AddFace( P1, P2, P3 );
  }
}

//############################################################################## ■