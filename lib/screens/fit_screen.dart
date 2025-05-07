  import 'dart:typed_data';
  import 'dart:ui';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:screenshot/screenshot.dart';
  import 'package:flutter_colorpicker/flutter_colorpicker.dart';
  import '../providers/image_provider.dart';

  class FitScreen extends StatefulWidget {
    const FitScreen({super.key});

    @override
    State<FitScreen> createState() => _FitScreenState();
  }

  class _FitScreenState extends State<FitScreen> {
    final ScreenshotController screenshotController = ScreenshotController();
    int x = 1, y = 1;

    bool showRatio = true;
    bool showBlur = false;
    bool showColor = false;
    bool showTexture = false;

    double blurValue = 0.0;
    Color backgroundColor = Colors.black;
    Uint8List? backgroundImage;
    String? texturePath;

    void _pickBackgroundColor() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Выберите цвет фона", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: backgroundColor,
                onColorChanged: (color) {
                  setState(() {
                    backgroundColor = color;
                  });
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Готово', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }

    void showActiveWidget({bool r = false, bool b = false, bool c = false, bool t = false}) {
      setState(() {
        showRatio = r;
        showBlur = b;
        showColor = c;
        showTexture = t;
      });
    }

    Future<void> _saveImage(AppImageProvider provider) async {
      Uint8List? bytes = await screenshotController.capture();
      if (bytes != null) {
        provider.changeImage(bytes);
        if (mounted) Navigator.of(context).pushReplacementNamed('/edit');
      }
    }

    @override
    Widget build(BuildContext context) {
      final imageProvider = Provider.of<AppImageProvider>(context, listen: false);

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
          ),
          title: const Text(
            'Fit',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _saveImage(imageProvider),
              icon: const Icon(Icons.check, size: 24, color: Colors.black),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<AppImageProvider>(
                  builder: (context, value, child) {
                    if (value.currentImage == null) return const Center(child: CircularProgressIndicator());

                    return AspectRatio(
                      aspectRatio: x / y,
                      child: Screenshot(
                        controller: screenshotController,
                        child: Stack(
                          children: [
                            Container(color: backgroundColor),
                            if (backgroundImage != null)
                              Positioned.fill(
                                child: Image.memory(backgroundImage!, fit: BoxFit.cover),
                              ),
                            if (showBlur) _blurWidget(),
                            Center(child: Image.memory(value.currentImage!)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildBottomToolbar(),
          ],
        ),
      );
    }

    Widget _buildBottomToolbar() {
      return Container(
        height: showBlur ? 250 : 150,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBlur) _blurSlider(),
                SizedBox(
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showRatio) ...[
                          _ratioButton('1:1', () => setState(() { x = 1; y = 1; })),
                          _ratioButton('1:2', () => setState(() { x = 1; y = 2; })),
                          _ratioButton('2:1', () => setState(() { x = 2; y = 1; })),
                          _ratioButton('3:4', () => setState(() { x = 3; y = 4; })),
                          _ratioButton('4:3', () => setState(() { x = 4; y = 3; })),
                          _ratioButton('16:9', () => setState(() { x = 16; y = 9; })),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildToolButton(
                        icon: Icons.aspect_ratio,
                        label: 'Ratio',
                        onPressed: () => showActiveWidget(r: true),
                      ),
                      _buildToolButton(
                        icon: Icons.blur_on,
                        label: 'Blur',
                        onPressed: () => showActiveWidget(b: true),
                      ),
                      _buildToolButton(
                        icon: Icons.color_lens,
                        label: 'Color',
                        onPressed: () {
                          _pickBackgroundColor();
                          showActiveWidget(c: true);
                        },
                      ),
                      _buildToolButton(
                        icon: Icons.texture,
                        label: 'Texture',
                        onPressed: () => showActiveWidget(t: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    }

    Widget _blurWidget() {
      return Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      );
    }

    Widget _blurSlider() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Text(
              "Уровень размытия",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Slider(
              value: blurValue,
              min: 0.0,
              max: 20.0,
              divisions: 20,
              label: blurValue.toStringAsFixed(1),
              activeColor: Colors.black,
              inactiveColor: Colors.grey,
              onChanged: (value) {
                setState(() {
                  blurValue = value;
                });
              },
            ),
          ],
        ),
      );
    }

    Widget _ratioButton(String text, VoidCallback onPress) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPress,
          child: Text(text, style: const TextStyle(color: Colors.black)),
        ),
      );
    }

    Widget _buildToolButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(icon, color: Colors.black),
              onPressed: onPressed,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      );
    }
  }