import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gemini_service.dart';

final supabase = Supabase.instance.client;

final geminiServiceProvider = Provider((ref) =>
    GeminiService(Supabase.instance.client));