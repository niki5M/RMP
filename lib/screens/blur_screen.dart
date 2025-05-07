import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../providers/image_provider.dart';

class BlurScreen extends StatefulWidget {
  const BlurScreen({super.key});

  @override
  State<BlurScreen> createState() => _BlurScreenState();
}

class _BlurScreenState extends State<BlurScreen> {
  late AppImageProvider imageProvider;
  final ScreenshotController screenshotController = ScreenshotController();

  double sigmaX = 0.1;
  double sigmaY = 0.1;
  TileMode tileMode = TileMode.decal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);
  }

  Future<void> _saveChanges() async {
    final bytes = await screenshotController.capture();
    if (bytes != null && mounted) {
      imageProvider.changeImage(bytes);
      Navigator.of(context).pushReplacementNamed('/edit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87, size: 24),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
        ),
        title: const Text(
          'Размытие',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black87, size: 24),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Consumer<AppImageProvider>(
                builder: (context, value, child) {
                  if (value.currentImage == null) {
                    return const CircularProgressIndicator(color: Colors.black87);
                  }
                  return Screenshot(
                    controller: screenshotController,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: sigmaX,
                        sigmaY: sigmaY,
                        tileMode: tileMode,
                      ),
                      child: Image.memory(
                        value.currentImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildControlsPanel(),
        ],
      ),
    );
  }

  Widget _buildControlsPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBlurSliders(),
          const SizedBox(height: 16),
          _buildTileModeSelector(),
        ],
      ),
    );
  }

  Widget _buildBlurSliders() {
    return Column(
      children: [
        _buildSlider('Горизонтальное размытие', sigmaX, (value) {
          setState(() => sigmaX = value);
        }),
        const SizedBox(height: 12),
        _buildSlider('Вертикальное размытие', sigmaY, (value) {
          setState(() => sigmaY = value);
        }),
      ],
    );
  }

  Widget _buildSlider(String title, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.black87,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.white,
            overlayColor: Colors.black87.withOpacity(0.2),
            valueIndicatorColor: Colors.black87,
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: Slider(
            value: value,
            min: 0.1,
            max: 10,
            divisions: 99,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTileModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edge Handling',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: TileMode.values.map((mode) {
              final isSelected = tileMode == mode;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    _getTileModeName(mode),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => tileMode = mode);
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.black87 : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getTileModeName(TileMode mode) {
    switch (mode) {
      case TileMode.decal:
        return 'Decal';
      case TileMode.clamp:
        return 'Clamp';
      case TileMode.mirror:
        return 'Mirror';
      case TileMode.repeated:
        return 'Repeat';
    }
  }
}