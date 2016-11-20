#
# GLSL textureless classic 2D noise "cnoise",
# with an RSL-style periodic variant "pnoise".
# Author:  Stefan Gustavson (stefan.gustavson@liu.se)
# Version: 2011-08-22
#
# Many thanks to Ian McEwan of Ashima Arts for the
# ideas for permutation and gradient selection.
#
# Copyright (c) 2011 Stefan Gustavson. All rights reserved.
# Distributed under the MIT license. See LICENSE file.
# https://github.com/stegu/webgl-noise
#

include shared

# Classic Perlin noise
proc cnoise*[T](P: Vec2[T]): T =
  var Pi: Vec4[T] = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  var Pf: Vec4[T] = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod289(Pi); # To avoid truncation effects in permutation
  var ix: Vec4[T] = Pi.xzxz;
  var iy: Vec4[T] = Pi.yyww;
  var fx: Vec4[T] = Pf.xzxz;
  var fy: Vec4[T] = Pf.yyww;

  var i: Vec4[T] = permute(permute(ix) + iy);

  var gx: Vec4[T] = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
  var gy: Vec4[T] = abs(gx) - 0.5 ;
  var tx: Vec4[T] = floor(gx + 0.5);
  gx = gx - tx;

  var g00: Vec2[T] = vec2(gx.x,gy.x);
  var g10: Vec2[T] = vec2(gx.y,gy.y);
  var g01: Vec2[T] = vec2(gx.z,gy.z);
  var g11: Vec2[T] = vec2(gx.w,gy.w);

  var norm: Vec4[T] = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;  
  g01 *= norm.y;  
  g10 *= norm.z;  
  g11 *= norm.w;  

  var n00 = dot(g00, vec2(fx.x, fy.x));
  var n10 = dot(g10, vec2(fx.y, fy.y));
  var n01 = dot(g01, vec2(fx.z, fy.z));
  var n11 = dot(g11, vec2(fx.w, fy.w));

  var fade_xy: Vec2[T] = fade(Pf.xy);
  var n_x: Vec2[T] = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  var n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;


# Classic Perlin noise, periodic variant
proc pnoise*[T](P: Vec2[T]; rep: Vec2[T]): T =
  var Pi: Vec4[T] = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  var Pf: Vec4[T] = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, rep.xyxy); # To create noise with explicit period
  Pi = mod289(Pi);        # To avoid truncation effects in permutation
  var ix: Vec4[T] = Pi.xzxz;
  var iy: Vec4[T] = Pi.yyww;
  var fx: Vec4[T] = Pf.xzxz;
  var fy: Vec4[T] = Pf.yyww;

  var i: Vec4[T] = permute(permute(ix) + iy);

  var gx: Vec4[T] = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
  var gy: Vec4[T] = abs(gx) - 0.5 ;
  var tx: Vec4[T] = floor(gx + 0.5);
  gx = gx - tx;

  var g00: Vec2[T] = vec2(gx.x,gy.x);
  var g10: Vec2[T] = vec2(gx.y,gy.y);
  var g01: Vec2[T] = vec2(gx.z,gy.z);
  var g11: Vec2[T] = vec2(gx.w,gy.w);

  var norm: Vec4[T] = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;  
  g01 *= norm.y;  
  g10 *= norm.z;  
  g11 *= norm.w;  

  var n00 = dot(g00, vec2(fx.x, fy.x));
  var n10 = dot(g10, vec2(fx.y, fy.y));
  var n01 = dot(g01, vec2(fx.z, fy.z));
  var n11 = dot(g11, vec2(fx.w, fy.w));

  var fade_xy: Vec2[T] = fade(Pf.xy);
  var n_x: Vec2[T] = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  var n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;

