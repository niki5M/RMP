import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../helper/image_picker.dart';
import '../../../providers/image_provider.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../core/theme/theme.dart';

// Модель проекта
class Project {
  final String id;
  final String name;
  final File? imageFile;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    this.imageFile,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// Провайдер для управления проектами
class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void removeProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static route() => MaterialPageRoute(builder: (context) => const HomePage());

  Future<void> _pickImage(BuildContext context) async {
    AppImagePicker(source: ImageSource.gallery).pick(
      onPick: (File? image) {
        if (image != null) {
          Provider.of<AppImageProvider>(context, listen: false).changeImageFile(image);
          _showSaveDialog(context, image);
        }
      },
    );
  }

  Future<void> _captureImage(BuildContext context) async {
    AppImagePicker(source: ImageSource.camera).pick(
      onPick: (File? image) {
        if (image != null) {
          Provider.of<AppImageProvider>(context, listen: false).changeImageFile(image);
          _showSaveDialog(context, image);
        }
      },
    );
  }

  void _showSaveDialog(BuildContext context, File image) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDark;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        final projectNameController = TextEditingController();
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text(
            'Сохранить проект',
            style: TextStyle(color: textColor),
          ),
          content: TextField(
            controller: projectNameController,
            decoration: InputDecoration(
              labelText: 'Название проекта',
              labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
            ),
            style: TextStyle(color: textColor),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (projectNameController.text.isNotEmpty) {
                  final project = Project(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: projectNameController.text,
                    imageFile: image,
                  );
                  Provider.of<ProjectProvider>(context, listen: false).addProject(project);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/edit');
                }
              },
              child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final textColor = isDark ? Colors.white : Colors.black;

    // Background images
    final String backgroundImage = isDark ? 'assets/images/main.png' : 'assets/images/login.png';

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Верх — пользователь + переключатели
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.user.name ?? 'Пользователь',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.user.email ?? 'email@example.com',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isDark ? Icons.light_mode : Icons.dark_mode,
                                  color: isDark ? Colors.white : Colors.black,
                                  size: 28,
                                ),
                                onPressed: () => themeProvider.toggleTheme(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, color: Colors.red, size: 28),
                                onPressed: () {
                                  context.read<AuthBloc>().add(AuthLogout());
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                        (route) => false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Заголовок проектов
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Text(
                            'Мои проекты',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Список проектов
                    Expanded(
                      child: Consumer<ProjectProvider>(
                        builder: (context, projectProvider, child) {
                          if (projectProvider.projects.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_camera_outlined,
                                  size: 100,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  'У вас пока нет проектов',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Создайте новый проект, выбрав фото',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: projectProvider.projects.length,
                            itemBuilder: (context, index) {
                              final project = projectProvider.projects[index];
                              return _buildProjectCard(context, project, isDark);
                            },
                          );
                        },
                      ),
                    ),

                    // Кнопки добавления
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              context,
                              label: 'Галерея',
                              icon: Icons.photo_library_outlined,
                              onTap: () => _pickImage(context),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildButton(
                              context,
                              label: 'Камера',
                              icon: Icons.camera_alt_outlined,
                              onTap: () => _captureImage(context),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () {
        if (project.imageFile != null) {
          Provider.of<AppImageProvider>(context, listen: false)
              .changeImageFile(project.imageFile!);
          Navigator.pushNamed(context, '/edit');
        }
      },
      child: Card(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: project.imageFile != null
                  ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.file(
                  project.imageFile!,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 50,
                    color: textColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Создан: ${_formatDate(project.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Widget _buildButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onTap,
        required bool isDark,
      }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: isDark ? Colors.white10 : Colors.black,
        foregroundColor: isDark ? Colors.white : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
      ),
      icon: Icon(icon, size: 26),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      onPressed: onTap,
    );
  }
}