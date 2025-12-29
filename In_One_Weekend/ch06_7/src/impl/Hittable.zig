const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const Hittable = @This();

ptr: *anyopaque,
vtable: *const VTable,

pub const VTable = struct {
    hit: *const fn (ctx: *anyopaque, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool,
};

pub fn hit(self: Hittable, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
    return self.vtable.hit(self.ptr, r, ray_tmin, ray_tmax, rec);
}
