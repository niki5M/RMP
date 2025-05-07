import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testik2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:testik2/features/auth/presentation/bloc/auth_event.dart';
import 'package:testik2/features/auth/presentation/bloc/auth_state.dart';
import 'package:testik2/features/auth/presentation/pages/login_page.dart';

import '../../helper/image_picker.dart';
import '../../providers/image_provider.dart';
import '../core/theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static route() => MaterialPageRoute(builder: (context) => const HomePage());

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppImageProvider imageProvider;

  @override
  void initState() {
    super.initState();
    imageProvider = Provider.of<AppImageProvider>(context, listen: false);
  }

  Future<void> _pickImage() async {
    AppImagePicker(source: ImageSource.gallery).pick(
      onPick: (File? image) {
        if (image != null) {
          imageProvider.changeImageFile(image);
          Navigator.pushNamed(context, '/edit');
        }
      },
    );
  }

  Future<void> _captureImage() async {
    AppImagePicker(source: ImageSource.camera).pick(
      onPick: (File? image) {
        if (image != null) {
          imageProvider.changeImageFile(image);
          Navigator.pushNamed(context, '/edit');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xff0D1313),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return Stack(
              children: [
                // Background image
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/first.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Logout button at top right
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black, size: 40),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogout());
                      Navigator.pushAndRemoveUntil(
                        context,
                        LoginPage.route(),
                            (route) => false,
                      );
                    },
                  ),
                ),

                // Action buttons at bottom
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildActionButtons(),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildImageActionButton('Редактировать', _pickImage),
          _buildImageActionButton('Камера', _captureImage),
        ],
      ),
    );
  }

  Widget _buildImageActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 175,
      child: ElevatedButton(

        style: ElevatedButton.styleFrom(
          fixedSize: const Size(175, 45),
          side: const BorderSide(color: Palete.blackColor, width: 1),
          backgroundColor: Color(0xffF2F2F2),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
