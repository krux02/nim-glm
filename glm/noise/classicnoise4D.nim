#
# GLSL textureless classic 4D noise "cnoise",
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

vec4 fade(vec4 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}
]#

# Classic Perlin noise
proc cnoise(P: Vec4): float =
  var  Pi0: Vec4 = floor(P); # Integer part for indexing
  var  Pi1: Vec4 = Pi0 + 1.0; # Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  var  Pf0: Vec4 = fract(P); # Fractional part for interpolation
  var  Pf1: Vec4 = Pf0 - 1.0; # Fractional part - 1.0
  var  ix: Vec4 = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  var  iy: Vec4 = vec4(Pi0.yy, Pi1.yy);
  var  iz0: Vec4 = vec4(Pi0.zzzz);
  var  iz1: Vec4 = vec4(Pi1.zzzz);
  var  iw0: Vec4 = vec4(Pi0.wwww);
  var  iw1: Vec4 = vec4(Pi1.wwww);

  var  ixy: Vec4 = permute(permute(ix) + iy);
  var  ixy0: Vec4 = permute(ixy + iz0);
  var  ixy1: Vec4 = permute(ixy + iz1);
  var  ixy00: Vec4 = permute(ixy0 + iw0);
  var  ixy01: Vec4 = permute(ixy0 + iw1);
  var  ixy10: Vec4 = permute(ixy1 + iw0);
  var  ixy11: Vec4 = permute(ixy1 + iw1);

  var  gx00: Vec4 = ixy00 * (1.0 / 7.0);
  var  gy00: Vec4 = floor(gx00) * (1.0 / 7.0);
  var  gz00: Vec4 = floor(gy00) * (1.0 / 6.0);
  gx00 = fract(gx00) - 0.5;
  gy00 = fract(gy00) - 0.5;
  gz00 = fract(gz00) - 0.5;
  var gw00: Vec4 = vec4(0.75) - abs(gx00) - abs(gy00) - abs(gz00);
  var sw00: Vec4 = step(gw00, vec4(0.0));
  gx00 -= sw00 * (step(0.0, gx00) - 0.5);
  gy00 -= sw00 * (step(0.0, gy00) - 0.5);

  var gx01: Vec4 = ixy01 * (1.0 / 7.0);
  var gy01: Vec4 = floor(gx01) * (1.0 / 7.0);
  var gz01: Vec4 = floor(gy01) * (1.0 / 6.0);
  gx01 = fract(gx01) - 0.5;
  gy01 = fract(gy01) - 0.5;
  gz01 = fract(gz01) - 0.5;
  var gw01: Vec4 = vec4(0.75) - abs(gx01) - abs(gy01) - abs(gz01);
  var sw01: Vec4 = step(gw01, vec4(0.0));
  gx01 -= sw01 * (step(0.0, gx01) - 0.5);
  gy01 -= sw01 * (step(0.0, gy01) - 0.5);

  var gx10: Vec4 = ixy10 * (1.0 / 7.0);
  var gy10: Vec4 = floor(gx10) * (1.0 / 7.0);
  var gz10: Vec4 = floor(gy10) * (1.0 / 6.0);
  gx10 = fract(gx10) - 0.5;
  gy10 = fract(gy10) - 0.5;
  gz10 = fract(gz10) - 0.5;
  var gw10: Vec4 = vec4(0.75) - abs(gx10) - abs(gy10) - abs(gz10);
  var sw10: Vec4 = step(gw10, vec4(0.0));
  gx10 -= sw10 * (step(0.0, gx10) - 0.5);
  gy10 -= sw10 * (step(0.0, gy10) - 0.5);

  var gx11: Vec4 = ixy11 * (1.0 / 7.0);
  var gy11: Vec4 = floor(gx11) * (1.0 / 7.0);
  var gz11: Vec4 = floor(gy11) * (1.0 / 6.0);
  gx11 = fract(gx11) - 0.5;
  gy11 = fract(gy11) - 0.5;
  gz11 = fract(gz11) - 0.5;
  var gw11: Vec4 = vec4(0.75) - abs(gx11) - abs(gy11) - abs(gz11);
  var sw11: Vec4 = step(gw11, vec4(0.0));
  gx11 -= sw11 * (step(0.0, gx11) - 0.5);
  gy11 -= sw11 * (step(0.0, gy11) - 0.5);

  var  g0000: Vec4 = vec4(gx00.x,gy00.x,gz00.x,gw00.x);
  var  g1000: Vec4 = vec4(gx00.y,gy00.y,gz00.y,gw00.y);
  var  g0100: Vec4 = vec4(gx00.z,gy00.z,gz00.z,gw00.z);
  var  g1100: Vec4 = vec4(gx00.w,gy00.w,gz00.w,gw00.w);
  var  g0010: Vec4 = vec4(gx10.x,gy10.x,gz10.x,gw10.x);
  var  g1010: Vec4 = vec4(gx10.y,gy10.y,gz10.y,gw10.y);
  var  g0110: Vec4 = vec4(gx10.z,gy10.z,gz10.z,gw10.z);
  var  g1110: Vec4 = vec4(gx10.w,gy10.w,gz10.w,gw10.w);
  var  g0001: Vec4 = vec4(gx01.x,gy01.x,gz01.x,gw01.x);
  var  g1001: Vec4 = vec4(gx01.y,gy01.y,gz01.y,gw01.y);
  var  g0101: Vec4 = vec4(gx01.z,gy01.z,gz01.z,gw01.z);
  var  g1101: Vec4 = vec4(gx01.w,gy01.w,gz01.w,gw01.w);
  var  g0011: Vec4 = vec4(gx11.x,gy11.x,gz11.x,gw11.x);
  var  g1011: Vec4 = vec4(gx11.y,gy11.y,gz11.y,gw11.y);
  var  g0111: Vec4 = vec4(gx11.z,gy11.z,gz11.z,gw11.z);
  var  g1111: Vec4 = vec4(gx11.w,gy11.w,gz11.w,gw11.w);

  var  norm00: Vec4 = taylorInvSqrt(vec4(dot(g0000, g0000), dot(g0100, g0100), dot(g1000, g1000), dot(g1100, g1100)));
  g0000 *= norm00.x;
  g0100 *= norm00.y;
  g1000 *= norm00.z;
  g1100 *= norm00.w;

  var  norm01: Vec4 = taylorInvSqrt(vec4(dot(g0001, g0001), dot(g0101, g0101), dot(g1001, g1001), dot(g1101, g1101)));
  g0001 *= norm01.x;
  g0101 *= norm01.y;
  g1001 *= norm01.z;
  g1101 *= norm01.w;

  var  norm10: Vec4 = taylorInvSqrt(vec4(dot(g0010, g0010), dot(g0110, g0110), dot(g1010, g1010), dot(g1110, g1110)));
  g0010 *= norm10.x;
  g0110 *= norm10.y;
  g1010 *= norm10.z;
  g1110 *= norm10.w;

  var  norm11: Vec4 = taylorInvSqrt(vec4(dot(g0011, g0011), dot(g0111, g0111), dot(g1011, g1011), dot(g1111, g1111)));
  g0011 *= norm11.x;
  g0111 *= norm11.y;
  g1011 *= norm11.z;
  g1111 *= norm11.w;

  var n0000 = dot(g0000, Pf0);
  var n1000 = dot(g1000, vec4(Pf1.x, Pf0.yzw));
  var n0100 = dot(g0100, vec4(Pf0.x, Pf1.y, Pf0.zw));
  var n1100 = dot(g1100, vec4(Pf1.xy, Pf0.zw));
  var n0010 = dot(g0010, vec4(Pf0.xy, Pf1.z, Pf0.w));
  var n1010 = dot(g1010, vec4(Pf1.x, Pf0.y, Pf1.z, Pf0.w));
  var n0110 = dot(g0110, vec4(Pf0.x, Pf1.yz, Pf0.w));
  var n1110 = dot(g1110, vec4(Pf1.xyz, Pf0.w));
  var n0001 = dot(g0001, vec4(Pf0.xyz, Pf1.w));
  var n1001 = dot(g1001, vec4(Pf1.x, Pf0.yz, Pf1.w));
  var n0101 = dot(g0101, vec4(Pf0.x, Pf1.y, Pf0.z, Pf1.w));
  var n1101 = dot(g1101, vec4(Pf1.xy, Pf0.z, Pf1.w));
  var n0011 = dot(g0011, vec4(Pf0.xy, Pf1.zw));
  var n1011 = dot(g1011, vec4(Pf1.x, Pf0.y, Pf1.zw));
  var n0111 = dot(g0111, vec4(Pf0.x, Pf1.yzw));
  var n1111 = dot(g1111, Pf1);

  var  fade_xyzw: Vec4 = fade(Pf0);
  var  n_0w: Vec4 = mix(vec4(n0000, n1000, n0100, n1100), vec4(n0001, n1001, n0101, n1101), fade_xyzw.w);
  var  n_1w: Vec4 = mix(vec4(n0010, n1010, n0110, n1110), vec4(n0011, n1011, n0111, n1111), fade_xyzw.w);
  var  n_zw: Vec4 = mix(n_0w, n_1w, fade_xyzw.z);
  var  n_yzw: Vec2 = mix(n_zw.xy, n_zw.zw, fade_xyzw.y);
  let n_xyzw = mix(n_yzw.x, n_yzw.y, fade_xyzw.x);
  return 2.2 * n_xyzw;


