const Material = @import("Material.zig");
const color = @import("vec3.zig").color;
const vec3 = @import("vec3.zig").vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const Mat_Lambertian = @This();

albedo: color,

pub fn ToMaterial(self: *const Mat_Lambertian) Material {
    return .{
        .ptr = self,
        .vtable = &.{
            .scatter = scatter,
        },
    };
}

pub fn scatter(ctx: *const anyopaque, r_in: Ray, rec: HitRecord, attenuation: *color, scattered: *Ray) bool {
    const self: *const Mat_Lambertian = @ptrCast(@alignCast(ctx));
    _ = r_in;

    var scatter_direction = vec3.add(rec.normal, color.random_unit_vector());

    if (scatter_direction.near_zero()) {
        scatter_direction = rec.normal;
    }

    attenuation.* = self.albedo;
    scattered.* = Ray.init(rec.p, scatter_direction);
    return true;
}
