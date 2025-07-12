const std = @import("std");
const testing = std.testing;
const Line = @import("line.zig").Line;

fn round(x: @Vector(2, f32)) @Vector(2, u16) {
    var y: @Vector(2, u16) = @intFromFloat(x);
    if (x.X - y.X >= 0.5)
        y.X ++ 1;
    if (x.Y - y.Y >= 0.5)
        y.Y += 1;
    return y;
}

const Vector2I = struct {
    x: u16,
    y: u16,
};

const QuadCurveParam = struct {
    p0: @Vector(2, u16),
    p1: @Vector(2, u16),
    p2: @Vector(2, u16),

    fn compImplct(c: *QuadCurveParam) QuadCurveImplct {
        //translate to simplify
        var p = c.p0 - c.p1;
        var q = c.p2 - c.p1;

        //find orientation
        const s = .{
            if ((q - p).X >= 0) 1 else -1,
            if ((q - p).Y <= 0) 1 else -1,
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
        }

        //some helpful mid-terms
        const a = p + q;
        cur = p.X * q.Y - p.Y * q.X; //curvature
        const d = p - q;

        return .{
            .c20 = a.Y * a.Y,
            .c11 = -2 * a.X * a.Y,
            .c02 = a.X * a.X,
            .c10 = 2 * d.Y * c,
            .c01 = -2 * d.X * c,
            .c00 = c * c,
        };
    }

    fn cutToMonotone(c: *QuadCurveParam, out_buffer: []QuadCurveParam) []QuadCurveParam {
        const t: [2]f32 = -(c.p1 - c.p0) / @as(@Vector(2, f32), @floatFromInt(c.p0 - 2 * c.p1 + c.p2));

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
                const p0: @Vector(2, f32) = c.p0;
                const p1: @Vector(2, f32) = c.p1;
                const p2: @Vector(2, f32) = c.p2;

                //find the point to cut at
                const p4: @Vector(2, u16) = c.evaluate(t[0]);

                const one: @Vector(2, f32) = @splat(1.0);

                //find y-intersections with axes of the spline
                const t3: @Vector(2, f32) = @splat((p4.X - p0.X) / (p1.X - p0.X));
                const p3: @Vector(2, u16) = round(p0 * (one - t3) + p1 * t3);

                const t5: @Vector(2, f32) = @splat((p4.X - p2.X) / (p1.X - p2.X));
                const p5: @Vector(2, u16) = round(p2 * (one - t5) + p1 * t5);

                //get the new splines
                out_buffer[0] = .{ .p0 = p0, .p1 = p3, .p2 = p4 };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p2 };
                return out_buffer[0..2];
            },
            .y_valid => {
                const p0: @Vector(2, f32) = c.p0;
                const p1: @Vector(2, f32) = c.p1;
                const p2: @Vector(2, f32) = c.p2;

                //find the point to cut at
                const p4: @Vector(2, u16) = c.evaluate(t[1]);

                const one: @Vector(2, f32) = @splat(1.0);

                //find y-intersections with axes of the spline
                const t3: @Vector(2, f32) = @splat((p4.Y - p0.Y) / (p1.Y - p0.Y));
                const p3: @Vector(2, u16) = round(p0 * (one - t3) + p1 * t3);

                const t5: @Vector(2, f32) = @splat((p4.Y - p2.Y) / (p1.Y - p2.Y));
                const p5: @Vector(2, u16) = round(p2 * (one - t5) + p1 * t5);

                //get the new splines
                out_buffer[0] = .{ .p0 = p0, .p1 = p3, .p2 = p4 };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p2 };
                return out_buffer[0..2];
            },
            .x_then_y => {
                const p0: @Vector(2, f32) = c.p0;
                const p1: @Vector(2, f32) = c.p1;
                const p2: @Vector(2, f32) = c.p2;

                const one: @Vector(2, f32) = @splat(1.0);

                const p4: @Vector(2, u16) = c.evaluate(t[1]);
                const t3: @Vector(2, f32) = @splat((p4.Y - p0.Y) / (p1.Y - p0.Y));
                const p3: @Vector(2, u16) = round(p0 * (one - t3) + p1 * t3);
                out_buffer[0] = .{ .p0 = p0, .p1 = p3, .p2 = p4 };

                const p6: @Vector(2, u16) = c.evaluate(t[0]);
                const t7: @Vector(2, f32) = (p6.X - p2.X) / (p1.X - p2.X);
                const p7: @Vector(2, u16) = round(p2 * (one - t7) + p1 * t7);
                out_buffer[2] = .{ .p0 = p6, .p1 = p7, .p2 = p2 };

                const p5: @Vector(2, u16) = .{ p6[0], p4[1] };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p6 };

                return out_buffer[0..3];
            },
            .y_then_x => {
                const p0: @Vector(2, f32) = c.p0;
                const p1: @Vector(2, f32) = c.p1;
                const p2: @Vector(2, f32) = c.p2;

                const one: @Vector(2, f32) = @splat(1.0);

                const p4: @Vector(2, u16) = c.evaluate(t[0]);
                const t3: @Vector(2, f32) = @splat((p4.X - p0.X) / (p1.X - p0.X));
                const p3: @Vector(2, u16) = round(p0 * (one - t3) + p1 * t3);
                out_buffer[0] = .{ .p0 = p0, .p1 = p3, .p2 = p4 };

                const p6: @Vector(2, u16) = c.evaluate(t[1]);
                const t7: @Vector(2, f32) = (p6.Y - p2.Y) / (p1.Y - p2.Y);
                const p7: @Vector(2, u16) = round(p2 * (one - t7) + p1 * t7);
                out_buffer[2] = .{ .p0 = p6, .p1 = p7, .p2 = p2 };

                const p5: @Vector(2, u16) = .{ p4[0], p6[1] };
                out_buffer[1] = .{ .p0 = p4, .p1 = p5, .p2 = p6 };

                return out_buffer[0..3];
            },
        }
    }

    fn evaluate(c: *QuadCurveParam, t: f32) @Vector(2, u16) {
        const p0: @Vector(2, f32) = c.p0;
        const p1: @Vector(2, f32) = c.p1;
        const p2: @Vector(2, f32) = c.p2;

        return round(p0 * (1 - t) * (1 - t) + 2 * p1 * (1 - t) * t + p2 * t * t);
    }

    fn drawMonotone(c: *QuadCurveParam, out_buffer: []@Vector(2, u16)) []@Vector(2, u16) {
        //translate to simplify
        var p = c.p0 - c.p1;
        var q = c.p2 - c.p1;

        //find orientation
        const s = .{
            if ((q - p).X >= 0) 1 else -1,
            if ((q - p).Y <= 0) 1 else -1,
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

            temp = p0;

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

        var p: @Vector(2, u16) = p0 - p1;
        var q: @Vector(2, u16) = p2 - p1;

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
            const line: Line = .{ .p = p0, .q = p2 };
            return line.ComputePixels(pixelsBuffer);
        }

        //step directions
        int sx = p0.X < p2.X ? 1 : -1;
        int sy = p0.Y < p2.Y ? 1 : -1;

        //2nd degree differences, hence CONSTANT
        long xx = 2 * curve.c20;
        long yy = 2 * curve.c02;
        long xy = -/* sx * sy * */ curve.c11;

        //1st degrree differences
        Int128 dx = 
            2 * curve.c20 * p.X + 
            curve.c20 + 
            curve.c11 * p.Y + 
            curve.c10;
        Int128 dy = 
            2 * (-1) * curve.c02 * p.Y + 
            curve.c02 + 
            (-1) * curve.c11 * p.X + 
            (-1) * curve.c01;
        Int128 e = dx + dy + xy;

        Vector2I pos = p0;
        int no = 0;
        bool yStep;
        bool xStep;
            
        while (dy > 0 && dx < 0 && no < pixelsBuffer.Length) //if the gradient changes then alg fails
        {
            pixelsBuffer[no++] = pos;
            if (pos == p2)
                break;

            yStep = 2 * e < dy;
            xStep = 2 * e > dx;
            if (xStep) //x step
            {
                pos.X += sx;
                dy += xy;
                dx += xx;
                e += dx + xy;
            }

            if (yStep) //y step
            {
                pos.Y += sy;
                dx += xy;
                dy += yy;
                e += dy + xy;
            }
        }

        //algorithm failed so is too close to being a straight line
        //do rest with s straight line
        if (pos != p2)
        {
            Line line = new(pos, p2);
            Span<Vector2I> linePixels = line.ComputePixels(pixelsBuffer[no..]);
            no += linePixels.Length;
        }

        return pixelsBuffer[0..no];
    }
};
