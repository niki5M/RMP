import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../helper/tints.dart';
import '../model/tint.dart';
import '../providers/image_provider.dart' as app_image_provider;

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
          const SnackBar(content: Text('Failed to save image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
        ),
        title: const Text(
          'Тинт',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 24, color: Colors.black),
            onPressed: _saveImage,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Consumer<app_image_provider.AppImageProvider>(
              builder: (context, value, child) {
                if (value.currentImage == null) {
                  return const Center(child: CircularProgressIndicator());
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
      ),
    );
  }
}

class _OpacitySlider extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onChanged;

  const _OpacitySlider({
    required this.opacity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
              const Text(
                "Opacity",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              Slider(
                value: opacity,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: opacity.toStringAsFixed(1),
                activeColor: Colors.black,
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

  const _TintSelector({
    required this.tints,
    required this.selectedIndex,
    required this.onTintSelected,
  });

  @override
  Widget build(BuildContext context) {
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
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: tints.length,
        itemBuilder: (context, index) {
          return _TintCircle(
            tint: tints[index],
            isSelected: index == selectedIndex,
            onTap: () => onTintSelected(index),
          );
        },
      ),
    );
  }
}

class _TintCircle extends StatelessWidget {
  final Tint tint;
  final bool isSelected;
  final VoidCallback onTap;

  const _TintCircle({
    required this.tint,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: isSelected ? Colors.black87 : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: tint.color,
            ),
          ),
        ),
      ),
    );
  }
}