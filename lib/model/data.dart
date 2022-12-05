class AllData {
  String? title;
  String? description;
  String? location;
  String? date;
  List<String> images = [];

  AllData(
      {required this.title,
      required this.description,
      required this.location,
      required this.date,
      required this.images});

  factory AllData.fromJson(Map<String, dynamic> json) => AllData(
        title: json["title"],
        description: json["description"],
        location: json["location"],
        date: json["date"],
        images: List<String>.from(json["images"].map((x) => x)),
      );
  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "location": location,
        "date": date,
        "images": List<dynamic>.from(images.map((x) => x)),
      };
}
