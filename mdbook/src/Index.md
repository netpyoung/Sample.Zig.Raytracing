# 들어가며

- [Ray Tracing in One Weekend — The Book Series](https://raytracing.github.io/)
  - [소스](https://github.com/RayTracing/raytracing.github.io/tree/release/src)
  - [Further-Readings](https://github.com/RayTracing/raytracing.github.io/wiki/Further-Readings)
  - [Ray Tracing in One Weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html)
  - [Ray Tracing: The Next Week](https://raytracing.github.io/books/RayTracingTheNextWeek.html)
  - [Ray Tracing: The Rest of Your Life](https://raytracing.github.io/books/RayTracingTheRestOfYourLife.html)
  - [Ray Tracing: GPU Edition](https://raytracing.github.io/gpu-tracing/book/RayTracingGPUEdition.html)

## Ref

### Zig

- [kristoff-it/kristRTX](https://github.com/kristoff-it/kristRTX)
  - [1](https://www.youtube.com/watch?v=ZBEYOnfFR90)
  - [2](https://www.youtube.com/watch?v=wC-VwljMUbo)
  - [3](https://www.youtube.com/watch?v=BSi-qmhIIvY)
- [Nidjo123/shirley-raytracer](https://github.com/Nidjo123/shirley-raytracer)
  - <https://bunjevac.net/blog/parallelizing-raytracer-in-a-weekend/>
- [Nelarius/weekend-raytracer-zig](https://github.com/Nelarius/weekend-raytracer-zig)
  - <https://nelari.us/post/raytracer_with_rust_and_zig/>

### 기타

- Lisp
  - <https://github.com/jstoddard/rtiow/>
- Cpp
  - <https://github.com/multitudes/Ray-Tracing-in-One-Weekend-in-C>

### 기타2

- https://github.com/kooparse/zalgebra
- https://github.com/zigimg/zigimg

## Demo

![image.bmp](./res/image.bmp)


``` txt
var cam = Camera.init(16.0 / 9.0, 800);
cam.samples_per_pixel = 400;
cam.max_depth         = 50;
cam.vfov              = 20;
cam.lookfrom          = point3.init(13, 2, 3);
cam.lookat            = point3.init(0, 0, 0);
cam.vup               = vec3.init(0, 1, 0);
cam.defocus_angle     = 0.6;
cam.focus_dist        = 10.0;

Measure-Command { .\ch14_thread\out\windows-x86_64-ReleaseFast\OneWeekend.exe > image.bmp }
Days              : 0
Hours             : 0
Minutes           : 2
Seconds           : 20
Milliseconds      : 522
Ticks             : 1405224153
TotalDays         : 0.00162641684375
TotalHours        : 0.03903400425
TotalMinutes      : 2.342040255
TotalSeconds      : 140.5224153
TotalMilliseconds : 140522.4153
```