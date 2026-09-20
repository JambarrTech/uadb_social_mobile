import 'dart:io';
import 'package:image/image.dart';

void main() {
  final width = 1024;
  final height = 1024;
  
  final image = Image(width: width, height: height);
  
  // Primary blue color
  final primaryColor = ColorRgb8(0x0B, 0x4F, 0xA2);
  final whiteColor = ColorRgb8(0xFF, 0xFF, 0xFF);
  
  // Fill with primary color
  fill(image, color: primaryColor);
  
  // Draw a circle background
  drawCircle(
    image,
    x: width ~/ 2,
    y: height ~/ 2,
    radius: width ~/ 2 - 20,
    color: primaryColor,
  );
  
  // Draw "U" shape (left)
  final centerX = width ~/ 2;
  final centerY = height ~/ 2;
  final letterSize = 200;
  final strokeWidth = 40;
  
  // Draw "U" - left vertical bar
  drawRect(
    image,
    x1: centerX - letterSize - 20,
    y1: centerY - letterSize,
    x2: centerX - letterSize - 20 + strokeWidth,
    y2: centerY + letterSize,
    color: whiteColor,
  );
  
  // Draw "U" - bottom curve (approximated with rect)
  drawRect(
    image,
    x1: centerX - letterSize - 20,
    y1: centerY + letterSize - strokeWidth,
    x2: centerX - 20,
    y2: centerY + letterSize,
    color: whiteColor,
  );
  
  // Draw "U" - right vertical bar
  drawRect(
    image,
    x1: centerX - 20 - strokeWidth,
    y1: centerY - letterSize,
    x2: centerX - 20,
    y2: centerY + letterSize,
    color: whiteColor,
  );
  
  // Draw "S" - simplified as three horizontal bars with connections
  final sX = centerX + 20;
  final sY = centerY;
  final sWidth = letterSize;
  final sHeight = letterSize * 2;
  final barHeight = strokeWidth;
  
  // Top bar
  drawRect(
    image,
    x1: sX,
    y1: sY - sHeight,
    x2: sX + sWidth,
    y2: sY - sHeight + barHeight,
    color: whiteColor,
  );
  
  // Middle bar
  drawRect(
    image,
    x1: sX,
    y1: sY - barHeight ~/ 2,
    x2: sX + sWidth,
    y2: sY + barHeight ~/ 2,
    color: whiteColor,
  );
  
  // Bottom bar
  drawRect(
    image,
    x1: sX,
    y1: sY + sHeight - barHeight,
    x2: sX + sWidth,
    y2: sY + sHeight,
    color: whiteColor,
  );
  
  // Left connectors for S
  drawRect(
    image,
    x1: sX,
    y1: sY - sHeight,
    x2: sX + barHeight,
    y2: sY,
    color: whiteColor,
  );
  
  drawRect(
    image,
    x1: sX,
    y1: sY,
    x2: sX + barHeight,
    y2: sY + sHeight,
    color: whiteColor,
  );
  
  // Save
  final pngBytes = encodePng(image);
  final file = File('assets/icon/icon.png');
  file.writeAsBytesSync(pngBytes);
  print('Icon generated: ${file.path} (${pngBytes.length} bytes)');
}