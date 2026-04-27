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

class AppRoutes {
  static const home = '/';
  static const owners = '/owners';
  static const veterinarians = '/vets';
  static const petTypes = '/pet-types';
  static const specialties = '/specialties';
  static const ownerNew = '/owners/new';
  static const vetNew = '/vets/new';
  static const petTypeNew = '/pet-types/new';
  static const specialtyNew = '/specialties/new';

  static String owner(int ownerId) => '/owners/$ownerId';
  static String ownerEdit(int ownerId) => '/owners/$ownerId/edit';
  static String ownerPetNew(int ownerId) => '/owners/$ownerId/pets/new';

  static String petEdit(int petId) => '/pets/$petId/edit';
  static String petVisitNew(int petId) => '/pets/$petId/visits/new';

  static String visitEdit(int visitId) => '/visits/$visitId/edit';
  static String vetEdit(int vetId) => '/vets/$vetId/edit';
  static String petTypeEdit(int petTypeId) => '/pet-types/$petTypeId/edit';
  static String specialtyEdit(int specialtyId) =>
      '/specialties/$specialtyId/edit';
}
