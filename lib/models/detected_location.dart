class LocationModel {
  String name;
  String photo;

  LocationModel({
    required this.name,
    required this.photo,
  });

  static List<LocationModel> getlocations() {
    List<LocationModel> locations = [];

    locations.add(LocationModel(
      name: 'Rafi',
      photo: 'assets/photos/rafi_crop.jpg',
    ));

    locations.add(LocationModel(name: 'Alex', photo: 'assets/photos/alex.jpg'));

    locations.add(LocationModel(
      name: 'Kevin',
      photo: 'assets/photos/kevin.png',
    ));

    locations.add(LocationModel(
      name: 'Veri',
      photo: 'assets/photos/ferry.png',
    ));

    locations.add(LocationModel(
      name: 'Yuna',
      photo:
          'assets/photos/Little-Girl-Eating-Lick-oral-hygiene-Calamvale-dental.jpg',
    ));

    locations.add(LocationModel(
      name: 'Acel',
      photo: 'assets/photos/acel3.jpeg',
    ));

    locations.add(LocationModel(
      name: 'Nami',
      photo: 'assets/photos/nami.png',
    ));

    locations.add(LocationModel(
      name: 'Mawar',
      photo: 'assets/photos/mawar2.png',
    ));

    return locations;
  }
}
