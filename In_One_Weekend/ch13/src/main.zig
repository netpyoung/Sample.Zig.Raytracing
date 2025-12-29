const std = @import("std");
const builtin = @import("builtin");

const vec3 = @import("impl/vec3.zig").vec3;
const point3 = @import("impl/vec3.zig").point3;
const color = @import("impl/vec3.zig").color;
const Sphere = @import("impl/Sphere.zig");
const HittableList = @import("impl/HittableList.zig");
const Camera = @import("impl/Camera.zig");
const Mat_Lambertian = @import("impl/Mat_Lambertian.zig");
const Mat_Metal = @import("impl/Mat_Metal.zig");
const Mat_Dielectric = @import("impl/Mat_Dielectric.zig");
const Rtweekend = @import("impl/Rtweekend.zig");

pub fn main() !void {
    const allocator = init_allocator();
    defer deinit_allocator();

    var world: HittableList = HittableList.init();
    defer world.deinit(allocator);

    const material_ground = Mat_Lambertian{ .albedo = color.init(0.8, 0.8, 0.0) };
    const material_center = Mat_Lambertian{ .albedo = color.init(0.1, 0.2, 0.5) };
    const material_left = Mat_Dielectric.init(1.50); // ch11_5
    const material_bubble = Mat_Dielectric.init(1.00 / 1.50);
    const material_right = Mat_Metal.init(color.init(0.8, 0.6, 0.2), 1.0);
    const m1 = material_ground.ToMaterial();
    const m2 = material_center.ToMaterial();
    const m3 = material_left.ToMaterial();
    const m_bubble = material_bubble.ToMaterial();
    const m4 = material_right.ToMaterial();

    var s1 = Sphere.init(point3.init(0.0, -100.5, -1.0), 100.0, m1);
    var s2 = Sphere.init(point3.init(0.0, 0.0, -1.2), 0.5, m2);
    var s3 = Sphere.init(point3.init(-1.0, 0.0, -1.0), 0.5, m3);
    var s_bubble = Sphere.init(point3.init(-1.0, 0.0, -1.0), 0.4, m_bubble);
    var s4 = Sphere.init(point3.init(1.0, 0.0, -1.0), 0.5, m4);

    world.add(allocator, s1.hittable());
    world.add(allocator, s2.hittable());
    world.add(allocator, s3.hittable());
    world.add(allocator, s4.hittable());
    world.add(allocator, s_bubble.hittable());

    world.add(allocator, s3.hittable());
    world.add(allocator, s4.hittable());

    var cam = Camera.init(16.0 / 9.0, 400);
    // ch08
    cam.samples_per_pixel = 100;
    // ch09_2
    cam.max_depth = 50;
    // ch11_1
    //cam.vfov = 90;
    // ch12_2
    cam.lookfrom = point3.init(-2, 2, 1);
    cam.lookat = point3.init(0, 0, -1);
    cam.vup = vec3.init(0, 1, 0);
    // cam.vfov = 90;
    cam.vfov = 20;
    //ch13
    cam.defocus_angle = 10.0;
    cam.focus_dist = 3.4;
    try cam.render(world.hittable());
}

// ======================================================================
// ======================================================================

var gpa_instance = std.heap.GeneralPurposeAllocator(.{
    .thread_safe = true,
    .never_unmap = true,
    .retain_metadata = true,
    .stack_trace_frames = 16,
}){};

fn init_allocator() std.mem.Allocator {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        return gpa_instance.allocator();
    } else {
        return std.heap.page_allocator;
    }
}

fn deinit_allocator() void {
    if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        const leaked = gpa_instance.deinit();
        if (leaked == .leak) {
            std.debug.print("\nMemory leak detected!\n", .{});
        }
    }
}
