// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:financy_ui/features/Users/Cubit/userState.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/colors.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  final UserModel? user;
  const UserProfileScreen({super.key, this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditing = false;
  
  // Controllers cho các trường thông tin
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Thông tin người dùng mẫu
  final String _avatarPath = '';
  DateTime _selectedBirthDate = DateTime(1990, 1, 1);
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Load data from UserModel if available, otherwise use default data
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _selectedBirthDate = widget.user!.dateOfBirth;
    } else {
      // Default data
      _nameController.text = 'Nguyễn Văn A';
      _emailController.text = 'nguyenvana@email.com';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context);
    
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state.status == UserStatus.success && state.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations?.profileUpdateSuccess ?? 'Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == UserStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEditing 
              ? localizations?.edit ?? 'Edit'
              : localizations?.personalInformation ?? 'Personal Information',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.primaryBlue),
                onPressed: _toggleEditMode,
              ),
          ],
        ),
        body: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state.status == UserStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 24),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 16),
                  _buildContactInfoSection(),
                  if (_isEditing) ...[
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 3),
            ),
            child: ClipOval(
              child: _avatarPath.isNotEmpty
                  ? Image.file(
                      File(_avatarPath),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    final localizations = AppLocalizations.of(context);
    return _buildSection(
      title: localizations?.personalInformation ?? 'Personal Information',
      children: [
        _buildInfoField(
          label: localizations?.fullName ?? 'Full Name',
          controller: _nameController,
          icon: Icons.person,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildBirthDateField(),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    final localizations = AppLocalizations.of(context);
    return _buildSection(
      title: localizations?.contactInformation ?? 'Contact Information',
      children: [
        _buildInfoField(
          label: localizations?.email ?? 'Email',
          controller: _emailController,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: AppColors.negativeRed),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _isEditing,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: textTheme.bodyLarge?.copyWith(
            color: _isEditing ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.7),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: _isEditing ? AppColors.primaryBlue : colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            filled: true,
            fillColor: _isEditing ? colorScheme.surface : colorScheme.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.dateOfBirth ?? 'Date of Birth',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isEditing ? _selectBirthDate : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
              color: _isEditing ? colorScheme.surface : colorScheme.surfaceVariant,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _isEditing ? AppColors.primaryBlue : colorScheme.onSurface.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedBirthDate.day}/${_selectedBirthDate.month}/${_selectedBirthDate.year}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: _isEditing ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context);
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEdit,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.outline),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              localizations?.cancel ?? 'Cancel',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              localizations?.save ?? 'Save',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadUserData(); // Reload original data
  }

  void _saveProfile() async {
    final localizations = AppLocalizations.of(context);
    
    // Validate email format
    if (_emailController.text.trim().isNotEmpty && !_isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.invalidEmailFormat ?? 'Invalid email format'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update user via Cubit
    await context.read<UserCubit>().updateUser(UserModel(
      id: widget.user?.id ?? '',
      uid: widget.user?.uid ?? '',
      picture: _avatarPath.isNotEmpty ? _avatarPath : widget.user?.picture ?? '',
      createdAt: widget.user?.createdAt ?? DateTime.now(),
      name: _nameController.text,
      email: _emailController.text,
      dateOfBirth: _selectedBirthDate,
    ));
    
    setState(() {
      _isEditing = false;
    });
  }

  void _pickImage() async {
    final localizations = AppLocalizations.of(context);
    // Simulate image picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations?.imagePickerFeatureComingSoon ?? 'Image picker feature will be added later'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}