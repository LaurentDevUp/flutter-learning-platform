import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attachment.dart';

class AttachmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all attachments for a fiche
  Future<List<Attachment>> getAttachments(String ficheId) async {
    final response = await _supabase
        .from('attachments')
        .select()
        .eq('fiche_id', ficheId)
        .order('created_at', ascending: true);

    return response.map((json) => Attachment.fromJson(json)).toList();
  }

  // Upload a file to Supabase Storage
  Future<String> uploadFile({
    required File file,
    required String fileName,
    required String bucket,
  }) async {
    final bytes = await file.readAsBytes();
    final path = '${_supabase.auth.currentUser!.id}/$fileName';
    
    await _supabase.storage.from(bucket).uploadBinary(path, bytes);
    
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  // Download and save file locally
  Future<String> downloadFile({
    required String fileUrl,
    required String fileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final localPath = '${directory.path}/attachments/$fileName';
    
    final file = File(localPath);
    await file.create(recursive: true);
    
    final response = await _supabase.storage.from('attachments').download(fileUrl);
    await file.writeAsBytes(response);
    
    return localPath;
  }

  // Create attachment record
  Future<Attachment> createAttachment({
    required String ficheId,
    required String fileName,
    required AttachmentType fileType,
    required String fileUrl,
    int? fileSize,
  }) async {
    final response = await _supabase.from('attachments').insert({
      'fiche_id': ficheId,
      'file_name': fileName,
      'file_type': fileType.toString().split('.').last,
      'file_url': fileUrl,
      'file_size': fileSize,
      'is_downloaded': false,
    }).select().single();

    return Attachment.fromJson(response);
  }

  // Mark file as downloaded
  Future<void> markAsDownloaded(String id, String localPath) async {
    await _supabase
        .from('attachments')
        .update({
          'is_downloaded': true,
          'local_path': localPath,
        })
        .eq('id', id);
  }

  // Delete attachment
  Future<void> deleteAttachment(String id) async {
    final attachment = await getAttachment(id);
    if (attachment != null) {
      // Delete from storage
      final path = attachment.fileUrl.split('/').last;
      await _supabase.storage.from('attachments').remove([path]);
      
      // Delete from database
      await _supabase.from('attachments').delete().eq('id', id);
    }
  }

  // Get a single attachment
  Future<Attachment?> getAttachment(String id) async {
    final response = await _supabase
        .from('attachments')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? Attachment.fromJson(response) : null;
  }

  // Check if file exists locally
  Future<bool> fileExistsLocally(String localPath) async {
    if (localPath == null) return false;
    return File(localPath).exists();
  }

  // Subscribe to real-time changes
  Stream<List<Attachment>> subscribeToAttachments(String ficheId) {
    return _supabase
        .from('attachments')
        .stream(primaryKey: ['id'])
        .eq('fiche_id', ficheId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => Attachment.fromJson(json)).toList());
  }
}
