import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class CameraService {
  CameraController? controller;
  List<CameraDescription> cameras = [];

  Future<void> initialize() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('Permissão da câmera negada');
    }

    cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('Nenhuma câmera encontrada');
    }

    controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller!.initialize();
  }

  Future<String> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      throw Exception('Câmera não inicializada');
    }

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${appDir.path}/Photos';
    await Directory(dirPath).create(recursive: true);
    final String filePath = path.join(
      dirPath,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    try {
      XFile photo = await controller!.takePicture();
      await photo.saveTo(filePath);
      return filePath;
    } catch (e) {
      throw Exception('Erro ao tirar foto: $e');
    }
  }

  Future<String?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    return image?.path;
  }

  void dispose() {
    controller?.dispose();
  }
}
