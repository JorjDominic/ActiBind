import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/features/notes/models/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteService {
  NoteService._();

  static SupabaseClient get _supabase => SupabaseService.client;

  static Future<List<Note>> getNotes() async {
    final response = await _supabase
        .from('notes')
        .select()
        .order('created_at', ascending: false);
    return response.map((item) => Note.fromJson(item)).toList();
  }

  static Future<Note> createNote({
    required String title,
    String? content,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('You must sign in before creating a note.');
    }
    final response = await _supabase
        .from('notes')
        .insert({
          'user_id': user.id,
          'title': title.trim(),
          'content': content?.trim(),
        })
        .select()
        .single();
    return Note.fromJson(response);
  }

  static Future<Note> updateNote({
    required String id,
    required String title,
    String? content,
  }) async {
    final response = await _supabase
        .from('notes')
        .update({
          'title': title.trim(),
          'content': content?.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return Note.fromJson(response);
  }

  static Future<void> deleteNote(String id) async {
    await _supabase.from('notes').delete().eq('id', id);
  }
}
