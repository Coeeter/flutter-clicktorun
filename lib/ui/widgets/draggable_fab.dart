import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:flutter/material.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final GlobalKey parentKey;

  const DraggableFloatingActionButton({
    required this.parentKey,
    required this.onPressed,
  });

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  final GlobalKey _key = GlobalKey();

  bool _isDragging = false;
  Offset _offset = const Offset(double.infinity, double.infinity);
  late Offset _minOffset;
  late Offset _maxOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final RenderBox parentRenderBox =
          widget.parentKey.currentContext?.findRenderObject() as RenderBox;
      final RenderBox renderBox =
          _key.currentContext?.findRenderObject() as RenderBox;

      try {
        final Size parentSize = parentRenderBox.size;
        final Size size = renderBox.size;

        setState(() {
          _minOffset = const Offset(10, 10);
          _maxOffset = Offset(
            parentSize.width - size.width - 10,
            parentSize.height - size.height - 10,
          );
          _offset = _maxOffset;
        });
      } catch (e) {
        print('catch: $e');
      }
    });
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    }
    if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    }
    if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent);

          setState(() {
            _isDragging = true;
          });
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          if (_isDragging) {
            return setState(() {
              _isDragging = false;
            });
          }
          widget.onPressed();
        },
        child: Container(
          key: _key,
          child: Container(
            width: 60,
            height: 60,
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
            ),
            child: Material(
              type: MaterialType.circle,
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Ink(
                  child: const Icon(Icons.add),
                  decoration: const BoxDecoration(
                    gradient: ClickToRunColors.linearGradient,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
