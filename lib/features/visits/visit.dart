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

class Visit {
  const Visit({
    this.id,
    this.petId,
    required this.date,
    required this.description,
  });

  final int? id;
  final int? petId;
  final String date;
  final String description;

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as int?,
      petId: json['petId'] as int?,
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toWriteJson() {
    return {'date': date, 'description': description};
  }
}
