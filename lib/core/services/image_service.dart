import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';
import 'package:flutter/material.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Mostrar opções para escolher foto (galeria ou câmera)
  static Future<String?> pickAndUploadProfilePhoto() async {
    try {
      print('📸 Iniciando seleção de foto...');

      // Mostrar dialog de opções
      final source = await _showImageSourceDialog();
      if (source == null) {
        print('❌ Usuário cancelou seleção');
        return null;
      }

      // Verificar permissões
      if (!await _checkPermissions(source)) {
        Get.snackbar(
          'Permissão necessária',
          'Permita o acesso para usar esta funcionalidade',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
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

      if (pickedFile == null) {
        print('❌ Nenhuma imagem selecionada');
        return null;
      }

      print('📸 Imagem selecionada: ${pickedFile.path}');

      // Mostrar loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        barrierDismissible: false,
      );

      // Upload para Firebase Storage
      final downloadUrl = await _uploadToFirebase(File(pickedFile.path));
      
      // Fechar loading
      Get.back();
      
      if (downloadUrl != null) {
        Get.snackbar(
          'Sucesso! 📸',
          'Foto de perfil atualizada',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        print('✅ Upload concluído: $downloadUrl');
      } else {
        Get.snackbar(
          'Erro',
          'Não foi possível fazer upload da foto',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return downloadUrl;

    } catch (e) {
      // Fechar loading se estiver aberto
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar a foto: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('❌ Erro no ImageService: $e');
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
            icon: const Icon(Icons.photo_library, color: AppColors.primary),
            label: const Text(
              'Galeria',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton.icon(
            onPressed: () => Get.back(result: ImageSource.camera),
            icon: const Icon(Icons.camera_alt, color: AppColors.primary),
            label: const Text(
              'Câmera',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> _checkPermissions(ImageSource source) async {
    try {
      PermissionStatus status;
      
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
        print('📷 Permissão da câmera: $status');
      } else {
        // Para Android 13+ usar photos, para versões anteriores usar storage
        if (Platform.isAndroid) {
          status = await Permission.photos.request();
          // Fallback para storage se photos não funcionar
          if (status.isDenied) {
            status = await Permission.storage.request();
          }
        } else {
          status = await Permission.photos.request();
        }
        print('📱 Permissão de fotos: $status');
      }
      
      return status == PermissionStatus.granted;
    } catch (e) {
      print('❌ Erro ao verificar permissões: $e');
      return false;
    }
  }

  static Future<String?> _uploadToFirebase(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      print('☁️ Iniciando upload para Firebase Storage...');

      // Nome único para o arquivo
      final fileName = 'profile_photos/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Referência do Storage
      final ref = _storage.ref().child(fileName);
      
      // Metadados do arquivo
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload com progress tracking
      final uploadTask = ref.putFile(imageFile, metadata);
      
      // Monitorar progresso (opcional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📊 Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Aguardar upload
      final snapshot = await uploadTask;
      
      // Obter URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Atualizar perfil do usuário no Firebase Auth
      await user.updatePhotoURL(downloadUrl);
      await user.reload(); // Recarregar dados do usuário
      
      print('✅ Upload concluído: $downloadUrl');
      return downloadUrl;

    } catch (e) {
      print('❌ Erro no upload: $e');
      return null;
    }
  }

  /// Deletar foto anterior (opcional)
  static Future<void> deleteProfilePhoto(String photoUrl) async {
    try {
      if (photoUrl.isNotEmpty && photoUrl.contains('firebase')) {
        final ref = _storage.refFromURL(photoUrl);
        await ref.delete();
        print('🗑️ Foto anterior deletada');
      }
    } catch (e) {
      print('⚠️ Erro ao deletar foto anterior: $e');
      // Não falhar por isso
    }
  }
}

// ✅ Widget para exibir avatar com foto ou inicial
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String fallbackText;
  final double size;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    required this.fallbackText,
    this.size = 80,
    this.onTap,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
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
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Erro ao carregar imagem: $error');
                        return _buildFallback();
                      },
                    ),
                  )
                : _buildFallback(),
          ),
          
          // Ícone de edição
          if (showEditIcon && onTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: size * 0.15,
                ),
              ),
            ),
        ],
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