import macros

macro components(args: varargs[untyped]): untyped =
  result = newStmtList()
  for arg in args:
    result.add quote do:
      import noise/`arg`
      export `arg`

components(classicnoise2D, classicnoise3D, classicnoise4D,
           noise2D, noise3D, noise3Dgrad, cellular3D, cellular2d, cellular2x2, cellular2x2x2)




