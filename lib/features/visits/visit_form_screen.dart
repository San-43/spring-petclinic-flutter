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
import '../../shared/utils/date_utils.dart';
import '../../shared/widgets/page_width.dart';
import '../owners/owner.dart';
import '../owners/owner_service.dart';
import '../pets/pet.dart';
import '../pets/pet_service.dart';
import 'visit.dart';
import 'visit_service.dart';

class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({super.key, this.petId, this.visitId})
    : assert(petId != null || visitId != null);

  final int? petId;
  final int? visitId;

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final VisitService _visitService = VisitService();
  final PetService _petService = PetService();
  final OwnerService _ownerService = OwnerService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  Owner? _owner;
  Pet? _pet;
  Visit? _visit;
  DateTime? _selectedDate;

  bool get _isEditing => widget.visitId != null;
  String get _fallbackRoute {
    final ownerId = _owner?.id;
    return ownerId == null ? AppRoutes.owners : AppRoutes.owner(ownerId);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isEditing) {
        final visit = await _visitService.getVisit(widget.visitId!);
        final pet = await _petService.getPet(visit.petId!);
        final owner = await _ownerService.getOwner(pet.ownerId!);

        if (!mounted) {
          return;
        }

        setState(() {
          _visit = visit;
          _pet = pet;
          _owner = owner;
          _selectedDate = parseApiDate(visit.date);
          _dateController.text = visit.date;
          _descriptionController.text = visit.description;
        });
      } else {
        final pet = await _petService.getPet(widget.petId!);
        final owner = await _ownerService.getOwner(pet.ownerId!);

        if (!mounted) {
          return;
        }

        setState(() {
          _pet = pet;
          _owner = owner;
        });
      }
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
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickVisitDate() async {
    final initialDate = _selectedDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = selected;
      _dateController.text = formatApiDate(selected);
    });
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

    final visit = Visit(
      id: _visit?.id,
      petId: _pet?.id,
      date: _dateController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    try {
      if (_isEditing) {
        await _visitService.updateVisit(visit);
      } else {
        await _visitService.createVisit(_owner!.id!, _pet!.id!, visit);
      }

      if (!mounted) {
        return;
      }
      context.popOrGo<bool>(_fallbackRoute, result: true);
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
    final pet = _pet;
    final owner = _owner;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Visit' : 'New Visit')),
      body: AppPageWidth(
        maxWidth: 720,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && pet == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadData,
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _VisitDetailRow(
                            label: 'Name',
                            value: pet?.name ?? '',
                          ),
                          _VisitDetailRow(
                            label: 'Birth Date',
                            value: pet?.birthDate ?? '',
                          ),
                          _VisitDetailRow(
                            label: 'Type',
                            value: pet?.type.name ?? '',
                          ),
                          _VisitDetailRow(
                            label: 'Owner',
                            value: owner?.fullName ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          onTap: _pickVisitDate,
                          validator: AppValidators.required('Date'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          validator: AppValidators.plainText(
                            'Description',
                            minLength: 1,
                            maxLength: 255,
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
                            label: Text(
                              _isEditing ? 'Update Visit' : 'Add Visit',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isEditing && (pet?.visits.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Previous Visits',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final visit in pet!.visits)
                      Card.outlined(
                        child: ListTile(
                          title: Text(visit.description),
                          subtitle: Text(visit.date),
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _VisitDetailRow extends StatelessWidget {
  const _VisitDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
