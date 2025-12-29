const Material = @import("Material.zig");
const color = @import("vec3.zig").color;
const vec3 = @import("vec3.zig").vec3;
const Ray = @import("Ray.zig");
const HitRecord = @import("HitRecord.zig");

const Mat_Dielectric = @This();

refraction_index: f64,

pub fn init(refraction_index: f64) Mat_Dielectric {
    return .{
        .refraction_index = refraction_index,
    };
}

pub fn ToMaterial(self: *const Mat_Dielectric) Material {
    return .{
        .ptr = self,
        .vtable = &.{
            .scatter = scatter,
        },
    };
}

pub fn scatter(ctx: *const anyopaque, r_in: Ray, rec: HitRecord, attenuation: *color, scattered: *Ray) bool {
    const self: *const Mat_Dielectric = @ptrCast(@alignCast(ctx));

    var ri: f64 = undefined;
    if (rec.front_face) {
        ri = (1.0 / self.refraction_index);
    } else {
        ri = self.refraction_index;
    }

    const unit_direction = vec3.unit(r_in.direction);
    const refracted = vec3.refract(unit_direction, rec.normal, ri);

    attenuation.* = color.one;
    scattered.* = Ray.init(rec.p, refracted);
    return true;
}
