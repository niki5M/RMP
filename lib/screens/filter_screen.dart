import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:testik2/helper/filters.dart';
import '../model/filter.dart';
import '../providers/image_provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/edit'),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
        ),
        title: const Text(
          'Фильтры',
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
          _buildFilterSelector(),
        ],
      ),
    );
  }

  Widget _buildFilterSelector() {
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
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2)
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
                color: isSelected ? Colors.blue : Colors.black,
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