import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/spotlight_background.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/database_helper.dart';
import '../../../data/models/watched_item.dart';
import '../../main/screens/main_screen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _titleController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _seasonController = TextEditingController();
  final _episodeController = TextEditingController();
  final _reviewController = TextEditingController();

  int _rating = 0;
  String _selectedCategory = 'Film';
  String _selectedStatus = 'Sudah Nonton';
  final List<String> _selectedGenres = [];
  String? _posterPath;
  bool _isSaving = false;

  static const List<String> _genres = [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Fantasy',
    'History',
    'Horror',
    'Musical',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'War',
    'Western',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _seasonController.dispose();
    _episodeController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickPoster() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _posterPath = image.path);
    }
  }

  Future<void> _saveItem() async {
    final user = MainScreen.of(context)?.currentUser;
    if (user == null || user.id == null) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }
    
    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 genre')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Save genres as comma-separated string
    final genreString = _selectedGenres.join(', ');

    final item = WatchedItem(
      userId: user.id!,
      title: title,
      category: _selectedCategory,
      genre: genreString,
      season: _selectedCategory == 'Series'
          ? int.tryParse(_seasonController.text)
          : null,
      episode: int.tryParse(_episodeController.text),
      synopsis: _synopsisController.text.trim().isNotEmpty
          ? _synopsisController.text.trim()
          : null,
      rating: _rating > 0 ? _rating.toDouble() : null,
      review: _reviewController.text.trim().isNotEmpty
          ? _reviewController.text.trim()
          : null,
      posterPath: _posterPath,
      status: _selectedStatus,
    );

    final id = await DatabaseHelper.instance.insertItem(item);
    final savedItem = item.copyWith(id: id);

    if (mounted) {
      setState(() => _isSaving = false);
      
      // Reset form
      _titleController.clear();
      _synopsisController.clear();
      _seasonController.clear();
      _episodeController.clear();
      _reviewController.clear();
      setState(() {
        _rating = 0;
        _selectedCategory = 'Film';
        _selectedStatus = 'Sudah Nonton';
        _selectedGenres.clear();
        _posterPath = null;
      });

      // Navigate to detail screen showing the saved item
      Navigator.of(context).pushNamed(
        '/detail',
        arguments: savedItem,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpotlightBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Center(
                child: Text(
                  'TAMBAH FILM / SERIES',
                  style: AppTypography.heading.copyWith(
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Poster upload area
              Center(
                child: GestureDetector(
                  onTap: _pickPoster,
                  child: Container(
                    width: 140,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.4),
                        width: 1,
                      ),
                      image: _posterPath != null
                          ? DecorationImage(
                              image: FileImage(File(_posterPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _posterPath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                color: AppColors.textHint,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambahkan\nPoster',
                                textAlign: TextAlign.center,
                                style: AppTypography.small.copyWith(
                                  color: AppColors.textHint,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Judul Film/Series
              AppTextField(
                controller: _titleController,
                label: 'Judul Film/Series',
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              _buildDropdown(
                label: 'Category',
                value: _selectedCategory,
                items: const ['Film', 'Series'],
                onChanged: (val) {
                  setState(() => _selectedCategory = val ?? 'Film');
                },
              ),
              const SizedBox(height: 20),

              // === STATUS ===
              Text(
                'STATUS',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildStatusRadio('Sudah Nonton', Icons.check_circle_outline),
              _buildStatusRadio('Planning Nonton', Icons.bookmark_outline),
              _buildStatusRadio('Up Coming', Icons.schedule_outlined),
              const SizedBox(height: 20),

              // Genre Multi-select Section
              Text(
                'Genre',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              
              // Selected Genres Tags
              if (_selectedGenres.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedGenres.map((g) {
                    return Chip(
                      label: Text(
                        g.toUpperCase(),
                        style: AppTypography.small.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.textPrimary,
                      deleteIconColor: AppColors.background,
                      onDeleted: () {
                        setState(() => _selectedGenres.remove(g));
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Available Genres Chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _genres.map((g) {
                  final isSelected = _selectedGenres.contains(g);
                  return FilterChip(
                    label: Text(
                      g,
                      style: AppTypography.label.copyWith(
                        color: isSelected ? AppColors.background : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGenres.add(g);
                        } else {
                          _selectedGenres.remove(g);
                        }
                      });
                    },
                    backgroundColor: AppColors.cardLight,
                    selectedColor: AppColors.textPrimary,
                    checkmarkColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppColors.textPrimary : AppColors.border,
                        width: 0.5,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Total Season & Total Episode — side by side
              if (_selectedCategory == 'Series') ...[
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _seasonController,
                        label: 'Total Season',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.gridGutter),
                    Expanded(
                      child: AppTextField(
                        controller: _episodeController,
                        label: 'Total Episode',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Synopsis
              AppTextField(
                controller: _synopsisController,
                label: 'Synopsis',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Rating section
              Text(
                'Rating',
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 10 star icons
                  ...List.generate(10, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _rating = starIndex);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          starIndex <= _rating
                              ? Icons.star
                              : Icons.star_outline,
                          color: starIndex <= _rating
                              ? AppColors.starFilled
                              : AppColors.starEmpty,
                          size: 22,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '$_rating',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Review
              AppTextField(
                controller: _reviewController,
                label: 'Review',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Simpan button
              AppButton(
                text: 'Simpan',
                icon: Icons.save_outlined,
                isLoading: _isSaving,
                onPressed: _saveItem,
              ),

              // Spacer for nav bar
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRadio(String value, IconData icon) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.1)
              : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.2),
            width: isSelected ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.accent : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textHint,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              value,
              style: AppTypography.body.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textHint,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.card,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
                size: 20,
              ),
              style: AppTypography.body,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
