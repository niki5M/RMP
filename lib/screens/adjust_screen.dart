import 'dart:typed_data';

import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../providers/image_provider.dart';
import '../core/theme/theme.dart'; // Import ThemeProvider

class AdjustScreen extends StatefulWidget {
  const AdjustScreen({super.key});

  @override
  State<AdjustScreen> createState() => _AdjustScreenState();
}

class _AdjustScreenState extends State<AdjustScreen> {
  double brightness = 0;
  double contrast = 0;
  double saturation = 0;
  double sepia = 0;
  double hue = 0;

  bool showBrightness = true;
  bool showContrast = false;
  bool showSaturation = false;
  bool showHue = false;
  bool showSepia = false;

  late ColorFilterGenerator adj;
  late AppImageProvider imageProvider;
  ScreenshotController screenshotController = ScreenshotController();

  void showSlider({bool? b, bool? c, bool? s, bool? h, bool? se}) {
    setState(() {
      showBrightness = b ?? false;
      showContrast = c ?? false;
      showSaturation = s ?? false;
      showHue = h ?? false;
      showSepia = se ?? false;
    });
  }

  @override
  void initState() {
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);
    adjust();
    super.initState();
  }

  void adjust({double? b, double? c, double? s, double? h, double? se}) {
    adj = ColorFilterGenerator(
      name: 'Adjust',
      filters: [
        ColorFilterAddons.brightness(b ?? brightness),
        ColorFilterAddons.contrast(c ?? contrast),
        ColorFilterAddons.saturation(s ?? saturation),
        ColorFilterAddons.hue(h ?? hue),
        ColorFilterAddons.sepia(se ?? sepia),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    final toolbarColor = isDark ? Colors.grey[900]! : Colors.white;
    final buttonColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final sliderActiveColor = isDark ? Colors.white : Colors.black;
    final sliderInactiveColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final resetTextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
          icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 24),
        ),
        title: Text(
          'Коррекция',
          style: TextStyle(
            fontSize: 24,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final bytes = await screenshotController.capture();
              if (bytes != null) {
                imageProvider.changeImage(bytes);
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/edit');
                }
              }
            },
            icon: Icon(Icons.check, size: 24, color: iconColor),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<AppImageProvider>(
                builder: (context, value, child) {
                  if (value.currentImage == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: iconColor,
                      ),
                    );
                  }
                  return Screenshot(
                    controller: screenshotController,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(adj.matrix),
                          child: Image.memory(
                            value.currentImage!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildAdjustmentControls(
            textColor: textColor,
            sliderActiveColor: sliderActiveColor,
            sliderInactiveColor: sliderInactiveColor,
            resetTextColor: resetTextColor,
          ),
          _buildAdjustmentTools(
            toolbarColor: toolbarColor,
            buttonColor: buttonColor,
            iconColor: iconColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentControls({
    required Color textColor,
    required Color sliderActiveColor,
    required Color sliderInactiveColor,
    required Color resetTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (showBrightness)
            _buildAdjustmentSlider(
              value: brightness,
              label: 'Яркость',
              onChanged: (value) {
                setState(() {
                  brightness = value;
                  adjust(b: brightness);
                });
              },
              textColor: textColor,
              sliderActiveColor: sliderActiveColor,
              sliderInactiveColor: sliderInactiveColor,
            ),
          if (showContrast)
            _buildAdjustmentSlider(
              value: contrast,
              label: 'Контраст',
              onChanged: (value) {
                setState(() {
                  contrast = value;
                  adjust(c: contrast);
                });
              },
              textColor: textColor,
              sliderActiveColor: sliderActiveColor,
              sliderInactiveColor: sliderInactiveColor,
            ),
          if (showSaturation)
            _buildAdjustmentSlider(
              value: saturation,
              label: 'Насыщенность',
              onChanged: (value) {
                setState(() {
                  saturation = value;
                  adjust(s: saturation);
                });
              },
              textColor: textColor,
              sliderActiveColor: sliderActiveColor,
              sliderInactiveColor: sliderInactiveColor,
            ),
          if (showHue)
            _buildAdjustmentSlider(
              value: hue,
              label: 'Оттенок',
              onChanged: (value) {
                setState(() {
                  hue = value;
                  adjust(h: hue);
                });
              },
              textColor: textColor,
              sliderActiveColor: sliderActiveColor,
              sliderInactiveColor: sliderInactiveColor,
            ),
          if (showSepia)
            _buildAdjustmentSlider(
              value: sepia,
              label: 'Сепия',
              onChanged: (value) {
                setState(() {
                  sepia = value;
                  adjust(se: sepia);
                });
              },
              textColor: textColor,
              sliderActiveColor: sliderActiveColor,
              sliderInactiveColor: sliderInactiveColor,
            ),
          TextButton(
            onPressed: () {
              setState(() {
                brightness = 0;
                contrast = 0;
                saturation = 0;
                hue = 0;
                sepia = 0;
                adjust(
                  b: brightness,
                  c: contrast,
                  s: saturation,
                  h: hue,
                  se: sepia,
                );
              });
            },
            child: Text(
              'Сбросить',
              style: TextStyle(color: resetTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentSlider({
    required double value,
    required String label,
    required ValueChanged<double> onChanged,
    required Color textColor,
    required Color sliderActiveColor,
    required Color sliderInactiveColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
        ),
        Slider(
          value: value,
          min: -0.9,
          max: 1,
          divisions: 19,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
          activeColor: sliderActiveColor,
          inactiveColor: sliderInactiveColor,
        ),
      ],
    );
  }

  Widget _buildAdjustmentTools({
    required Color toolbarColor,
    required Color buttonColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      height: 150,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            _buildAdjustmentButton(
              icon: Icons.brightness_6,
              label: 'Яркость',
              onPressed: () => showSlider(b: true),
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildAdjustmentButton(
              icon: Icons.contrast,
              label: 'Контраст',
              onPressed: () => showSlider(c: true),
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildAdjustmentButton(
              icon: Icons.color_lens,
              label: 'Насыщенность',
              onPressed: () => showSlider(s: true),
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildAdjustmentButton(
              icon: Icons.palette,
              label: 'Оттенок',
              onPressed: () => showSlider(h: true),
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildAdjustmentButton(
              icon: Icons.invert_colors,
              label: 'Сепия',
              onPressed: () => showSlider(se: true),
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color buttonColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
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
      ),
    );
  }
}