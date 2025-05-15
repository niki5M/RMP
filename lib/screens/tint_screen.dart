import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../helper/tints.dart';
import '../model/tint.dart';
import '../providers/image_provider.dart' as app_image_provider;
import '../core/theme/theme.dart';

class TintScreen extends StatefulWidget {
  const TintScreen({super.key});

  @override
  State<TintScreen> createState() => _TintScreenState();
}

class _TintScreenState extends State<TintScreen> {
  late final app_image_provider.AppImageProvider imageProvider;
  final ScreenshotController screenshotController = ScreenshotController();

  late final List<Tint> tints;
  int selectedTintIndex = 0;

  @override
  void initState() {
    super.initState();
    imageProvider = Provider.of<app_image_provider.AppImageProvider>(context, listen: false);
    tints = Tints().list();
  }

  Future<void> _saveImage() async {
    try {
      final bytes = await screenshotController.capture();
      if (bytes != null && mounted) {
        imageProvider.changeImage(bytes);
        Navigator.of(context).pushReplacementNamed('/edit');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 24),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
        ),
        title: Text(
          'Тинт',
          style: TextStyle(
            fontSize: 24,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, size: 24, color: iconColor),
            onPressed: _saveImage,
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Consumer<app_image_provider.AppImageProvider>(
              builder: (context, value, child) {
                if (value.currentImage == null) {
                  return Center(child: CircularProgressIndicator(color: iconColor));
                }

                return Screenshot(
                  controller: screenshotController,
                  child: Image.memory(
                    value.currentImage!,
                    color: tints[selectedTintIndex].color.withOpacity(
                      tints[selectedTintIndex].opacity,
                    ),
                    colorBlendMode: BlendMode.color,
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _OpacitySlider(
              opacity: tints[selectedTintIndex].opacity,
              onChanged: (value) {
                setState(() {
                  tints[selectedTintIndex].opacity = value;
                });
              },
              backgroundColor: toolbarColor!,
              textColor: textColor,
              activeColor: iconColor,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _TintSelector(
        tints: tints,
        selectedIndex: selectedTintIndex,
        onTintSelected: (index) {
          setState(() {
            selectedTintIndex = index;
          });
        },
        backgroundColor: toolbarColor,
        textColor: textColor,
        buttonColor: buttonColor!,
      ),
    );
  }
}

class _OpacitySlider extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onChanged;
  final Color backgroundColor;
  final Color textColor;
  final Color activeColor;

  const _OpacitySlider({
    required this.opacity,
    required this.onChanged,
    required this.backgroundColor,
    required this.textColor,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Яркость",
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              Slider(
                value: opacity,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: opacity.toStringAsFixed(1),
                activeColor: activeColor,
                inactiveColor: Colors.grey,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TintSelector extends StatelessWidget {
  final List<Tint> tints;
  final int selectedIndex;
  final ValueChanged<int> onTintSelected;
  final Color backgroundColor;
  final Color textColor;
  final Color buttonColor;

  const _TintSelector({
    required this.tints,
    required this.selectedIndex,
    required this.onTintSelected,
    required this.backgroundColor,
    required this.textColor,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: backgroundColor,
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
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: tints.length,
        itemBuilder: (context, index) {
          return _TintCircleWidget(
            tint: tints[index],
            isSelected: index == selectedIndex,
            onTap: () => onTintSelected(index),
            selectedColor: buttonColor,
            textColor: textColor,
          );
        },
      ),
    );
  }
}

class _TintCircleWidget extends StatelessWidget {
  final Tint tint;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color textColor;

  const _TintCircleWidget({
    required this.tint,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: isSelected ? selectedColor : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: tint.color,
              radius: 20,
            ),
          ),
        ),
      ),
    );
  }
}
