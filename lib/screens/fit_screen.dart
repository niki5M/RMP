import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/image_provider.dart';
import '../core/theme/theme.dart'; // Import ThemeProvider

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
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDark;

        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text(
            "Выберите цвет фона",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
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
              paletteType: PaletteType.hsvWithHue,
              displayThumbColor: true,
              labelTypes: const [],
              pickerAreaBorderRadius: BorderRadius.circular(12),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Готово',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final backgroundColorTheme = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    final toolbarColor = isDark ? Colors.grey[900]! : Colors.white;
    final buttonColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColorTheme,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
          icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 24),
        ),
        title: Text(
          'Фон',
          style: TextStyle(
            fontSize: 24,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _saveImage(imageProvider),
            icon: Icon(Icons.check, size: 24, color: iconColor),
          ),
        ],
      ),
      backgroundColor: backgroundColorTheme,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<AppImageProvider>(
                builder: (context, value, child) {
                  if (value.currentImage == null) return Center(
                    child: CircularProgressIndicator(color: iconColor),
                  );

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
          _buildBottomToolbar(
            toolbarColor: toolbarColor!,
            buttonColor: buttonColor,
            iconColor: iconColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar({
    required Color toolbarColor,
    required Color buttonColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      height: showBlur ? 250 : 150,
      decoration: BoxDecoration(
        color: toolbarColor,
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
              if (showBlur) _blurSlider(iconColor: iconColor, textColor: textColor),
              SizedBox(
                height: 50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showRatio) ...[
                        _ratioButton('1:1', () => setState(() { x = 1; y = 1; }),
                            buttonColor, textColor),
                        _ratioButton('1:2', () => setState(() { x = 1; y = 2; }),
                            buttonColor, textColor),
                        _ratioButton('2:1', () => setState(() { x = 2; y = 1; }),
                            buttonColor, textColor),
                        _ratioButton('3:4', () => setState(() { x = 3; y = 4; }),
                            buttonColor, textColor),
                        _ratioButton('4:3', () => setState(() { x = 4; y = 3; }),
                            buttonColor, textColor),
                        _ratioButton('16:9', () => setState(() { x = 16; y = 9; }),
                            buttonColor, textColor),
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
                      label: 'Отношение',
                      onPressed: () => showActiveWidget(r: true),
                      buttonColor: buttonColor,
                      iconColor: iconColor,
                      textColor: textColor,
                    ),
                    _buildToolButton(
                      icon: Icons.blur_on,
                      label: 'Размытие',
                      onPressed: () => showActiveWidget(b: true),
                      buttonColor: buttonColor,
                      iconColor: iconColor,
                      textColor: textColor,
                    ),
                    _buildToolButton(
                      icon: Icons.color_lens,
                      label: 'Цвет',
                      onPressed: () {
                        _pickBackgroundColor();
                        showActiveWidget(c: true);
                      },
                      buttonColor: buttonColor,
                      iconColor: iconColor,
                      textColor: textColor,
                    ),
                    _buildToolButton(
                      icon: Icons.texture,
                      label: 'Текстура',
                      onPressed: () => showActiveWidget(t: true),
                      buttonColor: buttonColor,
                      iconColor: iconColor,
                      textColor: textColor,
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

  Widget _blurSlider({required Color iconColor, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            "Уровень размытия",
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          Slider(
            value: blurValue,
            min: 0.0,
            max: 20.0,
            divisions: 20,
            label: blurValue.toStringAsFixed(1),
            activeColor: iconColor,
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

  Widget _ratioButton(String text, VoidCallback onPress, Color buttonColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPress,
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color buttonColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
          ),
        ),
      ],
    );
  }
}