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
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:spring_petclinic_flutter/features/owners/owner_detail_screen.dart';
import 'package:spring_petclinic_flutter/features/owners/owner_form_screen.dart';
import 'package:spring_petclinic_flutter/features/pettypes/pet_type_form_screen.dart';
import 'package:spring_petclinic_flutter/features/specialties/specialty_form_screen.dart';
import 'package:spring_petclinic_flutter/features/vets/vet_form_screen.dart';

import 'features/home/home_screen.dart';
import 'features/owners/owner_list_screen.dart';
import 'features/pets/pet_form_screen.dart';
import 'features/pettypes/pet_type_list_screen.dart';
import 'features/specialties/specialty_list_screen.dart';
import 'features/vets/vet_list_screen.dart';
import 'features/visits/visit_form_screen.dart';
import 'shared/navigation/app_routes.dart';
import 'shared/theme/classic_theme.dart';

void main() {
  usePathUrlStrategy();
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
      GoRoute(
        path: AppRoutes.ownerNew,
        builder: (context, state) => const OwnerFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.vetNew,
        builder: (context, state) => const VetFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.petTypeNew,
        builder: (context, state) => const PetTypeFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.specialtyNew,
        builder: (context, state) => const SpecialtyFormScreen(),
      ),
      GoRoute(
        path: '/owners/:ownerId',
        builder: (context, state) {
          final ownerId = int.parse(state.pathParameters['ownerId']!);
          return OwnerDetailScreen(ownerId: ownerId);
        },
      ),
      GoRoute(
        path: '/owners/:ownerId/edit',
        builder: (context, state) {
          final ownerId = int.parse(state.pathParameters['ownerId']!);
          return OwnerFormScreen(ownerId: ownerId);
        },
      ),
      GoRoute(
        path: '/owners/:ownerId/pets/new',
        builder: (context, state) {
          final ownerId = int.parse(state.pathParameters['ownerId']!);
          return PetFormScreen(ownerId: ownerId);
        },
      ),
      GoRoute(
        path: '/pets/:petId/edit',
        builder: (context, state) {
          final petId = int.parse(state.pathParameters['petId']!);
          return PetFormScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/pets/:petId/visits/new',
        builder: (context, state) {
          final petId = int.parse(state.pathParameters['petId']!);
          return VisitFormScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/visits/:visitId/edit',
        builder: (context, state) {
          final visitId = int.parse(state.pathParameters['visitId']!);
          return VisitFormScreen(visitId: visitId);
        },
      ),
      GoRoute(
        path: '/vets/:vetId/edit',
        builder: (context, state) {
          final vetId = int.parse(state.pathParameters['vetId']!);
          return VetFormScreen(vetId: vetId);
        },
      ),
      GoRoute(
        path: '/pet-types/:petTypeId/edit',
        builder: (context, state) {
          final petTypeId = int.parse(state.pathParameters['petTypeId']!);
          return PetTypeFormScreen(petTypeId: petTypeId);
        },
      ),
      GoRoute(
        path: '/specialties/:specialtyId/edit',
        builder: (context, state) {
          final specialtyId = int.parse(state.pathParameters['specialtyId']!);
          return SpecialtyFormScreen(specialtyId: specialtyId);
        },
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
