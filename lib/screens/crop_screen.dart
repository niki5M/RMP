import 'dart:io';
import 'dart:typed_data' show ByteData, Uint8List;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/colors.dart';
import '../providers/image_provider.dart';
import '../core/theme/theme.dart'; // Import ThemeProvider

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    final toolbarColor = isDark ? Colors.grey[900] : Colors.white;
    final buttonColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final gridColor = isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
          icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 24),
        ),
        title: Text(
          'Обрезать',
          style: TextStyle(
            fontSize: 24,
            color: textColor,
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
            icon: Icon(Icons.check, size: 24, color: iconColor),
          )
        ],
      ),
      backgroundColor: backgroundColor,
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
                        borderRadius: BorderRadius.circular(12),),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CropImage(
                            controller: controller,
                            image: Image.memory(value.currentImage!),
                            gridColor: gridColor,
                            gridInnerColor: gridColor,
                            gridCornerColor: gridColor,
                            gridCornerSize: 50,
                            showCorners: true,
                            gridThinWidth: 3,
                            gridThickWidth: 6,
                            scrimColor: isDark
                                ? Colors.black.withOpacity(0.7)
                                : Colors.white.withOpacity(0.7),
                            alwaysShowThirdLines: true,
                            onCrop: (rect) => print(rect),
                            minimumImageSize: 50,
                            maximumImageSize: 2000,
                          ),
                        ),
                      );
                      }
                      return Center(
                      child: CircularProgressIndicator(
                      color: iconColor,
                    ),
                  );
                },
              ),
            ),
          ),
          _buildBottomToolbar(
            backgroundColor: toolbarColor!,
            buttonColor: buttonColor!,
            iconColor: iconColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar({
    required Color backgroundColor,
    required Color buttonColor,
    required Color iconColor,
    required Color textColor,
  }) {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 8),
            _buildToolButton(
              icon: Icons.rotate_left,
              label: 'Повернуть',
              onPressed: () => controller.rotateLeft(),
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildToolButton(
              icon: Icons.rotate_right,
              label: 'Повернуть',
              onPressed: () => controller.rotateRight(),
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '1:1',
              onPressed: () {
                controller.aspectRatio = 1;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '2:1',
              onPressed: () {
                controller.aspectRatio = 2;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '1:2',
              onPressed: () {
                controller.aspectRatio = 1/2;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '4:3',
              onPressed: () {
                controller.aspectRatio = 4/3;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
              buttonColor: buttonColor,
              iconColor: iconColor,
              textColor: textColor,
            ),
            _buildToolButton(
              icon: Icons.aspect_ratio,
              label: '16:9',
              onPressed: () {
                controller.aspectRatio = 16/9;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
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

  Widget _buildToolButton({
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