import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../providers/image_provider.dart';
import '../core/theme/theme.dart'; // Import ThemeProvider

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    final toolbarColor = isDark ? Colors.grey[900] : Colors.white;
    final buttonColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final activeColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: iconColor, size: 24),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
        ),
        title: Text(
          'Размытие',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: iconColor, size: 24),
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
                    return CircularProgressIndicator(color: iconColor);
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
          _buildControlsPanel(
            toolbarColor: toolbarColor!,
            textColor: textColor,
            activeColor: activeColor,
            buttonColor: buttonColor!,
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel({
    required Color toolbarColor,
    required Color textColor,
    required Color activeColor,
    required Color buttonColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: toolbarColor,
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
          _buildBlurSliders(textColor: textColor, activeColor: activeColor),
          const SizedBox(height: 16),
          _buildTileModeSelector(
            textColor: textColor,
            buttonColor: buttonColor,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBlurSliders({
    required Color textColor,
    required Color activeColor,
  }) {
    return Column(
      children: [
        _buildSlider(
          'Горизонтальное размытие',
          sigmaX,
              (value) => setState(() => sigmaX = value),
          textColor: textColor,
          activeColor: activeColor,
        ),
        const SizedBox(height: 12),
        _buildSlider(
          'Вертикальное размытие',
          sigmaY,
              (value) => setState(() => sigmaY = value),
          textColor: textColor,
          activeColor: activeColor,
        ),
      ],
    );
  }

  Widget _buildSlider(
      String title,
      double value,
      ValueChanged<double> onChanged, {
        required Color textColor,
        required Color activeColor,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.white,
            overlayColor: activeColor.withOpacity(0.2),
            valueIndicatorColor: activeColor,
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

  Widget _buildTileModeSelector({
    required Color textColor,
    required Color buttonColor,
    required Color activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edge Handling',
          style: TextStyle(
            color: textColor,
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
                      color: isSelected ? Colors.white : textColor,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => tileMode = mode);
                  },
                  backgroundColor: buttonColor,
                  selectedColor: activeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? activeColor : Colors.grey[300]!,
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