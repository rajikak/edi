const std = @import("std");

pub fn read_file(file_name: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();
    const stat = try file.stat();
    const fileSize = stat.size;
    return try file.reader().readAllAlloc(allocator, fileSize);
}
