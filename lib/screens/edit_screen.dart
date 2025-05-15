import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testik2/providers/image_provider.dart';
import 'package:testik2/core/theme/theme.dart'; // Make sure to import ThemeProvider

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
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
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 24),
        ),
        title: Text(
          'Редактор',
          style: TextStyle(
            fontSize: 24,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
            },
            icon: Icon(Icons.more_vert, size: 24, color: iconColor),
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
                builder: (BuildContext context, AppImageProvider value, Widget? child) {
                  if (value.currentImage != null) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            value.currentImage!,
                            fit: BoxFit.contain,
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
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar({
    required Color backgroundColor,
    required Color buttonColor,
    required Color iconColor,
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
            const SizedBox(width: 16),
            _buildToolButton(
              icon: Icons.crop,
              label: 'Обрезать',
              onPressed: () => Navigator.pushNamed(context, '/crop'),
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            _buildToolButton(
              icon: Icons.filter_b_and_w,
              label: 'Фильтр',
              onPressed: () => Navigator.pushNamed(context, '/filter'),
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            _buildToolButton(
              icon: Icons.tune,
              label: 'Обработка',
              onPressed: () => Navigator.pushNamed(context, '/adjust'),
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            _buildToolButton(
              icon: Icons.fit_screen,
              label: 'Фон',
              onPressed: () => Navigator.pushNamed(context, '/fit'),
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            _buildToolButton(
              icon: Icons.color_lens,
              label: 'Тинт',
              onPressed: () => Navigator.pushNamed(context, '/tint'),
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            _buildToolButton(
              icon: Icons.blur_on,
              label: 'Размытие',
              onPressed: () => Navigator.pushNamed(context, '/blur'),
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            _buildToolButton(
              icon: Icons.text_fields,
              label: 'Текст',
              onPressed: () => Navigator.pushNamed(context, '/text'),
              buttonColor: buttonColor,
              iconColor: iconColor,
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
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}