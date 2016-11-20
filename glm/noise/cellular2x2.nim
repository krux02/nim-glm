# Cellular noise ("Worley noise") in 2D in GLSL.
# Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
# This code is released under the conditions of the MIT license.
# See LICENSE file for details.
# https://github.com/stegu/webgl-noise

include shared

# Cellular noise, returning F1 and F2 in a vec2.
# Speeded up by using 2x2 search window instead of 3x3,
# at the expense of some strong pattern artifacts.
# F2 is often wrong and has sharp discontinuities.
# If you need a smooth F2, use the slower 3x3 version.
# F1 is sometimes wrong, too, but OK for most purposes.
proc cellular2x2*[T](P: Vec2[T]): Vec2[T] =
  const jitter = 0.8 # jitter 1.0 makes F1 wrong more often

  var Pi: Vec2[T] = mod289(floor(P));
  var Pf: Vec2[T] = fract(P);
  var Pfx: Vec4[T] = Pf.x + vec4(-0.5, -1.5, -0.5, -1.5);
  var Pfy: Vec4[T] = Pf.y + vec4(-0.5, -0.5, -1.5, -1.5);
  var p: Vec4[T] = permute(Pi.x + vec4(0.0, 1.0, 0.0, 1.0));
  p = permute(p + Pi.y + (0.0, 0.0, 1.0, 1.0));
  var ox: Vec4[T] = mod7(p)*K+K2;
  var oy: Vec4[T] = mod7(floor(p*K))*K+K2;
  var dx: Vec4[T] = Pfx + jitter*ox;
  var dy: Vec4[T] = Pfy + jitter*oy;
  var d: Vec4[T] = dx * dx + dy * dy; # d11, d12, d21 and d22, squared
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

