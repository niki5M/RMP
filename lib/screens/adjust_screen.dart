import 'dart:typed_data';

import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../providers/image_provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
        ),
        title: const Text(
          'Коррекция',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
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
                  if (value.currentImage == null) {
                    return const Center(child: CircularProgressIndicator());
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
          _buildAdjustmentControls(),
          _buildAdjustmentTools(),
        ],
      ),
    );
  }

  Widget _buildAdjustmentControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (showBrightness)
            _buildAdjustmentSlider(
              value: brightness,
              label: 'Brightness',
              onChanged: (value) {
                setState(() {
                  brightness = value;
                  adjust(b: brightness);
                });
              },
            ),
          if (showContrast)
            _buildAdjustmentSlider(
              value: contrast,
              label: 'Contrast',
              onChanged: (value) {
                setState(() {
                  contrast = value;
                  adjust(c: contrast);
                });
              },
            ),
          if (showSaturation)
            _buildAdjustmentSlider(
              value: saturation,
              label: 'Saturation',
              onChanged: (value) {
                setState(() {
                  saturation = value;
                  adjust(s: saturation);
                });
              },
            ),
          if (showHue)
            _buildAdjustmentSlider(
              value: hue,
              label: 'Hue',
              onChanged: (value) {
                setState(() {
                  hue = value;
                  adjust(h: hue);
                });
              },
            ),
          if (showSepia)
            _buildAdjustmentSlider(
              value: sepia,
              label: 'Sepia',
              onChanged: (value) {
                setState(() {
                  sepia = value;
                  adjust(se: sepia);
                });
              },
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
            child: const Text(
              'Сбросить',
              style: TextStyle(color: Colors.grey),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Slider(
          value: value,
          min: -0.9,
          max: 1,
          divisions: 19,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
          activeColor: Colors.black87,
          inactiveColor: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildAdjustmentTools() {
    return Container(
      height: 150,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            _buildAdjustmentButton(
              icon: Icons.brightness_6,
              label: 'Brightness',
              onPressed: () => showSlider(b: true),
            ),
            _buildAdjustmentButton(
              icon: Icons.contrast,
              label: 'Contrast',
              onPressed: () => showSlider(c: true),
            ),
            _buildAdjustmentButton(
              icon: Icons.color_lens,
              label: 'Saturation',
              onPressed: () => showSlider(s: true),
            ),
            _buildAdjustmentButton(
              icon: Icons.palette,
              label: 'Hue',
              onPressed: () => showSlider(h: true),
            ),
            _buildAdjustmentButton(
              icon: Icons.invert_colors,
              label: 'Sepia',
              onPressed: () => showSlider(se: true),
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
      ),
    );
  }
}