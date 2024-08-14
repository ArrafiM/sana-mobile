class ImageModel {
  String name;
  String photo;
  String lastChat;

  ImageModel({
    required this.name,
    required this.photo,
    required this.lastChat,
  });

  static List<ImageModel> getImages() {
    List<ImageModel> chats = [];

    chats.add(ImageModel(
        name: 'Rafi',
        photo: 'assets/photos/rafi_crop.jpg',
        lastChat: 'Hallo!'));

    chats.add(ImageModel(
        name: 'Alex', photo: 'assets/photos/alex.jpg', 
    lastChat: 'Mabar!!'));

    chats.add(ImageModel(
        name: 'Kevin',
        photo: 'assets/photos/kevin.png',
        lastChat: 'Bola gak nih?'));

    chats.add(ImageModel(
        name: 'Veri',
        photo: 'assets/photos/ferry.png',
        lastChat: 'film ni seru banget'));

    chats.add(ImageModel(
        name: 'Yuna',
        photo:
            'assets/photos/Little-Girl-Eating-Lick-oral-hygiene-Calamvale-dental.jpg',
        lastChat: 'Apaan sih'));

    chats.add(ImageModel(
        name: 'Acel',
        photo: 'assets/photos/acel3.jpeg',
        lastChat: 'mabar ml gak sih'));

    chats.add(ImageModel(
        name: 'Nami', photo: 'assets/photos/nami.png', 
        lastChat: 'Otakaraa!'));

    chats.add(ImageModel(
        name: 'Mawar',
        photo: 'assets/photos/mawar2.png',
        lastChat: 'Senjouu!'));

    return chats;
  }
}
