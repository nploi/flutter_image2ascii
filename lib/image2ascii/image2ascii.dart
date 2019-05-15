import 'dart:io';

import 'package:image/image.dart';
import 'dart:math';

enum MODE { simple, complex }

var simpleAscii = '@%#*+=-:. ';
var complexAscii =
    '\$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,\"^` ';

class Image2Ascii {
  // Path input of image
  final String path;

  // Path to output text file
  MODE mode;

  // 10 or 70 different characters
  int numberColums;

  Image2Ascii({this.path, this.mode = MODE.simple, this.numberColums = 100})
      : assert(path != null),
        assert(mode != null),
        assert(numberColums > 0);

  String getASCII() {
    String chars = simpleAscii;
    if (this.mode == MODE.complex) {
      chars = complexAscii;
    }

    File file = new File(this.path);
    int numberChars = chars.length;
    Image image = decodeImage(file.readAsBytesSync());
    image = grayscale(image);
    int numberColums = this.numberColums,
        height = image.height,
        width = image.width,
        cellWidth = width ~/ numberColums,
        cellHeight = (cellWidth * 2).toInt(),
        numberRows = height ~/ cellHeight;

    // Too many columns or rows. Use default setting
    if (numberRows > width || numberRows > height) {
      cellWidth = 6;
      cellHeight = 12;
      numberColums = width ~/ cellWidth;
      numberRows = height ~/ cellHeight;
    }

    String lines = '';
    for (int i = 0; i < numberRows; i++) {
      String line = '';
      for (int j = 0; j < numberColums; j++) {
        int index = (getAVG(
                    image,
                    j * cellWidth,
                    min((j + 1) * cellWidth, width),
                    i * cellHeight,
                    min((i + 1) * cellHeight, height)) *
                numberChars) ~/
            255;
        line += chars[min(index, numberChars - 1)];
      }
      lines += line + '\n';
    }
    return lines;
  }

  int getAVG(Image image, int iStart, int iEnd, int jStart, int jEnd) {
    int sum = 0, count = 0;
    for (int i = iStart; i < iEnd; i++) {
      for (int j = jStart; j < jEnd; j++) {
        sum += getLuminance((image.getPixel(i, j)).toInt());
        count++;
      }
    }
    return sum ~/ count;
  }
}
