/*
 * Copyright 2002-2017 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';

import '../../shared/forms/app_validators.dart';
import '../../shared/navigation/app_routes.dart';
import '../../shared/navigation/navigation_extensions.dart';
import '../../shared/widgets/page_width.dart';
import 'specialty.dart';
import 'specialty_service.dart';

class SpecialtyFormScreen extends StatefulWidget {
  const SpecialtyFormScreen({super.key, this.specialty, this.specialtyId})
    : assert(specialty == null || specialtyId == null);

  final Specialty? specialty;
  final int? specialtyId;

  @override
  State<SpecialtyFormScreen> createState() => _SpecialtyFormScreenState();
}

class _SpecialtyFormScreenState extends State<SpecialtyFormScreen> {
  final SpecialtyService _specialtyService = SpecialtyService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  Specialty? _loadedSpecialty;

  Specialty? get _currentSpecialty => widget.specialty ?? _loadedSpecialty;
  bool get _isEditing => widget.specialty != null || widget.specialtyId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.specialty?.name ?? '');
    if (widget.specialtyId != null) {
      _loadSpecialty();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialty() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final specialty = await _specialtyService.getSpecialty(
        widget.specialtyId!,
      );
      if (!mounted) return;

      setState(() {
        _loadedSpecialty = specialty;
        _nameController.text = specialty.name;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final currentSpecialty = _currentSpecialty;

    final specialty = Specialty(
      id: currentSpecialty?.id ?? widget.specialtyId,
      name: _nameController.text.trim(),
    );

    try {
      if (_isEditing) {
        await _specialtyService.updateSpecialty(specialty);
      } else {
        await _specialtyService.createSpecialty(specialty);
      }

      if (!mounted) {
        return;
      }
      context.popOrGo<bool>(AppRoutes.specialties, result: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Specialty' : 'New Specialty'),
      ),
      body: AppPageWidth(
        maxWidth: 720,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null &&
                  widget.specialtyId != null &&
                  _currentSpecialty == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadSpecialty,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_errorMessage != null) ...[
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_errorMessage!),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: AppValidators.plainText(
                            'Name',
                            minLength: 1,
                            maxLength: 80,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _save,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(_isEditing ? 'Update' : 'Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
