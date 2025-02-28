import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' show pi, cos, sin;
import 'dart:async';  // Add this import
import 'package:firebase_database/firebase_database.dart';
import '../models/drawing_session.dart';
import '../models/game_session.dart';

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;
  final DrawingPoint? previewPoint;
  final Offset? currentPosition;
  final String selectedShape;

  _DrawingPainter(
    this.drawingPoints, {
    this.previewPoint,
    this.currentPosition,
    required this.selectedShape,
  });

  void drawShape(Canvas canvas, Offset start, Offset end, Paint paint, String shape) {
    // Remove the forced stroke style to respect the paint's existing style
    switch (shape) {
      case 'line':
        canvas.drawLine(start, end, paint);
        break;
      case 'rectangle':
        canvas.drawRect(
          Rect.fromPoints(start, end),
          paint,
        );
        break;
      case 'circle':
        final radius = (end - start).distance / 2;
        final center = start + (end - start) / 2;
        canvas.drawCircle(center, radius, paint);
        break;
      case 'triangle':
        final path = Path();
        path.moveTo(start.dx + (end.dx - start.dx) / 2, start.dy);
        path.lineTo(start.dx, end.dy);
        path.lineTo(end.dx, end.dy);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case 'arrow':
        final double arrowSize = 20;
        final double angle = (end - start).direction;
        
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(end.dx, end.dy);
        
        path.moveTo(end.dx, end.dy);
        path.lineTo(
          end.dx - arrowSize * cos(angle - pi / 6),
          end.dy - arrowSize * sin(angle - pi / 6),
        );
        path.moveTo(end.dx, end.dy);
        path.lineTo(
          end.dx - arrowSize * cos(angle + pi / 6),
          end.dy - arrowSize * sin(angle + pi / 6),
        );
        
        canvas.drawPath(path, paint);
        break;
      case 'star':
        final center = start + (end - start) / 2;
        final radius = (end - start).distance / 2;
        final path = Path();
        final double rotation = -pi / 2;
        
        for (int i = 0; i < 5; i++) {
          final double angle = (i * 4 * pi / 5) + rotation;
          final point = Offset(
            center.dx + radius * cos(angle),
            center.dy + radius * sin(angle),
          );
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
      case 'diamond':
        final center = start + (end - start) / 2;
        final path = Path()
          ..moveTo(center.dx, start.dy)
          ..lineTo(end.dx, center.dy)
          ..lineTo(center.dx, end.dy)
          ..lineTo(start.dx, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw permanent shapes
    for (int i = 0; i < drawingPoints.length; i++) {
      if (drawingPoints[i] == null) continue;
      
      final point = drawingPoints[i]!;
      if (point.shape == null) {
        // Draw freehand points
        if (i < drawingPoints.length - 1 && drawingPoints[i + 1] != null) {
          canvas.drawLine(point.offset, drawingPoints[i + 1]!.offset, point.paint);
        }
      } else if (point.endOffset != null) {
        // Draw permanent shapes
        drawShape(canvas, point.offset, point.endOffset!, point.paint, point.shape!);
      }
    }

    // Draw preview shape while dragging
    if (previewPoint != null && currentPosition != null && selectedShape != 'freehand') {
      drawShape(
        canvas,
        previewPoint!.offset,
        currentPosition!,
        previewPoint!.paint,
        selectedShape,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}



class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final String? shape;
  final Offset? endOffset; // Add this for shape end position

  DrawingPoint({
    required this.offset,
    required this.paint,
    this.shape,
    this.endOffset,
  });
}

class AdvancedDrawingCanvas extends StatefulWidget {
  final String? sessionId;
  final String userId;
  final Color initialColor;
  final double initialStrokeWidth;
  final List<Color> colors;
  final List<double> strokeWeights;
  final VoidCallback? onDrawingComplete;
  final GameSession? gameSession;  // Add this

  const AdvancedDrawingCanvas({
    Key? key,
    required this.userId,
    this.sessionId,
    this.initialColor = Colors.black,
    this.initialStrokeWidth = 5.0,
    this.colors = const [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.brown,
    ],
    this.strokeWeights = const [2, 4, 6, 8, 10, 12, 16, 20],
    this.onDrawingComplete,
    this.gameSession,
  }) : super(key: key);

  @override
  State<AdvancedDrawingCanvas> createState() => AdvancedDrawingCanvasState();
}

class AdvancedDrawingCanvasState extends State<AdvancedDrawingCanvas> 
    with SingleTickerProviderStateMixin {
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  List<DrawingPoint?> drawingPoints = [];
  List<DrawingPoint?> redoStack = [];
  String selectedShape = 'freehand';
  bool isFillMode = false;
  bool isColorMenuOpen = false;
  bool isStrokeMenuOpen = false;
  DrawingPoint? startPoint;
  Offset? currentDragPosition;

  late AnimationController _menuAnimationController;
  late Animation<double> _menuSlideAnimation;
  late DatabaseReference _sessionRef;
  bool _isInitialized = false;
  bool _hasSession = false;

  final List<Map<String, dynamic>> shapes = [
    {'name': 'Freehand', 'value': 'freehand', 'icon': Icons.edit},
    {'name': 'Line', 'value': 'line', 'icon': Icons.horizontal_rule},
    {'name': 'Rectangle', 'value': 'rectangle', 'icon': Icons.rectangle_outlined},
    {'name': 'Circle', 'value': 'circle', 'icon': Icons.circle_outlined},
    {'name': 'Triangle', 'value': 'triangle', 'icon': Icons.change_history},
    {'name': 'Star', 'value': 'star', 'icon': Icons.star_border},
    {'name': 'Diamond', 'value': 'diamond', 'icon': Icons.diamond_outlined},
  ];

  bool get isDrawingAllowed => 
      widget.gameSession == null || 
      widget.gameSession!.players
          .firstWhere((p) => p.id == widget.userId)
          .isDrawing;

  void undo() {
    if (drawingPoints.isNotEmpty) {
      setState(() {
        redoStack.add(drawingPoints.removeLast());
        while (drawingPoints.isNotEmpty && drawingPoints.last != null) {
          redoStack.add(drawingPoints.removeLast());
        }
      });
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      setState(() {
        drawingPoints.add(redoStack.removeLast());
        while (redoStack.isNotEmpty && redoStack.last != null) {
          drawingPoints.add(redoStack.removeLast());
        }
      });
    }
  }

  // Add these properties
  final List<Map<String, dynamic>> _pointsBatch = [];
  Timer? _syncTimer;
  static const syncInterval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    strokeWidth = widget.initialStrokeWidth;
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuSlideAnimation = Tween<double>(
      begin: 200,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeOut,
    ));

    if (widget.sessionId != null) {
      _sessionRef = FirebaseDatabase.instance
          .ref()
          .child('drawing_sessions')
          .child(widget.sessionId!);
      _initializeSession();
    }

    if (widget.gameSession != null) {
      _sessionRef = FirebaseDatabase.instance
          .ref()
          .child('game_sessions')
          .child(widget.gameSession!.id)
          .child('drawing_data');

      // Listen to drawing updates
      _sessionRef.onValue.listen((event) {
        if (!mounted) return;
        if (event.snapshot.value == null) return;

        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (data['points'] != null) {
          final List<DrawingPoint?> newPoints = [];
          for (var point in List<dynamic>.from(data['points'])) {
            if (point == null || point['isSeparator'] == true) {
              newPoints.add(null);
              continue;
            }
            
            newPoints.add(DrawingPoint(
              offset: Offset(
                (point['x'] as num).toDouble(),
                (point['y'] as num).toDouble(),
              ),
              paint: Paint()
                ..color = Color(point['color'] as int)
                ..strokeWidth = (point['strokeWidth'] as num).toDouble()
                ..style = point['isFilled'] == true
                    ? PaintingStyle.fill
                    : PaintingStyle.stroke,
              shape: point['shape'] as String?,
              endOffset: point['endX'] != null
                  ? Offset(
                      (point['endX'] as num).toDouble(),
                      (point['endY'] as num).toDouble(),
                    )
                  : null,
            ));
          }
          
          setState(() {
            drawingPoints = newPoints;
          });
        }
      });
    }
  }

  Future<void> _initializeSession() async {
    final snapshot = await _sessionRef.get();
    if (snapshot.exists) {
      final sessionData = DrawingSession.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map));
      setState(() {
        drawingPoints = sessionData.points
            .map((p) => p?.toDrawingPoint())
            .toList();
        _isInitialized = true;
      });
    }

    _sessionRef.child('points').onChildAdded.listen((event) {
      if (!_isInitialized) return;
      final pointData = SerializableDrawingPoint.fromJson(
        Map<String, dynamic>.from(event.snapshot.value as Map));
      setState(() {
        drawingPoints.add(pointData.toDrawingPoint());
      });
    });
  }

  void _initializeDrawingSync() {
    // Use once() instead of onValue for initial load
    _sessionRef.child('points').once().then((event) {
      if (!_isInitialized || event.snapshot.value == null) return;
      
      final List<dynamic> pointsData = event.snapshot.value as List;
      
      setState(() {
        drawingPoints.clear();
        for (final pointData in pointsData) {
          if (pointData == null || pointData['isSeparator'] == true) {
            drawingPoints.add(null);
            continue;
          }

          drawingPoints.add(DrawingPoint(
            offset: Offset(
              (pointData['x'] as num).toDouble(),
              (pointData['y'] as num).toDouble(),
            ),
            paint: Paint()
              ..color = Color(pointData['color'] as int)
              ..strokeWidth = (pointData['strokeWidth'] as num).toDouble()
              ..style = pointData['isFilled'] == true 
                  ? PaintingStyle.fill 
                  : PaintingStyle.stroke,
            shape: pointData['shape'] as String?,
            endOffset: pointData['endX'] != null && pointData['endY'] != null
                ? Offset(
                    (pointData['endX'] as num).toDouble(),
                    (pointData['endY'] as num).toDouble(),
                  )
                : null,
          ));
        }
      });
    });

    // Listen for updates with value events to get full points array
    _sessionRef.child('points').onValue.listen((event) {
      if (!_isInitialized || event.snapshot.value == null) return;
      
      final List<dynamic> pointsData = event.snapshot.value as List;
      
      setState(() {
        drawingPoints = pointsData.map((pointData) {
          if (pointData == null || pointData['isSeparator'] == true) {
            return null;
          }

          return DrawingPoint(
            offset: Offset(
              (pointData['x'] as num).toDouble(),
              (pointData['y'] as num).toDouble(),
            ),
            paint: Paint()
              ..color = Color(pointData['color'] as int)
              ..strokeWidth = (pointData['strokeWidth'] as num).toDouble()
              ..style = pointData['isFilled'] == true 
                  ? PaintingStyle.fill 
                  : PaintingStyle.stroke,
            shape: pointData['shape'] as String?,
            endOffset: pointData['endX'] != null && pointData['endY'] != null
                ? Offset(
                    (pointData['endX'] as num).toDouble(),
                    (pointData['endY'] as num).toDouble(),
                  )
                : null,
          );
        }).toList();
      });
    });
  }

  // Update _syncDrawing method
  void _syncDrawing() {
    if (!isDrawingAllowed || widget.gameSession == null) return;

    // Cancel any pending sync
    _syncTimer?.cancel();

    // Start new timer for batching
    _syncTimer = Timer(syncInterval, () {
      if (_pointsBatch.isEmpty) return;

      // Convert current drawingPoints to data format
      final List<Map<String, dynamic>> pointsData = drawingPoints.map((point) {
        if (point == null) return {'isSeparator': true};
        return {
          'x': point.offset.dx,
          'y': point.offset.dy,
          'color': point.paint.color.value,
          'strokeWidth': point.paint.strokeWidth,
          'isFilled': point.paint.style == PaintingStyle.fill,
          'shape': point.shape,
          'endX': point.endOffset?.dx,
          'endY': point.endOffset?.dy,
        };
      }).toList();

      // Update the entire points array
      _sessionRef.update({
        'points': pointsData,
        'timestamp': ServerValue.timestamp,
      });

      _pointsBatch.clear();
    });
  }

  // Update _syncPoint method
  void _syncPoint(DrawingPoint? point) {
    if (!isDrawingAllowed) return;
    
    // Just add to local points array, _syncDrawing will handle the sync
    if (point == null) {
      _pointsBatch.add({'isSeparator': true});
    } else {
      final pointData = {
        'x': point.offset.dx,
        'y': point.offset.dy,
        'color': point.paint.color.value,
        'strokeWidth': point.paint.strokeWidth,
        'isFilled': point.paint.style == PaintingStyle.fill,
        'shape': point.shape,
        'endX': point.endOffset?.dx,
        'endY': point.endOffset?.dy,
      };
      _pointsBatch.add(pointData);
    }
    
    // Trigger sync
    _syncDrawing();
  }

  void clearCanvas() {
    if (!isDrawingAllowed) return;
    setState(() {
      drawingPoints.clear();
      redoStack.clear();
    });
    _syncDrawing();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _menuAnimationController.dispose();
    super.dispose();
  }

void onPanStart(DragStartDetails details) {
    if (!isDrawingAllowed) return;
    // Add a separator (null) point when starting a new stroke
    if (selectedShape == 'freehand' || selectedShape == 'eraser') {
      drawingPoints.add(null);
    }
    
    startPoint = DrawingPoint(
      offset: details.localPosition,
      paint: Paint()
        ..color = selectedShape == 'eraser' ? Colors.white : selectedColor
        ..isAntiAlias = true
        ..strokeWidth = selectedShape == 'eraser' ? strokeWidth * 3 : strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = selectedShape == 'freehand' || selectedShape == 'eraser' 
            ? PaintingStyle.stroke 
            : (isFillMode ? PaintingStyle.fill : PaintingStyle.stroke),
    );
    setState(() {
      currentDragPosition = details.localPosition;
      if (selectedShape == 'freehand' || selectedShape == 'eraser') {
        final point = DrawingPoint(
          offset: details.localPosition,
          paint: startPoint!.paint,
        );
        drawingPoints.add(point);
        _syncPoint(point);
      }
    });
    _syncDrawing();
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (!isDrawingAllowed) return;
    setState(() {
      currentDragPosition = details.localPosition;
      if (selectedShape == 'freehand' || selectedShape == 'eraser') {
        final point = DrawingPoint(
          offset: details.localPosition,
          paint: Paint()
            ..color = selectedShape == 'eraser' ? Colors.white : selectedColor
            ..isAntiAlias = true
            ..strokeWidth = selectedShape == 'eraser' ? strokeWidth * 3 : strokeWidth
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
        drawingPoints.add(point);
        _syncPoint(point);
      }
    });
    _syncDrawing();
  }

  void onPanEnd(DragEndDetails details) {
    if (!isDrawingAllowed) return;
    if (selectedShape != 'freehand' && selectedShape != 'eraser' && 
        startPoint != null && currentDragPosition != null) {
      setState(() {
        final point = DrawingPoint(
          offset: startPoint!.offset,
          paint: startPoint!.paint,
          shape: selectedShape,
          endOffset: currentDragPosition, // Add end position for shape
        );
        drawingPoints.add(point);
        _syncPoint(point);
        drawingPoints.add(null); // Add separator
        _syncPoint(null);
      });
    }
    setState(() {
      startPoint = null;
      currentDragPosition = null;
      redoStack.clear(); // Clear redo stack when new drawing occurs
    });
    _syncDrawing();
  }


    final List<double> strokeWeights = [2, 4, 6, 8, 10, 12, 16, 20];



     Widget buildStrokeWeightButton(double weight) {
    return GestureDetector(
      onTap: () => setState(() {
        strokeWidth = weight;
        isStrokeMenuOpen = false;
        _menuAnimationController.reverse();
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        width: 160,
        height: 40,
        decoration: BoxDecoration(
          color: strokeWidth == weight ? selectedColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: strokeWidth == weight ? selectedColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 100,
            height: weight,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(weight / 2),
            ),
          ),
        ),
      ),
    );
  }


  Widget buildSpeedDial() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(  // Changed from Column to Row
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Main floating buttons
          Column(  // Changed from Row to Column
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'stroke',
                mini: true,
                child: const Icon(Icons.line_weight),
                onPressed: () {
                  setState(() => isStrokeMenuOpen = !isStrokeMenuOpen);
                  if (isStrokeMenuOpen) {
                    isColorMenuOpen = false;
                    _menuAnimationController.forward();
                  } else {
                    _menuAnimationController.reverse();
                  }
                },
                backgroundColor: isStrokeMenuOpen ? selectedColor : Colors.white,
                foregroundColor: isStrokeMenuOpen ? Colors.white : Colors.grey[800],
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'color',
                child: Icon(
                  Icons.color_lens,
                  color: isColorMenuOpen ? Colors.white : selectedColor,
                ),
                onPressed: () {
                  setState(() => isColorMenuOpen = !isColorMenuOpen);
                  if (isColorMenuOpen) {
                    isStrokeMenuOpen = false;
                    _menuAnimationController.forward();
                  } else {
                    _menuAnimationController.reverse();
                  }
                },
                backgroundColor: isColorMenuOpen ? selectedColor : Colors.white,
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Menus
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Stroke width menu
              if (isStrokeMenuOpen)
                AnimatedBuilder(
                  animation: _menuAnimationController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _menuSlideAnimation.value),  // Changed to vertical offset
                    child: child,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: strokeWeights
                          .map((weight) => buildStrokeWeightButton(weight))
                          .toList(),
                    ),
                  ),
                ),
              // Color menu
              if (isColorMenuOpen)
                AnimatedBuilder(
                  animation: _menuAnimationController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _menuSlideAnimation.value),  // Changed to vertical offset
                    child: child,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(  // Changed from Wrap to Column
                      mainAxisSize: MainAxisSize.min,
                      children: widget.colors.map((color) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedColor = color;
                            isColorMenuOpen = false;
                            _menuAnimationController.reverse();
                          }),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
        ),
        GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: CustomPaint(
            painter: _DrawingPainter(
              drawingPoints,
              previewPoint: startPoint,
              currentPosition: currentDragPosition,
              selectedShape: selectedShape,
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Only show tools if user is allowed to draw
        if (isDrawingAllowed) ...[
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Shapes selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: PopupMenuButton<String>(
                    initialValue: selectedShape,
                    onSelected: (String value) {
                      setState(() => selectedShape = value);
                    },
                    itemBuilder: (BuildContext context) => shapes.map((shape) {
                      return PopupMenuItem<String>(
                        value: shape['value'],
                        child: Row(
                          children: [
                            Icon(
                              shape['icon'],
                              color: selectedShape == shape['value'] 
                                  ? selectedColor 
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(shape['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            shapes.firstWhere((s) => s['value'] == selectedShape)['icon'],
                            color: selectedColor,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isFillMode ? Icons.format_color_fill : Icons.format_color_reset),
                      color: isFillMode ? selectedColor : Colors.grey,
                      onPressed: () => setState(() => isFillMode = !isFillMode),
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: undo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo),
                      onPressed: redo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        clearCanvas();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: buildSpeedDial(),
          ),
        ],

        // Show word display on top
        if (widget.gameSession != null)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  isDrawingAllowed
                      ? widget.gameSession!.currentWord != null
                          ? 'Draw: ${widget.gameSession!.currentWord}'
                          : 'Waiting for word...'
                      : 'Guess the word!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDrawingAllowed ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}


