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
import 'specialty.dart';
import 'specialty_service.dart';

class SpecialtyListScreen extends StatefulWidget {
  const SpecialtyListScreen({super.key});

  @override
  State<SpecialtyListScreen> createState() => _SpecialtyListScreenState();
}

class _SpecialtyListScreenState extends State<SpecialtyListScreen> {
  final SpecialtyService _specialtyService = SpecialtyService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Specialty> _specialties = const [];

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
  }

  Future<void> _loadSpecialties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final specialties = await _specialtyService.listSpecialties();
      if (!mounted) {
        return;
      }
      setState(() {
        _specialties = specialties;
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

  Future<void> _openForm({Specialty? specialty}) async {
    final changed = await context.push<bool>(
      specialty == null
          ? AppRoutes.specialtyNew
          : AppRoutes.specialtyEdit(specialty.id!),
    );
    if (changed == true) {
      await _loadSpecialties();
    }
  }

  Future<void> _deleteSpecialty(Specialty specialty) async {
    if (specialty.id == null) {
      return;
    }

    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete specialty?',
      message: 'Delete ${specialty.name}? This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) {
      return;
    }

    try {
      await _specialtyService.deleteSpecialty(specialty.id!);
      await _loadSpecialties();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${specialty.name} deleted.')));
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
      section: ClassicSection.specialties,
      title: 'Specialties',
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
                onPressed: _loadSpecialties,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_specialties.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          const Text('No specialties found.'),
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
      onRefresh: _loadSpecialties,
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
                      for (var index = 0; index < _specialties.length; index++)
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
                                  child: Text(_specialties[index].name),
                                ),
                              ),
                            ),
                            DataCell(
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _openForm(
                                      specialty: _specialties[index],
                                    ),
                                    style: ClassicPalette.editButtonStyle(),
                                    child: const Text('Edit'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () =>
                                        _deleteSpecialty(_specialties[index]),
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
