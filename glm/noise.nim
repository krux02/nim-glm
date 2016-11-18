##  Simplex 4D Noise 
##  by Ian McEwan, Ashima Arts

import vec

proc permute(x: Vec4d): Vec4d =
  return fmod(((x*34.0)+1.0)*x, 289.0)

proc permute(x: float64): float64 = floor(fmod(((x*34.0)+1.0)*x, 289.0))

proc taylorInvSqrt(r: Vec4d): Vec4d =
  vec4d(1.79284291400159) - 0.85373472095314 * r

proc taylorInvSqrt(r: float64): float64 = 1.79284291400159 - 0.85373472095314 * r
  
proc grad(j: float64; ip: Vec4d): Vec4d =
  let ones = vec4d(1,1,1,-1)
  var p,s: Vec4d
  p.xyz = floor( fract( vec3d(j) * ip.xyz) * 7) * ip.z - 1.0
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz)
  
  s = vec4d(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www; 

  return p

proc snoise*(v: Vec4d): float64 =
  let C: Vec2d = vec2( 0.138196601125010504,  # (5 - sqrt(5))/20  G4
                       0.309016994374947451); # (sqrt(5) - 1)/4   F4
  # First corner
  var i: Vec4d = floor(v + dot(v, C.yyyy) );
  let x0 : Vec4d = v -   i + dot(i, C.xxxx);

  # Other corners

  # Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  var i0 : Vec4d

  let isX = step( x0.yzw, x0.xxx );
  let isYZ = step( x0.zww, x0.yyz );
  #  i0.x = dot( isX, vec3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;

  #  i0.y += dot( isYZ.xy, vec2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;

  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  # i0 now contains the unique values 0,1,2,3 in each channel
  let i3 = clamp( i0, 0.0, 1.0 );
  let i2 = clamp( i0-1.0, 0.0, 1.0 );
  let i1 = clamp( i0-2.0, 0.0, 1.0 );

  #  x0 = x0 - 0.0 + 0.0 * C 
  let x1 = x0 - i1 + 1.0 * C.xxxx;
  let x2 = x0 - i2 + 2.0 * C.xxxx;
  let x3 = x0 - i3 + 3.0 * C.xxxx;
  let x4 = x0 - 1.0 + 4.0 * C.xxxx;

  # Permutations
  i = fmod(i, 289.0); 
  let j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  let j1 = permute( permute( permute( permute (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 )) +
             i.z + vec4(i1.z, i2.z, i3.z, 1.0 )) +
             i.y + vec4(i1.y, i2.y, i3.y, 1.0 )) +
             i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));
  # Gradients
  # ( 7*7*6 points uniformly over a cube, mapped onto a 4-octahedron.)
  # 7*7*6 = 294, which is close to the ring size 17*17 = 289.

  let ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  var p0 = grad(j0,   ip);
  var p1 = grad(j1.x, ip);
  var p2 = grad(j1.y, ip);
  var p3 = grad(j1.z, ip);
  var p4 = grad(j1.w, ip);

  # Normalise gradients
  var norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));

  # Mix contributions from the five corners
  var m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  var m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 ))) +
                  dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

  
