class DataModel {
  String title;
  String location;
  String contact;
  String major;
  String description;

  DataModel({
    this.title,
    this.location,
    this.contact,
    this.major,
    this.description,
  });

  DataModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    location = json['location'];
    contact = json['contact'];
    major = json['major'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_no'] = this.title;
    data['account_nickname'] = this.location;
    data['contact'] = this.contact;
    data['major'] = this.major;
    data['description'] = this.description;
    return data;
  }
}

enum Agency {
  education,
  agriculture_and_biological_sciences,
  humanities_and_social_sciences,
  science,
  management,
  graduate_school,
  college_of_complementary_medicine
}
