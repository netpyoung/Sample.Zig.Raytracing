const std = @import("std");
const point3 = @import("vec3.zig").point3;
const vec3 = @import("vec3.zig").vec3;

const Ray = @This();

origin: point3,
direction: vec3,

pub fn init(origin: point3, direction: point3) Ray {
    return .{ .origin = origin, .direction = direction };
}

pub fn at(self: Ray, t: f64) point3 {
    return point3{ .e = @mulAdd(@Vector(4, f64), @splat(t), self.direction.e, self.origin.e) };
}
