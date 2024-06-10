class AgentRequest {
  final int id;
  final String agentName;
  final String email;
  final String experience;
  final String contactNumber;
  final int userId;

  AgentRequest({
    required this.id,
    required this.agentName,
    required this.email,
    required this.experience,
    required this.contactNumber,
    required this.userId,
  });

  factory AgentRequest.fromJson(Map<String, dynamic> json) {
    return AgentRequest(
      id: json['id'],
      agentName: json['agent_name'],
      email: json['email'],
      experience: json['experience'],
      contactNumber: json['contact_number'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_name': agentName,
      'email': email,
      'experience': experience,
      'contact_number': contactNumber,
      'user_id': userId,
    };
  }
}
