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
const Material = @import("impl/Material.zig");

const Mat = union(enum) {
    lambertian: Mat_Lambertian,
    metal: Mat_Metal,
    dielectric: Mat_Dielectric,

    pub fn Convert(self: *const Mat) Material {
        return switch (self.*) {
            inline else => |*x| x.ToMaterial(),
        };
    }
};

pub fn main() !void {
    const allocator = init_allocator();
    defer deinit_allocator();

    var world: HittableList = HittableList.init();
    defer world.deinit(allocator);

    var matList = std.array_list.Aligned(*Mat, null).empty;
    defer {
        for (matList.items) |x| {
            allocator.destroy(x);
        }
        matList.deinit(allocator);
    }

    var sphereList = std.array_list.Aligned(*Sphere, null).empty;
    defer {
        for (sphereList.items) |x| {
            allocator.destroy(x);
        }
        sphereList.deinit(allocator);
    }
    {
        {
            // ground
            const m = try allocator.create(Mat);
            const s = try allocator.create(Sphere);
            try matList.append(allocator, m);
            try sphereList.append(allocator, s);

            m.* = Mat{ .lambertian = .{ .albedo = color.init(0.5, 0.5, 0.5) } };
            s.* = Sphere.init(point3.init(0.0, -1000.0, 0.0), 1000.0, m.Convert());
        }

        {
            // dielectric
            const m = try allocator.create(Mat);
            const s = try allocator.create(Sphere);
            try matList.append(allocator, m);
            try sphereList.append(allocator, s);

            m.* = Mat{ .dielectric = .{ .refraction_index = 1.5 } };
            s.* = Sphere.init(point3.init(0, 1, 0), 1.0, m.Convert());
        }
        {
            // lambertian
            const m = try allocator.create(Mat);
            const s = try allocator.create(Sphere);
            try matList.append(allocator, m);
            try sphereList.append(allocator, s);

            m.* = Mat{ .lambertian = .{ .albedo = color.init(0.4, 0.2, 0.1) } };
            s.* = Sphere.init(point3.init(-4, 1, 0), 1.0, m.Convert());
        }
        {
            // metal
            const m = try allocator.create(Mat);
            const s = try allocator.create(Sphere);
            try matList.append(allocator, m);
            try sphereList.append(allocator, s);

            m.* = Mat{ .metal = .{ .albedo = color.init(0.7, 0.6, 0.5), .fuzz = 0.0 } };
            s.* = Sphere.init(point3.init(4, 1, 0), 1.0, m.Convert());
        }

        {
            // balls
            var a: isize = -11;
            while (a < 11) : (a += 1) {
                var b: isize = -11;
                while (b < 11) : (b += 1) {
                    const center = point3.init(
                        @as(f64, @floatFromInt(a)) + 0.9 * Rtweekend.random_double(),
                        0.2,
                        @as(f64, @floatFromInt(b)) + 0.9 * Rtweekend.random_double(),
                    );

                    if (vec3.sub(center, point3.init(4, 0.2, 0)).length() > 0.9) {
                        const m = try allocator.create(Mat);
                        const s = try allocator.create(Sphere);
                        try matList.append(allocator, m);
                        try sphereList.append(allocator, s);

                        const choose_mat = Rtweekend.random_double();
                        if (choose_mat < 0.8) {
                            // diffuse
                            const albedo = vec3.mul(color.random(), color.random());
                            m.* = Mat{ .lambertian = .{ .albedo = albedo } };
                            s.* = Sphere.init(center, 0.2, m.Convert());
                        } else if (choose_mat < 0.95) {
                            // metal
                            const albedo = color.random_minmax(0.5, 1);
                            const fuzz = Rtweekend.random_double_minmax(0, 0.5);
                            m.* = Mat{ .metal = .{ .albedo = albedo, .fuzz = fuzz } };
                            s.* = Sphere.init(center, 0.2, m.Convert());
                        } else {
                            // glass
                            m.* = Mat{ .dielectric = .{ .refraction_index = 1.5 } };
                            s.* = Sphere.init(center, 0.2, m.Convert());
                        }
                    }
                }
            }
        }

        for (sphereList.items) |s| {
            world.add(allocator, s.hittable());
        }
    }

    var cam = Camera.init(16.0 / 9.0, 600);
    cam.samples_per_pixel = 250;
    //var cam = Camera.init(16.0 / 9.0, 200);
    //cam.samples_per_pixel = 10;
    cam.max_depth = 50;
    cam.vfov = 20;
    cam.lookfrom = point3.init(13, 2, 3);
    cam.lookat = point3.init(0, 0, 0);
    cam.vup = vec3.init(0, 1, 0);
    cam.defocus_angle = 0.6;
    cam.focus_dist = 10.0;
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
