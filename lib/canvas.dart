
import 'dart:math';

import 'package:image/image.dart' as image;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;


class DataNode {
  DataNode(var off, var colorp) {
    offset = off;
    color = colorp;
  }
  late Offset offset;
  late ui.Image? picture = null;
  late image.Image? originalImage = null;

  late String name = "Node";
  late Color color;
  late int index;
  double radius = 30;
  List<int> neighbours = <int>[];
}
List<DataNode> nodes = <DataNode>[];
int indexNodes = 0;

class GraphPainter extends CustomPainter {
  GraphPainter.without();
  Offset origin = Offset(0, 0);
  GraphPainter(var x, var y, Listenable repaint, {var name = ""})
      : super(repaint: repaint) {
    if (x >= 0 && y >= 0) {
      this.origin = origin;

      var circle = Offset(x, y);
      var rand = Random();
      int red = rand.nextInt(255);
      int green = rand.nextInt(255);
      int blue = rand.nextInt(255);
      Color color = Color.fromRGBO(red, green, blue, 1);
      var node = DataNode(circle, color);
      indexNodes += 1;
      node.name = name + " nr. ${indexNodes}";
      node.index = indexNodes;
      nodes.add(node);
    }
  }

  @override
  void paint(Canvas canvas, Size size) async {
    Rect boundary = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(boundary);

    for (var node in nodes) {
      for (var index in node.neighbours) {
        var paint1 = Paint()
          ..strokeWidth = 5
          ..color = node.color
          ..style = PaintingStyle.fill;
        if (nodes.indexWhere((element) => element.index == index) > 0)
          canvas.drawLine(
              node.offset,
              nodes[nodes.indexWhere((element) => element.index == index)]
                  .offset,
              paint1);
      }
    }

    for (var node in nodes) {
      var paint1 = Paint()
        ..strokeWidth = 5
        ..color = node.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(node.offset, node.radius, paint1);
      var textstyle = TextStyle(color: node.color, fontSize: 18);
      var textspan = TextSpan(text: node.name, style: textstyle);

      if (node.picture != null) {
        ui.Image resized = node.picture as ui.Image;

        canvas.save();

        var rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(node.offset.dx - node.radius,
                node.offset.dy - node.radius, 2 * node.radius, 2 * node.radius),
            Radius.circular(100));

        canvas.clipRRect(rect);
        canvas.drawImage(
            resized,
            Offset(node.offset.dx - node.radius, node.offset.dy - node.radius),
            paint1);
        canvas.saveLayer(
            Rect.fromLTWH(
                node.offset.dx - node.radius,
                node.offset.dy - node.radius,
                2.5 * node.radius,
                2.5 * node.radius),
            paint1);
        canvas.restore();
        canvas.restore();
      }

      var textpainter =
          TextPainter(text: textspan, textDirection: TextDirection.ltr);
      textpainter.layout();
      textpainter.paint(canvas,
          Offset(node.offset.dx - node.radius, node.offset.dy + node.radius));
      var textspan2 =
          TextSpan(text: "${node.neighbours.length} con.", style: textstyle);
      textpainter =
          TextPainter(text: textspan2, textDirection: TextDirection.ltr);
      textpainter.layout();
      textpainter.paint(
          canvas,
          Offset(node.offset.dx - node.radius + 20,
              node.offset.dy + node.radius + 20));
    }

    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

