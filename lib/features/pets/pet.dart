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

import '../pettypes/pet_type.dart';
import '../visits/visit.dart';

class Pet {
  const Pet({
    this.id,
    this.ownerId,
    required this.name,
    required this.birthDate,
    required this.type,
    this.visits = const [],
  });

  final int? id;
  final int? ownerId;
  final String name;
  final String birthDate;
  final PetType type;
  final List<Visit> visits;

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int?,
      ownerId: json['ownerId'] as int?,
      name: json['name'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      type: PetType.fromJson(json['type'] as Map<String, dynamic>),
      visits: ((json['visits'] as List<dynamic>?) ?? [])
          .map((item) => Visit.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toWriteJson() {
    return {'name': name, 'birthDate': birthDate, 'type': type.toJson()};
  }
}
