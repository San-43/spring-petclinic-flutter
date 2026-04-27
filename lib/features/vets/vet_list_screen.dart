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
import 'vet.dart';
import 'vet_service.dart';

class VetListScreen extends StatefulWidget {
  const VetListScreen({super.key, this.vetService});

  final VetService? vetService;

  @override
  State<VetListScreen> createState() => _VetListScreenState();
}

class _VetListScreenState extends State<VetListScreen> {
  late final VetService _vetService = widget.vetService ?? VetService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Vet> _vets = const [];

  @override
  void initState() {
    super.initState();
    _loadVets();
  }

  Future<void> _loadVets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vets = await _vetService.listVets();
      if (!mounted) {
        return;
      }
      setState(() {
        _vets = vets;
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

  Future<void> _openForm({int? vetId}) async {
    final changed = await context.push<bool>(
      vetId == null ? AppRoutes.vetNew : AppRoutes.vetEdit(vetId),
    );
    if (changed == true) {
      await _loadVets();
    }
  }

  Future<void> _deleteVet(Vet vet) async {
    if (vet.id == null) {
      return;
    }

    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete veterinarian?',
      message: 'Delete ${vet.fullName}? This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) {
      return;
    }

    try {
      await _vetService.deleteVet(vet.id!);
      await _loadVets();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${vet.fullName} deleted.')));
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
      section: ClassicSection.veterinarians,
      title: 'Veterinarians',
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
              FilledButton(onPressed: _loadVets, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_vets.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          const Text('No veterinarians found.'),
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
                child: const Text('Add Vet'),
              ),
            ],
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVets,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < 780
                  ? 780.0
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Specialties')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: [
                      for (var index = 0; index < _vets.length; index++)
                        DataRow.byIndex(
                          index: index,
                          color: WidgetStatePropertyAll(
                            index.isEven
                                ? Colors.white
                                : const Color(0xFFF8F8F8),
                          ),
                          cells: [
                            DataCell(Text(_vets[index].fullName)),
                            DataCell(
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_vets[index].specialties.isEmpty)
                                    const Text('none')
                                  else
                                    for (final specialty
                                        in _vets[index].specialties)
                                      Text(specialty.name),
                                ],
                              ),
                            ),
                            DataCell(
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () =>
                                        _openForm(vetId: _vets[index].id),
                                    style: ClassicPalette.editButtonStyle(),
                                    child: const Text('Edit Vet'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _deleteVet(_vets[index]),
                                    style: ClassicPalette.deleteButtonStyle(),
                                    child: const Text('Delete Vet'),
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
                child: const Text('Add Vet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
