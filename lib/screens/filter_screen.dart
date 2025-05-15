import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:testik2/helper/filters.dart';
import '../model/filter.dart';
import '../providers/image_provider.dart';
import '../core/theme/theme.dart'; // Import ThemeProvider

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late Filter currentFilter;
  late List<Filter> filters;
  late AppImageProvider imageProvider;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    filters = Filters().list();
    currentFilter = filters[0];
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
    final filterItemColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final selectedBorderColor = isDark ? Colors.lightBlue : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
          icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 24),
        ),
        title: Text(
          'Фильтры',
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
                      borderRadius: BorderRadius.circular(12),),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(currentFilter.matrix),
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
          _buildFilterSelector(
            backgroundColor: toolbarColor!,
            filterItemColor: filterItemColor!,
            textColor: textColor,
            selectedBorderColor: selectedBorderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSelector({
    required Color backgroundColor,
    required Color filterItemColor,
    required Color textColor,
    required Color selectedBorderColor,
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
      child: SafeArea(
        child: Consumer<AppImageProvider>(
          builder: (context, value, child) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final filter = filters[index];
                return _buildFilterItem(
                  filter: filter,
                  isSelected: filter == currentFilter,
                  image: value.currentImage,
                  onTap: () => setState(() => currentFilter = filter),
                  filterItemColor: filterItemColor,
                  textColor: textColor,
                  selectedBorderColor: selectedBorderColor,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterItem({
    required Filter filter,
    required bool isSelected,
    required Uint8List? image,
    required VoidCallback onTap,
    required Color filterItemColor,
    required Color textColor,
    required Color selectedBorderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: filterItemColor,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: selectedBorderColor, width: 2)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(filter.matrix),
                  child: image != null
                      ? Image.memory(image, fit: BoxFit.cover)
                      : const SizedBox(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter.filterName,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? selectedBorderColor : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}