class IntentActionModel {
  final String id;
  final String buttonText;
  final String action;

  IntentActionModel({
    required this.id,
    required this.buttonText, 
    required this.action
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'buttonText': buttonText,
    'action': action,
  };

  factory IntentActionModel.fromJson(Map<String, dynamic> json) => 
      IntentActionModel(
        id: json['id'],
        buttonText: json['buttonText'],
        action: json['action'],
      );
}
