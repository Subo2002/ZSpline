const Vector2I32 = @import("zsmath").Vector2Int(i32);

pub const Line = struct {
    p: Vector2I32,
    q: Vector2I32,

    pub fn init(p: Vector2I32, q: Vector2I32) Line {
        return Line{
            .p = p,
            .q = q,
        };
    }

    pub fn draw(c: *const Line, out_buffer: []Vector2I32) []Vector2I32 {
        var i: usize = 0;

        const p: Vector2I32 = c.p;
        const q: Vector2I32 = c.q;

        const sx: i2 = if (q.x > p.x) 1 else -1;
        const sy: i2 = if (q.y > p.y) 1 else -1;
        const dx: i32 = -sy * (q.y - p.y);
        const dy: i32 = sx * (q.x - p.x);
        var e: i32 = dx + dy;
        var e2: i32 = 0;
        var r: Vector2I32 = p;
        var cx: i32 = 0;
        var cy: i32 = 0;
        const len = out_buffer.len;

        out_buffer[i] = p;
        i += 1;

        while (true) {
            e2 = e << 1; //maybe
            cx = -@as(i32, @intFromBool(e2 >= dx)); //0 -> 0x0000, 1 -> 0xFFFF bit masks
            cy = -@as(i32, @intFromBool(e2 <= dy));
            e += (cx & dx) + (cy & dy); //using bit masks and & to avoid * by 0 or 1, which compiles to using imul, even if cx cy are u1
            r.x += cx & sx;
            r.y += cy & sy;

            out_buffer[i] = r;
            i += 1;
            if (i == len) {
                @branchHint(.cold);
                break;
            }
            if (r.x == q.x and r.y == q.y) break;
        }

        return out_buffer[0..i];
    }
};

//old, but not any worse actually
//pub fn draw(c: *const Line, out_buffer: []Vector2I) []Vector2I {
//    var i: u32 = 0;
//
//    const p: Vector2I = c.p;
//    const q: Vector2I = c.q;
//
//    const sx: i32 = if (q.x > p.x) 1 else -1;
//    const sy: i32 = if (q.y > p.y) 1 else -1;
//    const dx: i32 = -sy * (q.y - p.y);
//    const dy: i32 = sx * (q.x - p.x);
//    var e: i32 = dx + dy;
//    var e2: i32 = 0;
//    var r: Vector2I = p;
//
//    while (true) {
//        if (i == out_buffer.len)
//            break;
//
//        out_buffer[i] = r;
//        i += 1;
//
//        if (r.x == q.x and r.y == q.y)
//            break;
//
//        e2 = 2 * e;
//        if (e2 >= dx) {
//            e += dx;
//            r.x += sx;
//        }
//        if (e2 <= dy) {
//            e += dy;
//            r.y += sy;
//        }
//    }
//
//    return out_buffer[0..i];
//}

test "line works" {
    const line = Line{
        .p = .zero,
        .q = .init(32, 32),
    };
    var buffer: [64]Vector2I32 = undefined;
    const points = line.draw(buffer[0..]);
    try @import("std").testing.expect(points.len > 0);
}
