import 'package:cleanspot/config/app_theme.dart';
import 'package:cleanspot/models/toilet_model.dart';
import 'package:cleanspot/screens/toilets/toilet_details_screen.dart';
import 'package:cleanspot/services/location_service.dart';
import 'package:cleanspot/services/supabase_service.dart';
import 'package:cleanspot/widgets/toilet_card.dart';
import 'package:flutter/material.dart';

class ToiletListScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const ToiletListScreen({super.key, this.initialSearchQuery});

  @override
  State<ToiletListScreen> createState() => _ToiletListScreenState();
}

class _ToiletListScreenState extends State<ToiletListScreen> {
  final SupabaseService _supabase = SupabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<ToiletModel> _allToilets = [];
  List<ToiletModel> _filteredToilets = [];
  bool _isLoading = true;
  bool _isLocating = false;

  // Filter state
  bool _filterFourPlusRating = false;
  bool _filterWaterOnly = false;
  bool _filterSoapOnly = false;
  bool _filterWheelchairOnly = false;
  bool _sortByDistance = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
    }
    _searchController.addListener(_applyFilters);
    _loadToiletsAndLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadToiletsAndLocation() async {
    setState(() => _isLoading = true);
    try {
      final list = await _supabase.fetchToilets();
      _allToilets = list;
      _applyFilters();
    } catch (_) {
      // Fallback
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    // Attempt geolocation
    _detectUserLocation();
  }

  Future<void> _detectUserLocation() async {
    setState(() => _isLocating = true);
    final pos = await LocationService.getCurrentLocation();
    if (pos != null && mounted) {
      final updatedList = _allToilets.map((toilet) {
        final dist = LocationService.calculateDistanceInKm(
          pos.latitude,
          pos.longitude,
          toilet.latitude,
          toilet.longitude,
        );
        return toilet.copyWith(distanceKm: dist);
      }).toList();

      setState(() {
        _allToilets = updatedList;
        _isLocating = false;
      });
      _applyFilters();
    } else {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    List<ToiletModel> results = _allToilets.where((toilet) {
      // Search text match
      final matchesQuery = query.isEmpty ||
          toilet.name.toLowerCase().contains(query) ||
          toilet.address.toLowerCase().contains(query);

      // Rating filter
      final matchesRating =
          !_filterFourPlusRating || toilet.averageRating >= 4.0;

      // Amenities filters
      final matchesWater = !_filterWaterOnly || toilet.waterAvailable;
      final matchesSoap = !_filterSoapOnly || toilet.soapAvailable;
      final matchesWheelchair =
          !_filterWheelchairOnly || toilet.wheelchairAccessible;

      return matchesQuery &&
          matchesRating &&
          matchesWater &&
          matchesSoap &&
          matchesWheelchair;
    }).toList();

    if (_sortByDistance) {
      results.sort((a, b) {
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });
    }

    setState(() {
      _filteredToilets = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Find Public Toilets'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.my_location_rounded,
              color: _isLocating ? AppTheme.primaryLight : AppTheme.primaryColor,
            ),
            tooltip: 'Find Nearby Facilities',
            onPressed: _detectUserLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadToiletsAndLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by facility name or location...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        selected: _filterFourPlusRating,
                        label: const Text('Rating 4.0+ ★'),
                        onSelected: (val) {
                          setState(() => _filterFourPlusRating = val);
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _filterWaterOnly,
                        label: const Text('Running Water 💧'),
                        onSelected: (val) {
                          setState(() => _filterWaterOnly = val);
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _filterSoapOnly,
                        label: const Text('Soap Available 🧼'),
                        onSelected: (val) {
                          setState(() => _filterSoapOnly = val);
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _filterWheelchairOnly,
                        label: const Text('Wheelchair Accessible ♿'),
                        onSelected: (val) {
                          setState(() => _filterWheelchairOnly = val);
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _sortByDistance,
                        label: const Text('Nearest First 📍'),
                        onSelected: (val) {
                          setState(() => _sortByDistance = val);
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Count and Nearby Status indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${_filteredToilets.length} sanitation facilities available',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (_isLocating)
                  const Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Locating...',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : _filteredToilets.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Facilities Found',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try clearing your filters or searching for another location or landmark.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _filterFourPlusRating = false;
                                    _filterWaterOnly = false;
                                    _filterSoapOnly = false;
                                    _filterWheelchairOnly = false;
                                    _sortByDistance = false;
                                  });
                                  _applyFilters();
                                },
                                child: const Text('Reset All Filters'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredToilets.length,
                        itemBuilder: (context, index) {
                          final toilet = _filteredToilets[index];
                          return ToiletCard(
                            toilet: toilet,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ToiletDetailsScreen(toilet: toilet),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
