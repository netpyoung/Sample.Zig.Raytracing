const std = @import("std");
const builtin = @import("builtin");

const point3 = @import("impl/vec3.zig").point3;
const Sphere = @import("impl/Sphere.zig");
const HittableList = @import("impl/HittableList.zig");
const Camera = @import("impl/Camera.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    var world: HittableList = HittableList.init();
    defer world.deinit(allocator);

    var s1 = Sphere.init(point3.init(0, 0, -1), 0.5);
    var s2 = Sphere.init(point3.init(0, -100.5, -1), 100);

    world.add(allocator, s1.hittable());
    world.add(allocator, s2.hittable());

    var cam = Camera.init(16.0 / 9.0, 400);
    // ch08
    cam.samples_per_pixel = 100;

    // ch09_2
    cam.max_depth = 50;
    var console = std.Io.File.stdout().writer(init.io, &.{});
    const stdout = &console.interface;
    try cam.render(world.hittable(), stdout);
}
