import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/core/extensions/margin_extension.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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

  /// Original values (for unsaved change detection)
  late String _initialUsername;
  late String _initialFullName;
  DateTime? _initialDob;
  String? _initialImage;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final user = state.user;

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
  }

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

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _profilePicturePath = image.path;
        _checkChanges();
      });
    }
  }

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

  int _profileCompletion() {
    int completed = 0;
    if (_usernameController.text.isNotEmpty) completed++;
    if (_fullNameController.text.isNotEmpty) completed++;
    if (_selectedDate != null) completed++;
    if (_profilePicturePath != null) completed++;

    return ((completed / 4) * 100).round();
  }

  void _saveProfile() {
  if (!_formKey.currentState!.validate()) return;

  final state = context.read<AuthBloc>().state;
  if (state is! AuthAuthenticated) return;

  final currentUser = state.user;

  final updatedUser = currentUser.copyWith(
    username: _usernameController.text.trim(),
    fullName: _fullNameController.text.trim(),
    dateOfBirth: _selectedDate,
    profilePicturePath: _profilePicturePath,
  );

  context.read<AuthBloc>().add(
    AuthProfileUpdated(updatedUser),
  );
}

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Unsaved changes'),
            content:
                const Text('You have unsaved changes. Discard them?'),
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
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completion = _profileCompletion();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              setState(() {
                _hasChanges = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
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
                  /// Profile picture
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
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

                  16.hBox,

                  /// Completion indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profile completion: $completion%'),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: completion / 100),
                    ],
                  ),

                  24.hBox,

                  AppTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (v) =>
                        v == null || v.length < 3 ? 'Invalid username' : null,
                  ),

                  16.hBox,

                  AppTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    validator: (v) =>
                        v == null || v.length < 2 ? 'Invalid name' : null,
                  ),

                  16.hBox,

                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon:
                            Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('MMM dd, yyyy')
                                .format(_selectedDate!)
                            : 'Select date',
                      ),
                    ),
                  ),

                  32.hBox,

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
                      return AppButton(
                        text: 'Save Changes',
                        isLoaderBtn: loading,
                        onPressed: !_hasChanges || loading
                            ? null
                            : _saveProfile,
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
}
