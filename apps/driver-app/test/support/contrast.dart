import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast ratio of [a] against [b] (1 to 21).
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [top] painted over the opaque [bottom].
Color over(Color top, Color bottom) => Color.alphaBlend(top, bottom);

/// The colours an element is drawn on, nearest first, as the widgets that
/// paint them say (Material, decorations, coloured boxes). Each entry is one
/// or more colours (a gradient gives all its stops).
List<List<Color>> _backgrounds(Element element) {
  final layers = <List<Color>>[];
  void add(List<Color> colors) {
    final seen = colors.where((c) => c.a > 0).toList();
    if (seen.isNotEmpty) layers.add(seen);
  }

  element.visitAncestorElements((e) {
    final w = e.widget;
    switch (w) {
      case ColoredBox(:final color):
        add([color]);
      case DecoratedBox(:final decoration, :final position)
          when position == DecorationPosition.background:
        add(_colorsOf(decoration));
      case Ink(:final decoration):
        add(_colorsOf(decoration));
      case Material(:final type) when type != MaterialType.transparency:
        final theme = Theme.of(e);
        add([
          w.color ??
              (type == MaterialType.card ? theme.cardColor : theme.canvasColor),
        ]);
    }
    return true;
  });
  return layers;
}

/// The colours a decoration fills with (all stops of a gradient).
List<Color> _colorsOf(Decoration? d) => switch (d) {
  BoxDecoration(:final gradient?) => gradient.colors,
  BoxDecoration(:final color?) => [color],
  ShapeDecoration(:final gradient?) => gradient.colors,
  ShapeDecoration(:final color?) => [color],
  _ => const [],
};

/// The opaque colours behind [element]: its translucent layers composited
/// down to the first opaque one (white if none is found).
List<Color> backgroundsBehind(Element element) {
  final layers = _backgrounds(element);
  var result = <Color>[Colors.white];
  for (final layer in layers.reversed) {
    result = [
      for (final top in layer)
        for (final bottom in result) over(top, bottom),
    ];
  }
  return result;
}

String _hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

/// Every visible text and icon (icons are text in an icon font) with less
/// than [min] contrast against what's behind it, as readable lines. Faded
/// colours (alpha ≤ 0.45, Material's disabled and hint look) are skipped.
List<String> lowContrast(WidgetTester tester, {double min = 3}) {
  final problems = <String>{};
  for (final element in find.byType(RichText).evaluate()) {
    final render = element.renderObject;
    if (render is! RenderParagraph || !render.attached || !render.hasSize) {
      continue;
    }
    if (render.size.isEmpty) continue;
    var hidden = false;
    element.visitAncestorElements((e) {
      final w = e.widget;
      if ((w is Opacity && w.opacity < 0.5) ||
          (w is Offstage && w.offstage) ||
          (w is Visibility && !w.visible)) {
        hidden = true;
        return false;
      }
      return true;
    });
    if (hidden) continue;
    final behind = backgroundsBehind(element);
    void check(InlineSpan span, Color? inherited) {
      if (span is! TextSpan) return;
      final color = span.style?.color ?? inherited;
      final text = span.text ?? '';
      if (color != null && text.trim().isNotEmpty && color.a > 0.45) {
        for (final bg in behind) {
          final ratio = contrast(over(color, bg), bg);
          if (ratio < min) {
            final label = text.runes.length == 1 && text.runes.first > 0xE000
                ? 'icon U+${text.runes.first.toRadixString(16)}'
                : '"${text.length > 40 ? '${text.substring(0, 40)}…' : text}"';
            problems.add(
              '$label ${_hex(color)} on ${_hex(bg)}: '
              '${ratio.toStringAsFixed(2)}',
            );
          }
        }
      }
      for (final child in span.children ?? const <InlineSpan>[]) {
        check(child, color);
      }
    }

    check(render.text, null);
  }
  return problems.toList();
}

/// Large near-white surfaces (cards, boxes, sheets) left in a dark screen:
/// light-theme colours the dark theme didn't reach.
List<String> brightSurfaces(WidgetTester tester, {double minArea = 1500}) {
  final problems = <String>{};
  void check(Element e, List<Color> colors) {
    final render = e.renderObject;
    if (render is! RenderBox || !render.hasSize) return;
    final size = render.size;
    if (size.width * size.height < minArea) return;
    for (final c in colors) {
      if (c.a > 0.5 && c.computeLuminance() > 0.6) {
        problems.add(
          '${e.widget.runtimeType} ${_hex(c)} '
          '${size.width.round()}×${size.height.round()}',
        );
      }
    }
  }

  for (final e in find.byWidgetPredicate((_) => true).evaluate()) {
    switch (e.widget) {
      case ColoredBox(:final color):
        check(e, [color]);
      case DecoratedBox(:final decoration):
        check(e, _colorsOf(decoration));
      case Material(:final color?, :final type)
          when type != MaterialType.transparency:
        check(e, [color]);
    }
  }
  return problems.toList();
}
