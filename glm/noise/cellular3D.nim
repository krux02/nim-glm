# Cellular noise ("Worley noise") in 3D in GLSL.
# Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
# This code is released under the conditions of the MIT license.
# See LICENSE file for details.
# https://github.com/stegu/webgl-noise

include shared

#[
# Modulo 289 without a division (only multiplications)
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

# Modulo 7 without a division
vec3 mod7(vec3 x) {
  return x - floor(x * (1.0 / 7.0)) * 7.0;
}

# Permutation polynomial: (34x^2 + x) mod 289
vec3 permute(vec3 x) {
  return mod289((34.0 * x + 1.0) * x);
}
]#

# Cellular noise, returning F1 and F2 in a vec2.
# 3x3x3 search region for good F2 everywhere, but a lot
# slower than the 2x2x2 version.
# The code below is a bit scary even to its author,
# but it has at least half decent performance on a
# modern GPU. In any case, it beats any software
# implementation of Worley noise hands down.

proc cellular(P: Vec3): Vec2 =
  const jitter = 1.0 # smaller jitter gives more regular pattern

  var  Pi: Vec3 = mod289(floor(P));
  var  Pf: Vec3 = fract(P) - 0.5;

  var  Pfx: Vec3 = Pf.x + vec3(1.0, 0.0, -1.0);
  var  Pfy: Vec3 = Pf.y + vec3(1.0, 0.0, -1.0);
  var  Pfz: Vec3 = Pf.z + vec3(1.0, 0.0, -1.0);

  var  p: Vec3 = permute(Pi.x + vec3(-1.0, 0.0, 1.0));
  var  p1: Vec3 = permute(p + Pi.y - 1.0);
  var  p2: Vec3 = permute(p + Pi.y);
  var  p3: Vec3 = permute(p + Pi.y + 1.0);

  var  p11: Vec3 = permute(p1 + Pi.z - 1.0);
  var  p12: Vec3 = permute(p1 + Pi.z);
  var  p13: Vec3 = permute(p1 + Pi.z + 1.0);

  var  p21: Vec3 = permute(p2 + Pi.z - 1.0);
  var  p22: Vec3 = permute(p2 + Pi.z);
  var  p23: Vec3 = permute(p2 + Pi.z + 1.0);

  var  p31: Vec3 = permute(p3 + Pi.z - 1.0);
  var  p32: Vec3 = permute(p3 + Pi.z);
  var  p33: Vec3 = permute(p3 + Pi.z + 1.0);

  var  ox11: Vec3 = fract(p11*K) - Ko;
  var  oy11: Vec3 = mod7(floor(p11*K))*K - Ko;
  var  oz11: Vec3 = floor(p11*K2)*Kz - Kzo; # p11 < 289 guaranteed

  var  ox12: Vec3 = fract(p12*K) - Ko;
  var  oy12: Vec3 = mod7(floor(p12*K))*K - Ko;
  var  oz12: Vec3 = floor(p12*K2)*Kz - Kzo;

  var  ox13: Vec3 = fract(p13*K) - Ko;
  var  oy13: Vec3 = mod7(floor(p13*K))*K - Ko;
  var  oz13: Vec3 = floor(p13*K2)*Kz - Kzo;

  var  ox21: Vec3 = fract(p21*K) - Ko;
  var  oy21: Vec3 = mod7(floor(p21*K))*K - Ko;
  var  oz21: Vec3 = floor(p21*K2)*Kz - Kzo;

  var  ox22: Vec3 = fract(p22*K) - Ko;
  var  oy22: Vec3 = mod7(floor(p22*K))*K - Ko;
  var  oz22: Vec3 = floor(p22*K2)*Kz - Kzo;

  var  ox23: Vec3 = fract(p23*K) - Ko;
  var  oy23: Vec3 = mod7(floor(p23*K))*K - Ko;
  var  oz23: Vec3 = floor(p23*K2)*Kz - Kzo;

  var  ox31: Vec3 = fract(p31*K) - Ko;
  var  oy31: Vec3 = mod7(floor(p31*K))*K - Ko;
  var  oz31: Vec3 = floor(p31*K2)*Kz - Kzo;

  var  ox32: Vec3 = fract(p32*K) - Ko;
  var  oy32: Vec3 = mod7(floor(p32*K))*K - Ko;
  var  oz32: Vec3 = floor(p32*K2)*Kz - Kzo;

  var  ox33: Vec3 = fract(p33*K) - Ko;
  var  oy33: Vec3 = mod7(floor(p33*K))*K - Ko;
  var  oz33: Vec3 = floor(p33*K2)*Kz - Kzo;

  var  dx11: Vec3 = Pfx + jitter*ox11;
  var  dy11: Vec3 = Pfy.x + jitter*oy11;
  var  dz11: Vec3 = Pfz.x + jitter*oz11;

  var  dx12: Vec3 = Pfx + jitter*ox12;
  var  dy12: Vec3 = Pfy.x + jitter*oy12;
  var  dz12: Vec3 = Pfz.y + jitter*oz12;

  var  dx13: Vec3 = Pfx + jitter*ox13;
  var  dy13: Vec3 = Pfy.x + jitter*oy13;
  var  dz13: Vec3 = Pfz.z + jitter*oz13;

  var  dx21: Vec3 = Pfx + jitter*ox21;
  var  dy21: Vec3 = Pfy.y + jitter*oy21;
  var  dz21: Vec3 = Pfz.x + jitter*oz21;

  var  dx22: Vec3 = Pfx + jitter*ox22;
  var  dy22: Vec3 = Pfy.y + jitter*oy22;
  var  dz22: Vec3 = Pfz.y + jitter*oz22;

  var  dx23: Vec3 = Pfx + jitter*ox23;
  var  dy23: Vec3 = Pfy.y + jitter*oy23;
  var  dz23: Vec3 = Pfz.z + jitter*oz23;

  var  dx31: Vec3 = Pfx + jitter*ox31;
  var  dy31: Vec3 = Pfy.z + jitter*oy31;
  var  dz31: Vec3 = Pfz.x + jitter*oz31;

  var  dx32: Vec3 = Pfx + jitter*ox32;
  var  dy32: Vec3 = Pfy.z + jitter*oy32;
  var  dz32: Vec3 = Pfz.y + jitter*oz32;

  var  dx33: Vec3 = Pfx + jitter*ox33;
  var  dy33: Vec3 = Pfy.z + jitter*oy33;
  var  dz33: Vec3 = Pfz.z + jitter*oz33;

  var  d11: Vec3 = dx11 * dx11 + dy11 * dy11 + dz11 * dz11;
  var  d12: Vec3 = dx12 * dx12 + dy12 * dy12 + dz12 * dz12;
  var  d13: Vec3 = dx13 * dx13 + dy13 * dy13 + dz13 * dz13;
  var  d21: Vec3 = dx21 * dx21 + dy21 * dy21 + dz21 * dz21;
  var  d22: Vec3 = dx22 * dx22 + dy22 * dy22 + dz22 * dz22;
  var  d23: Vec3 = dx23 * dx23 + dy23 * dy23 + dz23 * dz23;
  var  d31: Vec3 = dx31 * dx31 + dy31 * dy31 + dz31 * dz31;
  var  d32: Vec3 = dx32 * dx32 + dy32 * dy32 + dz32 * dz32;
  var  d33: Vec3 = dx33 * dx33 + dy33 * dy33 + dz33 * dz33;

  # Sort out the two smallest distances (F1, F2)
  when false:
    # Cheat and sort out only F1
    var  d1: Vec3 = min(min(d11,d12), d13);
    var  d2: Vec3 = min(min(d21,d22), d23);
    var  d3: Vec3 = min(min(d31,d32), d33);
    var  d: Vec3 = min(min(d1,d2), d3);
    d.x = min(min(d.x,d.y),d.z);
    return vec2(sqrt(d.x)); # F1 duplicated, no F2 computed
  else:
    # Do it right and sort out both F1 and F2
    var  d1a: Vec3 = min(d11, d12);
    d12 = max(d11, d12);
    d11 = min(d1a, d13); # Smallest now not in d12 or d13
    d13 = max(d1a, d13);
    d12 = min(d12, d13); # 2nd smallest now not in d13
    var  d2a: Vec3 = min(d21, d22);
    d22 = max(d21, d22);
    d21 = min(d2a, d23); # Smallest now not in d22 or d23
    d23 = max(d2a, d23);
    d22 = min(d22, d23); # 2nd smallest now not in d23
    var  d3a: Vec3 = min(d31, d32);
    d32 = max(d31, d32);
    d31 = min(d3a, d33); # Smallest now not in d32 or d33
    d33 = max(d3a, d33);
    d32 = min(d32, d33); # 2nd smallest now not in d33
    var  da: Vec3 = min(d11, d21);
    d21 = max(d11, d21);
    d11 = min(da, d31); # Smallest now in d11
    d31 = max(da, d31); # 2nd smallest now not in d31
    d11.xy = if d11.x < d11.y: d11.xy else: d11.yx;
    d11.xz = if d11.x < d11.z: d11.xz else: d11.zx; # d11.x now smallest
    d12 = min(d12, d21); # 2nd smallest now not in d21
    d12 = min(d12, d22); # nor in d22
    d12 = min(d12, d31); # nor in d31
    d12 = min(d12, d32); # nor in d32
    d11.yz = min(d11.yz,d12.xy); # nor in d12.yz
    d11.y = min(d11.y,d12.z); # Only two more to go
    d11.y = min(d11.y,d11.z); # Done! (Phew!)
    return sqrt(d11.xy); # F1, F2

