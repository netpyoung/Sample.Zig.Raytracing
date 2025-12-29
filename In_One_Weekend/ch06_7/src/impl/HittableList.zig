const std = @import("std");
const Hittable = @import("Hittable.zig");
const point3 = @import("vec3.zig").point3;
const vec3 = @import("vec3.zig").vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const HittableList = @This(); // Hittable

objects: std.array_list.Aligned(Hittable, null),

pub fn hittable(self: *HittableList) Hittable {
    return Hittable{
        .ptr = self,
        .vtable = &.{
            .hit = hit,
        },
    };
}

pub fn init() HittableList {
    return .{ .objects = .empty };
}

pub fn deinit(self: *HittableList, allocator: std.mem.Allocator) void {
    self.clear(allocator);
}

pub fn initWith(allocator: std.mem.Allocator, obj: Hittable) HittableList {
    var objects = std.array_list.Aligned(Hittable, null);
    objects.append(allocator, obj) catch unreachable;
    return .{ .objects = objects };
}

pub fn clear(self: *HittableList, allocator: std.mem.Allocator) void {
    self.objects.clearAndFree(allocator);
}

pub fn add(self: *HittableList, allocator: std.mem.Allocator, item: Hittable) void {
    self.objects.append(allocator, item) catch unreachable;
}


fn hit(ctx: *anyopaque, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
    const self: *HittableList = @ptrCast(@alignCast(ctx));
    var temp_rec: HitRecord = undefined;
    var hit_anything = false;
    var closest_so_far = ray_tmax;

    for (self.objects.items) |*object| {
        if (object.hit(r, ray_tmin, closest_so_far, &temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec.* = temp_rec;
        }
    }

    return hit_anything;
}