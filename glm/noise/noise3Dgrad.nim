#
# Description : Array and textureless GLSL 2D/3D/4D simplex 
#               noise functions.
#      Author : Ian McEwan, Ashima Arts.
#  Maintainer : stegu
#     Lastmod : 20110822 (ijm)
#     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
#               Distributed under the MIT License. See LICENSE file.
#               https://github.com/ashima/webgl-noise
#               https://github.com/stegu/webgl-noise
# 

include shared

#[
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}
]#

proc snoise*(v: Vec3; gradient: var Vec3): float =
  const C: Vec2 = vec2(1.0/6.0, 1.0/3.0) ;
  const D: Vec4 = vec4(0.0, 0.5, 1.0, 2.0);

  # First corner
  var  i: Vec3  = floor(v + dot(v, C.yyy) );
  var  x0: Vec3 =   v - i + dot(i, C.xxx) ;

  # Other corners
  var  g: Vec3 = step(x0.yzx, x0.xyz);
  var  l: Vec3 = 1.0 - g;
  var  i1: Vec3 = min( g.xyz, l.zxy );
  var  i2: Vec3 = max( g.xyz, l.zxy );

  #   x0 = x0 - 0.0 + 0.0 * C.xxx;
  #   x1 = x0 - i1  + 1.0 * C.xxx;
  #   x2 = x0 - i2  + 2.0 * C.xxx;
  #   x3 = x0 - 1.0 + 3.0 * C.xxx;
  var  x1: Vec3 = x0 - i1 + C.xxx;
  var  x2: Vec3 = x0 - i2 + C.yyy; # 2.0*C.x = 1/3 = C.y
  var  x3: Vec3 = x0 - D.yyy;      # -1.0+3.0*C.x = -0.5 = -D.y

  # Permutations
  i = mod289(i); 
  var p: Vec4 = permute( permute( permute( i.z + vec4(0.0, i1.z, i2.z, 1.0 )) + i.y +
                         vec4(0.0, i1.y, i2.y, 1.0 )) + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

  # Gradients: 7x7 points over a square, mapped onto an octahedron.
  # The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  var ns: Vec3 = K * D.wyz - D.xzx;

  var j: Vec4 = p - 49.0 * floor(p * ns.z * ns.z);  #  mod(p,7*7)

  var  x_underscore: Vec4 = floor(j * ns.z);
  var  y_underscore: Vec4 = floor(j - 7.0 * x_underscore );    # mod(j,N)

  var  x: Vec4 = x_underscore * ns.x + ns.yyyy;
  var  y: Vec4 = y_underscore * ns.x + ns.yyyy;
  var  h: Vec4 = 1.0 - abs(x) - abs(y);

  var  b0: Vec4 = vec4( x.xy, y.xy );
  var  b1: Vec4 = vec4( x.zw, y.zw );

  #vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  #vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  var  s0: Vec4 = floor(b0)*2.0 + 1.0;
  var  s1: Vec4 = floor(b1)*2.0 + 1.0;
  var  sh: Vec4 = -step(h, vec4(0.0));

  var  a0: Vec4 = b0.xzyw + s0.xzyw*sh.xxyy ;
  var  a1: Vec4 = b1.xzyw + s1.xzyw*sh.zzww ;

  var  p0: Vec3 = vec3(a0.xy,h.x);
  var  p1: Vec3 = vec3(a0.zw,h.y);
  var  p2: Vec3 = vec3(a1.xy,h.z);
  var  p3: Vec3 = vec3(a1.zw,h.w);

  #Normalise gradients
  var norm: Vec4 = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  # Mix final noise value
  var  m: Vec4 = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  var  m2: Vec4 = m * m;
  var  m4: Vec4 = m2 * m2;
  var  pdotx: Vec4 = vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3));

  # Determine noise gradient
  var temp: Vec4 = m2 * m * pdotx;
  gradient = -8.0 * (temp.x * x0 + temp.y * x1 + temp.z * x2 + temp.w * x3);
  gradient += m4.x * p0 + m4.y * p1 + m4.z * p2 + m4.w * p3;
  gradient *= 42.0;

  return 42.0 * dot(m4, pdotx);
