import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../domain/entity/user_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();

  DateTime? _selectedDate;
  String? _profilePicturePath;

  final _imagePicker = ImagePicker();

  /// Original values
  late String _initialUsername;
  late String _initialFullName;
  DateTime? _initialDob;
  String? _initialImage;

  bool _hasChanges = false;

  // ---------------- INIT ----------------

  @override
  void initState() {
    super.initState();
    _loadUser(widget.user);
  }

  void _loadUser(User user) {
    _usernameController.text = user.username;
    _fullNameController.text = user.fullName;
    _selectedDate = user.dateOfBirth;
    _profilePicturePath = user.profilePicturePath;

    _initialUsername = user.username;
    _initialFullName = user.fullName;
    _initialDob = user.dateOfBirth;
    _initialImage = user.profilePicturePath;

    _usernameController.addListener(_checkChanges);
    _fullNameController.addListener(_checkChanges);
  }

  // ---------------- CHANGE DETECTION ----------------

  void _checkChanges() {
    final changed =
        _usernameController.text != _initialUsername ||
        _fullNameController.text != _initialFullName ||
        _selectedDate != _initialDob ||
        _profilePicturePath != _initialImage;

    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  // ---------------- IMAGE PICKER ----------------

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (image != null) {
      setState(() {
        _profilePicturePath = image.path;
        _checkChanges();
      });
    }
  }

  // ---------------- DATE PICKER ----------------

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _checkChanges();
      });
    }
  }

  // ---------------- SAVE ----------------

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = widget.user.copyWith(
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      dateOfBirth: _selectedDate,
      profilePicturePath: _profilePicturePath,
    );

    context.read<AuthBloc>().add(AuthProfileUpdated(updatedUser));
  }

  // ---------------- BACK HANDLING ----------------

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('Discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),

        /// LISTEN to AuthBloc for updates & logout
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              /// refresh local state after save
              _loadUser(state.user);
              _hasChanges = false;
            }

            if (state is AuthUnauthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- PROFILE IMAGE ----------
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage: _profilePicturePath != null
                            ? FileImage(File(_profilePicturePath!))
                            : null,
                        child: _profilePicturePath == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  AppTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (v) =>
                        v == null || v.length < 3 ? 'Invalid username' : null,
                  ),

                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    validator: (v) =>
                        v == null || v.length < 2 ? 'Invalid name' : null,
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('MMM dd, yyyy')
                                .format(_selectedDate!)
                            : 'Select date',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;

                      return AppButton(
                        text: 'Save Changes',
                        isLoaderBtn: loading,
                        onPressed:
                            !_hasChanges || loading ? null : _saveProfile,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }
}
