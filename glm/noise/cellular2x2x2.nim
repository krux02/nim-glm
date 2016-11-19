# Cellular noise ("Worley noise") in 3D in GLSL.
# Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
# This code is released under the conditions of the MIT license.
# See LICENSE file for details.
# https://github.com/stegu/webgl-noise

include shared

# Cellular noise, returning F1 and F2 in a vec2.
# Speeded up by using 2x2x2 search window instead of 3x3x3,
# at the expense of some pattern artifacts.
# F2 is often wrong and has sharp discontinuities.
# If you need a good F2, use the slower 3x3x3 version.
proc cellular2x2x2*(P: Vec3): Vec2 =
  const jitter = 0.8 # smaller jitter gives less errors in F2
  var Pi: Vec3 = mod289(floor(P));
  var  Pf: Vec3 = fract(P);
  var  Pfx: Vec4 = Pf.x + vec4(0.0, -1.0, 0.0, -1.0);
  var  Pfy: Vec4 = Pf.y + vec4(0.0, 0.0, -1.0, -1.0);
  var  p: Vec4 = permute(Pi.x + vec4(0.0, 1.0, 0.0, 1.0));
  p = permute(p + Pi.y + vec4(0.0, 0.0, 1.0, 1.0));
  var  p1: Vec4 = permute(p + Pi.z); # z+0
  var  p2: Vec4 = permute(p + Pi.z + vec4(1.0)); # z+1
  var  ox1: Vec4 = fract(p1*K) - Ko;
  var  oy1: Vec4 = mod7(floor(p1*K))*K - Ko;
  var  oz1: Vec4 = floor(p1*K2)*Kz - Kzo; # p1 < 289 guaranteed
  var  ox2: Vec4 = fract(p2*K) - Ko;
  var  oy2: Vec4 = mod7(floor(p2*K))*K - Ko;
  var  oz2: Vec4 = floor(p2*K2)*Kz - Kzo;
  var  dx1: Vec4 = Pfx + jitter*ox1;
  var  dy1: Vec4 = Pfy + jitter*oy1;
  var  dz1: Vec4 = Pf.z + jitter*oz1;
  var  dx2: Vec4 = Pfx + jitter*ox2;
  var  dy2: Vec4 = Pfy + jitter*oy2;
  var  dz2: Vec4 = Pf.z - 1.0 + jitter*oz2;
  var  d1: Vec4 = dx1 * dx1 + dy1 * dy1 + dz1 * dz1; # z+0
  var  d2: Vec4 = dx2 * dx2 + dy2 * dy2 + dz2 * dz2; # z+1

  # Sort out the two smallest distances (F1, F2)
  when false:
    # Cheat and sort out only F1
    d1 = min(d1, d2);
    d1.xy = min(d1.xy, d1.wz);
    d1.x = min(d1.x, d1.y);
    return vec2(sqrt(d1.x));
  else:
    # Do it right and sort out both F1 and F2
    vec4 d = min(d1,d2); # F1 is now in d
    d2 = max(d1,d2); # Make sure we keep all candidates for F2
    d.xy = if d.x < d.y: d.xy else: d.yx; # Swap smallest to d.x
    d.xz = if d.x < d.z: d.xz else: d.zx;
    d.xw = if d.x < d.w: d.xw else: d.wx; # F1 is now in d.x
    d.yzw = min(d.yzw, d2.yzw); # F2 now not in d2.yzw
    d.y = min(d.y, d.z); # nor in d.z
    d.y = min(d.y, d.w); # nor in d.w
    d.y = min(d.y, d2.x); # F2 is now in d.y
    return sqrt(d.xy); # F1 and F2

