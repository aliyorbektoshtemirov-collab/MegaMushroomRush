# Mega Mushroom Rush

## O‘yin haqida

Loyihaning nomi Mega Mushroom Rush. Bu Godot’da ishlangan 2D yugurish o‘yini. Qahramon o‘zi yuguradi, biz esa uni vaqtida sakratib yoki egiltirib turamiz. Maqsad — imkon qadar uzoq o‘ynash va ko‘proq ochko yig‘ish.

Boshqaruvi oddiy. Space yoki tepaga tugmasini bossak, qahramon sakraydi. Pastga tugmasini bosib tursak, egiladi. Shu tugmani havoda bossak, tezroq pastga tushadi. Bu, masalan, keyingi dushmanning ustiga aniq tushish uchun kerak bo‘ladi. Telefonda ham ekrandagi tugmalar orqali boshqarish mumkin.

Yo‘lda qo‘ziqorinlar, toshbaqalar, uchuvchi o‘qlar va quvurlar chiqadi. Qo‘ziqorin yoki toshbaqaning ustiga tushsak, uni bosib ezamiz va qahramon yana havoga sakraydi. Shu harakat o‘yinda stomp deb ataladi. Quvurdagi tishli guldan esa sakrab o‘tish kerak, uni oddiy stomp bilan yengib bo‘lmaydi.

O‘yinning qiziq joyi — combo yig‘ish. Dushman ustiga har tushganimizda combo bittaga oshadi. Agar yerga tegmasdan beshta dushmanni ketma-ket bossak, Super Star yoqiladi. Bu rejim olti soniya davom etadi. Shu paytda qahramon yengilmas bo‘ladi, tezlik ikki baravar oshadi va oldidagi to‘siqlarni urib uchirib yuboradi. Oddiy holatda yerga tushib qolsak, combo yana noldan boshlanadi.

Keyinroq boss ham chiqadi. Birinchi boss chegarasi ming ochko, keyingilari ikki ming, uch ming va shunday davom etadi. Agar Super Star faol bo‘lsa, boss hujumi uning tugashini kutadi. Boss chap tomondan kelib, qahramonni orqadan quvadi va olov otadi. Bu qismda o‘n ikki soniya olovdan qochib turish kerak. Past olov kelsa sakraymiz, baland olov kelsa egilamiz. Qaysi biri kelishi oldindan ko‘rsatiladi. Omon qolsak, boss ketadi va 250 ochko qo‘shiladi.

Tangalar ham ochko beradi: har bir tanga uchun 10 ochko olamiz. Yugurish davomida ham hisob oshib boradi. Vaqt o‘tgan sari o‘yin tezlashadi, shuning uchun boshida oson tuyulgan joylardan keyinroq o‘tish qiyinlashadi. Urinish tugaganda esa natija chiqadi va yana boshlash mumkin. Eng yuqori rekord saqlanib qoladi.

## Kod tomondan qanday ishlaydi?

Ekranda qahramon oldinga yugurayotgandek ko‘rinadi. Aslida esa uning joyi chap tomonga yaqin turadi, dushmanlar o‘ngdan chapga siljiydi. Fon ham harakatlanadi. Uzoqdagi tog‘lar sekinroq, yaqinroqdagi narsalar tezroq siljigani uchun manzarada chuqurlik seziladi.

Loyiha bir nechta qismga bo‘lingan. `main.tscn` — hammasi birlashadigan asosiy sahna. Qahramon, dushman, boss va interfeys uchun ham alohida sahnalar bor. Masalan, faqat qahramonning sakrashini ko‘rmoqchi bo‘lsak, `player.gd` faylini ochamiz. Ochko yoki combo qanday hisoblanishini ko‘rish uchun esa `main.gd` ga o‘tamiz.

Sakrashning o‘zi shunday ishlaydi: tugma bosilganda qahramonga yuqoriga qarab tezlik beriladi. Havoda gravitatsiya uni pastga tortadi. Godot’dagi `move_and_slide()` harakat va yer bilan to‘qnashuvni bajaradi. Yerga qo‘ngani aniqlangach, qahramon yana sakrashi mumkin bo‘ladi.

Dushmanga tegish esa alohida tekshiriladi. Avval qahramon bilan dushmanning to‘qnashuv shakllari bir-biriga tegdimi, shuni ko‘ramiz. Keyin qahramon yuqoridan tushyaptimi yoki yondan urildimi, shu ajratiladi. Yuqoridan to‘g‘ri tushgan bo‘lsa va dushmanni bosib ezish mumkin bo‘lsa, stomp bo‘ladi. Xavfli yon zarbada esa urinish tugaydi.

Combo yig‘ilganda `main.gd` ichidagi `_stomp()` ishlaydi. Beshga yetgach, `activate_star()` chaqiriladi va olti soniyalik taymer boshlanadi. Taymer tugaguncha tezlik va to‘qnashuv qoidalari Star rejimiga mos ishlaydi.

Bossning o‘z skripti — `boss.gd`. Unda boss avval ogohlantiradi, keyin ekranga kiradi, hujum qiladi va vaqt tugagach chekinadi. Bossning tepasidagi chiziq shu hujumdan qancha vaqt qolganini bildiradi.

O‘yin qismlari bir-biriga signal orqali xabar beradi. Masalan, qahramon sakraganda `jumped` signali chiqadi. Asosiy kod shu xabarni olib, sakrash ovozini chaladi. Shunday qilib, harakat kodi bilan ovoz kodi alohida turadi, lekin birga ishlaydi.

Menyular, hisoblagich va tugmalar `hud.gd` da joylashgan. Tezlik, sakrash kuchi va rejimlarning davomiyligi kabi asosiy qiymatlar esa `config.gd` da. O‘yinni biroz yengillashtirmoqchi bo‘lsak, shu fayldagi boshlang‘ich tezlikni kamaytirib ko‘rishimiz mumkin.

## Ko‘rsatib tushuntirish uchun

Avval ZIP’ni papkaga chiqarib, Godot 4.6’da `project.godot` faylini import qilamiz. Keyin F5 ni bosib, o‘yinni ishga tushiramiz. Loyiha Godot 4.6.3’da tekshirilgan.

Namoyishda avval sakrash va egilishni ko‘rsatish qulay. Keyin bir dushmanning ustiga tushib, oddiy sakrash bilan stompning farqini tushuntirish mumkin. Shundan so‘ng pauzaga qo‘yib, kodni ochamiz. Avval `config.gd`, keyin `player.gd`, oxirida `main.gd` dagi combo qismini ko‘rsatish yetarli.

| Tugma | Nima qiladi? |
| --- | --- |
| Space / W / ↑ | Sakrash |
| S / ↓ | Egilish yoki havodan tez tushish |
| P / Esc | Pauza va davom etish |
| R | Qaytadan boshlash |
| M | Ovozni yoqish yoki o‘chirish |
| F | To‘liq ekran |

Starni ko‘rsatish uchun beshta stompni yerga tegmasdan bajarish kerak. Bossni ko‘rsatish uchun esa navbatdagi ming ochkolik chegaraga yetish kerak bo‘ladi. Shu joylarini namoyishdan oldin bir marta mashq qilib olish yaxshi.

Loyiha bilan berilgan test natijasida 24 ta tekshiruv o‘tgan. Ular orasida sakrash, egilish, beshta stomp, Star muddati, boss hujumi va rekordni saqlash bor. Natijalar `tests/last_result.txt` faylida turibdi.
