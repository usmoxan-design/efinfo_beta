// -----------------------------------------------------------------------------
// 1. DATA MODEL (Takomillashtirilgan)
// -----------------------------------------------------------------------------

import '../models/formationsmodel.dart';

enum Difficulty { easy, medium, hard }

// Ma'lumotlar
// Barcha formationlar ro'yxati
final List<Formation> allFormations = [
  // ---------------------------------------------------------------------------
  // 4 HIMOYAChI BILAN O'YNALADIGAN SXEMALAR
  // ---------------------------------------------------------------------------
  const Formation(
    name: "4-4-2",
    title: "Klassik 4-4-2 (Flat)",
    subtitle: "Muvozanatli himoya va qanot hujumlari",
    difficulty: Difficulty.easy,
    description:
        "4-4-2 - futbolning eng klassik sxemalaridan biri. Himoyada 4 nafar mustahkam chiziq, markazda 4 ta yarim himoyachi bilan raqib pressini oson ushlab turadi. Hujumda RMF/LMF qanotlardan cross beradi, ikki CF esa box ichida gol uradi. Quick Counter yoki Out Wide o'yin uslubiga mukammal mos. Possession bilan o'ynasangiz ham ishlaydi, chunki midfield to'la. raqib 4-2-3-1 yoki 4-3-3 ishlatganda ustunlik beradi, chunki markaz teng.",
    bestFor: "• Quick Counter va Out Wide uchun ideal (kanatlardan crosslar)\n"
        "• Boshlovchilar va o'rta darajadagilar uchun eng oson sxema\n"
        "• raqib pressiga chidamli (4 midfield)\n"
        "• Ikki kuchli CF bilan gol mashinasi\n"
        "• Division 2-1 da barqaror natija beradi\n"
        "• Long Ball Counter bilan ham yaxshi (CF lar targetman)",
    playerRecommendations: "• GK: Courtois, Alisson, Ederson (1-on-1 kuchli)\n"
        "• CB (ikkala): Destroyer yoki Build Up (Van Dijk, Saliba, Rúben Dias, Araujo)\n"
        "• LB/RB: Defensive Fullback yoki Balanced (Theo Hernández, Carvajal, Cancelo, Davies)\n"
        "• LMF/RMF: Prolific Winger yoki Roaming Flank (Vinícius Jr, Salah, Saka, Yamal, Doku) — cross va dribling kuchli\n"
        "• CMF (ikkala): Box-to-Box yoki Orchestrator (Valverde, Kimmich, Rice, Pedri, Bruno Fernandes)\n"
        "• CF (ikkala): Goal Poacher + Deep Lying Forward (Haaland + Kane, Mbappé + Lewandowski) — bitta target, bitta tez",
    positions: [
      [0.5, 0.94], // GK
      [0.12, 0.82], // LB
      [0.35, 0.82], // LCB
      [0.65, 0.82], // RCB
      [0.88, 0.82], // RB
      [0.12, 0.50], // LMF
      [0.38, 0.50], // LCM
      [0.62, 0.50], // RCM
      [0.88, 0.50], // RMF
      [0.38, 0.18], // LCF
      [0.62, 0.18], // RCF
    ],
    labels: [
      'GK',
      'LB',
      'LCB',
      'RCB',
      'RB',
      'LMF',
      'LCM',
      'RCM',
      'RMF',
      'LCF',
      'RCF'
    ],
    warning: "Diqqat:\n"
        "• Wingers (LMF/RMF) ni Prolific Winger qo'ying, aks holda qanotlar zaif!\n"
        "• CMF larni Box-to-Box oling, chunki midfield pressga duch keladi\n"
        "• raqib 4-2-2-2 ishlatganda qanotlarni yoping, markaz ochilmasin\n"
        "• CF juftligi muhim: bitta tez (Mbappé), bitta kuchli (Haaland)\n"
        "• Possession raqibga qarshi Deep Defensive Line qo'ying",
  ),
  const Formation(
    name: "4-3-3",
    title: "Hujumkor 4-3-3 (Wide)",
    subtitle: "Qanotlar va markaz hujumi bilan muvozanat",
    difficulty: Difficulty.medium,
    description:
        "4-3-3 - eng mashhur hujumkor sxemalardan biri. Himoyada 4 nafar mustahkam, markazda 3 ta CMF bilan raqibni nazorat qiladi. LWF/RWF qanotlardan dribling va cross qiladi, CF esa box ichida gol uradi. Possession, Quick Counter yoki Out Wide o'yin uslubiga juda mos. raqib 4-2-3-1 ishlatganda ustunlik beradi, chunki qanotlar ochiq va tez hujumlar. Midfield 3 kishi bo'lgani uchun pressga chidamli, lekin himoyada bo'sh joylar paydo bo'lishi mumkin.",
    bestFor: "• Possession va Out Wide uchun ideal (qanotlar orqali hujum)\n"
        "• Tez va texnik o'yinchilar bilan gol mashinasi\n"
        "• raqib 4-4-2 yoki 5-3-2 ga qarshi ustunlik\n"
        "• Division 1 va eChampions League da eng ko'p ishlatiladi\n"
        "• Quick Counter bilan qarshi hujumlar (Mbappé + Vinícius)\n"
        "• Long Ball bilan CF targetman qo'ysangiz yaxshi",
    playerRecommendations:
        "• GK: Neuer, Alisson, Maignan (tez chiqish va pas kuchli)\n"
        "• CB (ikkala): Build Up yoki Destroyer (Van Dijk, Rúben Dias, Saliba, Araujo)\n"
        "• LB/RB: Attacking Fullback (Theo Hernández, Alexander-Arnold, Cancelo, Davies) — hujumga chiqadi\n"
        "• CMF (uchala): Orchestrator (markaziy), Box-to-Box (ikkala tomon) (De Bruyne, Bellingham, Valverde, Rodri, Pedri)\n"
        "• LWF/RWF: Prolific Winger yoki Creative Playmaker (Vinícius Jr, Salah, Neymar, Yamal, Doku) — dribling va tezlik 90+\n"
        "• CF: Goal Poacher yoki Deep Lying Forward (Mbappé, Haaland, Lewandowski, Kane) — tez va kuchli",
    positions: [
      [0.5, 0.94], // GK
      [0.12, 0.82], // LB
      [0.35, 0.82], // LCB
      [0.65, 0.82], // RCB
      [0.88, 0.82], // RB
      [0.32, 0.50], // LCM
      [0.5, 0.68], // CDM (DMF level)
      [0.68, 0.50], // RCM
      [0.15, 0.18], // LWF
      [0.51, 0.18], // CF
      [0.85, 0.18], // RWF
    ],
    labels: [
      'GK',
      'LB',
      'LCB',
      'RCB',
      'RB',
      'LCM',
      'CDM',
      'RCM',
      'LWF',
      'CF',
      'RWF'
    ],
    warning: "Diqqat:\n"
        "• LB/RB ni Attacking qo'ysangiz himoya ochiladi, Defensive qo'ying\n"
        "• CMF markaziy Orchestrator bo'lsin, aks holda paslar uziladi\n"
        "• Qanotlar (LWF/RWF) ni dribling kuchli oling, cross zaif bo'lmasin\n"
        "• raqib 5-2-1-2 ishlatganda midfield zaiflashadi, pressni kamaytiring\n"
        "• Possession raqibga qarshi Deep Defensive Line ishlatmang",
  ),
  const Formation(
    name: "4-3-2-1",
    title: "Markaziy Hujumkor 4-3-2-1 (Christmas Tree)",
    subtitle: "Markazni to'liq nazorat qiluvchi meta sxema",
    difficulty: Difficulty.medium,
    description:
        "4-3-2-1 (yoki 4-3-2-1 Narrow) - markaziy hujumlar uchun mukammal sxema. Himoyada 4 nafar mustahkam chiziq, 3 ta CMF bilan midfieldni to'liq egallaydi. Ikki AMF (yoki SS) CF orqasida bo'lib, paslar va dribling orqali himoyani yorib o'tadi. Possession Game, Quick Counter yoki Long Ball Counter ga juda mos. raqibning qanot hujumlarini oson ushlab turadi, chunki markaz 6-7 kishi bilan to'la. eFootball 2025/2026 da Tier S sxema, ayniqsa Division 1 da mashhur.",
    bestFor:
        "• Possession Game uchun ideal (markaziy paslar va kombinatsiyalar)\n"
        "• Quick Counter va Long Counter bilan raqibni 'yirtish'\n"
        "• raqib 4-3-3 yoki 4-2-3-1 ga qarshi ustunlik (midfield dominant)\n"
        "• Ikki kuchli AMF bilan (De Bruyne + Bellingham) gol mashinasi\n"
        "• Division 1 va Tourlarda eng barqaror natija\n"
        "• raqib 5 himoyachiga qarshi markazdan bosim",
    playerRecommendations:
        "• GK: Courtois, Neuer, Alisson (1-on-1 va long pass kuchli)\n"
        "• CB (ikkala): Destroyer/Build Up (Van Dijk, Saliba, Rúben Dias, Araujo, Kim Min-jae)\n"
        "• LB/RB: Defensive Fullback yoki Balanced (Cancelo, Davies, Carvajal, Koundé) — himoyada qolishi shart\n"
        "• CMF (3 ta): Box-to-Box (chap/o'ng), Orchestrator (markaziy) (Rodri markaz, Valverde/Bellingham chap/o'ng, Kimmich, Pedri)\n"
        "• LMF/RMF (AMF pozitsiyasi): Hole Player yoki Creative Playmaker (De Bruyne, Bruno Fernandes, Musiala, Foden) — bo'sh joylarga kirib uradi\n"
        "• CF: Goal Poacher (Haaland, Mbappé, Kane, Lewandowski) — box ichida tugatuvchi",
    positions: [
      [0.5, 0.94], // GK
      [0.12, 0.82], // LB
      [0.35, 0.82], // LCB
      [0.65, 0.82], // RCB
      [0.88, 0.82], // RB
      [0.32, 0.50], // LCM
      [0.5, 0.50], // CCM
      [0.68, 0.50], // RCM
      [0.35, 0.35], // LAMF
      [0.65, 0.35], // RAMF
      [0.5, 0.15], // CF
    ],
    labels: [
      'GK',
      'LB',
      'LCB',
      'RCB',
      'RB',
      'LCM',
      'CCM',
      'RCM',
      'LAMF',
      'RAMF',
      'CF'
    ],
    warning: "Diqqat:\n"
        "• Qanotlar zaif — LB/RB ni Defensive qo'ying, Attacking qo'ymaslik!\n"
        "• AMF larni Hole Player/Creative Playmaker qiling, ular bo'sh zonaga kiradi\n"
        "• Markaziy CMF Orchestrator bo'lsin (pas master), aks holda hujum tiqilib qoladi\n"
        "• raqib Out Wide o'ynasa, CMF larni Box-to-Box qilib press qiling\n"
        "• CF ni Goal Poacher qo'ymasangiz, gol urish qiyinlashadi",
  ),
  const Formation(
    name: "4-3-1-2",
    title: "Markaziy Meta 4-3-1-2 (Diamond)",
    subtitle: "Midfield dominant va ikki CF bilan gol mashinasi",
    difficulty: Difficulty.medium,
    description:
        "4-3-1-2 - eFootball 2025/2026 da Tier 1 meta sxemalardan biri. Himoyada 4 nafar mustahkam, 3 CMF + 1 AMF bilan markazni to'liq nazorat qiladi. Ikki CF box ichida gol uradi, AMF esa paslar va dribling bilan hujumni boshqaradi. Possession, Quick Counter yoki Long Ball Counter ga mukammal. DMF + 2 CMF raqib pressini ushlab turadi, qanotlar zaif bo'lsa ham fullbacklar yordam beradi. Division 1 da eng ko'p ishlatiladi, raqib 4-2-2-2 yoki 4-3-3 ga qarshi ustun.",
    bestFor: "• Quick Counter va Possession uchun ideal (markaziy hujumlar)\n"
        "• Midfield dominant — raqibni markazda 'bo'g'ib' qo'yadi\n"
        "• Ikki tez CF bilan qarshi hujumlar o'limli\n"
        "• raqib 4-2-3-1 yoki 4-3-3 ga qarshi ustunlik\n"
        "• Division 1 va Tourlarda barqaror (80%+ win rate)\n"
        "• Long Ball Counter bilan target CF + poacher juftligi",
    playerRecommendations:
        "• GK: Courtois, Neuer, Donnarumma (long pass va 1-on-1 kuchli)\n"
        "• CB (ikkala): Destroyer/Build Up (Van Dijk, Saliba, Araujo, Rúben Dias)\n"
        "• LB/RB: Attacking Fullback (Theo Hernández, Davies, Carvajal, Frimpong) — qanotlarga yordam\n"
        "• DMF: Anchorman deep line (Rodri, Tchouaméni, Zakaria, Rice) — himoyani qoplaydi\n"
        "• CMF (ikkala): Box-to-Box/Orchestrator (Valverde, Bellingham, Kimmich, Pedri) — press va pas\n"
        "• AMF: Creative Playmaker/Hole Player (De Bruyne, Bruno Fernandes, Musiala, Nedved) — hujum boshlovchi\n"
        "• CF (ikkala): Goal Poacher + Deep Lying Forward (Haaland + Mbappé, Kane + Lewandowski) — bitta tez, bitta kuchli",
    positions: [
      [0.5, 0.94], // GK
      [0.12, 0.82], // LB
      [0.35, 0.82], // LCB
      [0.65, 0.82], // RCB
      [0.88, 0.82], // RB
      [0.32, 0.50], // LCM
      [0.5, 0.68], // CDM (DMF)
      [0.68, 0.50], // RCM
      [0.5, 0.35], // AMF
      [0.35, 0.15], // LCF
      [0.65, 0.15], // RCF
    ],
    labels: [
      'GK',
      'LB',
      'LCB',
      'RCB',
      'RB',
      'LCM',
      'CCM',
      'RCM',
      'AMF',
      'LCF',
      'RCF'
    ],
    warning: "Diqqat:\n"
        "• Qanotlar zaif — LB/RB ni Attacking qo'ying, lekin Defensive ham sinang\n"
        "• AMF Creative Playmaker/Hole Player bo'lsin, pas va gol muhim\n"
        "• DMF Anchorman deep line qo'ying, aks holda markaz ochiladi\n"
        "• raqib wide o'ynasa (4-3-3), CMF larni Box-to-Box qilib press qiling\n"
        "• CF juftligi: Goal Poacher + DLF — bitta box ichida, bitta link-up",
  ),

  const Formation(
    name: "4-2-3-1",
    title: "Muvozanatli 4-2-3-1 (Narrow/Wide)",
    subtitle: "Himoyada mustahkam, hujumda ijodkor meta sxema",
    difficulty: Difficulty.medium,
    description:
        "4-2-3-1 - eFootball 2025/2026 da eng muvozanatli sxemalardan biri. Himoyada 4 nafar + 2 CDM bilan raqibni oson ushlab turadi. 3 AMF (LMF/RMF/CAM) bilan qanot va markazdan hujum qiladi, CF esa yakka holda gol uradi. Possession, Quick Counter yoki Out Wide ga mukammal mos. Ikki CDM markazni 'qulaydi', CAM esa hujumni boshqaradi. raqib 4-3-3 yoki 4-4-2 ga qarshi ustun, chunki midfield dominant.",
    bestFor:
        "• Possession va Quick Counter uchun ideal (markaziy nazorat + qanotlar)\n"
        "• Ikki CDM bilan pressga chidamli himoya\n"
        "• raqib 4-3-3 yoki 4-4-2 ga qarshi ustunlik\n"
        "• CAM orqali kreativ paslar va gollar\n"
        "• Division 1 da barqaror natija (safe option)\n"
        "• Long Ball Counter bilan CF targetman qo'ysangiz kuchli",
    playerRecommendations:
        "• GK: Courtois, Neuer, Alisson (1-on-1 va long pass kuchli)\n"
        "• CB (ikkala): Destroyer/Build Up (Van Dijk, Saliba, Rúben Dias, Araujo)\n"
        "• LB/RB: Balanced/Defensive Fullback (Theo Hernández, Davies, Carvajal, Cancelo) — qanotlarga yordam\n"
        "• CDM (ikkala): Anchorman + Box-to-Box/Orchestrator (Rodri + Valverde, Tchouaméni + Rice, Casemiro)\n"
        "• LMF/RMF: Prolific Winger/Roaming Flank (Vinícius Jr, Salah, Saka, Yamal, Doku) — dribling va cross\n"
        "• CAM: Creative Playmaker/Hole Player (De Bruyne, Bruno Fernandes, Musiala, Bellingham) — hujum boshlovchi\n"
        "• CF: Goal Poacher/Deep Lying Forward (Haaland, Mbappé, Kane, Lewandowski) — box ichida tugatuvchi",
    positions: [
      [0.5, 0.92], // GK
      [0.12, 0.74], // LB
      [0.35, 0.82], // LCB
      [0.65, 0.82], // RCB
      [0.88, 0.74], // RB
      [0.35, 0.62], // LCDM
      [0.65, 0.62], // RCDM
      [0.15, 0.42], // LMF
      [0.5, 0.42], // CAM
      [0.85, 0.42], // RMF
      [0.5, 0.15], // CF
    ],
    labels: [
      'GK',
      'LB',
      'LCB',
      'RCB',
      'RB',
      'LCDM',
      'RCDM',
      'LMF',
      'CAM',
      'RMF',
      'CF'
    ],
    warning: "Diqqat:\n"
        "• CF ni Goal Poacher qo'ymasangiz, yakka holda izolyatsiya bo'ladi!\n"
        "• CDM larni Anchorman + B2B juftligi qiling, markaz ochilmasin\n"
        "• LMF/RMF Prolific Winger bo'lsin, qanotlar faol bo'ladi\n"
        "• raqib 4-2-2-2 ishlatganda CAM ni Hole Player qilib press qiling\n"
        "• LB/RB ni Attacking qo'ymaslik, Defensive yaxshiroq",
  ),
  const Formation(
    name: "4-2-1-3",
    title: "Hujumkor 4-2-1-3 (Wide Attack)",
    subtitle: "Qanotlardan buzib o'tuvchi meta sxema",
    difficulty: Difficulty.medium,
    description:
        "4-2-1-3 - eFootball 2025/2026 da Tier 1 hujumkor sxema. Himoyada 4 nafar + 2 DMF bilan mustahkam turadi, markazda AMF paslar bilan hujumni boshqaradi. LWF/RWF qanotlardan dribling va cross qiladi, CF markazda gol uradi. Quick Counter, Long Ball Counter yoki Out Wide ga mukammal. Ikki DMF pressga chidamli midfield beradi, yuqori joylashgan wingers raqib himoyasini yorib o'tadi. 4-1-2-3 dan farqli o'laroq, 2 DMF markazni yaxshiroq qoplaydi.",
    bestFor:
        "• Quick Counter va Long Ball Counter uchun ideal (qanot qarshi hujumlar)\n"
        "• Out Wide bilan qanotlardan cross va dribling\n"
        "• raqib 4-3-3 yoki 4-4-2 ga qarshi ustunlik (2 DMF + wingers)\n"
        "• Division 1 da mashhur, 80%+ win rate\n"
        "• AMF kreativ paslari bilan gol imkoniyatlari\n"
        "• Possession ham ishlaydi (AMF Hole Player)",
    playerRecommendations:
        "• GK: Courtois, Neuer, Alisson (long pass va 1-on-1 kuchli)\n"
        "• CB (ikkala): Destroyer/Build Up (Van Dijk, Saliba, Rúben Dias, Araujo, Kim Min-jae)\n"
        "• LB/RB: Balanced/Attacking Fullback (Theo Hernández, Davies, Frimpong, Carvajal) — qanotlarga yordam\n"
        "• DMF (ikkala): Anchorman (deep line) + Box-to-Box/Destroyer (Rodri deep, Tchouaméni, Rice, Valverde)\n"
        "• AMF: Hole Player/Creative Playmaker (De Bruyne, Bellingham, Musiala, Hoeness, Nedved) — bo'sh zonaga kiradi\n"
        "• LWF/RWF: Prolific Winger (Vinícius Jr, Salah, Yamal, Doku, Saka) — tezlik va dribling 90+\n"
        "• CF: Goal Poacher (Haaland, Mbappé, Kane) — counter target",
    positions: [
      [0.5, 0.94], // GK
      [0.12, 0.82], // LB
      [0.35, 0.82], // LCB
      [0.65, 0.82], // RCB
      [0.88, 0.82], // RB
      [0.35, 0.68], // LDMF
      [0.65, 0.68], // RDMF
      [0.5, 0.35], // AMF
      [0.15, 0.15], // LWF
      [0.5, 0.15], // CF
      [0.85, 0.15], // RWF
    ],
    labels: [
      'GK',
      'LB',
      'LCB',
      'RCB',
      'RB',
      'LDMF',
      'RDMF',
      'AMF',
      'LWF',
      'CF',
      'RWF'
    ],
    warning: "Diqqat:\n"
        "• Wingers (LWF/RWF) Prolific Winger bo'lsin, aks holda qanotlar zaif!\n"
        "• AMF Hole Player qo'ying, u bo'sh joylarga kirib pas/gol beradi\n"
        "• Bitta DMF Anchorman deep line qiling, himoya ochilmasin\n"
        "• raqib 5 himoyachi ishlatganda Long Ball qilib qanotlarga uzating\n"
        "• CF Goal Poacher + counter target bo'lsin, yakka holda gol uradi",
  ),

  const Formation(
    name: "3-4-3",
    title: "Hujumkor 3-4-3 (Wide Attack)",
    subtitle: "3 himoyachi bilan yuqori press va qanot hujumlari",
    difficulty: Difficulty.hard,
    description:
        "3-4-3 - eFootball 2025/2026 da hujumkor va yuqori press sxemasi. Himoyada 3 CB mustahkam turadi, 4 midfield (2 CMF + 2 wide) raqibni press qiladi. LWF/RWF qanotlardan dribling/cross, CF markazda gol uradi. Possession yoki Quick Counter ga mos, ayniqsa Long Ball Counter bilan super long ball hujumlar. raqib narrow sxema (4-3-1-2) ga qarshi ustun, chunki qanotlar ochiq. Division 1 da undervalued meta, lekin to'g'ri o'yinchilar bilan OP.",
    bestFor:
        "• Quick Counter va Long Ball Counter uchun ideal (super long ball qanotga)\n"
        "• Yuqori press va possession (4 midfield raqibni bo'g'adi)\n"
        "• raqib narrow formationlarga qarshi (4-3-1-2, 4-2-3-1)\n"
        "• Qanot overloads va crosslar\n"
        "• Division 1 da surprise sxema, 75%+ win rate\n"
        "• Ruben Amorim uslubida (Manchester United)",
    playerRecommendations:
        "• GK: Neuer, Alisson, Courtois (sweeper keeper, long pass kuchli)\n"
        "• CB (uchala): Destroyer/Build Up/Extra Frontman (Van Dijk, Saliba, Araujo, Kim Min-jae, Maldini, Beckenbauer) — tez va stamina 90+\n"
        "• LMF/RMF (wide mids): Prolific Winger/Roaming Flank (Vinícius Jr, Salah, Yamal, Doku, Frimpong) — dribling, cross va track back\n"
        "• CMF (ikkala): Box-to-Box/Orchestrator (Bellingham, Valverde, Rodri, Gerrard, Kaka, Casemiro) — bitta anchor deep\n"
        "• LWF/RWF: Prolific Winger (Mbappé, Salah, Ronaldinho, Yamal) — tezlik 95+\n"
        "• CF: Goal Poacher (Haaland, Lewandowski, Torres, Eto’o) — counter target",
    positions: [
      [0.5, 0.92], // GK
      [0.3, 0.85], // LCB
      [0.5, 0.82], // CB (markaziy)
      [0.7, 0.85], // RCB
      [0.12, 0.52], // LMF
      [0.38, 0.62], // LCM
      [0.62, 0.62], // RCM
      [0.88, 0.52], // RMF
      [0.18, 0.28], // LWF
      [0.5, 0.15], // CF
      [0.82, 0.28], // RWF
    ],
    labels: [
      'GK',
      'LCB',
      'CB',
      'RCB',
      'LMF',
      'LCM',
      'RCM',
      'RMF',
      'LWF',
      'CF',
      'RWF'
    ],
    warning: "Diqqat:\n"
        "• Himoya riskli — CB lar tez va defensive awareness 90+ bo'lsin!\n"
        "• Wide mids (LMF/RMF) stamina 95+ va track back qilishi shart\n"
        "• raqib counter qilsa, deep defensive line qo'ying\n"
        "• Stamina boshqaring, 2-half da sub qiling\n"
        "• Long Ball bilan o'ynang, short pass tiqiladi",
  ),

  const Formation(
    name: "3-2-4-1",
    title: "Undervalued 3-2-4-1 (Out Wide)",
    subtitle: "Midfield dominant va qanot hujumlarining meta si",
    difficulty: Difficulty.medium,
    description:
        "3-2-4-1 - eFootball 2025/2026 da eng undervalued va kuchli sxemalardan biri. Himoyada 3 CB mustahkam turadi, 2 DMF markazni qulaydi, 4 midfield (LMF/RMF/CMF/AMF) bilan raqibni press qiladi va qanotlardan hujum qiladi. Possession, Long Ball Counter yoki Out Wide ga mukammal. Hujumda 3-2-5 ga aylanadi, LMF/RMF cross va dribling qiladi, AMF pas beradi, CF gol uradi. raqib 4-2-2-2 yoki 4-3-3 ga qarshi ustun, chunki midfield 6-7 kishi.",
    bestFor:
        "• Possession va Out Wide uchun ideal (qanot cross va markaz nazorati)\n"
        "• Long Ball Counter bilan qarshi hujumlar o'limli\n"
        "• raqib narrow sxemalarga qarshi (4-3-1-2, 4-2-3-1)\n"
        "• Midfield dominant — raqibni bo'g'ib qo'yadi\n"
        "• Division 1 da surprise sxema, 75%+ win rate\n"
        "• Quick Counter ham ishlaydi (LMF/RMF tez bo'lsa)",
    playerRecommendations:
        "• GK: Neuer, Courtois, Alisson (sweeper keeper, long pass kuchli)\n"
        "• CB (uchala): Destroyer/Build Up (Van Dijk, Saliba, Araujo, Kim Min-jae, Rúben Dias) — tez va stamina 90+\n"
        "• LDMF/RDMF: Anchorman (deep line) + Orchestrator/Box-to-Box (Rodri deep, Tchouaméni, Rice, Valverde)\n"
        "• LMF/RMF: Prolific Winger/Roaming Flank (Vinícius Jr, Salah, Yamal, Doku, Frimpong) — dribling, cross, track back\n"
        "• AMF: Creative Playmaker/Hole Player (De Bruyne, Bellingham, Musiala, Bruno Fernandes)\n"
        "• CF: Goal Poacher (Haaland, Mbappé, Kane, Lewandowski) — box ichida va counter target",
    positions: [
      [0.5, 0.92], // GK
      [0.3, 0.85], // LCB
      [0.5, 0.82], // CB (markaziy)
      [0.7, 0.85], // RCB
      [0.32, 0.65], // LDMF
      [0.68, 0.65], // RDMF
      [0.1, 0.45], // LMF
      [0.5, 0.42], // AMF
      [0.9, 0.45], // RMF
      [0.5, 0.15], // CF
    ],
    labels: [
      'GK',
      'LCB',
      'CB',
      'RCB',
      'LDMF',
      'RDMF',
      'LMF',
      'AMF',
      'RMF',
      'CF'
    ],
    warning: "Diqqat:\n"
        "• CB lar tez va defensive awareness 90+ bo'lsin, himoya riskli!\n"
        "• LMF/RMF stamina 95+ va defensive track back qilishi shart\n"
        "• raqib counter qilsa, deep defensive line qo'ying\n"
        "• DMF larni Anchorman + B2B qiling, markaz ochilmasin\n"
        "• Out Wide o'ynang, short pass tiqiladi — long ball va crosslar asosiy",
  ),

  const Formation(
    name: "3-2-3-2",
    title: "Midfield Dominant 3-2-3-2",
    subtitle: "Markazni bo'g'ib, ikki CF bilan gol mashinasi",
    difficulty: Difficulty.medium,
    description:
        "3-2-3-2 - eFootball 2025/2026 da Tier 3 kuchli sxema. Himoyada 3 CB mustahkam turadi, 2 DMF markazni qulaydi, 3 AMF (LMF/RMF/AMF) raqibni press qiladi va markazdan hujum qiladi. Ikki CF box ichida gol uradi. Possession Game, Long Counter yoki Out Wide ga mukammal. Hujumda 3-2-5 ga aylanadi, midfield 5 kishi bilan dominant. raqib 4-3-3 yoki 4-2-3-1 ga qarshi ustun, chunki markaz overload.",
    bestFor:
        "• Possession Game uchun ideal (markaziy nazorat va one-two passlar)\n"
        "• Long Ball Counter bilan ikki CF targetman qo'ysangiz o'limli\n"
        "• raqib 4-3-3 ga qarshi ustunlik (midfield 5 vs 3)\n"
        "• Out Wide bilan LMF/RMF crosslari\n"
        "• Division 1 da undervalued, 75%+ win rate\n"
        "• Quick Counter ham ishlaydi (tez AMF lar bo'lsa)",
    playerRecommendations:
        "• GK: Neuer, Courtois, Alisson (sweeper keeper, long pass kuchli)\n"
        "• CB (uchala): Destroyer/Build Up (Van Dijk, Saliba, Araujo, Kim Min-jae, Rúben Dias) — tez va defensive awareness 90+\n"
        "• LDMF/RDMF: Anchorman (deep line) + Box-to-Box/Orchestrator (Rodri deep, Tchouaméni, Rice, Valverde, Casemiro)\n"
        "• LMF/RMF: Prolific Winger/Roaming Flank (Vinícius Jr, Salah, Yamal, Doku, Saka) — dribling, cross va track back\n"
        "• AMF: Creative Playmaker/Hole Player (De Bruyne, Bellingham, Musiala, Bruno Fernandes, Pedri)\n"
        "• CF (ikkala): Goal Poacher + Deep Lying Forward (Haaland + Mbappé, Kane + Lewandowski) — bitta box poacher, bitta link-up",
    positions: [
      [0.5, 0.92], // GK
      [0.3, 0.85], // LCB
      [0.5, 0.82], // CB (markaziy)
      [0.7, 0.85], // RCB
      [0.35, 0.65], // LDMF
      [0.65, 0.65], // RDMF
      [0.12, 0.45], // LMF
      [0.5, 0.42], // AMF
      [0.88, 0.45], // RMF
      [0.38, 0.15], // LCF
      [0.62, 0.15], // RCF
    ],
    labels: [
      'GK',
      'LCB',
      'CB',
      'RCB',
      'LDMF',
      'RDMF',
      'LMF',
      'AMF',
      'RMF',
      'LCF',
      'RCF'
    ],
    warning: "Diqqat:\n"
        "• Himoya qanotlarda zaif — CB lar tez va wide coverage kuchli bo'lsin!\n"
        "• LMF/RMF stamina 95+ va defensive track back qilishi shart\n"
        "• DMF larni Anchorman deep line + B2B qiling, markaz ochilmasin\n"
        "• raqib wide overload qilsa (4-3-3), deep defensive line qo'ying\n"
        "• CF juftligi: Poacher + DLF — bitta golchi, bitta pas beruvchi",
  ),

  const Formation(
    name: "3-1-4-2",
    title: "Hujumkor 3-1-4-2 (Nagelsmann Style)",
    subtitle: "3 himoyachi bilan midfield dominant va 2 CF gol mashinasi",
    difficulty: Difficulty.hard,
    description:
        "3-1-4-2 - eFootball 2025/2026 da rare va undervalued sxema (J. Nagelsmann Bayern uchun). Himoyada 3 CB mustahkam turadi, 1 DMF markazni qulaydi, 4 midfield (LMF/RMF/CMF/AMF?) raqibni press qiladi. Ikki CF box ichida gol uradi. Long Ball Counter, Quick Counter yoki Out Wide ga mukammal. Hujumda 3-2-5 ga aylanadi, wide mids cross va dribling qiladi. raqib 4-3-3 yoki 4-2-3-1 ga qarshi ustun, chunki midfield overload. Division 1 da surprise sxema.",
    bestFor: "• Long Ball Counter uchun ideal (super long ball wide mids ga)\n"
        "• Out Wide bilan qanot crosslar va markaz nazorati\n"
        "• raqib narrow sxemalarga qarshi (4-3-1-2, 4-2-3-1)\n"
        "• Midfield 5 kishi press o'limli\n"
        "• Division 1 da surprise, 75%+ win rate\n"
        "• Possession ham ishlaydi (DMF Orchestrator bo'lsa)",
    playerRecommendations:
        "• GK: Neuer, Ederson, Alisson (sweeper keeper, long pass kuchli)\n"
        "• CB (uchala): Destroyer/Build Up (Van Dijk, Saliba, Araujo, Kim Min-jae) — tez va stamina 90+\n"
        "• DMF: Anchorman deep line (Rodri, Tchouaméni, Rice, Casemiro) — himoyani qoplaydi\n"
        "• LMF/RMF: Prolific Winger/Roaming Flank (Vinícius Jr, Salah, Yamal, Doku, Frimpong) — dribling, cross, track back\n"
        "• CMF/AMF: Box-to-Box/Orchestrator/Hole Player (Bellingham, Valverde, De Bruyne, Musiala)\n"
        "• CF (ikkala): Goal Poacher + Deep Lying Forward (Haaland + Mbappé, Kane + Lewandowski) — bitta tez, bitta kuchli",
    positions: [
      [0.5, 0.92], // GK
      [0.3, 0.75], // LCB
      [0.5, 0.72], // CB (markaziy)
      [0.7, 0.75], // RCB
      [0.5, 0.55], // DMF (markaziy anchorman)
      [0.1, 0.42], // LMF (wide left)
      [0.35, 0.38], // LCM
      [0.65, 0.38], // RCM
      [0.9, 0.42], // RMF (wide right)
      [0.35, 0.15], // LCF
      [0.65, 0.15], // RCF
    ],
    labels: [
      'GK',
      'LCB',
      'CB',
      'RCB',
      'DMF',
      'LMF',
      'LCM',
      'RCM',
      'RMF',
      'LCF',
      'RCF'
    ],
    warning: "Diqqat:\n"
        "• Himoya qanotlarda riskli — CB lar tez va wide coverage 90+ bo'lsin!\n"
        "• LMF/RMF stamina 95+ va track back qilishi SHART (Prolific Winger)\n"
        "• DMF Anchorman deep line qo'ying, aks holda markaz ochiladi\n"
        "• raqib counter qilsa, deep defensive line ishlatmang\n"
        "• Long Ball/Out Wide o'ynang, short pass tiqiladi — crosslar asosiy",
  ),

  const Formation(
    name: "5-3-2",
    title: "Himoyaviy Qalqon 5-3-2 (Wingback Hujum)",
    subtitle: "Eng mustahkam himoya va qarshi hujumlar meta sxemasi",
    difficulty: Difficulty.medium,
    description:
        "5-3-2 - eFootball 2025/2026 da Tier 3 kuchli himoyaviy sxema. Himoyada 5 nafar (3 CB + 2 WB) bilan raqibni 'bo'g'ib' turadi, 3 CMF markazni nazorat qiladi. Hujumda wingbacklar (LWB/RWB) oldinga chiqib qanotlardan cross beradi, ikki CF box ichida gol uradi. Quick Counter va Long Ball Counter ga mukammal, Possession ham ishlaydi. raqib 4-3-3 yoki 4-2-3-1 ga qarshi ustun, chunki himoya ochilmaydi. 3-5-2 ning himoyaviy versiyasi, fullbacklar Attacking qo'yilsa hujumda 3-5-2 ga aylanadi.",
    bestFor:
        "• Quick Counter va Long Ball Counter uchun ideal (5 himoya + qarshi hujumlar)\n"
        "• Yuqori pressga chidamli (5-back + 3 midfield)\n"
        "• raqib hujumkor sxemalarga qarshi (4-3-3, 4-2-2-2)\n"
        "• Lead ni ushlab turish va counter gollar\n"
        "• Division 1 da barqaror, 75%+ win rate\n"
        "• Boshlovchilar uchun oson himoya",
    playerRecommendations:
        "• GK: Courtois, Donnarumma, Neuer (baland, 1-on-1 kuchli)\n"
        "• CB (uchala): Destroyer/Build Up (Van Dijk markaz, Saliba/Araújo/Rúben Dias chap/o'ng) — tez va stamina 90+\n"
        "• LWB/RWB: Attacking Fullback yoki Fullback Finisher (Theo Hernández, Frimpong, Hakimi, Davies, Cafu) — cross va tezlik 95+\n"
        "• CMF (3 ta): Anchorman (chap deep), Box-to-Box (markaz), Orchestrator (o'ng) (Rodri/Tchouaméni chap, Bellingham/Valverde markaz, Kimmich/Pedri o'ng)\n"
        "• CF (ikkala): Goal Poacher + Deep Lying Forward (Haaland + Mbappé/Kane + Lewandowski) — bitta target, bitta tez",
    positions: [
      [0.5, 0.92], // GK
      [0.12, 0.78], // LWB
      [0.32, 0.85], // LCB
      [0.5, 0.82], // CB (markaziy)
      [0.68, 0.85], // RCB
      [0.88, 0.78], // RWB
      [0.30, 0.58], // LCM (Anchorman)
      [0.50, 0.65], // CCM (B2B)
      [0.70, 0.58], // RCM (Orchestrator)
      [0.38, 0.18], // LCF
      [0.62, 0.18], // RCF
    ],
    labels: [
      'GK',
      'LWB',
      'LCB',
      'CB',
      'RCB',
      'RWB',
      'LCM',
      'CCM',
      'RCM',
      'LCF',
      'RCF'
    ],
    warning: "Diqqat:\n"
        "• Wingbacklar (LWB/RWB) Attacking qo'ying, lekin stamina 95+ bo'lsin va track back qilsin!\n"
        "• CMF chap Anchorman deep line qo'ying, himoyani qoplaydi\n"
        "• raqib wide overload qilsa (4-3-3), deep defensive line ishlatmang\n"
        "• CF juftligi muhim: bitta Goal Poacher box ichida, bitta DLF link-up\n"
        "• Hujumda crosslarga tayaning, markaz tiqilishi mumkin",
  ),

  const Formation(
    name: "5-2-2-1",
    title: "Himoyaviy Qalqon 5-2-2-1 (Counter Hujum)",
    subtitle: "Boshlovchilar uchun eng yaxshi va Long Ball meta sxema",
    difficulty: Difficulty.easy,
    description:
        "5-2-2-1 - eFootball 2025/2026 da boshlovchilar va himoyaviy o'yin uchun Tier 2 sxema. Himoyada 5 nafar (3 CB + 2 WB) bilan raqibni to'liq 'qulaydi', 2 DMF markazni mustahkamlaydi. Hujumda LMF/RMF (AMF pozitsiyasi) cross va dribling qiladi, CF box ichida gol uradi. Long Ball Counter va Quick Counter ga mukammal, Possession ham ishlaydi. Wingbacklar oldinga chiqib qanot hujumlarini ta'minlaydi. raqib 4-3-3 yoki 4-2-3-1 ga qarshi ustun, chunki himoya ochilmaydi.",
    bestFor: "• Long Ball Counter uchun ideal (super long ball LMF/RMF ga)\n"
        "• Quick Counter bilan qarshi hujumlar o'limli\n"
        "• Boshlovchilar uchun eng oson sxema (himoya avtomatik)\n"
        "• raqib pressiga chidamli (5-back + 2 DMF)\n"
        "• Division 2-1 da barqaror natija\n"
        "• Lead ni ushlab turish va counter gollar",
    playerRecommendations:
        "• GK: Courtois, Donnarumma, Neuer (baland bo'yli, 1-on-1 kuchli)\n"
        "• CB (uchala): Destroyer/Build Up (Van Dijk markaz, Saliba/Araújo/Rúben Dias chap/o'ng) — tez va stamina 90+\n"
        "• LWB/RWB: Attacking Fullback/Fullback Finisher (Hakimi, Frimpong, Theo Hernández, Davies) — cross va tezlik 95+\n"
        "• DMF (ikkala): Anchorman (deep line) + Box-to-Box/Orchestrator (Rodri deep, Tchouaméni/Rice chap, Valverde/Bellingham o'ng)\n"
        "• LMF/RMF (AMF): Hole Player/Creative Playmaker/Prolific Winger (De Bruyne, Musiala, Bruno Fernandes, Yamal) — dribling va pas\n"
        "• CF: Goal Poacher (Haaland, Mbappé, Kane, Lewandowski) — box ichida va target",
    positions: [
      [0.5, 0.92], // GK
      [0.12, 0.78], // LWB
      [0.32, 0.85], // LCB
      [0.5, 0.82], // CB (markaziy)
      [0.68, 0.85], // RCB
      [0.88, 0.78], // RWB
      [0.32, 0.65], // LDMF (Anchorman)
      [0.68, 0.65], // RDMF (B2B)
      [0.18, 0.42], // LMF
      [0.82, 0.42], // RMF
      [0.5, 0.15], // CF
    ],
    labels: [
      'GK',
      'LWB',
      'LCB',
      'CB',
      'RCB',
      'RWB',
      'LDMF',
      'RDMF',
      'LAMF',
      'RAMF',
      'CF'
    ],
    warning: "Diqqat:\n"
        "• Wingbacklar (LWB/RWB) Attacking qo'ying, stamina 95+ va track back shart!\n"
        "• LMF/RMF Hole Player/Creative Playmaker bo'lsin, ular bo'sh zonaga kiradi\n"
        "• Bitta DMF Anchorman deep line qiling, markaz ochilmasin\n"
        "• raqib wide o'ynasa deep defensive line qo'ying\n"
        "• CF Goal Poacher bo'lsin, long ball target",
  ),
  const Formation(
    name: "4-2-2-2",
    title: "Meta 4-2-2-2 (Double AMF)",
    subtitle: "Markaz dominant va ikki CF bilan eng kuchli sxema",
    difficulty: Difficulty.medium,
    description:
        "4-2-2-2 - eFootball 2025/2026 da Tier 1 meta sxemalardan biri va eng mashhuri. Himoyada 4 nafar + 2 DMF bilan mustahkam turadi, 2 AMF markazdan pas va dribling bilan hujumni boshqaradi. Ikki CF box ichida gol uradi. Quick Counter, Long Ball Counter va Possession ga mukammal mos. Ikki DMF pressga chidamli midfield beradi, AMF lar raqib himoyasini yorib o'tadi. Division 1 da eng ko'p ishlatiladi, raqib 4-3-3 yoki 5-back ga qarshi ustun.",
    bestFor:
        "• Quick Counter va Long Ball Counter uchun ideal (ikki CF targetman)\n"
        "• Possession bilan markaz nazorati (2 AMF + 2 DMF)\n"
        "• raqib 4-3-3 yoki 5-2-1-2 ga qarshi ustunlik\n"
        "• Division 1 va Tourlarda 80%+ win rate\n"
        "• Ikki CF + AMF lar bilan gol mashinasi\n"
        "• Xabi Alonso yoki Fabio Capello bilan OP",
    playerRecommendations:
        "• GK: Courtois, Neuer, Alisson (1-on-1 va long pass kuchli)\n"
        "• CB (ikkala): Destroyer/Build Up (Van Dijk, Saliba, Rúben Dias, Araujo)\n"
        "• LB/RB: Balanced/Attacking Fullback (Theo Hernández, Davies, Carvajal, Hakimi) — qanot yordami\n"
        "• DMF (ikkala): Anchorman (deep line) + Box-to-Box/Orchestrator (Rodri deep, Tchouaméni/Rice, Valverde/Bellingham)\n"
        "• AMF (ikkala): Hole Player/Creative Playmaker (De Bruyne, Bruno Fernandes, Musiala, Bellingham, Zidane) — pas va bo'sh joy\n"
        "• CF (ikkala): Goal Poacher + Deep Lying Forward (Haaland + Mbappé, Kane + Lewandowski, Batistuta) — bitta tez, bitta kuchli target",
    positions: [
      [0.5, 0.92], // GK
      [0.12, 0.74], // LB
      [0.35, 0.82], // LCB
      [0.65, 0.82], // RCB
      [0.88, 0.74], // RB
      [0.35, 0.65], // LDMF
      [0.65, 0.65], // RDMF
      [0.35, 0.38], // LAMF
      [0.65, 0.38], // RAMF
      [0.38, 0.15], // LCF
      [0.62, 0.15], // RCF
    ],
    labels: [
      'GK',
      'LB',
      'LCB',
      'RCB',
      'RB',
      'LDMF',
      'RDMF',
      'LAMF',
      'RAMF',
      'LCF',
      'RCF'
    ],
    warning: "Diqqat:\n"
        "• Qanotlar zaif — LB/RB Attacking qo'ying yoki Defensive sinang\n"
        "• AMF Hole Player/Creative Playmaker bo'lsin, ular bo'sh zonaga kiradi\n"
        "• Bitta DMF Anchorman deep line qiling, markaz ochilmasin\n"
        "• raqib wide o'ynasa (4-3-3), AMF larni press qiling\n"
        "• CF juftligi: Goal Poacher (box) + DLF (link-up, header kuchli)",
  ),

  ///oxirgisi
  const Formation(
    name: "5-2-1-2",
    title: "Qalqon 5-2-1-2 (Hujumda 3-2-1-4)",
    subtitle: "Hozirgi metadagi eng muvozanatli va OP sxema",
    difficulty: Difficulty.medium,
    description:
        "Bu 5-2-1-2 sxemasi himoyada 5 nafar o'yinchi bilan juda mustahkam turadi, lekin hujumga chiqqanda CBF orqali oldinga chiqib 3-4-3 yoki 3-2-1-4 ga aylanadi. Quick Counter yoki Possession o'yin uslubiga juda mos. Ayniqsa Long Ball Counter bilan ishlatilsa raqibni 'yirtib' tashlaydi. Midfield 2 kishi bo'lsa ham, DMF va CBF ning to'g'ri joylashuvi tufayli markaz hech qachon ochilmaydi.",
    bestFor: "• Quick Counter va Long Ball Counter o'yin uslubi uchun ideal\n"
        "• Yuqori pressga juda chidamli (5 himoyachi + 2 DMF)\n"
        "• Tez qarshi hujumlardan ko'p gol urish\n"
        "• raqib 4-2-1-3 yoki 4-1-2-1-2 ishlatayotgan bo'lsa ustunlik\n"
        "• Possession bilan o'ynasangiz ham ishlaydi (CBF ni attacking qo'yiladi)\n"
        "• Top 100 va Division 1 da eng ko'p ishlatiladigan sxemalardan biri",
    playerRecommendations:
        "• GK: Courtois, Donnarumma, Neuer (baland bo'yli va 1-on-1 kuchli)\n"
        "• CB (uchala): Destroyer yoki Extra Frontman (Van Dijk, Rüdiger, Araújo, Saliba, Kim Min-jae)\n"
        "• LWB/RWB: Dumfries, Hakimi, Frimpong, Alexander-Arnold, Carvajal (hujumkor, tez, stamina 90+ bo'lsin)\n"
        "• DMF (ikkala): Anchorman yoki Orchestrator (Rodri, Tchouaméni, Rice, Casemiro, Kessié)\n"
        "• CBF (markazdagi himoyachi): EXTRA FRONTMAN bo'lishi shart! (Konaté, Gvardiol, Bastoni, Tomiyasu) — bu o'yinchi hujumda 4-himoyachiga aylanadi\n"
        "• AMF: Hole Player yoki Creative Playmaker (De Bruyne, Bellingham, Bruno Guimarães, Pedri, Musiala)\n"
        "• CF (ikkala): Goal Poacher yoki Deep-Lying Forward (Haaland, Mbappé, Lewandowski, Kane + bitta targetman bo'lsa yanada kuchli)",
    positions: [
      [0.5, 0.92], // GK
      [0.12, 0.78], // LWB
      [0.32, 0.85], // LCB
      [0.5, 0.82], // CBF
      [0.68, 0.85], // RCB
      [0.88, 0.78], // RWB
      [0.35, 0.62], // LDMF
      [0.65, 0.62], // RDMF
      [0.5, 0.42], // AMF
      [0.38, 0.15], // LCF
      [0.62, 0.15], // RCF
    ],
    labels: [
      'GK',
      'LWB',
      'LCB',
      'CBF',
      'RCB',
      'RWB',
      'LDMF',
      'RDMF',
      'AMF',
      'LCF',
      'RCF'
    ],
    warning: "Diqqat:\n"
        "• Agar CBF ni Extra Frontman qo'ymasangiz, hujumda himoya ochiladi!\n"
        "• AMF ni Hole Player qo'ying, u bo'sh zonaga kirib gol uradi\n"
        "• Wingbacklarni stamina 90+ va offensive awareness yuqori bo'lganini oling\n"
        "• Midfield biroz zaif ko'rinadi lekin aslida 5 himoyachi + 2 DMF tufayli pressga juda chidamli\n"
        "• raqib Possession o'ynasa, DMF larni Box-to-Box qilib qo'yish mumkin",
  ),
  const Formation(
    name: "4-2-4",
    title: "Ultra Hujumkor 4-2-4 (Meta)",
    subtitle: "4 hujumchi bilan raqib himoyasini parchalash",
    difficulty: Difficulty.hard,
    description:
        "4-2-4 - eFootball'dagi eng hujumkor sxemalardan biri. 4 ta hujumchi raqib himoyasini doimiy bosimda ushlab turadi. Markazda faqat 2 o'yinchi bo'lgani uchun, u yerda juda kuchli jismoniy holatga ega o'yinchilar bo'lishi shart.",
    bestFor:
        "• Tezkor qarshi hujumlar\n• Hisobda orqada qolayotgan paytda gol urish\n• Qanotlar orqali agressiv hujumlar",
    playerRecommendations:
        "• CMF (ikkala): Box-to-Box (Vieira, Bellingham)\n• FWDs: Tezkor qanot hujumchilari va tugatuvchi CFlar",
    positions: [
      [0.5, 0.92], // GK
      [0.12, 0.74], // LB
      [0.35, 0.82], // LCB
      [0.65, 0.82], // RCB
      [0.88, 0.74], // RB
      [0.38, 0.60], // LCM
      [0.62, 0.60], // RCM
      [0.15, 0.20], // LWF
      [0.38, 0.10], // LCF
      [0.62, 0.10], // RCF
      [0.85, 0.20], // RWF
    ],
    labels: [
      'GK',
      'LB',
      'LCB',
      'RCB',
      'RB',
      'LCM',
      'RCM',
      'LWF',
      'LCF',
      'RCF',
      'RWF'
    ],
    warning: "Markaz ochiq qolishi mumkin, himoyaga e'tibor bering!",
  ),
  const Formation(
    name: "3-1-3-3",
    title: "Eksperimental 3-1-3-3 (Super Meta)",
    subtitle: "3 himoyachi va 3 hujumchi bilan total futbol",
    difficulty: Difficulty.hard,
    description:
        "Bu sxema markazni va hujumni to'liq nazorat qilish uchun mo'ljallangan. 3 markaziy himoyachi va 1 tayanch yarim himoyachi himoya mustahkamligini ta'minlaydi.",
    bestFor:
        "• To'pni nazorat qilish (Possession)\n• Yuqori pressing\n• Ko'p golli vaziyatlar yaratish",
    playerRecommendations:
        "• DMF: Anchorman (Rodri)\n• CBlar: Juda tezkor bo'lishi shart",
    positions: [
      [0.5, 0.92], // GK
      [0.32, 0.85], // LCB
      [0.5, 0.82], // CB
      [0.68, 0.85], // RCB
      [0.5, 0.65], // DMF
      [0.2, 0.45], // LMF
      [0.5, 0.42], // AMF
      [0.8, 0.45], // RMF
      [0.18, 0.22], // LWF
      [0.5, 0.12], // CF
      [0.82, 0.22], // RWF
    ],
    labels: [
      'GK',
      'LCB',
      'CB',
      'RCB',
      'DMF',
      'LMF',
      'AMF',
      'RMF',
      'LWF',
      'CF',
      'RWF'
    ],
    warning: "Qanotlardan qarshi hujumlarga tayyor turing!",
  ),
];
