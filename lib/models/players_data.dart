import '../models/player.dart';

List<Player> getMockPlayers() {
  return [
    Player(id: '1', name: 'Tayip Birinci', team: 'FB', position: 'MID', rating: 85, imageUrl: 'https://api.superonbir.com/assets/playerCards/830645.jpg?v=20251203'),
    Player(id: '2', name: 'Marc Aosio', team: 'FB', position: 'FWD', rating: 90, imageUrl: 'https://api.superonbir.com/assets/playerCards/2823881.jpg?v=20251203'),
    Player(id: '3', name: 'Dummy GK', team: 'KOC', position: 'GK', rating: 88, imageUrl: 'https://api.superonbir.com/assets/playerCards/2821114.jpg?v=20251203'),
    // Qo'shimcha o'yinchilar qo'shing (saytdagi kabi 20+ ta)
    // Real uchun: http.get('https://api.efootball.com/players') dan oling
  ];
}