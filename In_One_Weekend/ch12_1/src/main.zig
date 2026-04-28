const std = @import("std");
const builtin = @import("builtin");

const point3 = @import("impl/vec3.zig").point3;
const color = @import("impl/vec3.zig").color;
const Sphere = @import("impl/Sphere.zig");
const HittableList = @import("impl/HittableList.zig");
const Camera = @import("impl/Camera.zig");
const Mat_Lambertian = @import("impl/Mat_Lambertian.zig");
const Mat_Metal = @import("impl/Mat_Metal.zig");
const Mat_Dielectric = @import("impl/Mat_Dielectric.zig");
const Rtweekend = @import("impl/Rtweekend.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    var world: HittableList = HittableList.init();
    defer world.deinit(allocator);

    const material_left = Mat_Lambertian{ .albedo = color.init(0, 0, 1) };
    const material_right = Mat_Lambertian{ .albedo = color.init(1, 0, 0) };
    const m3 = material_left.ToMaterial();
    const m4 = material_right.ToMaterial();

    const R = @cos(Rtweekend.PI / 4);
    var s3 = Sphere.init(point3.init(-R, 0.0, -1.0), R, m3);
    var s4 = Sphere.init(point3.init(R, 0.0, -1.0), R, m4);

    world.add(allocator, s3.hittable());
    world.add(allocator, s4.hittable());

    var cam = Camera.init(16.0 / 9.0, 400);
    // ch08
    cam.samples_per_pixel = 100;
    // ch09_2
    cam.max_depth = 50;
    // ch11_1
    cam.vfov = 90;
    var console = std.Io.File.stdout().writer(init.io, &.{});
    const stdout = &console.interface;
    try cam.render(world.hittable(), stdout);
}
