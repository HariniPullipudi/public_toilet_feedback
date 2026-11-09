import 'dart:typed_data';
import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/config/supabase_config.dart';
import 'package:cleanspot/models/feedback_model.dart';
import 'package:cleanspot/models/profile_model.dart';
import 'package:cleanspot/models/toilet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  ProfileModel? _currentProfile;
  ProfileModel? get currentProfile => _currentProfile;

  bool get isAuthenticated =>
      SupabaseConfig.isConfigured &&
      SupabaseConfig.client.auth.currentUser != null;

  User? get currentUser =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client.auth.currentUser : null;

  bool get isAdmin => _currentProfile?.isAdmin ?? false;

  // ----------------------------------------------------
  // AUTHENTICATION
  // ----------------------------------------------------

  /// Sign In with Email and Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase is not configured yet. Please configure your SUPABASE_URL and SUPABASE_ANON_KEY in lib/config/supabase_config.dart',
      );
    }

    final response = await SupabaseConfig.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.user != null) {
      await fetchUserProfile(response.user!.id);
    }

    return response;
  }

  /// Sign Up new user with full name (Always defaults to 'citizen' role)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase is not configured yet. Please configure your SUPABASE_URL and SUPABASE_ANON_KEY in lib/config/supabase_config.dart',
      );
    }

    // Role is strictly omitted from user input to enforce security: backend trigger sets role = 'citizen'
    final response = await SupabaseConfig.client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
      },
    );

    if (response.user != null) {
      // Ensure profile row exists
      try {
        await SupabaseConfig.client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': fullName.trim(),
          'role': AppConstants.roleCitizen, // strictly citizen
        });
      } catch (_) {
        // Handled by Postgres trigger if present
      }
      await fetchUserProfile(response.user!.id);
    }

    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    _currentProfile = null;
    if (SupabaseConfig.isConfigured) {
      await SupabaseConfig.client.auth.signOut();
    }
  }

  /// Fetch profile for given user ID
  Future<ProfileModel?> fetchUserProfile(String userId) async {
    if (!SupabaseConfig.isConfigured) return null;

    try {
      final data = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _currentProfile = ProfileModel.fromJson(data);
        return _currentProfile;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch profile error: $e');
    }
    return null;
  }

  // ----------------------------------------------------
  // TOILETS
  // ----------------------------------------------------

  /// Fetch all verified toilets
  Future<List<ToiletModel>> fetchToilets() async {
    if (!SupabaseConfig.isConfigured) {
      return getDemoToilets();
    }

    try {
      final List<dynamic> data = await SupabaseConfig.client
          .from('toilets')
          .select()
          .order('name', ascending: true);

      if (data.isEmpty) {
        return getDemoToilets();
      }

      return data
          .map((json) => ToiletModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching toilets from Supabase: $e');
      return getDemoToilets();
    }
  }

  /// Fetch single toilet with its reviews/feedback
  Future<ToiletModel?> fetchToiletById(String toiletId) async {
    if (!SupabaseConfig.isConfigured) {
      final demoList = getDemoToilets();
      return demoList.firstWhere(
        (t) => t.id == toiletId,
        orElse: () => demoList.first,
      );
    }

    try {
      final data = await SupabaseConfig.client
          .from('toilets')
          .select()
          .eq('id', toiletId)
          .single();

      return ToiletModel.fromJson(data);
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching toilet: $e');
      return null;
    }
  }

  // ----------------------------------------------------
  // FEEDBACK & COMPLAINTS
  // ----------------------------------------------------

  /// Fetch feedback for a specific toilet
  Future<List<FeedbackModel>> fetchFeedbackForToilet(String toiletId) async {
    if (!SupabaseConfig.isConfigured) {
      return getDemoFeedback().where((f) => f.toiletId == toiletId).toList();
    }

    try {
      final List<dynamic> data = await SupabaseConfig.client
          .from('feedback')
          .select('*, profiles(full_name)')
          .eq('toilet_id', toiletId)
          .order('created_at', ascending: false);

      return data
          .map((json) => FeedbackModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching toilet feedback: $e');
      return [];
    }
  }

  /// Submit citizen feedback and complaint
  Future<FeedbackModel> submitFeedback({
    required String toiletId,
    required int overallRating,
    required int cleanlinessRating,
    required int waterRating,
    required int maintenanceRating,
    required int facilitiesRating,
    required String issueCategory,
    required String comments,
    Uint8List? photoBytes,
    String? photoFileName,
    Map<String, dynamic>? aiAnalysis,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase is not configured. Please set your credentials in lib/config/supabase_config.dart to submit real feedback.',
      );
    }

    final user = currentUser;
    if (user == null) {
      throw Exception('You must be logged in to submit feedback.');
    }

    String? photoUrl;
    if (photoBytes != null && photoFileName != null) {
      photoUrl = await uploadToiletPhoto(photoBytes, photoFileName);
    }

    final insertData = {
      'toilet_id': toiletId,
      'user_id': user.id,
      'overall_rating': overallRating,
      'cleanliness_rating': cleanlinessRating,
      'water_rating': waterRating,
      'maintenance_rating': maintenanceRating,
      'facilities_rating': facilitiesRating,
      'issue_category': issueCategory,
      'comments': comments,
      'photo_path': photoUrl,
      'ai_analysis': aiAnalysis,
      'status': AppConstants.statusPending,
    };

    final response = await SupabaseConfig.client
        .from('feedback')
        .insert(insertData)
        .select()
        .single();

    return FeedbackModel.fromJson(response);
  }

  /// Fetch current user's submitted reports
  Future<List<FeedbackModel>> fetchMyFeedback() async {
    final user = currentUser;
    if (user == null) {
      return [];
    }

    if (!SupabaseConfig.isConfigured) {
      return getDemoFeedback().where((f) => f.userId == user.id).toList();
    }

    try {
      final List<dynamic> data = await SupabaseConfig.client
          .from('feedback')
          .select('*, toilets(name)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return data
          .map((json) => FeedbackModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching my feedback: $e');
      return [];
    }
  }

  /// Fetch all complaints for Administrator Dashboard (Enforced by backend RLS)
  Future<List<FeedbackModel>> fetchAllComplaintsForAdmin() async {
    if (!SupabaseConfig.isConfigured) {
      return getDemoFeedback();
    }

    try {
      final List<dynamic> data = await SupabaseConfig.client
          .from('feedback')
          .select('*, toilets(name), profiles(full_name)')
          .order('created_at', ascending: false);

      return data
          .map((json) => FeedbackModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching complaints for admin: $e');
      rethrow;
    }
  }

  /// Update complaint status and provide admin response (Enforced by backend RLS)
  Future<void> updateComplaintStatus({
    required String feedbackId,
    required String status,
    String? adminResponse,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception('Supabase is not configured.');
    }

    await SupabaseConfig.client.from('feedback').update({
      'status': status,
      'admin_response': adminResponse,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', feedbackId);
  }

  // ----------------------------------------------------
  // STORAGE
  // ----------------------------------------------------

  /// Upload toilet complaint photograph to Supabase Storage
  Future<String> uploadToiletPhoto(Uint8List bytes, String fileName) async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception('Supabase is not configured.');
    }

    final path = 'complaints/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await SupabaseConfig.client.storage
        .from(AppConstants.toiletPhotosBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final publicUrl = SupabaseConfig.client.storage
        .from(AppConstants.toiletPhotosBucket)
        .getPublicUrl(path);

    return publicUrl;
  }

  // ----------------------------------------------------
  // DEMONSTRATION DATA (Labeled Sample Data)
  // ----------------------------------------------------

  static List<ToiletModel> getDemoToilets() {
    return [
      ToiletModel(
        id: 'demo-toilet-1',
        name: 'Central Metro Station Public Restroom',
        address: 'Concourse Level 2, Metro Gate B, City Center',
        latitude: 17.4399,
        longitude: 78.4983,
        description:
            'High-footfall transit hub facility featuring automated flush systems, touchless sanitizer dispensers, and accessible stalls.',
        waterAvailable: true,
        soapAvailable: true,
        wheelchairAccessible: true,
        verificationStatus: 'verified',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        averageRating: 4.6,
        reviewCount: 38,
        distanceKm: 0.4,
      ),
      ToiletModel(
        id: 'demo-toilet-2',
        name: 'Gandhi Memorial Park Community Facility',
        address: 'Sector 4 Garden Walk, Opposite Children Playground',
        latitude: 17.4425,
        longitude: 78.4950,
        description:
            'Eco-sanitation public facility equipped with dual water supply, baby care changing station, and solar lighting.',
        waterAvailable: true,
        soapAvailable: true,
        wheelchairAccessible: true,
        verificationStatus: 'verified',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        averageRating: 4.2,
        reviewCount: 24,
        distanceKm: 0.9,
      ),
      ToiletModel(
        id: 'demo-toilet-3',
        name: 'Old Bazaar Municipal Sanitation Complex',
        address: 'Lane 7, Vegetable Wholesale Market',
        latitude: 17.4350,
        longitude: 78.5020,
        description:
            'Heavy traffic marketplace sanitation block. Requires periodic pressure wash maintenance during morning peak hours.',
        waterAvailable: true,
        soapAvailable: false,
        wheelchairAccessible: false,
        verificationStatus: 'verified',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        averageRating: 2.8,
        reviewCount: 52,
        distanceKm: 1.5,
      ),
      ToiletModel(
        id: 'demo-toilet-4',
        name: 'Civic Plaza Smart Toilet Pod',
        address: 'Pedestrian Boulevard, Next to Tourist Helpdesk',
        latitude: 17.4480,
        longitude: 78.4910,
        description:
            'Self-cleaning automated smart toilet pod with voice guidance and emergency call button for senior citizens.',
        waterAvailable: true,
        soapAvailable: true,
        wheelchairAccessible: true,
        verificationStatus: 'verified',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        averageRating: 4.8,
        reviewCount: 19,
        distanceKm: 2.1,
      ),
    ];
  }

  static List<FeedbackModel> getDemoFeedback() {
    return [
      FeedbackModel(
        id: 'demo-fb-1',
        toiletId: 'demo-toilet-3',
        userId: 'demo-user-1',
        toiletName: 'Old Bazaar Municipal Sanitation Complex',
        userName: 'Rahul Sharma',
        overallRating: 2,
        cleanlinessRating: 2,
        waterRating: 3,
        maintenanceRating: 2,
        facilitiesRating: 2,
        issueCategory: 'Overflowing Bins',
        comments:
            'Trash bins near the wash basin have been overflowing since morning. Need prompt disposal.',
        photoPath: null,
        status: AppConstants.statusInProgress,
        adminResponse:
            'Sanitation supervisor assigned. Cleaning crew dispatched to empty bins and disinfect area.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      FeedbackModel(
        id: 'demo-fb-2',
        toiletId: 'demo-toilet-1',
        userId: 'demo-user-2',
        toiletName: 'Central Metro Station Public Restroom',
        userName: 'Priya Patel',
        overallRating: 5,
        cleanlinessRating: 5,
        waterRating: 5,
        maintenanceRating: 5,
        facilitiesRating: 5,
        issueCategory: 'General Feedback',
        comments:
            'Extremely clean, dry floor, and soap was fully stocked. Great job maintaining SDG 6 standards!',
        photoPath: null,
        status: AppConstants.statusResolved,
        adminResponse: 'Thank you for your feedback! Daily sanitization protocol logged.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FeedbackModel(
        id: 'demo-fb-3',
        toiletId: 'demo-toilet-2',
        userId: 'demo-user-1',
        toiletName: 'Gandhi Memorial Park Community Facility',
        userName: 'Rahul Sharma',
        overallRating: 3,
        cleanlinessRating: 3,
        waterRating: 2,
        maintenanceRating: 3,
        facilitiesRating: 4,
        issueCategory: 'Lack of Water',
        comments:
            'Low water pressure in the outer wash tap. Handwashing soap dispenser was working well.',
        photoPath: null,
        status: AppConstants.statusPending,
        adminResponse: null,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
