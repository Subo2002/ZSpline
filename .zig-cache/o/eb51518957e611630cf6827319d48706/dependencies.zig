pub const packages = struct {
    pub const @"ZSMath-0.0.0-xSatLi1eAACOnPI_GecuDkkwyjrMXhbphOJnw_IpBE0o" = struct {
        pub const build_root = "C:\\Users\\suboc\\AppData\\Local\\zig\\p\\ZSMath-0.0.0-xSatLi1eAACOnPI_GecuDkkwyjrMXhbphOJnw_IpBE0o";
        pub const build_zig = @import("ZSMath-0.0.0-xSatLi1eAACOnPI_GecuDkkwyjrMXhbphOJnw_IpBE0o");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"zstbi-0.11.0-dev-L0Ea_9WVBwAO8t0Qbr87vnCEf1QBcNQHbV-O_D0UWYqT" = struct {
        pub const build_root = "C:\\Users\\suboc\\AppData\\Local\\zig\\p\\zstbi-0.11.0-dev-L0Ea_9WVBwAO8t0Qbr87vnCEf1QBcNQHbV-O_D0UWYqT";
        pub const build_zig = @import("zstbi-0.11.0-dev-L0Ea_9WVBwAO8t0Qbr87vnCEf1QBcNQHbV-O_D0UWYqT");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "zstbi", "zstbi-0.11.0-dev-L0Ea_9WVBwAO8t0Qbr87vnCEf1QBcNQHbV-O_D0UWYqT" },
    .{ "ZSMath", "ZSMath-0.0.0-xSatLi1eAACOnPI_GecuDkkwyjrMXhbphOJnw_IpBE0o" },
};
