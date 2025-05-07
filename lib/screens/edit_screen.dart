import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testik2/providers/image_provider.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
        ),
        title: const Text(
          'Редактор',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Действие для меню
            },
            icon: const Icon(Icons.more_vert, size: 24, color: Colors.black),
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
                builder: (BuildContext context, AppImageProvider value, Widget? child) {
                  if (value.currentImage != null) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          value.currentImage!,
                          fit: BoxFit.contain,
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
            const SizedBox(width: 16),
            _buildToolButton(
              icon: Icons.crop,
              label: 'Обрезать',
              onPressed: () => Navigator.pushNamed(context, '/crop'),
            ),
            _buildToolButton(
              icon: Icons.filter_b_and_w,
              label: 'Фильтр',
              onPressed: () => Navigator.pushNamed(context, '/filter'),
            ),
            _buildToolButton(
              icon: Icons.tune,
              label: 'Обработка',
              onPressed: () => Navigator.pushNamed(context, '/adjust'),
            ),
            _buildToolButton(
              icon: Icons.fit_screen,
              label: 'Fit',
              onPressed: () => Navigator.pushNamed(context, '/fit'),
            ),
            _buildToolButton(
              icon: Icons.color_lens,
              label: 'Tint',
              onPressed: () => Navigator.pushNamed(context, '/tint'),
            ),
            _buildToolButton(
              icon: Icons.blur_on,
              label: 'Blur',
              onPressed: () => Navigator.pushNamed(context, '/blur'),
            ),
            _buildToolButton(
              icon: Icons.text_fields,
              label: 'Text',
              onPressed: () => Navigator.pushNamed(context, '/text'),
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