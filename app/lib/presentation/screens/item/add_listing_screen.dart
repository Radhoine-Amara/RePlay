// FILE: lib/screens/add_listing_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/datasources/item_service.dart';
import '../../../data/datasources/auth_service.dart';
import '../../../data/datasources/user_service.dart';
import '../../../data/datasources/supabase_service.dart';
import '../../../data/models/item_model.dart';
import '../home/home_screen.dart';

class AddListingScreen extends StatefulWidget {
  final Function(ItemModel)
  onItemCreated; // callback to parent when item created
  final bool redirectToHome; // when true, navigate to HomeScreen after creation

  const AddListingScreen({
    super.key,
    required this.onItemCreated,
    this.redirectToHome = false,
  });

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  String _selectedType = 'sell';
  String _selectedCategory = 'Games';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _platformController = TextEditingController();

  bool _isSubmitting = false;

  // Image handling
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _useUrlInput = false; // false = use device storage, true = use URL input

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _platformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Add Listing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Image Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9C4DFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Product Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Toggle between URL and Storage
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _useUrlInput = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: !_useUrlInput
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Upload',
                                style: TextStyle(
                                  color: !_useUrlInput
                                      ? const Color(0xFF9C4DFF)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _useUrlInput = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _useUrlInput
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(20),
                                ),
                              ),
                              child: Text(
                                'URL',
                                style: TextStyle(
                                  color: _useUrlInput
                                      ? const Color(0xFF9C4DFF)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_useUrlInput)
                    // URL Input
                    TextFormField(
                      controller: _imageUrlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'https://example.com/image.jpg',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.link, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                      ),
                    )
                  else
                    // Upload from device
                    Column(
                      children: [
                        if (_selectedImage != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to add image',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton.icon(
                              onPressed: _showImagePickerOptions,
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text(
                                'Change Image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Item Details Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title Field
                  const Text(
                    'Title',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g., God of War Ragnarök (PS5)',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          'Describe your item, including condition, version, and any extras.',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Platform Field (optional)
                  const Text(
                    'Platform (optional)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _platformController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g., PS5, Xbox, Nintendo Switch',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Games', child: Text('Games')),
                        DropdownMenuItem(
                          value: 'Consoles',
                          child: Text('Consoles'),
                        ),
                        DropdownMenuItem(
                          value: 'Accessories',
                          child: Text('Accessories'),
                        ),
                        DropdownMenuItem(
                          value: 'Electronics',
                          child: Text('Electronics'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Listing Type Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Listing Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildTypeButton('Rent', 'rent'),
                        _buildTypeButton('Trade', 'trade'),
                        _buildTypeButton('Sell', 'sell'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Price Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_selectedType == 'trade')
                        const Text(
                          ' (Not required for trade)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    enabled: _selectedType != 'trade',
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _selectedType == 'rent'
                          ? 'e.g. 10 (per day)'
                          : 'e.g. 500',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _selectedType == 'trade'
                          ? Colors.grey[800]
                          : Colors.black,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Submit Listing Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C4DFF),
                  disabledBackgroundColor: const Color(
                    0xFF9C4DFF,
                  ).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Listing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String text, String value) {
    bool isSelected = _selectedType == value;
    return Expanded(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9C4DFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              _selectedType = value;
              // Clear price if trade is selected
              if (value == 'trade') {
                _priceController.clear();
              }
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF9C4DFF),
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF9C4DFF)),
                title: const Text(
                  'Camera',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnackbar('Failed to pick image: ${e.toString()}', isError: true);
    }
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final fileName = 'item_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'items/$fileName';

      await SupabaseService.client.storage
          .from('item-images')
          .upload(filePath, imageFile);

      final publicUrl = SupabaseService.client.storage
          .from('item-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitListing() async {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      _showSnackbar('Please enter a title', isError: true);
      return;
    }

    if (_selectedType != 'trade' && _priceController.text.trim().isEmpty) {
      _showSnackbar('Please enter a price', isError: true);
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showSnackbar('Please enter a description', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get current user ID from auth
      final authUser = _authService.getCurrentUser();
      if (authUser == null || authUser.email == null) {
        _showSnackbar(
          'You must be logged in to create a listing',
          isError: true,
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // Get the database user ID from the users table by email
      final dbUser = await _userService.getUserByEmail(authUser.email!);
      if (dbUser == null || dbUser.userId == null) {
        _showSnackbar('User not found in database', isError: true);
        setState(() => _isSubmitting = false);
        return;
      }
      final userId = dbUser.userId!;

      // Parse price
      int? price;
      if (_selectedType != 'trade') {
        price = int.tryParse(_priceController.text.trim());
        if (price == null) {
          _showSnackbar('Please enter a valid price', isError: true);
          setState(() => _isSubmitting = false);
          return;
        }
      }

      // Handle image URL - either from upload or direct URL input
      String? finalImageUrl;
      if (_useUrlInput) {
        // Using URL input
        finalImageUrl = _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim();
      } else if (_selectedImage != null) {
        // Upload image to Supabase storage
        finalImageUrl = await _uploadImageToSupabase(_selectedImage!);
        if (finalImageUrl == null) {
          _showSnackbar(
            'Failed to upload image. Please try again.',
            isError: true,
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }

      // Build ItemModel
      final newItem = ItemModel(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        type: _selectedType,
        price: price,
        userId: userId,
        status: true,
        imageUrl: finalImageUrl,
        platform: _platformController.text.trim().isEmpty
            ? null
            : _platformController.text.trim(),
      );

      // Call service to create item
      final created = await _itemService.createItem(newItem);

      if (created != null) {
        // Inform parent via callback so embedded usages (like HomeScreen tab)
        // can update their lists immediately.
        try {
          widget.onItemCreated(created);
        } catch (_) {}

        _showSnackbar('Listing created successfully!', isError: false);

        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _imageUrlController.clear();
        _platformController.clear();
        setState(() {
          _selectedImage = null;
          _useUrlInput = false;
        });

        // Navigate appropriately after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          if (widget.redirectToHome) {
            // If requested, navigate to HomeScreen and clear stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          } else {
            // If this screen was presented as a route, pop it returning the created item.
            // If it's embedded (e.g., used as a tab), the parent callback will handle UI changes
            if (Navigator.canPop(context)) {
              Navigator.pop(context, created);
            }
          }
        }
      } else {
        _showSnackbar(
          'Failed to create listing. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
