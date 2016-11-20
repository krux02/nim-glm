import glm

# Modulo 289 without a division (only multiplications)
proc mod289*(x: Vec): Vec =
  return x - floor(x * (1.0 / 289.0)) * 289.0;
     
# Modulo 7 without a division
proc mod7*(x: Vec): Vec =
  return x - floor(x * (1.0 / 7.0)) * 7.0;

# Permutation polynomial: (34x^2 + x) mod 289
proc permute*(x: Vec): Vec =
  return mod289((34.0 * x + 1.0) * x);

proc taylorInvSqrt*(r: Vec): Vec =
  return 1.79284291400159 - 0.85373472095314 * r

proc fade*(t: Vec): Vec =
  return t*t*t*(t*(t*6.0-15.0)+10.0);

const
  K   = 0.142857142857    # 1/7
  Ko  = 0.428571428571    # 1/2-K/2
  K2  = 0.020408163265306 # 1/(7*7)
  Kz  = 0.166666666667    # 1/6
  Kzo = 0.416666666667    # 1/2-1/6*2

     
