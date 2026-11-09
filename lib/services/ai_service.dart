import 'dart:convert';
import 'dart:typed_data';
import 'package:cleanspot/config/supabase_config.dart';

class AiAnalysisResult {
  final bool isConfigured;
  final bool isSuccess;
  final String? errorMessage;
  final String? suggestedCategory;
  final int? suggestedCleanlinessRating;
  final List<String> detectedIssues;
  final String explanation;
  final String disclaimer;

  AiAnalysisResult({
    required this.isConfigured,
    required this.isSuccess,
    this.errorMessage,
    this.suggestedCategory,
    this.suggestedCleanlinessRating,
    this.detectedIssues = const [],
    this.explanation = '',
    this.disclaimer =
        'Notice: AI analysis is an automated visual estimation and should be treated as a preliminary suggestion, not a definitive cleanliness audit.',
  });

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'suggested_category': suggestedCategory,
      'suggested_cleanliness_rating': suggestedCleanlinessRating,
      'detected_issues': detectedIssues,
      'explanation': explanation,
      'disclaimer': disclaimer,
    };
  }

  factory AiAnalysisResult.unconfigured({String? customMessage}) {
    return AiAnalysisResult(
      isConfigured: false,
      isSuccess: false,
      errorMessage: customMessage ??
          'Supabase Edge Function not configured yet.\n\nTo enable Vision AI analysis:\n1. Deploy the "analyze-toilet-image" function located in /supabase/functions/\n2. Set GEMINI_API_KEY in your Supabase secrets.\n3. Configure your project URL in lib/config/supabase_config.dart.',
    );
  }

  factory AiAnalysisResult.fromResponse(Map<String, dynamic> data) {
    final issuesRaw = data['detected_issues'];
    List<String> issues = [];
    if (issuesRaw is List) {
      issues = issuesRaw.map((e) => e.toString()).toList();
    }

    return AiAnalysisResult(
      isConfigured: true,
      isSuccess: data['is_success'] == true,
      suggestedCategory: data['suggested_category'] as String?,
      suggestedCleanlinessRating:
          (data['suggested_cleanliness_rating'] as num?)?.toInt() ?? 3,
      detectedIssues: issues,
      explanation: data['explanation'] as String? ?? 'No details provided.',
      disclaimer: data['disclaimer'] as String? ??
          'Notice: AI analysis is an automated suggestion, not a definitive judgment.',
    );
  }
}

class AiService {
  /// Analyzes a toilet photo using Supabase Edge Function
  /// Never exposes API keys on the Flutter client
  static Future<AiAnalysisResult> analyzePhotoBytes(
    Uint8List imageBytes, {
    String? mimeType = 'image/jpeg',
  }) async {
    // 1. Guard check if Supabase is configured
    if (!SupabaseConfig.isConfigured) {
      return AiAnalysisResult.unconfigured();
    }

    try {
      final base64Image = base64Encode(imageBytes);

      // Invoke the secure Supabase Edge Function
      final response = await SupabaseConfig.client.functions.invoke(
        SupabaseConfig.aiAnalysisFunctionName,
        body: {
          'imageBase64': base64Image,
          'mimeType': mimeType,
        },
      );

      if (response.status == 200 && response.data != null) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data as Map<String, dynamic>
                : jsonDecode(response.data.toString()) as Map<String, dynamic>;

        return AiAnalysisResult.fromResponse(responseData);
      } else {
        return AiAnalysisResult(
          isConfigured: true,
          isSuccess: false,
          errorMessage:
              'Edge function returned status ${response.status}: ${response.data}',
        );
      }
    } catch (e) {
      return AiAnalysisResult(
        isConfigured: true,
        isSuccess: false,
        errorMessage: 'Unable to connect to AI Edge Function: $e',
      );
    }
  }
}
