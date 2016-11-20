#
# GLSL textureless classic 3D noise "cnoise",
# with an RSL-style periodic variant "pnoise".
# Author:  Stefan Gustavson (stefan.gustavson@liu.se)
# Version: 2011-10-11
#
# Many thanks to Ian McEwan of Ashima Arts for the
# ideas for permutation and gradient selection.
#
# Copyright (c) 2011 Stefan Gustavson. All rights reserved.
# Distributed under the MIT license. See LICENSE file.
# https://github.com/stegu/webgl-noise
#

include shared

#[
vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec3 fade(vec3 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}
]#

# Classic Perlin noise
proc cnoise*(P: Vec3) : SomeReal =
  var  Pi0: Vec3 = floor(P); # Integer part for indexing
  var  Pi1: Vec3 = Pi0 + vec3(1.0); # Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  var  Pf0: Vec3 = fract(P); # Fractional part for interpolation
  var  Pf1: Vec3 = Pf0 - vec3(1.0); # Fractional part - 1.0
  var  ix: Vec4 = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  var  iy: Vec4 = vec4(Pi0.yy, Pi1.yy);
  var  iz0: Vec4 = Pi0.zzzz;
  var  iz1: Vec4 = Pi1.zzzz;

  var  ixy: Vec4 = permute(permute(ix) + iy);
  var  ixy0: Vec4 = permute(ixy + iz0);
  var  ixy1: Vec4 = permute(ixy + iz1);

  var  gx0: Vec4 = ixy0 * (1.0 / 7.0);
  var  gy0: Vec4 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  var  gz0: Vec4 = vec4(0.5) - abs(gx0) - abs(gy0);
  var  sz0: Vec4 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  var  gx1: Vec4 = ixy1 * (1.0 / 7.0);
  var  gy1: Vec4 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  var  gz1: Vec4 = vec4(0.5) - abs(gx1) - abs(gy1);
  var  sz1: Vec4 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  var  g000: Vec3 = vec3(gx0.x,gy0.x,gz0.x);
  var  g100: Vec3 = vec3(gx0.y,gy0.y,gz0.y);
  var  g010: Vec3 = vec3(gx0.z,gy0.z,gz0.z);
  var  g110: Vec3 = vec3(gx0.w,gy0.w,gz0.w);
  var  g001: Vec3 = vec3(gx1.x,gy1.x,gz1.x);
  var  g101: Vec3 = vec3(gx1.y,gy1.y,gz1.y);
  var  g011: Vec3 = vec3(gx1.z,gy1.z,gz1.z);
  var  g111: Vec3 = vec3(gx1.w,gy1.w,gz1.w);

  var  norm0: Vec4 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  var  norm1: Vec4 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  var n000 = dot(g000, Pf0);
  var n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  var n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  var n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  var n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  var n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  var n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  var n111 = dot(g111, Pf1);

  var  fade_xyz: Vec3 = fade(Pf0);
  var  n_z: Vec4 = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  var  n_yz: Vec2 = mix(n_z.xy, n_z.zw, fade_xyz.y);
  var n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;


# Classic Perlin noise, periodic variant
proc pnoise*(P: Vec3; rep: Vec3): float =
  var  Pi0: Vec3 = mod(floor(P), rep); # Integer part, modulo period
  var  Pi1: Vec3 = mod(Pi0 + vec3(1.0), rep); # Integer part + 1, mod period
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  var  Pf0: Vec3 = fract(P); # Fractional part for interpolation
  var  Pf1: Vec3 = Pf0 - vec3(1.0); # Fractional part - 1.0
  var  ix: Vec4 = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  var  iy: Vec4 = vec4(Pi0.yy, Pi1.yy);
  var  iz0: Vec4 = Pi0.zzzz;
  var  iz1: Vec4 = Pi1.zzzz;

  var  ixy: Vec4 = permute(permute(ix) + iy);
  var  ixy0: Vec4 = permute(ixy + iz0);
  var  ixy1: Vec4 = permute(ixy + iz1);

  var  gx0: Vec4 = ixy0 * (1.0 / 7.0);
  var  gy0: Vec4 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  var  gz0: Vec4 = vec4(0.5) - abs(gx0) - abs(gy0);
  var  sz0: Vec4 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  var  gx1: Vec4 = ixy1 * (1.0 / 7.0);
  var  gy1: Vec4 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  var  gz1: Vec4 = vec4(0.5) - abs(gx1) - abs(gy1);
  var  sz1: Vec4 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  var  g000: Vec3 = vec3(gx0.x,gy0.x,gz0.x);
  var  g100: Vec3 = vec3(gx0.y,gy0.y,gz0.y);
  var  g010: Vec3 = vec3(gx0.z,gy0.z,gz0.z);
  var  g110: Vec3 = vec3(gx0.w,gy0.w,gz0.w);
  var  g001: Vec3 = vec3(gx1.x,gy1.x,gz1.x);
  var  g101: Vec3 = vec3(gx1.y,gy1.y,gz1.y);
  var  g011: Vec3 = vec3(gx1.z,gy1.z,gz1.z);
  var  g111: Vec3 = vec3(gx1.w,gy1.w,gz1.w);

  var  norm0: Vec4 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  var norm1: Vec4 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  var n000 = dot(g000, Pf0);
  var n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  var n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  var n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  var n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  var n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  var n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  var n111 = dot(g111, Pf1);

  var  fade_xyz: Vec3 = fade(Pf0);
  var  n_z: Vec4 = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  var  n_yz: Vec2 = mix(n_z.xy, n_z.zw, fade_xyz.y);
  let n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;

