const std = @import("std");
const Line = @import("line.zig").Line;

pub const Vector2I = struct {
    x: i32,
    y: i32,

    pub const zero: Vector2I = .{ .x = 0, .y = 0 };

    pub fn init(x: i32, y: i32) Vector2I {
        return .{ .x = x, .y = y };
    }

    pub fn add(a: Vector2I, b: Vector2I) Vector2I {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: Vector2I, b: Vector2I) Vector2I {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn mult(a: Vector2I, b: Vector2I) Vector2I {
        return .{ .x = a.x * b.x, .y = a.y * b.y };
    }

    pub fn div(a: Vector2I, b: Vector2I) Vector2I {
        return .{ .x = a.x / b.x, .y = a.y / b.y };
    }

    pub fn scale(a: Vector2I, c: i132) Vector2I {
        return .{ .x = a.x * c, .y = a.y * c };
    }

    pub fn toFloat(a: Vector2I) Vector2 {
        return .{ .x = @floatFromInt(a.x), .y = @floatFromInt(a.y) };
    }

    pub fn toDouble(a: Vector2I) Vector2B {
        return .{ .x = @floatFromInt(a.x), .y = @floatFromInt(a.y) };
    }
};

pub const Vector2 = struct {
    x: f32,
    y: f32,

    pub const zero: Vector2 = .{ .x = 0, .y = 0 };

    pub fn init(x: f32, y: f32) Vector2 {
        return .{ .x = x, .y = y };
    }

    pub fn add(a: Vector2, b: Vector2) Vector2 {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: Vector2, b: Vector2) Vector2 {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn mult(a: Vector2, b: Vector2) Vector2 {
        return .{ .x = a.x * b.x, .y = a.y * b.y };
    }

    pub fn div(a: Vector2, b: Vector2) Vector2 {
        return .{ .x = a.x / b.x, .y = a.y / b.y };
    }

    pub fn scale(a: Vector2, c: f32) Vector2 {
        return .{ .x = a.x * c, .y = a.y * c };
    }

    pub fn toVector2B(a: Vector2) Vector2B {
        return .{ .x = a.x, .y = a.y };
    }

    pub fn round(a: Vector2) Vector2I {
        var b: Vector2I = .{ .x = @intFromFloat(a.x), .y = @intFromFloat(a.y) };
        if (a.x - @as(f32, @floatFromInt(b.y)) >= 0.5)
            b.x += 1;
        if (a.y - @as(f32, @floatFromInt(b.y)) >= 0.5)
            b.y += 1;
        return b;
    }
};

pub const Vector2B = struct {
    x: f64,
    y: f64,

    pub const zero: Vector2B = .{ .x = 0, .y = 0 };

    pub fn init(x: f64, y: f64) Vector2B {
        return .{ .x = x, .y = y };
    }

    pub fn add(a: Vector2B, b: Vector2B) Vector2B {
        return .{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: Vector2B, b: Vector2B) Vector2B {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn mult(a: Vector2B, b: Vector2B) Vector2B {
        return .{ .x = a.x * b.x, .y = a.y * b.y };
    }

    pub fn div(a: Vector2B, b: Vector2B) Vector2B {
        return .{ .x = a.x / b.x, .y = a.y / b.y };
    }

    pub fn scale(a: Vector2B, c: f64) Vector2B {
        return .{ .x = a.x * c, .y = a.y * c };
    }

    pub fn trunc(a: Vector2B) Vector2 {
        return .{
            .x = @floatCast(a.x),
            .y = @floatCast(a.y),
        };
    }

    pub fn round(a: Vector2) Vector2I {
        var b: Vector2I = .{ .x = @intFromFloat(a.x), .y = @intFromFloat(a.y) };
        if (a.x - @as(f64, @floatFromInt(b.y)) >= 0.5)
            b.x += 1;
        if (a.y - @as(f64, @floatFromInt(b.y)) >= 0.5)
            b.y += 1;
        return b;
    }
};

pub const QuadSpline = struct {
    p0: Vector2I,
    p1: Vector2I,
    p2: Vector2I,

    const errors = error{
        weird,
    };

    pub fn draw(c: *QuadSpline, out_buffer: []Vector2I) []Vector2I {
        const curves: []QuadSpline = ([1]QuadSpline{.{ .p0 = .zero, .p1 = .zero, .p2 = .zero }} ** 3)[0..3];
        curves = c.cutToMonotone(curves);
        switch (curves.len) {
            1 => return curves[0].DrawMonotone(out_buffer),
            2 => {
                const c1 = curves[0].drawMonotone(out_buffer);
                const c2 = curves[1].drawMonotone(out_buffer[c1.len..]);
                return out_buffer[0..(c1.len + c2.len)];
            },
            3 => {
                const c1 = curves[0].drawMonotone(out_buffer);
                const c2 = curves[1].drawMonotone(out_buffer[c1.len..]);
                const c3 = curves[2].drawMonotone(out_buffer[(c1.len + c2.len)..]);
                return out_buffer[0..(c1.len + c2.len + c3.len)];
            },
            else => unreachable,
        }
    }

    fn cutToMonotone(c: *QuadSpline, out_buffer: []QuadSpline) []QuadSpline {
        const t = c.p1.sub(c.p0).scale(-1).toFloat().div(c.p0.add(c.p1.scale(-2)).add(c.p2).toFloat());

        const State = packed struct {
            x_valid: bool,
            y_valid: bool,
            y_then_x: bool,
        };

        const x_valid = t[0] < 0 or t[0] > 1;
        const y_valid = t[1] < 0 or t[1] > 1;
        const _state: State = .{
            .x_valid = x_valid,
            .y_valid = y_valid,
            .y_then_x = x_valid and y_valid and t[1] < t[0],
        };
        const state_enum = enum(u4) {
            null,
            x_valid,
            y_valid,
            x_then_y,
            y_then_x,
        };
        const state: state_enum = @ptrCast(_state);
        switch (state) {
            .null => {
                out_buffer[0] = c;
                return out_buffer[0..1];
            },
            .x_valid => {
                const p0: Vector2 = c.p0;
                const p1: Vector2 = c.p1;
                const p2: Vector2 = c.p2;

                //find the point to cut at
                const p4: Vector2I = c.evaluate(t[0]);

                //find y-intersections with axes of the spline
                const t3: f32 = (p4.X - p0.X) / (p1.X - p0.X);
                const p3: Vector2I = p0.scale(1 - t3).add(p1.scale(t3));

                const t5: f32 = (p4.X - p2.X) / (p1.X - p2.X);
                const p5: Vector2I = p2.scale(1 - t5).add(p1.scale(t5)).round();

                //get the new splines
                out_buffer[0] = .{ .p0 = p0, .p1 = p3, .p2 = p4 };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p2 };
                return out_buffer[0..2];
            },
            .y_valid => {
                const p0: Vector2 = c.p0;
                const p1: Vector2 = c.p1;
                const p2: Vector2 = c.p2;

                //find the point to cut at
                const p4: Vector2I = c.evaluate(t[1]);

                //find y-intersections with axes of the spline
                const t3: f32 = (p4.Y - p0.Y) / (p1.Y - p0.Y);
                const p3: Vector2I = p0.scale(1 - t3).add(p1.scale(t3)).round();

                const t5: f32 = (p4.Y - p2.Y) / (p1.Y - p2.Y);
                const p5: Vector2I = p2.scale(1 - t5).add(p1.scale(t5)).round();

                //get the new splines
                out_buffer[0] = .{ .p0 = p0, .p1 = p3, .p2 = p4 };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p2 };
                return out_buffer[0..2];
            },
            .x_then_y => {
                const p0: Vector2 = c.p0;
                const p1: Vector2 = c.p1;
                const p2: Vector2 = c.p2;

                const p4: Vector2I = c.evaluate(t[1]);
                const t3: f32 = (p4.Y - p0.Y) / (p1.Y - p0.Y);
                const p3: Vector2I = p0.scale(1 - t3).add(p1.scale(t3)).round();
                out_buffer[0] = .{ .p0 = p0, .p1 = p3, .p2 = p4 };

                const p6: Vector2I = c.evaluate(t[0]);
                const t7: f32 = (p6.X - p2.X) / (p1.X - p2.X);
                const p7: Vector2I = p2.scale(1 - t7).add(p1.scale(t7)).round();
                out_buffer[2] = .{ .p0 = p6, .p1 = p7, .p2 = p2 };

                const p5: Vector2I = .{ p6[0], p4[1] };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p6 };

                return out_buffer[0..3];
            },
            .y_then_x => {
                const p0: Vector2 = c.p0;
                const p1: Vector2 = c.p1;
                const p2: Vector2 = c.p2;

                const p4: Vector2I = c.evaluate(t[0]);
                const t3: f32 = (p4.X - p0.X) / (p1.X - p0.X);
                const p3: Vector2I = p0.scale(1 - t3).add(p1.scale(t3)).round();
                out_buffer[0] = .{ .p0 = p0, .p1 = p3, .p2 = p4 };

                const p6: Vector2I = c.evaluate(t[1]);
                const t7: f32 = (p6.Y - p2.Y) / (p1.Y - p2.Y);
                const p7: Vector2I = p2.scale(1 - t7).add(p1.scale(t7)).round();
                out_buffer[2] = .{ .p0 = p6, .p1 = p7, .p2 = p2 };

                const p5: Vector2I = .{ p4[0], p6[1] };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p6 };

                return out_buffer[0..3];
            },
        }
    }

    fn evaluate(c: *QuadSpline, t: f32) Vector2I {
        const p0: Vector2 = c.p0;
        const p1: Vector2 = c.p1;
        const p2: Vector2 = c.p2;

        return p0.scale((1 - t) * (1 - t)).add(p1.scale(2 * (1 - t) * t)).add(p2.scale(t * t)).round();
    }

    fn drawMonotone(c: *QuadSpline, out_buffer: []Vector2I) []Vector2I {
        //translate to simplify
        var p = c.p0 - c.p1;
        var q = c.p2 - c.p1;

        //find orientation
        const s: Vector2I = .{
            .x = if ((q - p).X >= 0) 1 else -1,
            .y = if ((q - p).Y <= 0) 1 else -1,
        };

        //move it, move it
        p *= s;
        q *= s;

        var cur = p.X * q.Y - p.Y * q.X;

        //negate curvature
        if (cur > 0) {
            const temp = -p;
            p = -q;
            q = temp;

            temp = c.p0;
        }

        //some helpful mid-terms
        const a = p + q;
        cur = p.X * q.Y - p.Y * q.X; //curvature
        const d = p - q;

        const c20: u32 = a.Y * a.Y;
        const c11: u32 = -2 * a.X * a.Y;
        const c02: u32 = a.X * a.X;
        const c10: u32 = 2 * d.Y * c;
        const c01: u32 = -2 * d.X * c;
        const c00: u32 = c * c;
        _ = c00;

        if (!((q - p)[0] >= 0 and (q - p)[1] <= 0))
            std.debug.print("FAIL");

        //begin with longer part
        //if (q.X * q.X + q.Y * q.Y > p.X * p.X + p.Y * p.Y)
        //{
        //    (p0, p2) = (p2, p0);
        //    cur = -cur;
        //    (p, q) = (q, p);
        //    b = -b;
        //}

        if (cur == 0) //straight line
        {
            const line: Line = .{ .p = c.p0, .q = c.p2 };
            return line.ComputePixels(out_buffer);
        }

        //2nd degree differences, hence CONSTANT
        const xx = 2 * c.c20;
        const yy = 2 * c.c02;
        const xy = c.c11;

        //1st degrree differences
        var dx: u64 =
            2 * c20 * p.X +
            c20 +
            c11 * p.Y +
            c10;
        var dy: u64 =
            2 * (-1) * c02 * p.Y +
            c02 +
            (-1) * c11 * p.X +
            (-1) * c01;
        var e: u64 = dx + dy + xy;

        var pos: Vector2I = c.p0;
        var no = 0;
        var yStep: bool = undefined;
        var xStep: bool = undefined;

        while (dy > 0 and dx < 0 and no < out_buffer.len) //if the gradient changes then alg fails
        {
            out_buffer[no] = pos;
            no += 1;
            if (pos == c.p2)
                break;

            yStep = 2 * e < dy;
            xStep = 2 * e > dx;
            if (xStep) //x step
            {
                pos.X += s.x;
                dy += xy;
                dx += xx;
                e += dx + xy;
            }

            if (yStep) //y step
            {
                pos.Y += s.y;
                dx += xy;
                dy += yy;
                e += dy + xy;
            }
        }

        //algorithm failed so is too close to being a straight line
        //do rest with s straight line
        if (pos != c.p2) {
            const line: Line = .{ .p0 = pos, .p1 = c.p2 };
            const linePixels: []Vector2I = line.draw(out_buffer[no..]);
            no += linePixels.len;
        }

        return out_buffer[0..no];
    }
};
