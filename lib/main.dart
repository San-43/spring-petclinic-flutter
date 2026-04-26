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

import 'features/home/home_screen.dart';
import 'features/owners/owner_list_screen.dart';
import 'features/pettypes/pet_type_list_screen.dart';
import 'features/specialties/specialty_list_screen.dart';
import 'features/vets/vet_list_screen.dart';
import 'shared/navigation/app_routes.dart';
import 'shared/theme/classic_theme.dart';

void main() {
  runApp(const PetClinicApp());
}

class PetClinicApp extends StatelessWidget {
  const PetClinicApp({super.key});

  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.owners,
        builder: (context, state) => const OwnerListScreen(),
      ),
      GoRoute(
        path: AppRoutes.petTypes,
        builder: (context, state) => const PetTypeListScreen(),
      ),
      GoRoute(
        path: AppRoutes.veterinarians,
        builder: (context, state) => const VetListScreen(),
      ),
      GoRoute(
        path: AppRoutes.specialties,
        builder: (context, state) => const SpecialtyListScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spring Petclinic',
      debugShowCheckedModeBanner: false,
      theme: ClassicPalette.buildTheme(),
      routerConfig: _router,
    );
  }
}
