const std = @import("std");
const Allocator = std.mem.Allocator;

const json = std.json;

const GameRunner = enum {
    WineGE,
    Native
};

const GameOptions = struct {
    gamescope: bool,
    gamemode: bool,
};

const GameConfig = struct {
    name: []const u8,
    path: []const u8,
    runner: GameRunner,
    options: GameOptions,
    pub fn run(self: *const GameConfig, allocator: Allocator) !void {
        var argv = std.ArrayList([]const u8).init(allocator);
        defer argv.deinit();
        if (self.options.gamescope) {
            try argv.append("gamescope");
            try argv.append("-f");
        }
        try argv.append(self.path);
        
        const args = .{
            .allocator = allocator,
            .argv = argv.toOwnedSlice(), 
            .max_output_bytes = 100000,
            .expand_arg0 = std.ChildProcess.Arg0Expand.no_expand,
        };
        const result = try std.ChildProcess.exec(args);
        allocator.free(result.stdout);
        allocator.free(result.stderr);
    }
};

fn parse_game_json(allocator: Allocator, path: []const u8) !GameConfig {
    var file = try std.fs.cwd().openFile(path, .{});
    const file_len = (try file.stat()).size;
    var buffer = try allocator.alloc(u8, file_len);
    defer allocator.free(buffer);
    try file.reader().readNoEof(buffer);


    var stream = json.TokenStream.init(buffer);
    const game_config = try json.parse(GameConfig, &stream, .{.allocator = allocator });
    return game_config;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();
    const game_config: GameConfig = try parse_game_json(allocator, "welp.txt");
    defer json.parseFree(GameConfig, game_config, .{.allocator = allocator });
    try game_config.run(allocator);
}
