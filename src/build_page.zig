const std = @import("std");
pub const SIZE: usize = 50;

pub fn generatePage() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    const docStart = "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\" /><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" /><title>Generator</title></head><body>";

    const howManyButtons = SIZE * SIZE;

    const docEnd = "</body></html>";

    const file = try std.fs.cwd().createFile("index.html", .{});
    defer file.close();
    const writer = file.writer();
    var buf_writer = std.io.bufferedWriter(writer);

    _ = try buf_writer.write(docStart);
    {
        var maal = std.mem.zeroes([100]u8);
        _ = try std.fmt.bufPrint(&maal, "<script>var L={0};</script>", .{howManyButtons});
        _ = try buf_writer.write(&maal);
    }

    for (0..howManyButtons) |i| {
        var maal = std.mem.zeroes([100]u8);

        _ = try std.fmt.bufPrint(&maal, "<button id={0} onclick=toggle('{0}')>O</button>", .{i});
        _ = try buf_writer.write(&maal);
        if ((i + 1) % std.math.sqrt(howManyButtons) == 0) {
            _ = try buf_writer.write("<br />");
        }
    }

    _ = try buf_writer.write("<h3 id='v1'>0</h3>");
    _ = try buf_writer.write("<script>String.prototype.replaceAt = function(index, replacement) {return this.substring(0, index) + replacement + this.substring(index + replacement.length);};var v1='0'.repeat(L);function toggle(id){e=document.getElementById(id);e.style.background = e.style.background == 'black' ? '' : 'black';v1=v1.replaceAt(L-1-id,v1[L-1-id] == '1' ? '0' : '1');p=document.getElementById('v1');p.textContent=trim(v1);}</script>");
    _ = try buf_writer.write("<script>function trim(v){var p='',a=false;for(c of v){if(c=='1'){a=true};if(a){p+=c;}}return p;}</script>");
    _ = try buf_writer.write(docEnd);
    try buf_writer.flush();
}
