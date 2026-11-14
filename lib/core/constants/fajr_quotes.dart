/// Authentic Quran verses, Hadith and encouraging wake-up messages about Fajr.
/// Each entry has Arabic (primary), English and French text plus a source label.
/// Add more entries to the list: the notification scheduler and the picker use it automatically.
class FajrQuote {
  final String ar, en, fr, source;
  const FajrQuote(this.ar, this.en, this.fr, this.source);

  String text(String lang) => switch (lang) { 'en' => en, 'fr' => fr, _ => ar };
}

const List<FajrQuote> fajrQuotes = [
  // ---- القرآن الكريم ----
  FajrQuote(
      '﴿إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا﴾',
      'Indeed, the recitation of dawn is ever witnessed.',
      'Certes, la récitation de l\'aube est toujours attestée.',
      'الإسراء ٧٨'),
  FajrQuote(
      '﴿حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ﴾',
      'Guard strictly the prayers, and the middle prayer, and stand before Allah devoutly obedient.',
      'Soyez assidus aux prières, et à la prière médiane, et tenez-vous debout devant Allah avec humilité.',
      'البقرة ٢٣٨'),
  FajrQuote(
      '﴿وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِّنَ اللَّيْلِ﴾',
      'Establish prayer at the two ends of the day and at the approach of the night.',
      'Accomplis la prière aux deux extrémités du jour et à l\'approche de la nuit.',
      'هود ١١٤'),
  FajrQuote(
      '﴿تَتَجَافَىٰ جُنُوبُهُمْ عَنِ الْمَضَاجِعِ يَدْعُونَ رَبَّهُمْ خَوْفًا وَطَمَعًا﴾',
      'Their sides forsake their beds; they call upon their Lord in fear and hope.',
      'Leurs flancs désertent leurs lits pour invoquer leur Seigneur avec crainte et espoir.',
      'السجدة ١٦'),
  FajrQuote(
      '﴿كَانُوا قَلِيلًا مِّنَ اللَّيْلِ مَا يَهْجَعُونَ * وَبِالْأَسْحَارِ هُمْ يَسْتَغْفِرُونَ﴾',
      'They used to sleep but little of the night, and before dawn they would seek forgiveness.',
      'Ils dormaient peu la nuit, et à l\'aube ils demandaient pardon.',
      'الذاريات ١٧-١٨'),
  FajrQuote(
      '﴿وَأْمُرْ أَهْلَكَ بِالصَّلَاةِ وَاصْطَبِرْ عَلَيْهَا﴾',
      'And enjoin prayer upon your family and be steadfast therein.',
      'Ordonne la prière aux tiens et persévère dans son accomplissement.',
      'طه ١٣٢'),
  FajrQuote(
      '﴿وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ﴾',
      'Seek help through patience and prayer.',
      'Cherchez secours dans la patience et la prière.',
      'البقرة ٤٥'),
  FajrQuote(
      '﴿إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ﴾',
      'Indeed, prayer prohibits immorality and wrongdoing.',
      'En vérité, la prière préserve de la turpitude et du blâmable.',
      'العنكبوت ٤٥'),
  FajrQuote(
      '﴿قَدْ أَفْلَحَ الْمُؤْمِنُونَ * الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ﴾',
      'Successful indeed are the believers, those who are humble in their prayers.',
      'Bienheureux sont les croyants, ceux qui sont humbles dans leur prière.',
      'المؤمنون ١-٢'),
  FajrQuote(
      '﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾',
      'Verily, in the remembrance of Allah do hearts find rest.',
      'C\'est par le rappel d\'Allah que les cœurs s\'apaisent.',
      'الرعد ٢٨'),
  FajrQuote(
      '﴿فَاذْكُرُونِي أَذْكُرْكُمْ﴾',
      'So remember Me; I will remember you.',
      'Souvenez-vous de Moi, Je Me souviendrai de vous.',
      'البقرة ١٥٢'),
  FajrQuote(
      '﴿وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا﴾',
      'Those who strive for Us, We will surely guide them to Our ways.',
      'Ceux qui s\'efforcent pour Nous, Nous les guiderons sur Nos chemins.',
      'العنكبوت ٦٩'),
  FajrQuote(
      '﴿فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾',
      'Indeed, with hardship comes ease. Indeed, with hardship comes ease.',
      'À côté de la difficulté il y a certes une facilité. À côté de la difficulté il y a certes une facilité.',
      'الشرح ٥-٦'),
  FajrQuote(
      '﴿وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا﴾',
      'Whoever fears Allah, He will make a way out for him.',
      'Quiconque craint Allah, Il lui donnera une issue.',
      'الطلاق ٢'),
  FajrQuote(
      '﴿وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ﴾',
      'Whoever relies upon Allah, He is sufficient for him.',
      'Quiconque place sa confiance en Allah, Il lui suffit.',
      'الطلاق ٣'),
  FajrQuote('﴿فَاسْتَبِقُوا الْخَيْرَاتِ﴾', 'So race to all that is good.',
      'Rivalisez donc dans les bonnes actions.', 'البقرة ١٤٨'),
  FajrQuote(
      '﴿وَسَارِعُوا إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ وَجَنَّةٍ﴾',
      'Hasten to forgiveness from your Lord and a Paradise.',
      'Hâtez-vous vers un pardon de votre Seigneur et un Paradis.',
      'آل عمران ١٣٣'),
  FajrQuote(
      '﴿وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ﴾',
      'And your Lord is going to give you, and you will be satisfied.',
      'Ton Seigneur te comblera bientôt et tu seras satisfait.',
      'الضحى ٥'),
  FajrQuote(
      '﴿إِنَّ اللَّهَ مَعَ الصَّابِرِينَ﴾',
      'Indeed, Allah is with the patient.',
      'Allah est avec les endurants.',
      'البقرة ١٥٣'),
  FajrQuote(
      '﴿رَبِّ اشْرَحْ لِي صَدْرِي * وَيَسِّرْ لِي أَمْرِي﴾',
      'My Lord, expand for me my chest and ease my task for me.',
      'Seigneur, ouvre-moi la poitrine et facilite ma mission.',
      'طه ٢٥-٢٦'),
  FajrQuote(
      '﴿يَا أَيُّهَا الْمُزَّمِّلُ * قُمِ اللَّيْلَ إِلَّا قَلِيلًا﴾',
      'O you who wraps himself in clothing, arise in prayer through the night, except a little.',
      'Ô toi, enveloppé dans ton manteau, lève-toi pour prier la nuit, sauf une petite partie.',
      'المزمل ١-٢'),
  FajrQuote(
      '﴿إِنَّ نَاشِئَةَ اللَّيْلِ هِيَ أَشَدُّ وَطْئًا وَأَقْوَمُ قِيلًا﴾',
      'Indeed, worship in the night is more effective and more suitable for words.',
      'La veille de nuit est plus efficace et plus propice à la récitation.',
      'المزمل ٦'),
  FajrQuote(
      '﴿إِنَّا لَا نُضِيعُ أَجْرَ مَنْ أَحْسَنَ عَمَلًا﴾',
      'Indeed, We do not waste the reward of one who has done well in deeds.',
      'Nous ne laissons pas perdre la récompense de celui qui a bien agi.',
      'الكهف ٣٠'),
  FajrQuote(
      '﴿وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ﴾',
      'And my success is only through Allah.',
      'Ma réussite ne dépend que d\'Allah.',
      'هود ٨٨'),
  FajrQuote(
      '﴿إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ﴾',
      'Indeed, Allah loves those who repent and loves those who purify themselves.',
      'Allah aime ceux qui se repentent et ceux qui se purifient.',
      'البقرة ٢٢٢'),
  // ---- الأحاديث الصحيحة ----
  FajrQuote(
      '«رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا»',
      'The two rak\'ahs of Fajr are better than the world and all it contains.',
      'Les deux rak\'at du Fajr valent mieux que le monde et ce qu\'il contient.',
      'رواه مسلم'),
  FajrQuote(
      '«مَنْ صَلَّى الصُّبْحَ فَهُوَ فِي ذِمَّةِ اللَّهِ»',
      'Whoever prays Fajr is under the protection of Allah.',
      'Celui qui accomplit la prière du Fajr est sous la protection d\'Allah.',
      'رواه مسلم'),
  FajrQuote(
      '«مَنْ صَلَّى الْبَرْدَيْنِ دَخَلَ الْجَنَّةَ»',
      'Whoever prays the two cool prayers (Fajr and Asr) will enter Paradise.',
      'Celui qui accomplit les deux prières fraîches (Fajr et Asr) entrera au Paradis.',
      'متفق عليه'),
  FajrQuote(
      '«لَنْ يَلِجَ النَّارَ أَحَدٌ صَلَّى قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ غُرُوبِهَا»',
      'None who prays before sunrise and before sunset will enter the Fire.',
      'N\'entrera pas en Enfer celui qui prie avant le lever et avant le coucher du soleil.',
      'رواه مسلم'),
  FajrQuote(
      '«مَنْ صَلَّى الْعِشَاءَ فِي جَمَاعَةٍ فَكَأَنَّمَا قَامَ نِصْفَ اللَّيْلِ، وَمَنْ صَلَّى الصُّبْحَ فِي جَمَاعَةٍ فَكَأَنَّمَا صَلَّى اللَّيْلَ كُلَّهُ»',
      'Whoever prays Isha in congregation, it is as if he stood half the night; and whoever prays Fajr in congregation, it is as if he prayed the whole night.',
      'Qui prie l\'Icha en groupe, c\'est comme s\'il avait veillé la moitié de la nuit ; qui prie le Fajr en groupe, c\'est comme s\'il avait veillé toute la nuit.',
      'رواه مسلم'),
  FajrQuote(
      '«بَشِّرِ الْمَشَّائِينَ فِي الظُّلَمِ إِلَى الْمَسَاجِدِ بِالنُّورِ التَّامِّ يَوْمَ الْقِيَامَةِ»',
      'Give glad tidings to those who walk to the mosques in the darkness of a perfect light on the Day of Resurrection.',
      'Annonce à ceux qui marchent vers les mosquées dans l\'obscurité une lumière parfaite au Jour de la Résurrection.',
      'أبو داود والترمذي'),
  FajrQuote(
      '«أَثْقَلُ الصَّلَاةِ عَلَى الْمُنَافِقِينَ صَلَاةُ الْعِشَاءِ وَصَلَاةُ الْفَجْرِ، وَلَوْ يَعْلَمُونَ مَا فِيهِمَا لَأَتَوْهُمَا وَلَوْ حَبْوًا»',
      'The heaviest prayers upon the hypocrites are Isha and Fajr; if they knew what they contain, they would come even crawling.',
      'Les prières les plus lourdes pour les hypocrites sont l\'Icha et le Fajr ; s\'ils savaient ce qu\'elles contiennent, ils y viendraient même en rampant.',
      'متفق عليه'),
  FajrQuote(
      '«اللَّهُمَّ بَارِكْ لِأُمَّتِي فِي بُكُورِهَا»',
      'O Allah, bless my nation in its early mornings.',
      'Ô Allah, bénis ma communauté dans ses débuts de journée.',
      'أبو داود والترمذي'),
  FajrQuote(
      '«يَتَعَاقَبُونَ فِيكُمْ مَلَائِكَةٌ بِاللَّيْلِ وَمَلَائِكَةٌ بِالنَّهَارِ، وَيَجْتَمِعُونَ فِي صَلَاةِ الْفَجْرِ وَصَلَاةِ الْعَصْرِ»',
      'Angels of the night and angels of the day succeed one another among you and gather at Fajr and Asr.',
      'Des anges de la nuit et du jour se relaient auprès de vous et se réunissent à la prière du Fajr et de l\'Asr.',
      'متفق عليه'),
  FajrQuote(
      '«يَعْقِدُ الشَّيْطَانُ عَلَى قَافِيَةِ رَأْسِ أَحَدِكُمْ ثَلَاثَ عُقَدٍ... فَإِنِ اسْتَيْقَظَ وَذَكَرَ اللَّهَ انْحَلَّتْ عُقْدَةٌ، فَإِنْ تَوَضَّأَ انْحَلَّتْ عُقْدَةٌ، فَإِنْ صَلَّى انْحَلَّتْ عُقَدُهُ كُلُّهَا»',
      'Satan ties three knots at the back of your head while you sleep. If you wake and remember Allah, one knot is undone; if you perform wudu, another; if you pray, all the knots are undone.',
      'Satan fait trois nœuds sur la nuque de celui qui dort. S\'il se réveille et évoque Allah, un nœud se défait ; s\'il fait ses ablutions, un autre ; s\'il prie, tous les nœuds se défont.',
      'متفق عليه'),
  FajrQuote(
      '«مَنْ صَلَّى الْغَدَاةَ فِي جَمَاعَةٍ ثُمَّ قَعَدَ يَذْكُرُ اللَّهَ حَتَّى تَطْلُعَ الشَّمْسُ ثُمَّ صَلَّى رَكْعَتَيْنِ كَانَتْ لَهُ كَأَجْرِ حَجَّةٍ وَعُمْرَةٍ تَامَّةٍ تَامَّةٍ تَامَّةٍ»',
      'Whoever prays Fajr in congregation, then sits remembering Allah until sunrise and prays two rak\'ahs, will have the reward of a complete Hajj and Umrah.',
      'Qui prie le Fajr en groupe, reste à évoquer Allah jusqu\'au lever du soleil puis prie deux rak\'at, aura la récompense d\'un Hajj et d\'une Omra complets.',
      'رواه الترمذي'),
  FajrQuote(
      '«يَنْزِلُ رَبُّنَا كُلَّ لَيْلَةٍ إِلَى السَّمَاءِ الدُّنْيَا حِينَ يَبْقَى ثُلُثُ اللَّيْلِ الْآخِرُ فَيَقُولُ: مَنْ يَدْعُونِي فَأَسْتَجِيبَ لَهُ؟»',
      'Our Lord descends every night to the lowest heaven in the last third of the night and says: Who calls upon Me that I may answer him?',
      'Notre Seigneur descend chaque nuit au ciel le plus bas durant le dernier tiers de la nuit et dit : Qui M\'invoque pour que Je lui réponde ?',
      'متفق عليه'),
  FajrQuote(
      '«أَفْضَلُ الصَّلَاةِ بَعْدَ الْفَرِيضَةِ صَلَاةُ اللَّيْلِ»',
      'The best prayer after the obligatory prayers is the night prayer.',
      'La meilleure prière après la prière obligatoire est la prière de la nuit.',
      'رواه مسلم'),
  FajrQuote(
      '«عَلَيْكُمْ بِقِيَامِ اللَّيْلِ فَإِنَّهُ دَأْبُ الصَّالِحِينَ قَبْلَكُمْ»',
      'Hold to the night prayer, for it was the habit of the righteous before you.',
      'Tenez-vous à la prière de la nuit, car c\'était l\'habitude des gens vertueux avant vous.',
      'رواه الترمذي'),
  FajrQuote(
      '«أَحَبُّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ»',
      'The most beloved deeds to Allah are the most consistent, even if small.',
      'Les œuvres les plus aimées d\'Allah sont les plus régulières, même minimes.',
      'متفق عليه'),
  FajrQuote(
      '«الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ»',
      'The strong believer is better and more beloved to Allah than the weak believer.',
      'Le croyant fort est meilleur et plus aimé d\'Allah que le croyant faible.',
      'رواه مسلم'),
  FajrQuote(
      '«احْرِصْ عَلَى مَا يَنْفَعُكَ وَاسْتَعِنْ بِاللَّهِ وَلَا تَعْجَزْ»',
      'Be keen on what benefits you, seek Allah\'s help, and do not give up.',
      'Sois soucieux de ce qui t\'est utile, demande l\'aide d\'Allah et ne baisse pas les bras.',
      'رواه مسلم'),
  FajrQuote(
      '«مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ»',
      'Whoever treads a path seeking knowledge, Allah makes easy for him a path to Paradise.',
      'Quiconque emprunte un chemin pour chercher le savoir, Allah lui facilite un chemin vers le Paradis.',
      'رواه مسلم'),
  FajrQuote(
      '«مَا مِنْ عَبْدٍ مُسْلِمٍ يُصَلِّي لِلَّهِ كُلَّ يَوْمٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً تَطَوُّعًا غَيْرَ فَرِيضَةٍ إِلَّا بَنَى اللَّهُ لَهُ بَيْتًا فِي الْجَنَّةِ»',
      'Any Muslim who prays twelve voluntary rak\'ahs for Allah each day, Allah builds for him a house in Paradise.',
      'Tout musulman qui prie chaque jour douze rak\'at surérogatoires, Allah lui bâtit une maison au Paradis.',
      'رواه مسلم'),
  FajrQuote('«الصَّلَاةُ نُورٌ»', 'Prayer is light.',
      'La prière est une lumière.', 'رواه مسلم'),
  FajrQuote(
      '«إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ»',
      'Deeds are only by intentions.',
      'Les actes ne valent que par les intentions.',
      'متفق عليه'),
  FajrQuote(
      '«الصَّلَاةُ خَيْرٌ مِنَ النَّوْمِ»',
      'Prayer is better than sleep.',
      'La prière est meilleure que le sommeil.',
      'من الأذان'),
  // ---- عبارات تحفيزية ----
  FajrQuote(
      'دفء الفراش ينتهي بعد دقائق، وأجر الفجر يبقى إلى الأبد.',
      'The warmth of the bed fades in minutes; the reward of Fajr remains forever.',
      'La chaleur du lit s\'estompe en quelques minutes ; la récompense du Fajr reste pour toujours.',
      'عبارة تحفيزية'),
  FajrQuote(
      'قمتَ للفجر؟ إذن بدأتَ يومك منتصرًا على نفسك.',
      'Up for Fajr? Then you began your day victorious over yourself.',
      'Debout pour le Fajr ? Alors tu as commencé ta journée en vainqueur de toi-même.',
      'عبارة تحفيزية'),
  FajrQuote(
      'من غلب نفسه عند الفجر سهُل عليه كل ما بعده.',
      'Whoever overcomes himself at Fajr finds everything after it easier.',
      'Qui se vainc au Fajr trouve tout le reste plus facile.',
      'عبارة تحفيزية'),
  FajrQuote(
      'يوم جديد، وفرصة جديدة، ورب كريم ينتظرك.',
      'A new day, a new chance, and a Generous Lord awaits you.',
      'Un jour nouveau, une chance nouvelle, et un Seigneur Généreux t\'attend.',
      'عبارة تحفيزية'),
  FajrQuote(
      'كل فجر تصليه هو خطوة في طريقك إلى الله.',
      'Every Fajr you pray is a step on your path to Allah.',
      'Chaque Fajr que tu pries est un pas sur ton chemin vers Allah.',
      'عبارة تحفيزية'),
  FajrQuote(
      'لا تؤجّل قيامك؛ فقد يكون هذا الفجر موعدك مع الرحمة.',
      'Do not postpone rising; this dawn may be your appointment with mercy.',
      'Ne remets pas ton réveil à plus tard ; cette aube est peut-être ton rendez-vous avec la miséricorde.',
      'عبارة تحفيزية'),
  FajrQuote(
      'الله ناداك: الصلاة خير من النوم، فلبِّ النداء.',
      'Allah has called you: prayer is better than sleep. Answer the call.',
      'Allah t\'a appelé : la prière est meilleure que le sommeil. Réponds à l\'appel.',
      'عبارة تحفيزية'),
  FajrQuote(
      'القطرة تحفر الصخر بالمداومة؛ فداوم على فجرك.',
      'A drop carves the rock through persistence; be persistent in your Fajr.',
      'La goutte creuse le rocher par la constance ; sois constant dans ton Fajr.',
      'عبارة تحفيزية'),
  FajrQuote(
      'سلسلة أيامك أمانة؛ لا تكسرها اليوم.',
      'Your streak is a trust; do not break it today.',
      'Ta série de jours est un dépôt ; ne la brise pas aujourd\'hui.',
      'عبارة تحفيزية'),
  FajrQuote(
      'من خطا نحو الفجر بنية صادقة أعانه الله على الباقي.',
      'Whoever steps toward Fajr with sincere intention, Allah helps with the rest.',
      'Qui avance vers le Fajr avec une intention sincère, Allah l\'aide pour le reste.',
      'عبارة تحفيزية'),
  FajrQuote(
      'اجعل أول كلمة في يومك: «الله أكبر».',
      'Make the first words of your day: "Allahu Akbar".',
      'Fais de « Allahou Akbar » les premiers mots de ta journée.',
      'عبارة تحفيزية'),
  FajrQuote(
      'النوم يعوَّض، أما الفجر فلا يعود.',
      'Sleep can be made up; this Fajr will not return.',
      'Le sommeil se rattrape ; ce Fajr ne reviendra pas.',
      'عبارة تحفيزية'),
  FajrQuote(
      'قم الآن، فالسكينة تنتظرك في سجدة الفجر.',
      'Rise now; tranquility awaits you in the prostration of Fajr.',
      'Lève-toi maintenant, la sérénité t\'attend dans la prosternation du Fajr.',
      'عبارة تحفيزية'),
];
