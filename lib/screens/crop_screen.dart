import 'dart:io';
import 'dart:typed_data' show ByteData, Uint8List;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/colors.dart';
import '../providers/image_provider.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  late AppImageProvider imageProvider;

  @override
  void initState() {
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);
    super.initState();
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
          'Обрезать',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                print('Начинаем обрезку изображения...');
                ui.Image bitmap = await controller.croppedBitmap();
                ByteData? data = await bitmap.toByteData(format: ui.ImageByteFormat.png);

                if (data == null) {
                  print('Ошибка: данные изображения null!');
                  return;
                }

                Uint8List bytes = data.buffer.asUint8List();
                imageProvider.changeImage(bytes);
                if (!mounted) return;

                Navigator.of(context).pushReplacementNamed('/edit');
                print('Экран закрыт успешно.');
              } catch (e) {
                print('Ошибка при сохранении изображения: $e');
              }
            },
            icon: const Icon(Icons.check, size: 24, color: Colors.black),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<AppImageProvider>(
                builder: (BuildContext context, AppImageProvider value, Widget? child) {
                  print('Обновленный размер изображения: ${value.currentImage?.length ?? 'Нет изображения'}');
                  if (value.currentImage != null) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CropImage(
                          controller: controller,
                          image: Image.memory(value.currentImage!),
                          gridColor: Colors.white,
                          gridInnerColor: Colors.white,
                          gridCornerColor: Colors.white,
                          gridCornerSize: 50,
                          showCorners: true,
                          gridThinWidth: 3,
                          gridThickWidth: 6,
                          scrimColor: Colors.grey.withOpacity(0.5),
                          alwaysShowThirdLines: true,
                          onCrop: (rect) => print(rect),
                          minimumImageSize: 50,
                          maximumImageSize: 2000,
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
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
            const SizedBox(width: 8),
            _buildToolButton(
              icon: Icons.rotate_left,
              label: 'Повернуть',
              onPressed: () => controller.rotateLeft(),
            ),
            _buildToolButton(
              icon: Icons.rotate_right,
              label: 'Повернуть',
              onPressed: () => controller.rotateRight(),
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '1:1',
              onPressed: () {
                controller.aspectRatio = 1;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '2:1',
              onPressed: () {
                controller.aspectRatio = 2;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '1:2',
              onPressed: () {
                controller.aspectRatio = 1/2;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '4:3',
              onPressed: () {
                controller.aspectRatio = 4/3;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '16:9',
              onPressed: () {
                controller.aspectRatio = 16/9;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
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