import 'dart:typed_data';
import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/config/supabase_config.dart';
import 'package:cleanspot/models/toilet_model.dart';
import 'package:cleanspot/screens/feedback/ai_analysis_screen.dart';
import 'package:cleanspot/services/ai_service.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:cleanspot/widgets/star_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SubmitFeedbackScreen extends StatefulWidget {
  final ToiletModel? preselectedToilet;
  final bool isUrgentReport;

  const SubmitFeedbackScreen({
    super.key,
    this.preselectedToilet,
    this.isUrgentReport = false,
  });

  @override
  State<SubmitFeedbackScreen> createState() => _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends State<SubmitFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabase = SupabaseService();
  final ImagePicker _picker = ImagePicker();

  List<ToiletModel> _toilets = [];
  ToiletModel? _selectedToilet;
  bool _isLoadingToilets = true;

  // Multi-dimensional Ratings
  int _overallRating = 4;
  int _cleanlinessRating = 4;
  int _waterRating = 4;
  int _maintenanceRating = 4;
  int _facilitiesRating = 4;

  // Category and Comments
  String _selectedCategory = AppConstants.issueCategories.first;
  final TextEditingController _commentsController = TextEditingController();

  // Attached Image & AI Vision Result
  Uint8List? _attachedImageBytes;
  String? _attachedImageName;
  AiAnalysisResult? _aiAnalysisResult;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedToilet = widget.preselectedToilet;
    if (widget.isUrgentReport) {
      _overallRating = 2;
      _cleanlinessRating = 1;
      _selectedCategory = 'Dirty Surfaces';
    }
    _loadToilets();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadToilets() async {
    setState(() => _isLoadingToilets = true);
    try {
      final list = await _supabase.fetchToilets();
      if (mounted) {
        setState(() {
          _toilets = list;
          if (_selectedToilet == null && list.isNotEmpty) {
            _selectedToilet = list.first;
          }
          _isLoadingToilets = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingToilets = false);
    }
  }

  Future<void> _openAiAnalysis() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AiAnalysisScreen(
          initialImageBytes: _attachedImageBytes,
          initialImageName: _attachedImageName,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _attachedImageBytes = result['imageBytes'] as Uint8List?;
        _attachedImageName = result['imageName'] as String?;
        final aiResult = result['analysis'] as AiAnalysisResult?;
        _aiAnalysisResult = aiResult;

        // Apply suggestions if available
        if (aiResult != null && aiResult.isSuccess) {
          if (aiResult.suggestedCategory != null &&
              AppConstants.issueCategories.contains(aiResult.suggestedCategory)) {
            _selectedCategory = aiResult.suggestedCategory!;
          }
          if (aiResult.suggestedCleanlinessRating != null) {
            _cleanlinessRating = aiResult.suggestedCleanlinessRating!;
            _overallRating = aiResult.suggestedCleanlinessRating!;
          }
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _attachedImageBytes = bytes;
          _attachedImageName = file.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick photo: $e')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (_selectedToilet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a public toilet facility')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Check Supabase Configuration
    if (!SupabaseConfig.isConfigured) {
      _showUnconfiguredDialog();
      return;
    }

    if (!_supabase.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in with your citizen account to submit reports.'),
          backgroundColor: AppTheme.statusPending,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _supabase.submitFeedback(
        toiletId: _selectedToilet!.id,
        overallRating: _overallRating,
        cleanlinessRating: _cleanlinessRating,
        waterRating: _waterRating,
        maintenanceRating: _maintenanceRating,
        facilitiesRating: _facilitiesRating,
        issueCategory: _selectedCategory,
        comments: _commentsController.text.trim(),
        photoBytes: _attachedImageBytes,
        photoFileName: _attachedImageName,
        aiAnalysis: _aiAnalysisResult?.toJson(),
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: AppTheme.statusRejected,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showUnconfiguredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: AppTheme.statusPending),
            SizedBox(width: 8),
            Text('Supabase Not Connected'),
          ],
        ),
        content: const Text(
          'Your report was validated! However, live database persistence requires active Supabase credentials.\n\n'
          'To connect live Supabase:\n'
          '1. Set supabaseUrl and supabaseAnonKey in lib/config/supabase_config.dart\n'
          '2. Run the SQL schema script provided in /supabase/schema.sql.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Feedback Submitted!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thank you for contributing to UN SDG 6 sanitation standards. Your report has been dispatched to local sanitation supervisors.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.isUrgentReport ? 'Report Issue' : 'Submit Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toilet Selector
              const Text(
                'Select Toilet Facility',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingToilets)
                const LinearProgressIndicator(color: AppTheme.primaryColor)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ToiletModel>(
                      isExpanded: true,
                      value: _selectedToilet,
                      items: _toilets.map((toilet) {
                        return DropdownMenuItem<ToiletModel>(
                          value: toilet,
                          child: Text(
                            toilet.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedToilet = val);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Multi-dimensional Ratings Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hygiene & Condition Ratings',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Overall
                    _buildInteractiveRatingRow(
                      'Overall Satisfaction',
                      _overallRating,
                      (val) => setState(() => _overallRating = val),
                      isHighlight: true,
                    ),
                    const Divider(height: 20, color: AppTheme.dividerColor),

                    // Cleanliness
                    _buildInteractiveRatingRow(
                      'Cleanliness & Odour',
                      _cleanlinessRating,
                      (val) => setState(() => _cleanlinessRating = val),
                    ),
                    const SizedBox(height: 10),

                    // Water
                    _buildInteractiveRatingRow(
                      'Water Availability',
                      _waterRating,
                      (val) => setState(() => _waterRating = val),
                    ),
                    const SizedBox(height: 10),

                    // Maintenance
                    _buildInteractiveRatingRow(
                      'Fixture Maintenance',
                      _maintenanceRating,
                      (val) => setState(() => _maintenanceRating = val),
                    ),
                    const SizedBox(height: 10),

                    // Facilities
                    _buildInteractiveRatingRow(
                      'Soap & Accessibility',
                      _facilitiesRating,
                      (val) => setState(() => _facilitiesRating = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Issue Category Selector
              const Text(
                'Issue / Feedback Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.issueCategories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryDark : AppTheme.textSecondary,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Comments input
              const Text(
                'Observations & Comments (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Describe specific sanitation conditions, broken taps, missing soap, or commend cleanliness...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Attached Photograph & AI Analysis Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attach Photograph Evidence',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _openAiAnalysis,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('AI Vision Audit'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_attachedImageBytes == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 36,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Upload or take a photo to support your report',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded, size: 16),
                            label: const Text('Camera'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_rounded, size: 16),
                            label: const Text('Gallery'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(14)),
                        child: Image.memory(
                          _attachedImageBytes!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _attachedImageName ?? 'photo.jpg',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _attachedImageBytes = null;
                                  _attachedImageName = null;
                                  _aiAnalysisResult = null;
                                });
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isUrgentReport
                        ? const Color(0xFFDC2626)
                        : AppTheme.primaryColor,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isUrgentReport
                              ? 'Submit Urgent Issue Report'
                              : 'Submit Facility Feedback',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveRatingRow(
    String title,
    int currentScore,
    ValueChanged<int> onScoreChanged, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isHighlight ? 14 : 13,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            color: isHighlight ? AppTheme.primaryDark : AppTheme.textPrimary,
          ),
        ),
        StarRatingBar(
          rating: currentScore.toDouble(),
          size: isHighlight ? 22 : 18,
          isInteractive: true,
          onRatingChanged: onScoreChanged,
        ),
      ],
    );
  }
}
