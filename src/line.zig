const Vector2I = @import("root.zig").Vector2I;

pub const Line = struct {
    p: Vector2I,
    q: Vector2I,

    fn draw(c: *Line, out_buffer: []Vector2I) []Vector2I {
        var i: u32 = 0;

        const p: Vector2I = c.p;
        const q: Vector2I = c.q;

        const sx = if (q.X > p.X) 1 else -1;
        const sy = if (q.Y > p.Y) 1 else -1;
        const dx: u16 = -sy * (q.Y - p.Y);
        const dy: u16 = sx * (q.X - p.X);
        var e: u32 = dx + dy;
        var e2: u32 = 0;
        var r: Vector2I = p;

        while (true) {
            if (i == out_buffer.len)
                break;

            out_buffer[i] = r;
            i += 1;

            if (r.x == q.x and r.y == q.y)
                break;

            e2 = 2 * e;
            if (e2 >= dx) {
                e += dx;
                r.x += sx;
            }
            if (e2 <= dy) {
                e += dy;
                r.y += sy;
            }
        }

        return out_buffer[0..i];
    }
};
