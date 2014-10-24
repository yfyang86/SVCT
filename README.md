SVCT
====

Stratified Variance Component Test

The clang/clang++ on Mac doesn't have OpenMP installed. 

Solutions
-----------
1. Install [CLANG-OMP](http://clang-omp.github.io/), which is not a coponant in Mac's clang yet;    

2. Install [GCC-4.8](http://hpc.sourceforge.net/) or Compile GCC yourself. But this requires a rebuild of R using GNU-GCC instead of Mac's llvm version.


