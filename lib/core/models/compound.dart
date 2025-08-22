/// Data model for chemical compound information from PubChem API
class Compound {
  /// Compound identifier (CID)
  final int cid;
  
  /// Compound title/name
  final String title;
  
  /// Molecular formula
  final String? molecularFormula;
  
  /// Molecular weight
  final String? molecularWeight;
  
  /// IUPAC name
  final String? iupacName;
  
  /// CAS registry number
  final String? casNumber;
  
  /// List of synonyms
  final List<String> synonyms;
  
  /// Compound description
  final String? description;

  
  /// Hazard information
  final List<String> hazards;
  
  /// Timestamp when data was fetched
  final DateTime fetchedAt;
  
  /// Constructor
  const Compound({
    required this.cid,
    required this.title,
    this.molecularFormula,
    this.molecularWeight,
    this.iupacName,
    this.casNumber,
    this.synonyms = const [],
    this.description,
    this.hazards = const [],
    required this.fetchedAt,
  });
  
  /// Create compound from JSON
  factory Compound.fromJson(Map<String, dynamic> json) {
    return Compound(
      cid: json['cid'] as int,
      title: json['title'] as String,
      molecularFormula: json['molecular_formula'] as String?,
      molecularWeight: (json['molecular_weight'] as String?),
      iupacName: json['iupac_name'] as String?,
      casNumber: json['cas_number'] as String?,
      synonyms: (json['synonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      description: json['description'] as String?,
      hazards: (json['hazards'] as List<dynamic>?)?.cast<String>() ?? [],
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
    );
  }
  
  /// Convert compound to JSON
  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'title': title,
      'molecular_formula': molecularFormula,
      'molecular_weight': molecularWeight,
      'iupac_name': iupacName,
      'cas_number': casNumber,
      'synonyms': synonyms,
      'description': description,
      'hazards': hazards,
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }
  
  /// Create a copy with updated fields
  Compound copyWith({
    int? cid,
    String? title,
    String? molecularFormula,
    String? molecularWeight,
    String? iupacName,
    String? casNumber,
    List<String>? synonyms,
    String? description,
    List<String>? hazards,
    DateTime? fetchedAt,
  }) {
    return Compound(
      cid: cid ?? this.cid,
      title: title ?? this.title,
      molecularFormula: molecularFormula ?? this.molecularFormula,
      molecularWeight: molecularWeight ?? this.molecularWeight,
      iupacName: iupacName ?? this.iupacName,
      casNumber: casNumber ?? this.casNumber,
      synonyms: synonyms ?? this.synonyms,
      description: description ?? this.description,
      hazards: hazards ?? this.hazards,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
  
  /// Check if compound has hazard warnings
  bool get hasHazards => hazards.isNotEmpty;
  
  /// Get display name (title or IUPAC name)
  String get displayName => title.isNotEmpty ? title : (iupacName ?? 'Unknown Compound');
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Compound && other.cid == cid;
  }
  
  @override
  int get hashCode => cid.hashCode;
  
  @override
  String toString() {
    return 'Compound(cid: $cid, title: $title, formula: $molecularFormula)';
  }
}