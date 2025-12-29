const Material = @import("Material.zig");
const color = @import("vec3.zig").color;
const vec3 = @import("vec3.zig").vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const Mat_Metal = @This();

albedo: color,

pub fn ToMaterial(self: *const Mat_Metal) Material {
    return .{
        .ptr = self,
        .vtable = &.{
            .scatter = scatter,
        },
    };
}

pub fn scatter(ctx: *const anyopaque, r_in: Ray, rec: HitRecord, attenuation: *color, scattered: *Ray) bool {
    const self: *const Mat_Metal = @ptrCast(@alignCast(ctx));

    const reflected = vec3.reflect(r_in.direction, rec.normal);
    attenuation.* = self.albedo;
    scattered.* = Ray.init(rec.p, reflected);
    return true;
}
