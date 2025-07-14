const Vector2I = @import("root.zig").Vector2I;

pub const Line = struct {
    p: Vector2I,
    q: Vector2I,

    pub fn draw(c: *const Line, out_buffer: []Vector2I) []Vector2I {
        var i: u32 = 0;

        const p: Vector2I = c.p;
        const q: Vector2I = c.q;

        const sx = if (q.x > p.x) 1 else -1;
        const sy = if (q.y > p.y) 1 else -1;
        const dx: u16 = -sy * (q.y - p.y);
        const dy: u16 = sx * (q.x - p.x);
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