# Classic Perlin noise, periodic version
proc pnoise(P: Vec4; rep: Vec4): float =
  var Pi0: Vec4 = mod(floor(P), rep); # Integer part modulo rep
  var Pi1: Vec4 = mod(Pi0 + 1.0, rep); # Integer part + 1 mod rep
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  var Pf0: Vec4 = fract(P); # Fractional part for interpolation
  var Pf1: Vec4 = Pf0 - 1.0; # Fractional part - 1.0
  var ix: Vec4 = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  var iy: Vec4 = vec4(Pi0.yy, Pi1.yy);
  var iz0: Vec4 = vec4(Pi0.zzzz);
  var iz1: Vec4 = vec4(Pi1.zzzz);
  var iw0: Vec4 = vec4(Pi0.wwww);
  var iw1: Vec4 = vec4(Pi1.wwww);

  var   ixy: Vec4 = permute(permute(ix) + iy);
  var ixy0: Vec4 = permute(ixy + iz0);
  var ixy1: Vec4 = permute(ixy + iz1);
  var ixy00: Vec4 = permute(ixy0 + iw0);
  var ixy01: Vec4 = permute(ixy0 + iw1);
  var ixy10: Vec4 = permute(ixy1 + iw0);
  var ixy11: Vec4 = permute(ixy1 + iw1);

  var gx00: Vec4 = ixy00 * (1.0 / 7.0);
  var gy00: Vec4 = floor(gx00) * (1.0 / 7.0);
  var gz00: Vec4 = floor(gy00) * (1.0 / 6.0);
  gx00 = fract(gx00) - 0.5;
  gy00 = fract(gy00) - 0.5;
  gz00 = fract(gz00) - 0.5;
  var gw00: Vec4 = vec4(0.75) - abs(gx00) - abs(gy00) - abs(gz00);
  var sw00: Vec4 = step(gw00, vec4(0.0));
  gx00 -= sw00 * (step(0.0, gx00) - 0.5);
  gy00 -= sw00 * (step(0.0, gy00) - 0.5);

  var gx01: Vec4 = ixy01 * (1.0 / 7.0);
  var gy01: Vec4 = floor(gx01) * (1.0 / 7.0);
  var gz01: Vec4 = floor(gy01) * (1.0 / 6.0);
  gx01 = fract(gx01) - 0.5;
  gy01 = fract(gy01) - 0.5;
  gz01 = fract(gz01) - 0.5;
  var gw01: Vec4 = vec4(0.75) - abs(gx01) - abs(gy01) - abs(gz01);
  var sw01: Vec4 = step(gw01, vec4(0.0));
  gx01 -= sw01 * (step(0.0, gx01) - 0.5);
  gy01 -= sw01 * (step(0.0, gy01) - 0.5);

  var gx10: Vec4 = ixy10 * (1.0 / 7.0);
  var gy10: Vec4 = floor(gx10) * (1.0 / 7.0);
  var gz10: Vec4 = floor(gy10) * (1.0 / 6.0);
  gx10 = fract(gx10) - 0.5;
  gy10 = fract(gy10) - 0.5;
  gz10 = fract(gz10) - 0.5;
  var gw10: Vec4 = vec4(0.75) - abs(gx10) - abs(gy10) - abs(gz10);
  var sw10: Vec4 = step(gw10, vec4(0.0));
  gx10 -= sw10 * (step(0.0, gx10) - 0.5);
  gy10 -= sw10 * (step(0.0, gy10) - 0.5);

  var gx11: Vec4 = ixy11 * (1.0 / 7.0);
  var gy11: Vec4 = floor(gx11) * (1.0 / 7.0);
  var gz11: Vec4 = floor(gy11) * (1.0 / 6.0);
  gx11 = fract(gx11) - 0.5;
  gy11 = fract(gy11) - 0.5;
  gz11 = fract(gz11) - 0.5;
  var gw11: Vec4 = vec4(0.75) - abs(gx11) - abs(gy11) - abs(gz11);
  var sw11: Vec4 = step(gw11, vec4(0.0));
  gx11 -= sw11 * (step(0.0, gx11) - 0.5);
  gy11 -= sw11 * (step(0.0, gy11) - 0.5);

  var g0000: Vec4 = vec4(gx00.x,gy00.x,gz00.x,gw00.x);
  var g1000: Vec4 = vec4(gx00.y,gy00.y,gz00.y,gw00.y);
  var g0100: Vec4 = vec4(gx00.z,gy00.z,gz00.z,gw00.z);
  var g1100: Vec4 = vec4(gx00.w,gy00.w,gz00.w,gw00.w);
  var g0010: Vec4 = vec4(gx10.x,gy10.x,gz10.x,gw10.x);
  var g1010: Vec4 = vec4(gx10.y,gy10.y,gz10.y,gw10.y);
  var g0110: Vec4 = vec4(gx10.z,gy10.z,gz10.z,gw10.z);
  var g1110: Vec4 = vec4(gx10.w,gy10.w,gz10.w,gw10.w);
  var g0001: Vec4 = vec4(gx01.x,gy01.x,gz01.x,gw01.x);
  var g1001: Vec4 = vec4(gx01.y,gy01.y,gz01.y,gw01.y);
  var g0101: Vec4 = vec4(gx01.z,gy01.z,gz01.z,gw01.z);
  var g1101: Vec4 = vec4(gx01.w,gy01.w,gz01.w,gw01.w);
  var g0011: Vec4 = vec4(gx11.x,gy11.x,gz11.x,gw11.x);
  var g1011: Vec4 = vec4(gx11.y,gy11.y,gz11.y,gw11.y);
  var g0111: Vec4 = vec4(gx11.z,gy11.z,gz11.z,gw11.z);
  var g1111: Vec4 = vec4(gx11.w,gy11.w,gz11.w,gw11.w);

  var norm00: Vec4 = taylorInvSqrt(vec4(dot(g0000, g0000), dot(g0100, g0100), dot(g1000, g1000), dot(g1100, g1100)));
  g0000 *= norm00.x;
  g0100 *= norm00.y;
  g1000 *= norm00.z;
  g1100 *= norm00.w;

  var norm01: Vec4 = taylorInvSqrt(vec4(dot(g0001, g0001), dot(g0101, g0101), dot(g1001, g1001), dot(g1101, g1101)));
  g0001 *= norm01.x;
  g0101 *= norm01.y;
  g1001 *= norm01.z;
  g1101 *= norm01.w;

  var norm10: Vec4 = taylorInvSqrt(vec4(dot(g0010, g0010), dot(g0110, g0110), dot(g1010, g1010), dot(g1110, g1110)));
  g0010 *= norm10.x;
  g0110 *= norm10.y;
  g1010 *= norm10.z;
  g1110 *= norm10.w;

  var norm11: Vec4 = taylorInvSqrt(vec4(dot(g0011, g0011), dot(g0111, g0111), dot(g1011, g1011), dot(g1111, g1111)));
  g0011 *= norm11.x;
  g0111 *= norm11.y;
  g1011 *= norm11.z;
  g1111 *= norm11.w;

  var n0000 = dot(g0000, Pf0);
  var n1000 = dot(g1000, vec4(Pf1.x, Pf0.yzw));
  var n0100 = dot(g0100, vec4(Pf0.x, Pf1.y, Pf0.zw));
  var n1100 = dot(g1100, vec4(Pf1.xy, Pf0.zw));
  var n0010 = dot(g0010, vec4(Pf0.xy, Pf1.z, Pf0.w));
  var n1010 = dot(g1010, vec4(Pf1.x, Pf0.y, Pf1.z, Pf0.w));
  var n0110 = dot(g0110, vec4(Pf0.x, Pf1.yz, Pf0.w));
  var n1110 = dot(g1110, vec4(Pf1.xyz, Pf0.w));
  var n0001 = dot(g0001, vec4(Pf0.xyz, Pf1.w));
  var n1001 = dot(g1001, vec4(Pf1.x, Pf0.yz, Pf1.w));
  var n0101 = dot(g0101, vec4(Pf0.x, Pf1.y, Pf0.z, Pf1.w));
  var n1101 = dot(g1101, vec4(Pf1.xy, Pf0.z, Pf1.w));
  var n0011 = dot(g0011, vec4(Pf0.xy, Pf1.zw));
  var n1011 = dot(g1011, vec4(Pf1.x, Pf0.y, Pf1.zw));
  var n0111 = dot(g0111, vec4(Pf0.x, Pf1.yzw));
  var n1111 = dot(g1111, Pf1);

  var fade_xyzw: Vec4 = fade(Pf0);
  var n_0w: Vec4 = mix(vec4(n0000, n1000, n0100, n1100), vec4(n0001, n1001, n0101, n1101), fade_xyzw.w);
  var n_1w: Vec4 = mix(vec4(n0010, n1010, n0110, n1110), vec4(n0011, n1011, n0111, n1111), fade_xyzw.w);
  var n_zw: Vec4 = mix(n_0w, n_1w, fade_xyzw.z);
  var n_yzw: Vec2 = mix(n_zw.xy, n_zw.zw, fade_xyzw.y);
  var n_xyzw = mix(n_yzw.x, n_yzw.y, fade_xyzw.x);
  return 2.2 * n_xyzw;

