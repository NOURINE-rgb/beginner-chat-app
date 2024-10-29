import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget {
  const UserImage({super.key, required this.onPeak});
  final void Function(File pickedImage) onPeak;
  @override
  State<UserImage> createState() {
    return _UserImageState();
  }
}

File? pickedImage;

class _UserImageState extends State<UserImage> {
  void pickImage() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 50, maxHeight: 150);
    if (image == null) {
      return;
    }
    widget.onPeak(
      File(image.path),
    );
    setState(() {
      pickedImage = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: pickedImage == null ? null : FileImage(pickedImage!),
        ),
        TextButton.icon(
          onPressed: pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            "Take an image",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
