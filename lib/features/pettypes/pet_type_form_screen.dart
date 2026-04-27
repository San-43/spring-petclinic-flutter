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
import 'pet_type.dart';
import 'pet_type_service.dart';

class PetTypeFormScreen extends StatefulWidget {
  const PetTypeFormScreen({super.key, this.petType, this.petTypeId})
    : assert(petType == null || petTypeId == null);

  final PetType? petType;
  final int? petTypeId;

  @override
  State<PetTypeFormScreen> createState() => _PetTypeFormScreenState();
}

class _PetTypeFormScreenState extends State<PetTypeFormScreen> {
  final PetTypeService _petTypeService = PetTypeService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  PetType? _loadedPetType;

  PetType? get _currentPetType => widget.petType ?? _loadedPetType;
  bool get _isEditing => widget.petType != null || widget.petTypeId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.petType?.name ?? '');
    if (widget.petTypeId != null) {
      _loadPetType();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPetType() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final petType = await _petTypeService.getPetType(widget.petTypeId!);
      if (!mounted) return;

      setState(() {
        _loadedPetType = petType;
        _nameController.text = petType.name;
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

    final currentPetType = _currentPetType;

    final petType = PetType(
      id: currentPetType?.id ?? widget.petTypeId,
      name: _nameController.text.trim(),
    );

    try {
      if (_isEditing) {
        await _petTypeService.updatePetType(petType);
      } else {
        await _petTypeService.createPetType(petType);
      }

      if (!mounted) {
        return;
      }
      context.popOrGo<bool>(AppRoutes.petTypes, result: true);
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
        title: Text(_isEditing ? 'Edit Pet Type' : 'New Pet Type'),
      ),
      body: AppPageWidth(
        maxWidth: 720,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null &&
                  widget.petTypeId != null &&
                  _currentPetType == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadPetType,
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
