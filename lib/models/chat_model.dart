class ChatModel {
  String name;
  String photo;
  String lastChat;

  ChatModel({
    required this.name,
    required this.photo,
    required this.lastChat,
  });

  static List<ChatModel> getChats() {
    List<ChatModel> chats = [];

    chats.add(ChatModel(
        name: 'Rafi',
        photo: 'assets/photos/rafi_crop.jpg',
        lastChat: 'Hallo!'));

    chats.add(ChatModel(
        name: 'Alex', photo: 'assets/photos/alex.jpg', lastChat: 'Mabar!!'));

    chats.add(ChatModel(
        name: 'Kevin',
        photo: 'assets/photos/kevin.png',
        lastChat: 'Bola gak nih?'));

    chats.add(ChatModel(
        name: 'Veri',
        photo: 'assets/photos/ferry.png',
        lastChat: 'film ni seru banget'));

    chats.add(ChatModel(
        name: 'Yuna',
        photo:
            'assets/photos/Little-Girl-Eating-Lick-oral-hygiene-Calamvale-dental.jpg',
        lastChat: 'Apaan sih'));

    chats.add(ChatModel(
        name: 'Acel',
        photo: 'assets/photos/acel3.jpeg',
        lastChat: 'mabar ml gak sih'));

    chats.add(ChatModel(
        name: 'Nami', photo: 'assets/photos/nami.png', lastChat: 'Otakaraa!'));

    chats.add(ChatModel(
        name: 'Mawar',
        photo: 'assets/photos/mawar2.png',
        lastChat: 'Senjouu!'));

    return chats;
  }
}
