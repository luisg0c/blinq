import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Mostrar opções para escolher foto (galeria ou câmera)
  static Future<String?> pickAndUploadProfilePhoto() async {
    try {
      // Mostrar dialog de opções
      final source = await _showImageSourceDialog();
      if (source == null) return null;

      // Verificar permissões
      if (!await _checkPermissions(source)) {
        Get.snackbar(
          'Permissão necessária',
          'Permita o acesso para usar esta funcionalidade',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return null;
      }

      // Escolher imagem
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Upload para Firebase Storage
      final downloadUrl = await _uploadToFirebase(File(pickedFile.path));
      
      if (downloadUrl != null) {
        Get.snackbar(
          'Sucesso! 📸',
          'Foto de perfil atualizada',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }

      return downloadUrl;

    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar a foto: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return null;
    }
  }

  static Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Escolher foto'),
        content: const Text('Como você gostaria de escolher sua foto?'),
        actions: [
          TextButton.icon(
            onPressed: () => Get.back(result: ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeria'),
          ),
          TextButton.icon(
            onPressed: () => Get.back(result: ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Câmera'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  static Future<bool> _checkPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } else {
      final status = await Permission.photos.request();
      return status == PermissionStatus.granted;
    }
  }

  static Future<String?> _uploadToFirebase(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Nome único para o arquivo
      final fileName = 'profile_photos/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Referência do Storage
      final ref = _storage.ref().child(fileName);
      
      // Upload
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Aguardar upload
      final snapshot = await uploadTask;
      
      // Obter URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Atualizar perfil do usuário no Firebase Auth
      await user.updatePhotoURL(downloadUrl);
      
      return downloadUrl;

    } catch (e) {
      print('Erro no upload: $e');
      return null;
    }
  }

  /// Deletar foto anterior (opcional)
  static Future<void> deleteProfilePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      print('Erro ao deletar foto anterior: $e');
    }
  }
}

// ✅ Widget para exibir avatar com foto ou inicial
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String fallbackText;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    required this.fallbackText,
    this.size = 80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: photoUrl == null ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF5BC4A8),
            ],
          ) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 15,
            ),
          ],
        ),
        child: photoUrl != null
            ? ClipOval(
                child: Image.network(
                  photoUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallback();
                  },
                ),
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        fallbackText.isNotEmpty ? fallbackText.substring(0, 1).toUpperCase() : 'U',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}