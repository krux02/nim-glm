# Cellular noise ("Worley noise") in 2D in GLSL.
# Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
# This code is released under the conditions of the MIT license.
# See LICENSE file for details.
# https://github.com/stegu/webgl-noise

import glm

# Modulo 289 without a division (only multiplications)
proc mod289(x: Vec3): Vec3 =
  return x - floor(x * (1.0 / 289.0)) * 289.0;

proc mod289(x: Vec2): Vec2 =
  return x - floor(x * (1.0 / 289.0)) * 289.0;

# Modulo 7 without a division
proc mod7(x: Vec3): Vec3 =
  return x - floor(x * (1.0 / 7.0)) * 7.0;

# Permutation polynomial: (34x^2 + x) mod 289
proc permute(x: Vec3): Vec3 =
  return mod289((34.0 * x + 1.0) * x);


# Cellular noise, returning F1 and F2 in a vec2.
# Standard 3x3 search window for good F1 and F2 values
proc cellular*(P: Vec2): Vec2 =
  const
    K = 0.142857142857 # 1/7
    Ko = 0.428571428571 # 3/7
    jitter = 1.0 # Less gives more regular pattern

  var Pi: Vec2 = mod289(floor(P));
  var Pf: Vec2 = fract(P);
  var oi: Vec3 = vec3(-1.0, 0.0, 1.0);
  var off: Vec3 = vec3(-0.5, 0.5, 1.5);
  var px: Vec3 = permute(Pi.x + oi);
  var p: Vec3 = permute(px.x + Pi.y + oi); # p11, p12, p13
  var ox: Vec3 = fract(p*K) - Ko;
  var oy: Vec3 = mod7(floor(p*K))*K - Ko;
  var dx: Vec3 = Pf.x + 0.5 + jitter*ox;
  var dy: Vec3 = Pf.y - off + jitter*oy;
  var d1: Vec3 = dx * dx + dy * dy; # d11, d12 and d13, squared
  p = permute(px.y + Pi.y + oi); # p21, p22, p23
  ox = fract(p*K) - Ko;
  oy = mod7(floor(p*K))*K - Ko;
  dx = Pf.x - 0.5 + jitter*ox;
  dy = Pf.y - off + jitter*oy;
  var d2: Vec3 = dx * dx + dy * dy; # d21, d22 and d23, squared
  p = permute(px.z + Pi.y + oi); # p31, p32, p33
  ox = fract(p*K) - Ko;
  oy = mod7(floor(p*K))*K - Ko;
  dx = Pf.x - 1.5 + jitter*ox;
  dy = Pf.y - off + jitter*oy;
  var d3: Vec3 = dx * dx + dy * dy; # d31, d32 and d33, squared
  # Sort out the two smallest distances (F1, F2)
  var d1a: Vec3 = min(d1, d2);
  d2 = max(d1, d2); # Swap to keep candidates for F2
  d2 = min(d2, d3); # neither F1 nor F2 are now in d3
  d1 = min(d1a, d2); # F1 is now in d1
  d2 = max(d1a, d2); # Swap to keep candidates for F2
  d1.xy = if d1.x < d1.y: d1.xy else: d1.yx; # Swap if smaller
  d1.xz = if d1.x < d1.z: d1.xz else: d1.zx; # F1 is in d1.x
  d1.yz = min(d1.yz, d2.yz); # F2 is now not in d2.yz
  d1.y = min(d1.y, d1.z); # nor in  d1.z
  d1.y = min(d1.y, d2.x); # F2 is in d1.y, we're done.
  return sqrt(d1.xy);

