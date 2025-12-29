const std = @import("std");
const builtin = @import("builtin");

const point3 = @import("impl/vec3.zig").point3;
const Sphere = @import("impl/Sphere.zig");
const HittableList = @import("impl/HittableList.zig");
const Camera = @import("impl/Camera.zig");

pub fn main() !void {
    const allocator = init_allocator();
    defer deinit_allocator();

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
