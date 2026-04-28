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

import '../specialties/specialty.dart';

class Vet {
  const Vet({
    this.id,
    required this.firstName,
    required this.lastName,
    this.specialties = const [],
  });

  final int? id;
  final String firstName;
  final String lastName;
  final List<Specialty> specialties;

  String get fullName => '$firstName $lastName';

  factory Vet.fromJson(Map<String, dynamic> json) {
    return Vet(
      id: json['id'] as int?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      specialties: ((json['specialties'] as List<dynamic>?) ?? [])
          .map((item) => Specialty.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toWriteJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'specialties': specialties
          .map((specialty) => specialty.toJson())
          .toList(),
    };
  }
}
