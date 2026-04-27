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
import 'package:go_router/go_router.dart';

import '../../shared/navigation/app_routes.dart';
import '../../shared/theme/classic_theme.dart';
import '../../shared/widgets/classic_scaffold.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import 'pet_type.dart';
import 'pet_type_service.dart';

class PetTypeListScreen extends StatefulWidget {
  const PetTypeListScreen({super.key});

  @override
  State<PetTypeListScreen> createState() => _PetTypeListScreenState();
}

class _PetTypeListScreenState extends State<PetTypeListScreen> {
  final PetTypeService _petTypeService = PetTypeService();

  bool _isLoading = true;
  String? _errorMessage;
  List<PetType> _petTypes = const [];

  @override
  void initState() {
    super.initState();
    _loadPetTypes();
  }

  Future<void> _loadPetTypes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final petTypes = await _petTypeService.listPetTypes();
      if (!mounted) {
        return;
      }
      setState(() {
        _petTypes = petTypes;
      });
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

  Future<void> _openForm({PetType? petType}) async {
    final changed = await context.push<bool>(
      petType == null
          ? AppRoutes.petTypeNew
          : AppRoutes.petTypeEdit(petType.id!),
    );
    if (changed == true) {
      await _loadPetTypes();
    }
  }

  Future<void> _deletePetType(PetType petType) async {
    if (petType.id == null) {
      return;
    }

    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete pet type?',
      message: 'Delete ${petType.name}? This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) {
      return;
    }

    try {
      await _petTypeService.deletePetType(petType.id!);
      await _loadPetTypes();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${petType.name} deleted.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClassicScaffold(
      section: ClassicSection.petTypes,
      title: 'Pet Types',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadPetTypes,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_petTypes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          const Text('No pet types found.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Home'),
              ),
              OutlinedButton(
                onPressed: () => _openForm(),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPetTypes,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < 620
                  ? 620.0
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: [
                      for (var index = 0; index < _petTypes.length; index++)
                        DataRow.byIndex(
                          index: index,
                          color: WidgetStatePropertyAll(
                            index.isEven
                                ? Colors.white
                                : const Color(0xFFF8F8F8),
                          ),
                          cells: [
                            DataCell(
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: ClassicPalette.border,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  child: Text(_petTypes[index].name),
                                ),
                              ),
                            ),
                            DataCell(
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () =>
                                        _openForm(petType: _petTypes[index]),
                                    style: ClassicPalette.editButtonStyle(),
                                    child: const Text('Edit'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () =>
                                        _deletePetType(_petTypes[index]),
                                    style: ClassicPalette.deleteButtonStyle(),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Home'),
              ),
              OutlinedButton(
                onPressed: () => _openForm(),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
