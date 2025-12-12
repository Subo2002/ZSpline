const Vector2I = @import("zsmath").Vector2I;

pub const Circle = struct {
    p: Vector2I,
    r: i16,

    pub fn init(p: Vector2I, r: i16) Circle {
        return .{ .p = p, .r = r };
    }

    pub fn draw(c: *const Circle, out_buffer: []Vector2I) []Vector2I {
        var dx: i32 = 1;
        var dy: i32 = 1 - 2 * c.r;

        const ddx = 2;
        const ddy = 2;

        var e: i32 = dx + dy;
        var e2: i32 = 0;
        var pos: Vector2I = .{ .x = 0, .y = c.r };

        var i: usize = 0;
        while (true) {
            if (i == out_buffer.len)
                break;

            out_buffer[i] = c.p.add(pos);
            out_buffer[i + 1] = c.p.add(.{ .x = -pos.x, .y = pos.y });
            out_buffer[i + 2] = c.p.add(.{ .x = pos.x, .y = -pos.y });
            out_buffer[i + 3] = c.p.add(.{ .x = -pos.x, .y = -pos.y });
            i += 4;

            if (pos.eql(.{ .x = c.r, .y = 0 }))
                break;

            e2 = 2 * e;
            if (e2 <= dx) {
                dx += ddx;
                e += dx;
                pos.x += 1;
            }
            if (e2 >= dy) {
                dy += ddy;
                e += dy;
                pos.y += -1;
            }
        }

        return out_buffer[0..i];
    }

    //pub fn drawFilled(c: *const Circle, out_buffer: []Vector2I) []Vector2I {
    //    var dx: i32 = 1;
    //    var dy: i32 = 1 - 2 * c.r;
    //
    //    const ddx = 2;
    //    const ddy = 2;
    //
    //    var e: i32 = dx + dy;
    //    var e2: i32 = 0;
    //    var pos: Vector2I = .{ .x = 0, .y = c.r };
    //
    //    var i: usize = 0;
    //    while (true) {
    //        if (i == out_buffer.len)
    //            break;

    //        out_buffer[i] = c.p.add(pos);
    //        out_buffer[i + 1] = c.p.add(.{ .x = -pos.x, .y = pos.y });
    //        out_buffer[i + 2] = c.p.add(.{ .x = pos.x, .y = -pos.y });
    //        out_buffer[i + 3] = c.p.add(.{ .x = -pos.x, .y = -pos.y });
    //        i += 4;
    //
    //        if (pos.eql(.{ .x = c.r, .y = 0 }))
    //            break;
    //
    //        e2 = 2 * e;
    //        if (e2 <= dx) {
    //            dx += ddx;
    //            e += dx;
    //            pos.x += 1;
    //        }
    //        if (e2 >= dy) {
    //            dy += ddy;
    //            e += dy;
    //            pos.y += -1;
    //        }
    //    }

    //    var j: usize = 0;
    //    while (j < @divTrunc(i, 4)) {}
    //    return out_buffer[0..i];
    //}
};
