import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/database_helper.dart';
import '../../../data/models/watched_item.dart';

class DetailScreen extends StatefulWidget {
  final WatchedItem? item;

  const DetailScreen({super.key, this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late WatchedItem? _item;
  bool _isEditingReview = false;
  late TextEditingController _reviewController;
  final GlobalKey _posterKey = GlobalKey();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _reviewController = TextEditingController(
      text: _item?.review ?? '',
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    if (_item == null || _item!.id == null) return;

    final updatedItem = _item!.copyWith(
      review: _reviewController.text.trim(),
    );

    await DatabaseHelper.instance.updateItem(updatedItem);

    if (mounted) {
      setState(() {
        _item = updatedItem;
        _isEditingReview = false;
      });
    }
  }

  Future<void> _deleteItem() async {
    if (_item == null || _item!.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Entry',
          style: AppTypography.heading.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Yakin ingin menghapus ${_item!.title}?',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: AppTypography.button.copyWith(color: AppColors.textHint),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCF6679),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DatabaseHelper.instance.deleteItem(_item!.id!);
      if (mounted) {
        Navigator.of(context).pop(); // Go back to home
      }
    }
  }

  Future<void> _downloadPoster() async {
    if (_isDownloading) return;
    
    // Check permissions
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        final photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin akses penyimpanan dibutuhkan')),
            );
          }
          // Some Android versions don't strictly require this when using MediaStore
          // We will proceed anyway and let the plugin handle it if possible.
        }
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (!status.isGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin akses foto dibutuhkan')),
        );
        return;
      }
    }

    setState(() => _isDownloading = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memproses poster...')),
      );
    }

    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final boundary = _posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary == null) {
            throw Exception("Gagal merender poster");
          }
          
          // We render it larger for better resolution
          final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
          final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          final Uint8List pngBytes = byteData!.buffer.asUint8List();

          final result = await ImageGallerySaverPlus.saveImage(
            pngBytes,
            quality: 100,
            name: "watched_${_item!.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}",
          );

          if (mounted) {
            if (result['isSuccess'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Poster berhasil disimpan ke Galeri!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gagal menyimpan poster')),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isDownloading = false);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final screenWidth = MediaQuery.of(context).size.width;

    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text(
            'Item not found',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              slivers: [
                // Hero image area
                SliverToBoxAdapter(
                  child: _buildHeroSection(item, screenWidth),
                ),

                // Content below hero
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenMargin,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          item.title.toUpperCase(),
                          style: AppTypography.title.copyWith(
                            fontSize: 24,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category badge & Genre tags
                        _buildBadges(item),
                        const SizedBox(height: 16),

                        // Season / Episode (if series)
                        if (item.category == 'Series')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSeasonEpisodeInfo(item),
                          ),

                        // Rating row
                        if (item.rating != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildRatingRow(item),
                          ),

                        // Synopsis
                        if (item.synopsis != null &&
                            item.synopsis!.isNotEmpty) ...[
                          Text(
                            'SYNOPSIS',
                            style: AppTypography.label.copyWith(
                              letterSpacing: 3,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.synopsis!,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Review section (editable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REVIEW',
                              style: AppTypography.label.copyWith(
                                letterSpacing: 3,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_isEditingReview) {
                                  _saveReview();
                                } else {
                                  setState(() => _isEditingReview = true);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.accent,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _isEditingReview ? 'SAVE' : 'EDIT',
                                  style: AppTypography.small.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (_isEditingReview)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.card.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: TextField(
                              controller: _reviewController,
                              maxLines: 5,
                              style: AppTypography.body,
                              cursorColor: AppColors.accent,
                              decoration: InputDecoration(
                                hintText: 'Tulis review...',
                                hintStyle: AppTypography.body.copyWith(
                                  color: AppColors.textHint,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.all(14),
                              ),
                            ),
                          )
                        else
                          Text(
                            item.review != null && item.review!.isNotEmpty
                                ? item.review!
                                : 'Belum ada review. Tap EDIT untuk menulis.',
                            style: AppTypography.body.copyWith(
                              color: item.review != null && item.review!.isNotEmpty
                                  ? AppColors.textSecondary
                                  : AppColors.textHint,
                              height: 1.8,
                              fontStyle: item.review == null || item.review!.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),

                        // Bottom spacer
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Bar with Back Arrow and 3-dot Menu
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                  
                  // 3-dot menu
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      color: AppColors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'download') {
                          _downloadPoster();
                        } else if (value == 'delete') {
                          _deleteItem();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'download',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.download_outlined,
                                color: AppColors.textPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Download Poster',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFCF6679),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: AppTypography.body.copyWith(
                                  color: const Color(0xFFCF6679),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Offstage widget for generating the Letterboxd poster
            Offstage(
              offstage: true,
              child: RepaintBoundary(
                key: _posterKey,
                child: _buildLetterboxdPoster(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterboxdPoster(WatchedItem item) {
    // 60% poster, 40% cream background with metadata
    return Container(
      width: 1080,
      height: 1920,
      color: const Color(0xFFFFFDD0), // Cream / Off-white background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top 60% Image
          SizedBox(
            height: 1152, // 1920 * 0.6
            width: double.infinity,
            child: item.posterPath != null && item.posterPath!.isNotEmpty
                ? Image.file(
                    File(item.posterPath!),
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.black87),
          ),
          
          // Bottom 40% Metadata
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      _buildPosterBadge(item.category.toUpperCase(), true),
                      const SizedBox(width: 16),
                      ...item.genre.split(',').map((g) {
                        if (g.trim().isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildPosterBadge(g.trim().toUpperCase(), false),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (item.category == 'Series' && (item.season != null || item.episode != null)) ...[
                    Text(
                      [
                        if (item.season != null) 'SEASON ${item.season}',
                        if (item.episode != null) 'EPISODE ${item.episode}'
                      ].join('  •  '),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  if (item.rating != null) ...[
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final rating5 = item.rating! / 2;
                          if (index < rating5.floor()) {
                            return const Icon(Icons.star, color: Colors.black, size: 48);
                          } else if (index < rating5.ceil() && rating5 % 1 > 0) {
                            return const Icon(Icons.star_half, color: Colors.black, size: 48);
                          }
                          return const Icon(Icons.star_outline, color: Colors.black26, size: 48);
                        }),
                        const SizedBox(width: 20),
                        Text(
                          item.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],

                  if (item.synopsis != null && item.synopsis!.isNotEmpty) ...[
                    Text(
                      'SYNOPSIS',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black45,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.synopsis!,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 40),
                  ],

                  if (item.review != null && item.review!.isNotEmpty) ...[
                    Text(
                      'REVIEW',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black45,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        '"${item.review!}"',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterBadge(String text, bool isCategory) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isCategory ? Colors.black : Colors.black12,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 24,
          fontWeight: isCategory ? FontWeight.w700 : FontWeight.w600,
          color: isCategory ? Colors.white : Colors.black87,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeroSection(WatchedItem item, double screenWidth) {
    return SizedBox(
      height: 320,
      width: screenWidth,
      child: Stack(
        children: [
          // Poster image or gradient placeholder
          Positioned.fill(
            child: Hero(
              tag: 'poster_${item.id}',
              child: item.posterPath != null && item.posterPath!.isNotEmpty
                  ? Image.file(
                      File(item.posterPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => _heroPlaceholder(item),
                    )
                  : _heroPlaceholder(item),
            ),
          ),
          // Bottom fade to background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPlaceholder(WatchedItem item) {
    final hash = item.title.hashCode;
    final hue = (hash % 360).abs().toDouble();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSLColor.fromAHSL(1.0, hue, 0.15, 0.25).toColor(),
            HSLColor.fromAHSL(1.0, hue, 0.10, 0.10).toColor(),
            AppColors.background,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: Colors.white.withValues(alpha: 0.08),
          size: 80,
        ),
      ),
    );
  }

  Widget _buildBadges(WatchedItem item) {
    final genres = item.genre.split(',').map((e) => e.trim()).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            item.category.toUpperCase(),
            style: AppTypography.small.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Multiple Genre tags
        ...genres.map((g) {
          if (g.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              g.toUpperCase(),
              style: AppTypography.small.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRatingRow(WatchedItem item) {
    final rating10 = item.rating ?? 0;
    final rating5 = rating10 / 2;

    return Row(
      children: [
        ...List.generate(5, (index) {
          if (index < rating5.floor()) {
            return const Padding(
              padding: EdgeInsets.only(right: 3),
              child: Icon(Icons.star, color: AppColors.starFilled, size: 18),
            );
          } else if (index < rating5.ceil() && rating5 % 1 > 0) {
            return const Padding(
              padding: EdgeInsets.only(right: 3),
              child: Icon(Icons.star_half, color: AppColors.starFilled, size: 18),
            );
          }
          return const Padding(
            padding: EdgeInsets.only(right: 3),
            child: Icon(Icons.star_outline, color: AppColors.starEmpty, size: 18),
          );
        }),
        const SizedBox(width: 8),
        Text(
          rating10.toStringAsFixed(1),
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonEpisodeInfo(WatchedItem item) {
    return Row(
      children: [
        if (item.season != null) ...[
          Text(
            '${item.season} Season',
            style: AppTypography.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 1,
              height: 14,
              color: AppColors.border,
            ),
          ),
        ],
        if (item.episode != null)
          Text(
            '${item.episode} Episode',
            style: AppTypography.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
