# Cellular noise ("Worley noise") in 2D in GLSL.
# Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
# This code is released under the conditions of the MIT license.
# See LICENSE file for details.
# https://github.com/stegu/webgl-noise

import glm

# Modulo 289 without a division (only multiplications)
proc mod289(x: Vec): Vec =
  return x - floor(x * (1.0 / 289.0)) * 289.0;
     
# Modulo 7 without a division
proc mod7(x: Vec): Vec3 =
  return x - floor(x * (1.0 / 7.0)) * 7.0;

# Permutation polynomial: (34x^2 + x) mod 289
proc permute(x: Vec): Vec3 =
  return mod289((34.0 * x + 1.0) * x);

# Cellular noise, returning F1 and F2 in a vec2.
# Speeded up by using 2x2 search window instead of 3x3,
# at the expense of some strong pattern artifacts.
# F2 is often wrong and has sharp discontinuities.
# If you need a smooth F2, use the slower 3x3 version.
# F1 is sometimes wrong, too, but OK for most purposes.
proc cellular2x2(P: Vec2): Vec2 =
  const
    K = 0.142857142857 # 1/7
    K2 = 0.0714285714285 # K/2
    jitter = 0.8 # jitter 1.0 makes F1 wrong more often

  var Pi: Vec2 = mod289(floor(P));
  var Pf: Vec2 = fract(P);
  var Pfx: Vec4 = Pf.x + vec4(-0.5, -1.5, -0.5, -1.5);
  var Pfy: Vec4 = Pf.y + vec4(-0.5, -0.5, -1.5, -1.5);
  var p: Vec4 = permute(Pi.x + vec4(0.0, 1.0, 0.0, 1.0));
  p = permute(p + Pi.y + (0.0, 0.0, 1.0, 1.0));
  var ox: Vec4 = mod7(p)*K+K2;
  var oy: Vec4 = mod7(floor(p*K))*K+K2;
  var dx: Vec4 = Pfx + jitter*ox;
  var dy: Vec4 = Pfy + jitter*oy;
  var d: Vec4 = dx * dx + dy * dy; # d11, d12, d21 and d22, squared
  # Sort out the two smallest distances
  when false:
    # Cheat and pick only F1
    d.xy = min(d.xy, d.zw);
    d.x = min(d.x, d.y);
    return vec2(sqrt(d.x)); # F1 duplicated, F2 not computed
  else:
    # Do it right and find both F1 and F2
    d.xy = if d.x < d.y: d.xy else: d.yx; # Swap if smaller
    d.xz = if d.x < d.z: d.xz else: d.zx;
    d.xw = if d.x < d.w: d.xw else: d.wx;
    d.y = min(d.y, d.z);
    d.y = min(d.y, d.w);
    return sqrt(d.xy);

