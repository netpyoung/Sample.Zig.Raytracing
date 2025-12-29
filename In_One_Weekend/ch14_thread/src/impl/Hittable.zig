const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");
const Interval = @import("Interval.zig");

const Hittable = @This();

ptr: *anyopaque,
vtable: *const VTable,

pub const VTable = struct {
    hit: *const fn (ctx: *anyopaque, r: Ray, ray_t: Interval, rec: *HitRecord) bool,
};

pub fn hit(self: Hittable, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
    return self.vtable.hit(self.ptr, r, ray_t, rec);
}