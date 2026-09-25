<#
========================================================================================
SYSTEM PSBBN TRANSLATOR - V1
Author: Emerson Teles (CosmicScale)
Standalone Modular Implementation (40 Languages, Self-Contained)
========================================================================================
#>

[CmdletBinding()]
param(
    [string]$Lang,
    [switch]$NoWait
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls

# Universal Suite Root Resolver
$currentDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $currentDir) { $currentDir = (Get-Location).Path }

if (Test-Path (Join-Path $currentDir "PSBBN-Translator.ps1")) {
    $ScriptDir = $currentDir
} elseif (Test-Path (Join-Path $currentDir "..\PSBBN-Translator.ps1")) {
    $ScriptDir = (Resolve-Path (Join-Path $currentDir "..")).Path
} elseif (Test-Path (Join-Path $currentDir "Readme")) {
    $ScriptDir = $currentDir
} elseif (Test-Path (Join-Path (Split-Path -Parent $currentDir) "Readme")) {
    $ScriptDir = Split-Path -Parent $currentDir
} else {
    $ScriptDir = $currentDir
}

# Global 40 Languages Definition
$Languages40 = @(
    @{ id = "1"; code = "ar"; code3 = "ara"; google = "ar"; name = "Arabic"; native = "العربية"; dir = "Arabic"; optExtras = "الإضافات الاختيارية"; gameSelector = "محدد الألعاب"; installGames = "تثبيت الألعاب والتطبيقات"; gameCollection = "مجموعة الألعاب"; mc = "بطاقة الذاكرة"; gameCh = "قناة اللعبة"; gameChPlural = "قنوات الألعاب"; movieCh = "قناة الأفلام"; musicCh = "قناة الموسيقى"; photoCh = "قناة الصور"; internetCh = "قناة الإنترنت"; onlineCh = "القنوات عبر الإنترنت"; channelWord = "القناة"; channelsWord = "القنوات"; psConfirm = "تأكيد"; psBack = "العودة"; psCircle = "الدائرة"; psCross = "X"; psSquare = "المربع"; psTriangle = "المثلث"; psDpad = "D-Pad"; hosdBrowser = "متصفح" },
    @{ id = "2"; code = "bn"; code3 = "ben"; google = "bn"; name = "Bengali"; native = "বাংলা"; dir = "Bengali"; optExtras = "ঐচ্ছিক অতিরিক্ত"; gameSelector = "গেম নির্বাচক"; installGames = "গেম এবং অ্যাপস ইনস্টল করুন"; gameCollection = "গেম কালেকশন"; mc = "মেমরি কার্ড"; gameCh = "গেম চ্যানেল"; gameChPlural = "গেম চ্যানেল"; movieCh = "মুভি চ্যানেল"; musicCh = "মিউজিক চ্যানেল"; photoCh = "ফটো চ্যানেল"; internetCh = "ইন্টারনেট চ্যানেল"; onlineCh = "অনলাইন চ্যানেল"; channelWord = "চ্যানেল"; channelsWord = "চ্যানেলগুলি"; psConfirm = "নিশ্চিত করুন"; psBack = "পিছনে"; psCircle = "সার্কেল"; psCross = "X"; psSquare = "বর্গাকার"; psTriangle = "ত্রিভুজ"; psDpad = "D-Pad"; hosdBrowser = "ব্রাউজার" },
    @{ id = "3"; code = "bg"; code3 = "bul"; google = "bg"; name = "Bulgarian"; native = "Български"; dir = "Bulgarian"; optExtras = "Допълнителни екстри"; gameSelector = "Селектор на игри"; installGames = "Инсталирайте игри и приложения"; gameCollection = "Колекция от игри"; mc = "Карта с памет"; gameCh = "Канал за игри"; gameChPlural = "Канали за игри"; movieCh = "Филмов канал"; musicCh = "Музикален канал"; photoCh = "Фото канал"; internetCh = "Интернет канал"; onlineCh = "Онлайн канали"; channelWord = "Канал"; channelsWord = "Канали"; psConfirm = "Потвърди"; psBack = "Назад"; psCircle = "Кръг"; psCross = "X"; psSquare = "Квадрат"; psTriangle = "Триъгълник"; psDpad = "D-Pad"; hosdBrowser = "Браузър" },
    @{ id = "4"; code = "zh-cn"; code3 = "chi_sim"; google = "zh-CN"; name = "Chinese (Simplified)"; native = "简体中文"; dir = "Chinese (Simplified)"; optExtras = "可选附加功能"; gameSelector = "游戏选择器"; installGames = "安装游戏和应用程序"; gameCollection = "游戏收藏"; mc = "存储卡"; gameCh = "游戏频道"; gameChPlural = "游戏频道"; movieCh = "电影频道"; musicCh = "音乐频道"; photoCh = "图片频道"; internetCh = "网络频道"; onlineCh = "在线频道"; channelWord = "频道"; channelsWord = "频道"; psConfirm = "确认"; psBack = "返回"; psCircle = "圆形"; psCross = "X"; psSquare = "方形"; psTriangle = "��角形"; psDpad = "D-Pad"; hosdBrowser = "浏览器" },
    @{ id = "5"; code = "zh-tw"; code3 = "chi_tra"; google = "zh-TW"; name = "Chinese (Traditional)"; native = "繁體中文"; dir = "Chinese (Traditional)"; optExtras = "可選附加功能"; gameSelector = "遊戲選擇器"; installGames = "安裝遊戲和應用程式"; gameCollection = "遊戲收藏"; mc = "記憶卡"; gameCh = "遊戲頻道"; gameChPlural = "遊戲頻道"; movieCh = "電影頻道"; musicCh = "音樂頻道"; photoCh = "圖片頻道"; internetCh = "網路頻道"; onlineCh = "線上頻道"; channelWord = "頻道"; channelsWord = "頻道"; psConfirm = "確認"; psBack = "返回"; psCircle = "圓形"; psCross = "X"; psSquare = "方形"; psTriangle = "��角形"; psDpad = "D-Pad"; hosdBrowser = "瀏覽器" },
    @{ id = "6"; code = "hr"; code3 = "hrv"; google = "hr"; name = "Croatian"; native = "Hrvatski"; dir = "Croatian"; optExtras = "Izborni dodaci"; gameSelector = "Odabir igara"; installGames = "Instalirajte igre i aplikacije"; gameCollection = "Kolekcija igara"; mc = "Memorijska kartica"; gameCh = "Kanal za igre"; gameChPlural = "Kanali za igre"; movieCh = "Filmski kanal"; musicCh = "Glazbeni kanal"; photoCh = "Foto kanal"; internetCh = "Internetski kanal"; onlineCh = "Online kanali"; channelWord = "Kanal"; channelsWord = "Kanali"; psConfirm = "Potvrdi"; psBack = "Natrag"; psCircle = "Krug"; psCross = "X"; psSquare = "Kvadrat"; psTriangle = "Trokut"; psDpad = "D-Pad"; hosdBrowser = "Preglednik" },
    @{ id = "7"; code = "cs"; code3 = "ces"; google = "cs"; name = "Czech"; native = "Čeština"; dir = "Czech"; optExtras = "Volitelné doplňky"; gameSelector = "Výběr her"; installGames = "Instalace her a aplikací"; gameCollection = "Sbírka her"; mc = "Paměťová karta"; gameCh = "Herní kanál"; gameChPlural = "Herní kanály"; movieCh = "Filmový kanál"; musicCh = "Hudební kanál"; photoCh = "Foto kanál"; internetCh = "Internetový kanál"; onlineCh = "Online kanály"; channelWord = "Kanál"; channelsWord = "Kanály"; psConfirm = "Potvrdit"; psBack = "Zpět"; psCircle = "Kruh"; psCross = "X"; psSquare = "Čtverec"; psTriangle = "Trojúhelník"; psDpad = "D-Pad"; hosdBrowser = "Prohlížeč" },
    @{ id = "8"; code = "da"; code3 = "dan"; google = "da"; name = "Danish"; native = "Dansk"; dir = "Danish"; optExtras = "Valgfrit ekstraudstyr"; gameSelector = "Spilvælger"; installGames = "Installer spil og apps"; gameCollection = "Spilsamling"; mc = "Hukommelseskort"; gameCh = "Spilkanal"; gameChPlural = "Spilkanaler"; movieCh = "Filmkanal"; musicCh = "Musikkanal"; photoCh = "Fotokanal"; internetCh = "Internetkanal"; onlineCh = "Onlinekanaler"; channelWord = "Kanal"; channelsWord = "Kanaler"; psConfirm = "Bekræft"; psBack = "Tilbage"; psCircle = "Cirkel"; psCross = "X"; psSquare = "Firkant"; psTriangle = "Trekant"; psDpad = "D-Pad"; hosdBrowser = "Browser" },
    @{ id = "9"; code = "nl"; code3 = "nld"; google = "nl"; name = "Dutch"; native = "Nederlands"; dir = "Dutch"; optExtras = "Optionele extra's"; gameSelector = "Game Selector"; installGames = "Games en apps installeren"; gameCollection = "Gamecollectie"; mc = "Geheugenkaart"; gameCh = "Gamekanaal"; gameChPlural = "Gamekanalen"; movieCh = "Filmkanaal"; musicCh = "Muziekkanaal"; photoCh = "Fotokanaal"; internetCh = "Internetkanaal"; onlineCh = "Onlinekanalen"; channelWord = "Kanaal"; channelsWord = "Kanalen"; psConfirm = "Bevestigen"; psBack = "Terug"; psCircle = "Cirkel"; psCross = "X"; psSquare = "Vierkant"; psTriangle = "Driehoek"; psDpad = "D-Pad"; hosdBrowser = "Browser" },
    @{ id = "10"; code = "tl"; code3 = "fil"; google = "tl"; name = "Filipino"; native = "Tagalog"; dir = "Filipino"; optExtras = "Mga Opsyonal na Extra"; gameSelector = "Tagapili ng Laro"; installGames = "I-install ang Mga Laro at App"; gameCollection = "Koleksyon ng Laro"; mc = "Memory Card"; gameCh = "Channel ng Laro"; gameChPlural = "Mga Channel ng Laro"; movieCh = "Channel ng Pelikula"; musicCh = "Channel ng Musika"; photoCh = "Channel ng Larawan"; internetCh = "Channel sa Internet"; onlineCh = "Mga Online na Channel"; channelWord = "Channel"; channelsWord = "Mga Channel"; psConfirm = "Kumpirmahin"; psBack = "Bumalik"; psCircle = "Circle"; psCross = "X"; psSquare = "Square"; psTriangle = "Triangle"; psDpad = "D-Pad"; hosdBrowser = "Browser" },
    @{ id = "11"; code = "fi"; code3 = "fin"; google = "fi"; name = "Finnish"; native = "Suomi"; dir = "Finnish"; optExtras = "Valinnaiset lisäosat"; gameSelector = "Game Selector"; installGames = "Asenna pelejä ja sovelluksia"; gameCollection = "Pelikokoelma"; mc = "Muistikortti"; gameCh = "Pelikanava"; gameChPlural = "Pelikanavat"; movieCh = "Elokuvakanava"; musicCh = "Musiikkikanava"; photoCh = "Valokuvakanava"; internetCh = "Internet-kanava"; onlineCh = "Online-kanavat"; channelWord = "Kanava"; channelsWord = "Kanavat"; psConfirm = "Vahvista"; psBack = "Takaisin"; psCircle = "Ympyrä"; psCross = "X"; psSquare = "Neliö"; psTriangle = "Kolmio"; psDpad = "D-Pad"; hosdBrowser = "Selain" },
    @{ id = "12"; code = "fr"; code3 = "fre"; google = "fr"; name = "French"; native = "Français"; dir = "French"; optExtras = "Extras en option"; gameSelector = "Sélecteur de jeux"; installGames = "Installer des jeux et des applications"; gameCollection = "Collection de jeux"; mc = "Carte mémoire"; gameCh = "Chaîne Jeux"; gameChPlural = "Chaînes de Jeux"; movieCh = "Chaîne Films"; musicCh = "Chaîne Musique"; photoCh = "Chaîne Photos"; internetCh = "Chaîne Internet"; onlineCh = "Chaînes en Ligne"; channelWord = "Chaîne"; channelsWord = "Chaînes"; psConfirm = "Valider"; psBack = "Retour"; psCircle = "Rond"; psCross = "Croix"; psSquare = "Carré"; psTriangle = "Triangle"; psDpad = "Croix directionnelle"; hosdBrowser = "Navigateur" },
    @{ id = "13"; code = "de"; code3 = "ger"; google = "de"; name = "German"; native = "Deutsch"; dir = "German"; optExtras = "Optionale Extras"; gameSelector = "Spieleauswahl"; installGames = "Spiele und Apps installieren"; gameCollection = "Spielesammlung"; mc = "Speicherkarte"; gameCh = "Spiele-Kanal"; gameChPlural = "Spiele-Kanäle"; movieCh = "Film-Kanal"; musicCh = "Musik-Kanal"; photoCh = "Foto-Kanal"; internetCh = "Internet-Kanal"; onlineCh = "Online-Kanäle"; channelWord = "Kanal"; channelsWord = "Kanäle"; psConfirm = "Bestätigen"; psBack = "Zurück"; psCircle = "Kreis"; psCross = "Kreuz"; psSquare = "Quadrat"; psTriangle = "Dreieck"; psDpad = "Steuerkreuz"; hosdBrowser = "Browser" },
    @{ id = "14"; code = "el"; code3 = "ell"; google = "el"; name = "Greek"; native = "Ελληνικά"; dir = "Greek"; optExtras = "Προαιρετικά πρόσθετα"; gameSelector = "Επιλογέας παιχνιδιών"; installGames = "Εγκατάσταση παιχνιδιών και εφαρμογών"; gameCollection = "Συλλογή παιχνιδιών"; mc = "Κάρτα μνήμης"; gameCh = "Κανάλι παιχνιδιού"; gameChPlural = "Κανάλια παιχνιδιών"; movieCh = "Κανάλι ταινίας"; musicCh = "Μουσικό κανάλι"; photoCh = "Κανάλι φωτογραφιών"; internetCh = "Κανάλι Διαδικτύου"; onlineCh = "Διαδικτυακά κανάλια"; channelWord = "Κανάλια"; channelsWord = "Κανάλια"; psConfirm = "Επιβεβαίωση"; psBack = "Πίσω"; psCircle = "Κύκλος"; psCross = "X"; psSquare = "Τετράγωνο"; psTriangle = "Τρίγωνο"; psDpad = "D-Pad"; hosdBrowser = "Πρόγραμμα περιήγησης" },
    @{ id = "15"; code = "iw"; code3 = "heb"; google = "iw"; name = "Hebrew"; native = "עברית"; dir = "Hebrew"; optExtras = "תוספות אופציונליות"; gameSelector = "בורר משחקים"; installGames = "התקן משחקים ואפליקציות"; gameCollection = "אוסף משחקים"; mc = "כרטיס זיכרון"; gameCh = "ערוץ משחק"; gameChPlural = "ערוצי משחקים"; movieCh = "ערוץ סרטים"; musicCh = "ערוץ מוזיקה"; photoCh = "ערוץ תמונות"; internetCh = "ערוץ אינטרנט"; onlineCh = "ערוצים מקוונים"; channelWord = "ערוץ"; channelsWord = "ערוצים"; psConfirm = "אישור"; psBack = "חזרה"; psCircle = "עיגול"; psCross = "X"; psSquare = "ריבוע"; psTriangle = "משולש"; psDpad = "D-Pad"; hosdBrowser = "דפדפן" },
    @{ id = "16"; code = "hi"; code3 = "hin"; google = "hi"; name = "Hindi"; native = "हिन्दी"; dir = "Hindi"; optExtras = "वैकल्पिक अतिरिक्त"; gameSelector = "गेम चयनकर्ता"; installGames = "गेम और ऐप्स इंस्टॉल करें"; gameCollection = "गेम कलेक्शन"; mc = "मेमोरी कार्ड"; gameCh = "गेम चैनल"; gameChPlural = "गेम चैनल"; movieCh = "मूवी चैनल"; musicCh = "संगीत चैनल"; photoCh = "फोटो चैनल"; internetCh = "इंटरनेट चैनल"; onlineCh = "ऑनलाइन चैनल"; channelWord = "चैनल"; channelsWord = "चैनल"; psConfirm = "पुष्टि करें"; psBack = "वापस"; psCircle = "वृत्त"; psCross = "X"; psSquare = "वर्ग"; psTriangle = "त्रिभुज"; psDpad = "D-Pad"; hosdBrowser = "ब्राउज़र" },
    @{ id = "17"; code = "hu"; code3 = "hun"; google = "hu"; name = "Hungarian"; native = "Magyar"; dir = "Hungarian"; optExtras = "Opcionális Extrák"; gameSelector = "Játékválasztó"; installGames = "Játékok és alkalmazások telepítése"; gameCollection = "Játékgyűjtemény"; mc = "Memóriakártya"; gameCh = "Játék csatorna"; gameChPlural = "Játékcsatornák"; movieCh = "Filmcsatorna"; musicCh = "Zenei csatorna"; photoCh = "Fotócsatorna"; internetCh = "Internetes csatorna"; onlineCh = "Online csatornák"; channelWord = "Csatorna"; channelsWord = "Csatornák"; psConfirm = "Megerősítés"; psBack = "Vissza"; psCircle = "Kör"; psCross = "X"; psSquare = "Négyzet"; psTriangle = "Háromszög"; psDpad = "D-Pad"; hosdBrowser = "Böngésző" },
    @{ id = "18"; code = "id"; code3 = "ind"; google = "id"; name = "Indonesian"; native = "Bahasa Indonesia"; dir = "Indonesian"; optExtras = "Ekstra Opsional"; gameSelector = "Pemilih Game"; installGames = "Instal Game dan Aplikasi"; gameCollection = "Koleksi Game"; mc = "Kartu Memori"; gameCh = "Saluran Game"; gameChPlural = "Saluran Permainan"; movieCh = "Saluran Film"; musicCh = "Saluran Musik"; photoCh = "Saluran Foto"; internetCh = "Saluran Internet"; onlineCh = "Saluran Online"; channelWord = "Saluran"; channelsWord = "Saluran"; psConfirm = "Konfirmasi"; psBack = "Kembali"; psCircle = "Lingkaran"; psCross = "X"; psSquare = "Kotak"; psTriangle = "Segitiga"; psDpad = "D-Pad"; hosdBrowser = "Peramban" },
    @{ id = "19"; code = "it"; code3 = "ita"; google = "it"; name = "Italian"; native = "Italiano"; dir = "Italian"; optExtras = "Extra opzionali"; gameSelector = "Selettore giochi"; installGames = "Installa giochi e app"; gameCollection = "Raccolta giochi"; mc = "Scheda di memoria"; gameCh = "Canale Giochi"; gameChPlural = "Canali Giochi"; movieCh = "Canale Film"; musicCh = "Canale Musica"; photoCh = "Canale Foto"; internetCh = "Canale Internet"; onlineCh = "Canali Online"; channelWord = "Canale"; channelsWord = "Canali"; psConfirm = "Conferma"; psBack = "Indietro"; psCircle = "Cerchio"; psCross = "Croce"; psSquare = "Quadrato"; psTriangle = "Triangolo"; psDpad = "Croce direzionale"; hosdBrowser = "Browser" },
    @{ id = "20"; code = "ja"; code3 = "jpn"; google = "ja"; name = "Japanese"; native = "日本語"; dir = "Japanese"; optExtras = "オプションの追加機能"; gameSelector = "ゲーム セレクター"; installGames = "ゲームとアプリのインストール"; gameCollection = "ゲーム コレクション"; mc = "メモリ カード"; gameCh = "ゲームチャンネル"; gameChPlural = "ゲームチャンネル"; movieCh = "ムービーチャンネル"; musicCh = "ミュージックチャンネル"; photoCh = "フォトチャンネル"; internetCh = "インターネットチャンネル"; onlineCh = "オンラインチャンネル"; channelWord = "チャンネル"; channelsWord = "チャンネル"; psConfirm = "決定"; psBack = "戻る"; psCircle = "○"; psCross = "×"; psSquare = "□"; psTriangle = "△"; psDpad = "方向キー"; hosdBrowser = "ブラウザ" },
    @{ id = "21"; code = "ko"; code3 = "kor"; google = "ko"; name = "Korean"; native = "한국어"; dir = "Korean"; optExtras = "추가 옵션"; gameSelector = "게임 선택기"; installGames = "게임 및 앱 설치"; gameCollection = "게임 컬렉션"; mc = "메모리 카드"; gameCh = "게임 채널"; gameChPlural = "게임 채널"; movieCh = "영화 채널"; musicCh = "음악 채널"; photoCh = "사진 채널"; internetCh = "인터넷 채널"; onlineCh = "온라인 채널"; channelWord = "채널"; channelsWord = "채널"; psConfirm = "확인"; psBack = "뒤로"; psCircle = "원"; psCross = "X"; psSquare = "정사각형"; psTriangle = "삼각형"; psDpad = "D-Pad"; hosdBrowser = "브라우저" },
    @{ id = "22"; code = "ms"; code3 = "msa"; google = "ms"; name = "Malay"; native = "Bahasa Melayu"; dir = "Malay"; optExtras = "Tambahan Pilihan"; gameSelector = "Pemilih Permainan"; installGames = "Pasang Permainan dan Apl"; gameCollection = "Koleksi Permainan"; mc = "Kad Memori"; gameCh = "Saluran Permainan"; gameChPlural = "Saluran Permainan"; movieCh = "Saluran Filem"; musicCh = "Saluran Muzik"; photoCh = "Saluran Foto"; internetCh = "Saluran Internet"; onlineCh = "Saluran Dalam Talian"; channelWord = "Saluran"; channelsWord = "Saluran"; psConfirm = "Sahkan"; psBack = "Belakang"; psCircle = "Bulatan"; psCross = "X"; psSquare = "Segiempat"; psTriangle = "Segitiga"; psDpad = "D-Pad"; hosdBrowser = "Pelayar" },
    @{ id = "23"; code = "mr"; code3 = "mar"; google = "mr"; name = "Marathi"; native = "मराठी"; dir = "Marathi"; optExtras = "पर्यायी अतिरिक्त"; gameSelector = "गेम निवडक"; installGames = "गेम आणि ॲप्स स्थापित करा"; gameCollection = "गेम संग्रह"; mc = "मेमरी कार्ड"; gameCh = "गेम चॅनेल"; gameChPlural = "गेम चॅनेल"; movieCh = "चित्रपट चॅनेल"; musicCh = "संगीत चॅनेल"; photoCh = "फोटो चॅनेल"; internetCh = "इंटरनेट चॅनेल"; onlineCh = "ऑनलाइन चॅनेल"; channelWord = "चॅनेल"; channelsWord = "चॅनेल"; psConfirm = "पुष्टी करा"; psBack = "मागे"; psCircle = "वर्तुळ"; psCross = "X"; psSquare = "चौरस"; psTriangle = "त्रिकोण"; psDpad = "D-Pad"; hosdBrowser = "ब्राउझर" },
    @{ id = "24"; code = "no"; code3 = "nor"; google = "no"; name = "Norwegian"; native = "Norsk"; dir = "Norwegian"; optExtras = "Valgfritt ekstra"; gameSelector = "Spillvelger"; installGames = "Installer spill og apper"; gameCollection = "Spillsamling"; mc = "Minnekort"; gameCh = "Spillkanal"; gameChPlural = "Spillkanaler"; movieCh = "Filmkanal"; musicCh = "Musikkkanal"; photoCh = "Fotokanal"; internetCh = "Internettkanal"; onlineCh = "Onlinekanaler"; channelWord = "Kanal"; channelsWord = "Kanaler"; psConfirm = "Bekreft"; psBack = "Tilbake"; psCircle = "Sirkel"; psCross = "X"; psSquare = "Firkant"; psTriangle = "Triangle"; psDpad = "D-Pad"; hosdBrowser = "Nettleser" },
    @{ id = "25"; code = "fa"; code3 = "fas"; google = "fa"; name = "Persian"; native = "فارسی"; dir = "Persian"; optExtras = "موارد اضافی اختیاری"; gameSelector = "انتخابگر بازی"; installGames = "نصب بازی ها و برنامه ها"; gameCollection = "مجموعه بازی"; mc = "کارت حافظه"; gameCh = "کانال بازی"; gameChPlural = "کانال های بازی"; movieCh = "کانال فیلم"; musicCh = "کانال موسیقی"; photoCh = "کانال عکس"; internetCh = "کانال اینترنتی"; onlineCh = "کانال های آنلاین"; channelWord = "کانال"; channelsWord = "کانال ها"; psConfirm = "تایید"; psBack = "برگشت"; psCircle = "دایره"; psCross = "X"; psSquare = "مربع"; psTriangle = "مثلث"; psDpad = "D-Pad"; hosdBrowser = "مرورگر" },
    @{ id = "26"; code = "pl"; code3 = "pol"; google = "pl"; name = "Polish"; native = "Polski"; dir = "Polish"; optExtras = "Dodatki opcjonalne"; gameSelector = "Selektor gier"; installGames = "Zainstaluj gry i aplikacje"; gameCollection = "Kolekcja gier"; mc = "Karta pamięci"; gameCh = "Kanał gier"; gameChPlural = "Kanały z grami"; movieCh = "Kanał filmowy"; musicCh = "Kanał muzyczny"; photoCh = "Kanał fotograficzny"; internetCh = "Kanał internetowy"; onlineCh = "Kanały online"; channelWord = "Kanał"; channelsWord = "Kanały"; psConfirm = "Potwierdź"; psBack = "Wróć"; psCircle = "Okrąg"; psCross = "X"; psSquare = "Kwadrat"; psTriangle = "Trójkąt"; psDpad = "D-Pad"; hosdBrowser = "Przeglądarka" },
    @{ id = "27"; code = "pt"; code3 = "por"; google = "pt"; name = "Portuguese (Brazil)"; native = "Português (Brasil)"; dir = "Portuguese (Brazil)"; optExtras = "Extras Opcionais"; gameSelector = "Seletor de Jogos"; installGames = "Instalar Jogos e Aplicativos"; gameCollection = "Coleção de Jogos"; mc = "Memory Card"; gameCh = "Canal de Jogos"; gameChPlural = "Canais de Jogos"; movieCh = "Canal de Filmes"; musicCh = "Canal de Música"; photoCh = "Canal de Fotos"; internetCh = "Canal de Internet"; onlineCh = "Canais Online"; channelWord = "Canal"; channelsWord = "Canais"; psConfirm = "Confirmar"; psBack = "Voltar"; psCircle = "Círculo"; psCross = "Cruz"; psSquare = "Quadrado"; psTriangle = "Triângulo"; psDpad = "D-Pad"; hosdBrowser = "Rotina de pesquisa" },
    @{ id = "28"; code = "pt-pt"; code3 = "por_pt"; google = "pt-PT"; name = "Portuguese (Portugal)"; native = "Português (Portugal)"; dir = "Portuguese (Portugal)"; optExtras = "Extras Opcionais"; gameSelector = "Seletor de Jogos"; installGames = "Instalar Jogos e Aplicações"; gameCollection = "Coleção de Jogos"; mc = "Memory Card"; gameCh = "Canal de Jogos"; gameChPlural = "Canais de Jogos"; movieCh = "Canal de Filmes"; musicCh = "Canal de Música"; photoCh = "Canal de Fotos"; internetCh = "Canal de Internet"; onlineCh = "Canais Online"; channelWord = "Canal"; channelsWord = "Canais"; psConfirm = "Confirmar"; psBack = "Voltar"; psCircle = "Círculo"; psCross = "Cruz"; psSquare = "Quadrado"; psTriangle = "Triângulo"; psDpad = "D-Pad"; hosdBrowser = "Rotina de pesquisa" },
    @{ id = "29"; code = "ro"; code3 = "ron"; google = "ro"; name = "Romanian"; native = "Română"; dir = "Romanian"; optExtras = "Suplimente opționale"; gameSelector = "Selector de jocuri"; installGames = "Instalați jocuri și aplicații"; gameCollection = "Colecția de jocuri"; mc = "Card de memorie"; gameCh = "Canalul de jocuri"; gameChPlural = "Canale de jocuri"; movieCh = "Canal de film"; musicCh = "Canal de muzică"; photoCh = "Canal foto"; internetCh = "Canal de Internet"; onlineCh = "Canale online"; channelWord = "Canal"; channelsWord = "Canale"; psConfirm = "Confirmare"; psBack = "Înapoi"; psCircle = "Cerc"; psCross = "X"; psSquare = "Pătrat"; psTriangle = "Triunghi"; psDpad = "D-Pad"; hosdBrowser = "Browser" },
    @{ id = "30"; code = "ru"; code3 = "rus"; google = "ru"; name = "Russian"; native = "Русский"; dir = "Russian"; optExtras = "Дополнительные возможности"; gameSelector = "Выбор игр"; installGames = "Установка игр и приложений"; gameCollection = "Коллекция игр"; mc = "Карта памяти"; gameCh = "Игровой канал"; gameChPlural = "Игровые каналы"; movieCh = "Канал фильмов"; musicCh = "Музыкальный канал"; photoCh = "Фотоканал"; internetCh = "Интернет-канал"; onlineCh = "Онлайн-каналы"; channelWord = "Канал"; channelsWord = "Каналы"; psConfirm = "Подтвердить"; psBack = "Назад"; psCircle = "Круг"; psCross = "Крест"; psSquare = "Квадрат"; psTriangle = "Треугольник"; psDpad = "D-Pad"; hosdBrowser = "Браузер" },
    @{ id = "31"; code = "sr"; code3 = "srp"; google = "sr"; name = "Serbian"; native = "Српски"; dir = "Serbian"; optExtras = "Опциони додаци"; gameSelector = "Бирач игара"; installGames = "Инсталирајте игре и апликације"; gameCollection = "Колекција игара"; mc = "Меморијска картица"; gameCh = "Канал игре"; gameChPlural = "Канали за игре"; movieCh = "Филмски канал"; musicCh = "Музички канал"; photoCh = "Фото канал"; internetCh = "Интернет канал"; onlineCh = "Канали на мрежи"; channelWord = "Канал"; channelsWord = "Канали"; psConfirm = "Потврди"; psBack = "Назад"; psCircle = "Круг"; psCross = "X"; psSquare = "Квадрат"; psTriangle = "Троугао"; psDpad = "D-Pad"; hosdBrowser = "Прегледач" },
    @{ id = "32"; code = "sk"; code3 = "slk"; google = "sk"; name = "Slovak"; native = "Slovenčina"; dir = "Slovak"; optExtras = "Voliteľné doplnky"; gameSelector = "Výber hier"; installGames = "Inštalácia hier a aplikácií"; gameCollection = "Zbierka hier"; mc = "Pamäťová karta"; gameCh = "Kanál hry"; gameChPlural = "Herné kanály"; movieCh = "Filmový kanál"; musicCh = "Hudobný kanál"; photoCh = "Foto kanál"; internetCh = "Internetový kanál"; onlineCh = "Online kanály"; channelWord = "Kanál"; channelsWord = "Kanály"; psConfirm = "Potvrdiť"; psBack = "Späť"; psCircle = "Kruh"; psCross = "X"; psSquare = "Štvorec"; psTriangle = "Trojuholník"; psDpad = "D-Pad"; hosdBrowser = "Prehliadač" },
    @{ id = "33"; code = "es"; code3 = "spa"; google = "es"; name = "Spanish"; native = "Español"; dir = "Spanish"; optExtras = "Extras Opcionales"; gameSelector = "Selector de Juegos"; installGames = "Instalar Juegos y Aplicaciones"; gameCollection = "Colección de Juegos"; mc = "Tarjeta de memoria"; gameCh = "Canal de Juegos"; gameChPlural = "Canales de Juegos"; movieCh = "Canal de Películas"; musicCh = "Canal de Música"; photoCh = "Canal de Fotos"; internetCh = "Canal de Internet"; onlineCh = "Canales Online"; channelWord = "Canal"; channelsWord = "Canales"; psConfirm = "Confirmar"; psBack = "Volver"; psCircle = "Círculo"; psCross = "X"; psSquare = "Cuadrado"; psTriangle = "Triángulo"; psDpad = "Cruceta"; hosdBrowser = "Navegador" },
    @{ id = "34"; code = "sv"; code3 = "swe"; google = "sv"; name = "Swedish"; native = "Svenska"; dir = "Swedish"; optExtras = "Tillval"; gameSelector = "Spelväljare"; installGames = "Installera spel och appar"; gameCollection = "Spelsamling"; mc = "Minneskort"; gameCh = "Spelkanal"; gameChPlural = "Spelkanaler"; movieCh = "Filmkanal"; musicCh = "Musikkanal"; photoCh = "Fotokanal"; internetCh = "Internetkanal"; onlineCh = "Onlinekanaler"; channelWord = "Kanal"; channelsWord = "Kanaler"; psConfirm = "Bekräfta"; psBack = "Tillbaka"; psCircle = "Cirkel"; psCross = "X"; psSquare = "Fyrkant"; psTriangle = "Triangel"; psDpad = "D-Pad"; hosdBrowser = "Webbläsare" },
    @{ id = "35"; code = "ta"; code3 = "tam"; google = "ta"; name = "Tamil"; native = "தமிழ்"; dir = "Tamil"; optExtras = "விருப்ப கூடுதல்"; gameSelector = "கேம் செலக்டர்"; installGames = "கேம்கள் மற்றும் பயன்பாடுகளை நிறுவவும்"; gameCollection = "கேம் சேகரிப்பு"; mc = "மெமரி கார்டு"; gameCh = "கேம் சேனல்"; gameChPlural = "கேம் சேனல்கள்"; movieCh = "மூவி சேனல்"; musicCh = "இசை சேனல்"; photoCh = "புகைப்பட சேனல்"; internetCh = "இணைய சேனல்"; onlineCh = "ஆன்லைன் சேனல்கள்"; channelWord = "சேனல்"; channelsWord = "சேனல்கள்"; psConfirm = "உறுதிப்படுத்தவும்"; psBack = "பின்"; psCircle = "வட்டம்"; psCross = "X"; psSquare = "சதுரம்"; psTriangle = "முக்கோணம்"; psDpad = "D-Pad"; hosdBrowser = "உலாவி" },
    @{ id = "36"; code = "te"; code3 = "tel"; google = "te"; name = "Telugu"; native = "తెలుగు"; dir = "Telugu"; optExtras = "ఐచ్ఛిక ఎక్స్‌ట్రాలు"; gameSelector = "గేమ్ సెలెక్టర్"; installGames = "గేమ్‌లు మరియు యాప్‌లను ఇన్‌స్టాల్ చేయండి"; gameCollection = "గేమ్ కలెక్షన్"; mc = "మెమరీ కార్డ్"; gameCh = "గేమ్ ఛానెల్"; gameChPlural = "గేమ్ ఛానెల్‌లు"; movieCh = "మూవీ ఛానల్"; musicCh = "మ్యూజిక్ ఛానల్"; photoCh = "ఫోటో ఛానల్"; internetCh = "ఇంటర్నెట్ ఛానెల్"; onlineCh = "ఆన్‌లైన్ ఛానెల్‌లు"; channelWord = "ఛానెల్"; channelsWord = "ఛానెల్‌లు"; psConfirm = "నిర్ధారించండి"; psBack = "వెనుక"; psCircle = "సర్కిల్"; psCross = "X"; psSquare = "స్క్వేర్"; psTriangle = "త్రిభుజం"; psDpad = "D-Pad"; hosdBrowser = "బ్రౌజర్" },
    @{ id = "37"; code = "th"; code3 = "tha"; google = "th"; name = "Thai"; native = "ไทย"; dir = "Thai"; optExtras = "ตัวเลือกพิเศษ"; gameSelector = "ตัวเลือกเกม"; installGames = "ติดตั้งเกมและแอพ"; gameCollection = "คอลเลกชันเกม"; mc = "การ์ดหน่วยความจำ"; gameCh = "ช่องเกม"; gameChPlural = "ช่องเกม"; movieCh = "ช่องภาพยนตร์"; musicCh = "ช่องเพลง"; photoCh = "ช่องภาพ"; internetCh = "ช่องอินเทอร์เน็ต"; onlineCh = "ช่องออนไลน์"; channelWord = "ช่อง"; channelsWord = "ช่อง"; psConfirm = "ยืนยัน"; psBack = "กลับ"; psCircle = "วงกลม"; psCross = "X"; psSquare = "สี่เหลี่ยม"; psTriangle = "สามเหลี่ยม"; psDpad = "D-Pad"; hosdBrowser = "เบราว์เซอร์" },
    @{ id = "38"; code = "tr"; code3 = "tur"; google = "tr"; name = "Turkish"; native = "Türkçe"; dir = "Turkish"; optExtras = "İsteğe Bağlı Ekstralar"; gameSelector = "Oyun Seçici"; installGames = "Oyunları ve Uygulamaları Yükle"; gameCollection = "Oyun Koleksiyonu"; mc = "Hafıza Kartı"; gameCh = "Oyun Kanalı"; gameChPlural = "Oyun Kanalları"; movieCh = "Film Kanalı"; musicCh = "Müzik Kanalı"; photoCh = "Fotoğraf Kanalı"; internetCh = "İnternet Kanalı"; onlineCh = "Çevrimiçi Kanallar"; channelWord = "Kanal"; channelsWord = "Kanallar"; psConfirm = "Onayla"; psBack = "Geri"; psCircle = "Daire"; psCross = "X"; psSquare = "Kare"; psTriangle = "Üçgen"; psDpad = "D-Pad"; hosdBrowser = "Tarayıcı" },
    @{ id = "39"; code = "uk"; code3 = "ukr"; google = "uk"; name = "Ukrainian"; native = "Українська"; dir = "Ukrainian"; optExtras = "Додаткові додаткові функції"; gameSelector = "Вибір ігор"; installGames = "Встановіть ігри та програми"; gameCollection = "Колекція ігор"; mc = "Карта пам’яті"; gameCh = "Ігровий канал"; gameChPlural = "Ігрові канали"; movieCh = "Канал фільмів"; musicCh = "Музичний канал"; photoCh = "Фотоканал"; internetCh = "Інтернет-канал"; onlineCh = "Онлайн-канали"; channelWord = "Канал"; channelsWord = "Канали"; psConfirm = "Підтвердити"; psBack = "Назад"; psCircle = "Круг"; psCross = "X"; psSquare = "Квадрат"; psTriangle = "Трикутник"; psDpad = "D-Pad"; hosdBrowser = "Браузер" },
    @{ id = "40"; code = "vi"; code3 = "vie"; google = "vi"; name = "Vietnamese"; native = "Tiếng Việt"; dir = "Vietnamese"; optExtras = "Các tính năng bổ sung tùy chọn"; gameSelector = "Bộ chọn trò chơi"; installGames = "Cài đặt trò chơi và ứng dụng"; gameCollection = "Bộ sưu tập trò chơi"; mc = "Thẻ nhớ"; gameCh = "Kênh trò chơi"; gameChPlural = "Kênh Trò chơi"; movieCh = "Kênh Phim"; musicCh = "Kênh Âm nhạc"; photoCh = "Kênh Ảnh"; internetCh = "Kênh Internet"; onlineCh = "Kênh Trực tuyến"; channelWord = "Kênh"; channelsWord = "Kênh"; psConfirm = "Xác nhận"; psBack = "Quay lại"; psCircle = "Vòng tròn"; psCross = "X"; psSquare = "Hình vuông"; psTriangle = "Tam giác"; psDpad = "D-Pad"; hosdBrowser = "Trình duyệt" }
)

# Global 40 Languages UI Translations
$Global:UI_Translations40 = @{
    "ar" = @{
        "All40Success" = 'جميع اللغات الأربعين (كاملة متعددة اللغات)'
        "AllLanguages" = 'ترجمة جميع اللغات (1 - 40)'
        "BackMenu" = 'الرجوع إلى القائمة الرئيسية'
        "CancelOption" = 'العودة'
        "CannotConnectGithub" = '[!] لا يمكن الاتصال بـ GitHub: {0}'
        "ChangeLanguage" = 'تغيير لغة واجهة المستخدم'
        "ChangelogMainNotFoundTitle" = '[!] خطأ: لا يمكن تنزيل أو تحديد موقع CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'المترجم الرئيسي لـ PSBBN Changelog [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] خطأ: لا يمكن تنزيل أو تحديد موقع CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'مترجم PSBBN Changelog Patch [By Emerson Teles]'
        "ChooseOption" = 'حدد خيارًا:'
        "CompletionBanner" = '[OK] تم الانتهاء من ترجمة {0} بنجاح - 100%'
        "DescLauncher" = 'يقوم بإنشاء وتحديث PSBBN Launcher لنظام التشغيل Windows مع دعم لجميع اللغات الأربعين.'
        "DescMain" = 'يترجم ملاحظات إصدار المثبت الرئيسي وسجل التغيير (changelog_main_eng.txt).'
        "DescPatch" = 'يترجم سجل التصحيح والإصلاحات وملاحظات تحديث القناة (changelog_patch_eng.txt).'
        "DescReadme" = 'يترجم PSBBN README.md الرسمي الذي يحافظ على تنسيق تخفيض السعر والروابط.'
        "DescScript" = 'يترجم جميع سلاسل واجهة المستخدم البالغ عددها 458 لـ البرنامج النصي لتثبيت Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'يترجم جميع ملفات نظام PS2 PSBBN (مربعات حوار XML، والأدلة، والقوائم، ومساعدة NetFront/ATOK).'
        "DestFile" = 'الوجهة:'
        "DownloadingLatestGithub" = '[i] جارٍ تنزيل أحدث إصدار رسمي من GitHub...'
        "DownloadingOfficial" = '[*] جارٍ تنزيل الملف الرسمي من مستودع GitHub...'
        "EnglishOption" = 'الإنجليزية (افتراضي)'
        "EngTxtEnsureFile" = 'يرجى التأكد من وجود ملف "eng.txt" في مجلد "الإدخال".'
        "EngTxtErrorTitle" = '[!] خطأ: لم يتم العثور على ملف ENG.TXT!'
        "EngTxtNotFoundDownloading" = '[*] لم يتم العثور على eng.txt. جاري التحميل من المستودع الرسمي...'
        "EnsureConnected" = 'يرجى التأكد من اتصالك بالإنترنت أو وضع الملف في دليل الإدخال.'
        "ExitOption" = 'خروج'
        "ExpectedPath" = 'المسار المتوقع: {0}'
        "ExtractingPack" = '[*] استخراج حزمة الترجمة PSBBN v3.5...'
        "FileNotFoundError" = '[خطأ] لم يتم العثور على الملف: {0}'
        "GeneratedFile" = '[موافق] الملف الذي تم إنشاؤه: {0}'
        "GenericEnsureInternetOrInput" = 'يرجى التأكد من اتصالك بالإنترنت أو وجود الملف في مجلد "الإدخال".'
        "IndividualBlocks" = 'الكتل الفردية: {0}'
        "IndividualBlocksNotice" = '[موافق] الكتل الفردية لـ CosmicScale: {0}_'
        "InputFileDeleted" = '[موافق] تم حذف الملف (الملفات) من مجلد الإدخال.'
        "InputFileKept" = '[موافق] يتم الاحتفاظ بالملف (الملفات) في مجلد الإدخال.'
        "InvalidOption" = 'خيار غير صالح! اضغط على Enter للمحاولة مرة أخرى...'
        "LangAppliedSuccess" = '[OK] تم تطبيق لغة الواجهة بنجاح: {0} ({1})'
        "LauncherAutoDetect" = '[موافق] تم تمكين الاكتشاف التلقائي للغة نظام Windows.'
        "LauncherBaseNotFoundTitle" = '[!] خطأ: لا يمكن تنزيل البرنامج النصي للمشغل الأساسي أو تحديد موقعه!'
        "LauncherIntegrated" = '[موافق] الدعم المتكامل للغة (اللغات) {0}_ في PSBBN Launcher لنظام التشغيل Windows!'
        "LauncherPrompt" = 'اختر لغة واحدة أو أكثر (على سبيل المثال 7 أو 1 أو 2 أو 3 أو 1-5 أو A):'
        "LauncherTip1" = '- أدخل رقمًا واحدًا لإنشاء الملف بهذه اللغة فقط.'
        "LauncherTipAll" = '- أدخل \''A\'' لإنشاء الملف الكامل بجميع اللغات الأربعين.'
        "LauncherTipHeader" = '* نصيحة: يؤدي كل تنفيذ إلى إنشاء ملف نظيف يحتوي فقط على اللغة (اللغات) المختارة.'
        "LauncherTipMulti" = '- أدخل أرقامًا متعددة مفصولة بفاصلة (على سبيل المثال 1، 2، 3) لإنشاء تلك اللغات.'
        "LauncherTipRange" = '- أدخل نطاقًا (على سبيل المثال 1-5) لإنشاء هذا النطاق من اللغات.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[ب] الشاشة السابقة'
        "NavDeleteInput" = '[X] حذف الملف من مجلد الإدخال'
        "NavEnter" = '[أدخل] القائمة الرئيسية'
        "NavExit" = '[خروج] خروج'
        "NavInstructions" = '[أدخل] القائمة الرئيسية |  [ب] الشاشة السابقة |  [خروج] خروج'
        "NavKeepInput" = '[V] احتفظ بالملف في مجلد الإدخال'
        "OfficialDownloadSuccess" = '[موافق] تم تنزيل الملف الرسمي بنجاح ({0:N0} بايت).'
        "PkgCompressingGz" = '[*] جارٍ الضغط إلى "bnupdate.tar.gz" عبر .NET GZipStream...'
        "PkgCreatingTar" = '[*] إنشاء "bnupdate.tar" وتعيين أذونات تنفيذ POSIX (+x)...'
        "PkgErrorTar" = '[!] تعذر إنشاء bnupdate.tar.'
        "PkgGenTitle" = 'إنشاء حزمة تثبيت PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. تظل الأنسجة (.tm2 و.png) باللغة الإنجليزية (تتطلب إعادة تصميم الرسم يدويًا).'
        "PkgNotice2" = '2. تتم ترجمة 100% من نصوص النظام (XML وATOK HTML والبرامج النصية).'
        "PkgNotice3" = '3. تم تصميم ملف "bnupdate.tar.gz" للاختبار الفوري على PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[إشعار فني]:'
        "PkgPromptTar" = 'هل تريد إنشاء ملف "bnupdate.tar.gz" لاختباره على PS2؟ (نعم/لا) [الافتراضي: نعم]'
        "PkgSuccess" = '[+] تم إنشاء الحزمة بنجاح (تم تمكين أذونات Linux 0755): {0} ({1:N0} بايت)'
        "PosixPatchedCount" = '[+] الملفات التي تم تصحيحها بإذن تنفيذ POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'اضغط على أي مفتاح للعودة إلى القائمة...'
        "ProgressAtokHelp" = 'ترجمة مساعدة ATOK'
        "ProgressUpdatingHtml" = 'تحديث ملفات HTML'
        "ProgressUpdatingXml" = 'تحديث ملفات XML'
        "ProgressXmlStrings" = 'ترجمة سلاسل XML'
        "PsbbnEnglishEnsure" = 'يرجى التأكد من وجود المجلد ''PSBBN_English'' داخل ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] خطأ: لم يتم العثور على الدليل الأساسي PSBBN_ENGLISH!'
        "ReadmeEnsure" = 'الرجاء التأكد من وجود الملف "README.md" في المجلد "الإدخال".'
        "ReadmeNotFoundDownloading" = '[*] لم يتم العثور على الملف README.md. جاري التحميل من المستودع الرسمي...'
        "ReadmeNotFoundTitle" = '[!] خطأ: لم يتم العثور على ملف README.MD!'
        "ReadmeTitle" = 'مترجم PSBBN التمهيدي [By Emerson Teles]'
        "ScriptTitle" = 'مترجم البرامج النصية PSBBN [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0}_ اللغات المحددة (_{1})'
        "SelectUILangPrompt" = 'حدد خيارًا'
        "SelectUITitle" = 'تغيير لغة واجهة المستخدم'
        "SessionStarted" = 'بدأت الجلسة في:'
        "SourceFile" = 'المصدر:'
        "Step1Copying" = '[*] [1/3] نسخ البنية الكاملة والثنائيات...'
        "Step2TranslatingXml" = '[*] [2/3] ترجمة {0}_ ملفات النظام XML...'
        "Step3TranslatingAtok" = '[*] [3/3] ترجمة {0}_ ملفات تعليمات ATOK HTML...'
        "SuiteTitle" = 'مجموعة الترجمة متعددة اللغات PSBBN - الإصدار الأول [By Emerson Teles]'
        "SystemTitle" = 'نظام PSBBN مترجم [By Emerson Teles]'
        "TextureDisclaimer" = 'ملاحظة: تحتوي الأنسجة (.tm2 / .png) على رسومات مضمنة وتتطلب تحريرًا   يدويًا؛ لا يتم تغييرها بواسطة البرنامج النصي. تتم ترجمة الملفات النصية   للنظام (XML وHTML وtxt) بنسبة 100%.'
        "Translating" = 'الترجمة'
        "UsingFallback" = '[!] استخدام البديل المحلي: {0}'
        "ValidatingXml" = '[*] التحقق من التكامل النحوي لـ 100% من ملفات XML...'
        "XmlSyntaxError" = '[!] خطأ في بناء الجملة في {0}_: {1}'
        "XmlValidationSuccess" = '[+] تم التحقق من صحة 100% من ملفات XML بنجاح (0 أخطاء في بناء الجملة).'
    }
    "bg" = @{
        "All40Success" = 'Всички 40 езика (пълно многоезично)'
        "AllLanguages" = 'Превод на всички езици (1 - 40)'
        "BackMenu" = 'Назад към главното меню'
        "CancelOption" = 'Назад'
        "CannotConnectGithub" = '[!] Не може да се свърже с GitHub: {0}'
        "ChangeLanguage" = 'Промяна на езика на потребителския интерфейс'
        "ChangelogMainNotFoundTitle" = '[!] ГРЕШКА: НЕ МОЖЕ ДА СЕ ИЗТЕГЛИ ИЛИ НАМЕРИ CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ГРЕШКА: НЕ МОЖЕ ДА СЕ ИЗТЕГЛИ ИЛИ НАМЕРИ CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Изберете опция:'
        "CompletionBanner" = '[OK] Преводът на {0} завърши успешно - 100%'
        "DescLauncher" = 'Генерира и актуализира PSBBN Launcher за Windows с поддръжка за всички 40 езика.'
        "DescMain" = 'Превежда основните бележки за изданието на инсталатора и регистъра на промените (changelog_main_eng.txt).'
        "DescPatch" = 'Превежда историята на корекциите, поправките и бележките за актуализиране на канала (changelog_patch_eng.txt).'
        "DescReadme" = 'Превежда официалния PSBBN README.md запазване на форматирането и връзките за маркиране.'
        "DescScript" = 'Превежда всички 458 низа на потребителския интерфейс за скрипта за инсталиране на Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'Превежда всички системни файлове на PS2 PSBBN (XML диалози, ръководства, менюта, помощ за NetFront/ATOK).'
        "DestFile" = 'Дестинация:'
        "DownloadingLatestGithub" = '[i] Изтегля се последната официална версия от GitHub...'
        "DownloadingOfficial" = '[*] Изтегляне на официалния файл от хранилището на GitHub...'
        "EnglishOption" = 'Английски (по подразбиране)'
        "EngTxtEnsureFile" = 'Моля, уверете се, че файлът „eng.txt“ присъства в папката „input“.'
        "EngTxtErrorTitle" = '[!] ГРЕШКА: ENG.TXT ФАЙЛЪТ НЕ Е НАМЕРЕН!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt не е намерен. Изтегляне от официалното хранилище...'
        "EnsureConnected" = 'Моля, уверете се, че сте свързани с интернет или поставете файла във входната директория.'
        "ExitOption" = 'Изход'
        "ExpectedPath" = 'Очакван път: {0}'
        "ExtractingPack" = '[*] Извличане на преводачески пакет PSBBN v3.5...'
        "FileNotFoundError" = '[ГРЕШКА] Файлът не е намерен: {0}'
        "GeneratedFile" = '[OK] Генериран файл: {0}'
        "GenericEnsureInternetOrInput" = 'Моля, уверете се, че сте свързани с интернет или имате файла в папката „input“.'
        "IndividualBlocks" = 'Индивидуални блокове: {0}'
        "IndividualBlocksNotice" = '[OK] Индивидуални блокове за CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Файл(ове) са изтрити от входната папка.'
        "InputFileKept" = '[OK] Файл(ове), съхранявани във входна папка.'
        "InvalidOption" = 'Невалидно опция! Натиснете Enter, за да опитате отново...'
        "LangAppliedSuccess" = '[OK] Езикът на интерфейса е успешно приложен: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Автоматичното откриване на системния език на Windows е активирано.'
        "LauncherBaseNotFoundTitle" = '[!] ГРЕШКА: НЕ МОЖЕ ДА СЕ ИЗТЕГЛИ ИЛИ НАМЕРИ СКРИПТА НА БАЗОВАТА ПРОГРАМА ЗА СТАРТИРАНЕ!'
        "LauncherIntegrated" = '[OK] Интегрирана поддръжка за {0} език(ове) в PSBBN Launcher за Windows!'
        "LauncherPrompt" = 'Изберете един или повече езици (напр. 7 или 1, 2, 3 или 1-5 или A):'
        "LauncherTip1" = '- Въведете 1 число, за да генерирате файла само с този език.'
        "LauncherTipAll" = '- Въведете ''A'', за да генерирате пълния файл с всичките 40 езика.'
        "LauncherTipHeader" = '* Съвет: Всяко изпълнение генерира чист файл, съдържащ само избраните езици.'
        "LauncherTipMulti" = '- Въведете няколко числа, разделени със запетая (напр. 1, 2, 3), за да генерирате с тези езици.'
        "LauncherTipRange" = '- Въведете диапазон (напр. 1-5), за да генерирате с този диапазон от езици.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Предишен екран'
        "NavDeleteInput" = '[X] Изтриване на файл от входна папка'
        "NavEnter" = '[Enter] Главно меню'
        "NavExit" = '[Esc] Изход'
        "NavInstructions" = '[Enter] Главно меню |  [B] Предишен екран |  [Esc] Изход'
        "NavKeepInput" = '[V] Запазване на файла във входната папка'
        "OfficialDownloadSuccess" = '[OK] Официалният файл е изтеглен успешно ({0:N0} байта).'
        "PkgCompressingGz" = '[*] Компресиране до ''bnupdate.tar.gz'' чрез .NET GZipStream...'
        "PkgCreatingTar" = '[*] Създаване на „bnupdate.tar“ и задаване на разрешения за изпълнение на POSIX (+x)...'
        "PkgErrorTar" = '[!] Не може да се генерира bnupdate.tar.'
        "PkgGenTitle" = 'ГЕНЕРИРАНЕ НА ПАКЕТ ЗА ИНСТАЛИРАНЕ НА PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Текстурите (.tm2 и .png) остават на английски (изискват ръчен графичен редизайн).'
        "PkgNotice2" = '2. 100% от системните текстове (XML, ATOK HTML и скриптове) са преведени.'
        "PkgNotice3" = '3. Файлът ''bnupdate.tar.gz'' е предназначен за незабавно тестване на PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[ТЕХНИЧЕСКА БЕЛЕЖКА]:'
        "PkgPromptTar" = 'Искате ли да генерирате файла „bnupdate.tar.gz“ за тестване на PS2? (Y/N) [По подразбиране: Y]'
        "PkgSuccess" = '[+] Пакетът е генериран успешно (разрешенията за Linux 0755 са активирани): {0} ({1:N0} байта)'
        "PosixPatchedCount" = '[+] Файлове, коригирани с разрешение за изпълнение на POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Натиснете произволен клавиш, за да се върнете към менюто...'
        "ProgressAtokHelp" = 'Помощ за превод на ATOK'
        "ProgressUpdatingHtml" = 'Актуализиране на HTML файлове'
        "ProgressUpdatingXml" = 'Актуализиране на XML файлове'
        "ProgressXmlStrings" = 'Превод на XML низове'
        "PsbbnEnglishEnsure" = 'Моля, уверете се, че папката „PSBBN_English“ присъства във „input“.'
        "PsbbnEnglishNotFoundTitle" = '[!] ГРЕШКА: ОСНОВНАТА ДИРЕКТОРИЯ PSBBN_ENGLISH НЕ Е НАМЕРЕНА!'
        "ReadmeEnsure" = 'Моля, уверете се, че файлът „README.md“ е в папката „input“.'
        "ReadmeNotFoundDownloading" = '[*] README.md не е намерен. Изтегляне от официалното хранилище...'
        "ReadmeNotFoundTitle" = '[!] ГРЕШКА: ФАЙЛЪТ README.MD НЕ Е НАМЕРЕН!'
        "ReadmeTitle" = 'PSBBN Readme преводач [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} избрани езика ({1})'
        "SelectUILangPrompt" = 'Изберете опция'
        "SelectUITitle" = 'ПРОМЯНА НА ЕЗИКА НА ПОТРЕБИТЕЛСКИЯ ИНТЕРФЕЙС'
        "SessionStarted" = 'Сесията е започнала на:'
        "SourceFile" = 'Източник:'
        "Step1Copying" = '[*] [1/3] Копиране на пълна структура и двоични файлове...'
        "Step2TranslatingXml" = '[*] [2/3] Превеждам {0} системни XML файлове...'
        "Step3TranslatingAtok" = '[*] [3/3] Превод на {0} ATOK HTML помощни файлове...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'Системен PSBBN преводач [By Emerson Teles]'
        "TextureDisclaimer" = 'Забележка: Текстури (.tm2 / .png) съдържат вградени графики и изискват   ръчно редактиране; те не се променят от скрипта. Системните текстови   файлове (XML, HTML, txt) са 100% преведени.'
        "Translating" = 'Превод'
        "UsingFallback" = '[!] Използване на локален резервен вариант: {0}'
        "ValidatingXml" = '[*] Проверка на синтактичната цялост на 100% от XML файловете...'
        "XmlSyntaxError" = '[!] Синтаксична грешка в {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% от XML файловете са валидирани успешно (0 синтактични грешки).'
    }
    "bn" = @{
        "All40Success" = 'সমস্ত 40টি ভাষা (সম্পূর্ণ বহুভাষিক)'
        "AllLanguages" = 'Translate All Languages (1 - 40)'
        "BackMenu" = 'মূল মেনুতে ফিরে যান'
        "CancelOption" = 'পিছনে'
        "CannotConnectGithub" = '[!] গিটহাবের সাথে সংযোগ করা যাচ্ছে না: {0}'
        "ChangeLanguage" = 'UI ভাষা পরিবর্তন করুন'
        "ChangelogMainNotFoundTitle" = '[!] ত্রুটি: CHANGELOG_MAIN_ENG.TXT ডাউনলোড বা সনাক্ত করা যায়নি!'
        "ChangelogMainTitle" = 'PSBBN চেঞ্জলগ প্রধান অনুবাদক [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ত্রুটি: CHANGELOG_PATCH_ENG.TXT ডাউনলোড বা সনাক্ত করা যায়নি!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'একটি বিকল্প নির্বাচন করুন:'
        "CompletionBanner" = '[OK] {0}-এর অনুবাদ সফলভাবে শেষ হয়েছে - 100%'
        "DescLauncher" = 'সমস্ত 40টি ভাষার জন্য সমর্থন সহ Windows এর জন্য PSBBN লঞ্চার তৈরি ও আপডেট করে।'
        "DescMain" = 'প্রধান ইনস্টলার রিলিজ নোট এবং চেঞ্জলগ (changelog_main_eng.txt) অনুবাদ করে।'
        "DescPatch" = 'প্যাচ ইতিহাস, সংশোধন, এবং চ্যানেল আপডেট নোট (changelog_patch_eng.txt) অনুবাদ করে।'
        "DescReadme" = 'মার্কডাউন ফরম্যাটিং এবং লিঙ্ক সংরক্ষণ করে অফিসিয়াল PSBBN README.md অনুবাদ করে।'
        "DescScript" = 'Linux/WSL PSBBN ইনস্টলার স্ক্রিপ্ট (eng.txt) এর জন্য সমস্ত 458 UI স্ট্রিং অনুবাদ করে।'
        "DescSystem" = 'সমস্ত PS2 PSBBN সিস্টেম ফাইল অনুবাদ করে (XML ডায়ালগ, গাইড, মেনু, NetFront/ATOK সহায়তা)।'
        "DestFile" = 'গন্তব্য:'
        "DownloadingLatestGithub" = '[i] GitHub থেকে সর্বশেষ অফিসিয়াল সংস্করণ ডাউনলোড করা হচ্ছে...'
        "DownloadingOfficial" = '[*] গিটহাব রিপোজিটরি থেকে অফিসিয়াল ফাইল ডাউনলোড করা হচ্ছে...'
        "EnglishOption" = 'ইংরেজি (ডিফল্ট)'
        "EngTxtEnsureFile" = 'অনুগ্রহ করে নিশ্চিত করুন যে ''eng.txt'' ফাইলটি ''ইনপুট'' ফোল্ডারে উপস্থিত রয়েছে।'
        "EngTxtErrorTitle" = '[!] ত্রুটি: ENG.TXT ফাইল পাওয়া যায়নি!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt পাওয়া যায়নি। অফিসিয়াল রিপোজিটরি থেকে ডাউনলোড হচ্ছে...'
        "EnsureConnected" = 'অনুগ্রহ করে নিশ্চিত করুন যে আপনি ইন্টারনেটের সাথে সংযুক্ত আছেন বা ইনপুট ডিরেক্টরিতে ফাইলটি রাখুন৷'
        "ExitOption" = 'প্রস্থান করুন'
        "ExpectedPath" = 'প্রত্যাশিত পথ: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 অনুবাদ প্যাক বের করা হচ্ছে...'
        "FileNotFoundError" = '[ত্রুটি] ফাইল পাওয়া যায়নি: {0}'
        "GeneratedFile" = '[ঠিক আছে] তৈরি করা ফাইল: {0}'
        "GenericEnsureInternetOrInput" = 'অনুগ্রহ করে নিশ্চিত করুন যে আপনি ইন্টারনেটের সাথে সংযুক্ত বা ''ইনপুট'' ফোল্ডারে ফাইলটি আছে৷'
        "IndividualBlocks" = 'স্বতন্ত্র ব্লক: {0}'
        "IndividualBlocksNotice" = '[ঠিক আছে] কসমিকস্কেলের জন্য পৃথক ব্লক: {0}'
        "InputFileDeleted" = '[ঠিক আছে] ইনপুট ফোল্ডার থেকে ফাইল(গুলি) মুছে ফেলা হয়েছে।'
        "InputFileKept" = '[ঠিক আছে] ফাইল(গুলি) ইনপুট ফোল্ডারে রাখা হয়েছে।'
        "InvalidOption" = 'অবৈধ বিকল্প! আবার চেষ্টা করতে এন্টার টিপুন...'
        "LangAppliedSuccess" = '[OK] ইউজার ইন্টারফেস ভাষা সফলভাবে প্রয়োগ করা হয়েছে: {0} ({1})'
        "LauncherAutoDetect" = '[ঠিক আছে] উইন্ডোজ সিস্টেম ভাষা স্বয়ংক্রিয় সনাক্তকরণ সক্ষম।'
        "LauncherBaseNotFoundTitle" = '[!] ত্রুটি: বেস লঞ্চার স্ক্রিপ্ট ডাউনলোড বা সনাক্ত করা যায়নি!'
        "LauncherIntegrated" = '[ঠিক আছে] Windows এর জন্য PSBBN লঞ্চারে {0} ভাষা(গুলি) এর জন্য সমন্বিত সমর্থন!'
        "LauncherPrompt" = 'এক বা একাধিক ভাষা চয়ন করুন (যেমন 7 বা 1, 2, 3 বা 1-5 বা A):'
        "LauncherTip1" = '- শুধুমাত্র সেই ভাষা দিয়ে ফাইল তৈরি করতে 1 নম্বর লিখুন।'
        "LauncherTipAll" = '- সমস্ত 40টি ভাষায় সম্পূর্ণ ফাইল তৈরি করতে ''A'' লিখুন।'
        "LauncherTipHeader" = '* টিপ: প্রতিটি এক্সিকিউশন শুধুমাত্র নির্বাচিত ভাষা(গুলি) ধারণকারী একটি পরিষ্কার ফাইল তৈরি করে।'
        "LauncherTipMulti" = '- কমা দ্বারা পৃথক করা একাধিক সংখ্যা লিখুন (যেমন 1, 2, 3) সেই ভাষাগুলির সাথে তৈরি করতে।'
        "LauncherTipRange" = '- ভাষাগুলির সেই পরিসর দিয়ে তৈরি করতে একটি পরিসর লিখুন (যেমন 1-5)।'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[খ] পূর্ববর্তী পর্দা'
        "NavDeleteInput" = '[X] ইনপুট ফোল্ডার থেকে ফাইল মুছুন'
        "NavEnter" = '[প্রবেশ করুন] প্রধান মেনু'
        "NavExit" = '[Esc] প্রস্থান'
        "NavInstructions" = '[প্রবেশ করুন] প্রধান মেনু |  [খ] পূর্ববর্তী পর্দা |  [Esc] প্রস্থান করুন'
        "NavKeepInput" = '[V] ইনপুট ফোল্ডারে ফাইল রাখুন'
        "OfficialDownloadSuccess" = '[ঠিক আছে] অফিসিয়াল ফাইল সফলভাবে ডাউনলোড করা হয়েছে ({0:N0} বাইট)।'
        "PkgCompressingGz" = '[*] .NET GZipStream এর মাধ্যমে ''bnupdate.tar.gz''-এ কম্প্রেস করা হচ্ছে...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' তৈরি করা এবং POSIX এক্সিকিউশন পারমিশন সেট করা (+x)...'
        "PkgErrorTar" = '[!] bnupdate.tar তৈরি করা যায়নি।'
        "PkgGenTitle" = 'PSBBN ইনস্টলেশন প্যাকেজ জেনারেশন (bnupdate.tar.gz)'
        "PkgNotice1" = '1. টেক্সচার (.tm2 এবং .png) ইংরেজিতে থাকে (ম্যানুয়াল গ্রাফিক রিডিজাইন প্রয়োজন)।'
        "PkgNotice2" = '2. 100% সিস্টেম টেক্সট (XML, ATOK HTML এবং স্ক্রিপ্ট) অনুবাদ করা হয়।'
        "PkgNotice3" = '3. ''bnupdate.tar.gz'' ফাইলটি PS2 (HDD/Telnet/USB) এ তাৎক্ষণিক পরীক্ষার জন্য তৈরি।'
        "PkgNoticeHeader" = '[প্রযুক্তিগত বিজ্ঞপ্তি]:'
        "PkgPromptTar" = 'আপনি কি PS2 এ পরীক্ষা করার জন্য ''bnupdate.tar.gz'' ফাইল তৈরি করতে চান? (Y/N) [ডিফল্ট: Y]'
        "PkgSuccess" = '[+] প্যাকেজ সফলভাবে তৈরি হয়েছে (লিনাক্স 0755 অনুমতি সক্রিয়): {0} ({1:N0} বাইট)'
        "PosixPatchedCount" = 'POSIX 0755 এক্সিকিউশন পারমিশন (+x): {0}'
        "PressAnyKey" = 'মেনুতে ফিরে যেতে যেকোনো কী টিপুন...'
        "ProgressAtokHelp" = 'ATOK সাহায্য অনুবাদ করা হচ্ছে'
        "ProgressUpdatingHtml" = 'HTML ফাইল আপডেট করা হচ্ছে'
        "ProgressUpdatingXml" = 'XML ফাইল আপডেট করা হচ্ছে'
        "ProgressXmlStrings" = 'XML স্ট্রিংগুলি অনুবাদ করা হচ্ছে'
        "PsbbnEnglishEnsure" = 'অনুগ্রহ করে নিশ্চিত করুন যে ''PSBBN_English'' ফোল্ডারটি ''ইনপুট''-এর ভিতরে উপস্থিত রয়েছে।'
        "PsbbnEnglishNotFoundTitle" = '[!] ত্রুটি: বেস ডাইরেক্টরি PSBBN_ENGLISH পাওয়া যায়নি!'
        "ReadmeEnsure" = 'অনুগ্রহ করে নিশ্চিত করুন যে ''README.md'' ফাইলটি ''ইনপুট'' ফোল্ডারে রয়েছে।'
        "ReadmeNotFoundDownloading" = '[*] README.md পাওয়া যায়নি। অফিসিয়াল রিপোজিটরি থেকে ডাউনলোড হচ্ছে...'
        "ReadmeNotFoundTitle" = '[!] ত্রুটি: README.MD ফাইলটি পাওয়া যায়নি!'
        "ReadmeTitle" = 'PSBBN রিডমি অনুবাদক [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN স্ক্রিপ্ট অনুবাদক [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} ভাষা নির্বাচিত ({1})'
        "SelectUILangPrompt" = 'একটি বিকল্প নির্বাচন করুন'
        "SelectUITitle" = 'UI ভাষা পরিবর্তন করুন'
        "SessionStarted" = 'অধিবেশন শুরু হয়েছে:'
        "SourceFile" = 'সূত্র:'
        "Step1Copying" = '[*] [1/3] সম্পূর্ণ কাঠামো এবং বাইনারি অনুলিপি করা...'
        "Step2TranslatingXml" = '[*] [2/3] {0} সিস্টেম এক্সএমএল ফাইল অনুবাদ করা হচ্ছে...'
        "Step3TranslatingAtok" = '[*] [3/3] অনুবাদ করা হচ্ছে {0} ATOK HTML সহায়তা ফাইল...'
        "SuiteTitle" = 'PSBBN বহুভাষিক অনুবাদ স্যুট - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'বিজ্ঞপ্তি: টেক্সচার (.tm2 / .png) এম্বেডেড গ্রাফিক্স ধারণ কর��� এবং   ম্যানুয়াল এডিটিং প্রয়োজন; তারা স্ক্রিপ্ট দ্বারা পরিবর্তিত হয় না.   সিস্টেম টেক্সট ফাইল (XML, HTML, txt) 100% অনূদিত।'
        "Translating" = 'অনুবাদ করছে'
        "UsingFallback" = '[!] স্থানীয় ফলব্যাক ব্যবহার করে: {0}'
        "ValidatingXml" = '[*] XML ফাইলের 100% সিনট্যাকটিক অখণ্ডতা যাচাই করা...'
        "XmlSyntaxError" = '[!] {0} এ সিনট্যাক্স ত্রুটি: {1}'
        "XmlValidationSuccess" = '[+] XML ফাইলের 100% সফলভাবে যাচাই করা হয়েছে (0 সিনট্যাক্স ত্রুটি)।'
    }
    "cs" = @{
        "All40Success" = 'Všech 40 jazyků (plná vícejazyčnost)'
        "AllLanguages" = 'Přeložit všechny jazyky (1–40)'
        "BackMenu" = 'Zpět do hlavní nabídky'
        "CancelOption" = 'Zpět'
        "CannotConnectGithub" = '[!] Nelze se připojit ke GitHubu: {0}'
        "ChangeLanguage" = 'Změnit jazyk uživatelského rozhraní'
        "ChangelogMainNotFoundTitle" = '[!] CHYBA: NELZE STÁHNOUT NEBO NAJÍT CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Hlavní překladatel protokolu PSBBN [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] CHYBA: NELZE STÁHNOUT NEBO NAJÍT CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Překladač oprav protokolu PSBBN [By Emerson Teles]'
        "ChooseOption" = 'Vybrat možnost'
        "CompletionBanner" = '[OK] Překlad jazyka {0} úspěšně dokončen – 100 %'
        "DescLauncher" = 'Generuje a aktualizuje PSBBN Launcher pro Windows s podporou všech 40 jazyků.'
        "DescMain" = 'Překládá poznámky k vydání hlavního instalátoru a protokol změn (changelog_main_eng.txt).'
        "DescPatch" = 'Překládá historii oprav, opravy a poznámky k aktualizaci kanálu (changelog_patch_eng.txt).'
        "DescReadme" = 'Překládá oficiální formát markdownu PSBBN README. odkazy.'
        "DescScript" = 'Přeloží všech 458 řetězců uživatelského rozhraní pro instalační skript Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'Přeloží všechny systémové soubory PS2 PSBBN (XML dialogy, průvodce, nabídky, nápovědu NetFront/ATOK).'
        "DestFile" = 'Cíl:'
        "DownloadingLatestGithub" = '[i] Stahování nejnovější oficiální verze z GitHubu...'
        "DownloadingOfficial" = '[*] Stahování oficiálního souboru z úložiště GitHub...'
        "EnglishOption" = 'Angličtina (výchozí)'
        "EngTxtEnsureFile" = 'Ujistěte se, že soubor ''eng.txt'' je přítomen ve složce ''input''.'
        "EngTxtErrorTitle" = '[!] CHYBA: ENG.TXT SOUBOR NENALEZEN!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt nenalezen. Stahování z oficiálního úložiště...'
        "EnsureConnected" = 'Ujistěte se, že jste připojeni k internetu, nebo umístěte soubor do vstupního adresáře.'
        "ExitOption" = 'Konec'
        "ExpectedPath" = 'Očekávaná cesta: {0}'
        "ExtractingPack" = '[*] Extrahování překladového balíčku PSBBN v3.5...'
        "FileNotFoundError" = '[CHYBA] Soubor nenalezen: {0}'
        "GeneratedFile" = '[OK] Vygenerovaný soubor: {0}'
        "GenericEnsureInternetOrInput" = 'Ujistěte se, že jste připojeni k internetu nebo máte soubor ve složce ''input''.'
        "IndividualBlocks" = 'Jednotlivé bloky: {0}'
        "IndividualBlocksNotice" = '[OK] Jednotlivé bloky pro CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Soubor(y) odstraněný ze vstupní složky.'
        "InputFileKept" = '[OK] Soubor(y) uložené ve vstupní složce.'
        "InvalidOption" = 'Konec! Stiskněte Enter a zkuste to znovu...'
        "LangAppliedSuccess" = '[OK] Jazyk rozhraní byl úspěšně nastaven: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Automatická detekce jazyka systému Windows povolena.'
        "LauncherBaseNotFoundTitle" = '[!] CHYBA: NELZE STÁHNOUT NEBO NAJÍT ZÁKLADNÍ SPUŠTĚNÍ SKRIPTU!'
        "LauncherIntegrated" = '[OK] Integrovaná podpora {0} jazyků do PSBBN Launcher pro Windows!'
        "LauncherPrompt" = 'Vyberte jeden nebo více jazyků (např. 7 nebo 1, 2, 3 nebo 1-5 nebo A):'
        "LauncherTip1" = '- Zadejte 1 číslo pro vygenerování souboru pouze v tomto jazyce.'
        "LauncherTipAll" = '- Zadejte ''A'' pro vygenerování kompletního souboru se všemi 40 jazyky.'
        "LauncherTipHeader" = '* Tip: Každé spuštění vygeneruje čistý soubor obsahující pouze zvolené jazyky.'
        "LauncherTipMulti" = '– Zadejte více čísel oddělených čárkou (např. 1, 2, 3), která chcete generovat s těmito jazyky.'
        "LauncherTipRange" = '– Zadejte rozsah (např. 1–5), který se má vygenerovat s tímto rozsahem jazyků.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Předchozí obrazovka'
        "NavDeleteInput" = '[X] Smazat soubor ze vstupní složky'
        "NavEnter" = '[Enter] Hlavní nabídka'
        "NavExit" = '[Esc] Konec'
        "NavInstructions" = '[Enter] Hlavní nabídka |  [B] Předchozí obrazovka |  [Esc] Konec'
        "NavKeepInput" = '[V] Uchovávejte soubor ve vstupní složce'
        "OfficialDownloadSuccess" = '[OK] Oficiální soubor byl úspěšně stažen ({0:N0} bajtů).'
        "PkgCompressingGz" = '[*] Komprese na ''bnupdate.tar.gz'' přes .NET GZipStream...'
        "PkgCreatingTar" = '[*] Vytváření ''bnupdate.tar'' a nastavení oprávnění k provádění POSIX (+x)...'
        "PkgErrorTar" = '[!] Nelze vygenerovat bnupdate.tar.'
        "PkgGenTitle" = 'GENEROVÁNÍ INSTALAČNÍHO BALÍČKU PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Textury (.tm2 a .png) zůstávají v angličtině (vyžadují ruční úpravu grafiky).'
        "PkgNotice2" = '2. Je přeloženo 100 % systémových textů (XML, ATOK HTML a skripty).'
        "PkgNotice3" = '3. Soubor ''bnupdate.tar.gz'' je určen k okamžitému testování na PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TECHNICKÉ UPOZORNĚNÍ]:'
        "PkgPromptTar" = 'Chcete vygenerovat soubor ''bnupdate.tar.gz'' pro testování na PS2? (A/N) [Výchozí: A]'
        "PkgSuccess" = '[+] Balíček byl úspěšně vygenerován (oprávnění Linux 0755 povolena): {0} ({1:N0} bajtů)'
        "PosixPatchedCount" = '[+] Soubory opravené s oprávněním ke spuštění POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Stisknutím libovolné klávesy se vrátíte do nabídky...'
        "ProgressAtokHelp" = 'Překlad nápovědy ATOK'
        "ProgressUpdatingHtml" = 'Aktualizace HTML souborů'
        "ProgressUpdatingXml" = 'Aktualizace souborů XML'
        "ProgressXmlStrings" = 'Překlad řetězců XML'
        "PsbbnEnglishEnsure" = 'Ujistěte se prosím, že složka ''PSBBN_English'' je přítomna uvnitř ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] CHYBA: ZÁKLADNÍ DIRECTORY PSBBN_ENGLISH NENÍ NALEZENO!'
        "ReadmeEnsure" = 'Ujistěte se, že soubor ''README.md'' je ve složce ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md nebyl nalezen. Stahování z oficiálního úložiště...'
        "ReadmeNotFoundTitle" = '[!] CHYBA: SOUBOR README.MD NENALEZEN!'
        "ReadmeTitle" = 'Překladač PSBBN Readme [By Emerson Teles]'
        "ScriptTitle" = 'Teles] [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} vybraných jazyků ({1})'
        "SelectUILangPrompt" = 'Vybrat možnost'
        "SelectUITitle" = 'ZMĚNIT JAZYK UŽIVATELSKÉHO ROZHRANÍ'
        "SessionStarted" = 'Relace zahájena dne:'
        "SourceFile" = 'Zdroj:'
        "Step1Copying" = '[*] [1/3] Kopírování kompletní struktury a binárních souborů...'
        "Step2TranslatingXml" = '[*] [2/3] Překlad {0} systémových souborů XML...'
        "Step3TranslatingAtok" = '[*] [3/3] Překlad {0} souborů nápovědy HTML ATOK...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite – V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Upozornění: Textury (.tm2 / .png) vyžadují ruční grafickou úpravu (mimo skript). Sada překládá 100 % textů systémových souborů (XML, HTML, nabídky a skripty).'
        "Translating" = 'Překlad'
        "UsingFallback" = '[!] Použití místní záložní: {0}'
        "ValidatingXml" = '[*] Ověřování syntaktické integrity 100 % souborů XML...'
        "XmlSyntaxError" = '[!] Chyba syntaxe v {0}: {1}'
        "XmlValidationSuccess" = '[+] 100 % souborů XML bylo úspěšně ověřeno (0 syntaktických chyb).'
    }
    "da" = @{
        "All40Success" = 'Alle 40 sprog (Fuld flersproget)'
        "AllLanguages" = 'Oversæt alle sprog (1 - 40)'
        "BackMenu" = 'Tilbage til hovedmenu'
        "CancelOption" = 'Tilbage'
        "CannotConnectGithub" = '[!] Kan ikke oprette forbindelse til GitHub: {0}'
        "ChangeLanguage" = 'Skift UI-sprog'
        "ChangelogMainNotFoundTitle" = '[!] FEJL: KUNNE IKKE DOWNLOAD ELLER FINDE CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] FEJL: KUNNE IKKE DOWNLOAD ELLER FINDE CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Vælg en valgmulighed:'
        "CompletionBanner" = '[OK] Oversættelse af {0} afsluttet - 100 %'
        "DescLauncher" = 'Genererer og opdaterer PSBBN Launcher til Windows med understøttelse af alle 40 sprog.'
        "DescMain" = 'Oversætter hovedinstallationsprogrammets udgivelsesnoter og ændringslog (changelog_main_eng.txt).'
        "DescPatch" = 'Oversætter patchhistorik, rettelser og kanalopdateringsnoter (changelog_patch_eng.txt).'
        "DescReadme" = 'Oversætter det officielle markeringsformat og PSBBN READ ned. links.'
        "DescScript" = 'Oversætter alle 458 UI-strenge til Linux/WSL PSBBN-installationsscriptet (eng.txt).'
        "DescSystem" = 'Oversætter alle PS2 PSBBN-systemfiler (XML-dialoger, vejledninger, menuer, NetFront/ATOK-hjælp).'
        "DestFile" = 'Destination:'
        "DownloadingLatestGithub" = '[i] Downloader seneste officielle version fra GitHub...'
        "DownloadingOfficial" = '[*] Downloader officiel fil fra GitHub-lageret...'
        "EnglishOption" = 'Engelsk (standard)'
        "EngTxtEnsureFile" = 'Sørg for, at ''eng.txt''-filen er til stede i ''input''-mappen.'
        "EngTxtErrorTitle" = '[!] FEJL: ENG.TXT FIL IKKE FUNDET!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt ikke fundet. Downloader fra officielt lager...'
        "EnsureConnected" = 'Sørg for, at du har forbindelse til internettet, eller placer filen i input-mappen.'
        "ExitOption" = 'Afslut'
        "ExpectedPath" = 'Forventet sti: {0}'
        "ExtractingPack" = '[*] Udpakker PSBBN v3.5 oversættelsespakke...'
        "FileNotFoundError" = '[FEJL] Filen blev ikke fundet: {0}'
        "GeneratedFile" = '[OK] Genereret fil: {0}'
        "GenericEnsureInternetOrInput" = 'Sørg for, at du har forbindelse til internettet eller har filen i ''input''-mappen.'
        "IndividualBlocks" = 'Individuelle blokke: {0}'
        "IndividualBlocksNotice" = '[OK] Individuelle blokke for CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Fil(er) slettet fra inputmappe.'
        "InputFileKept" = '[OK] Fil(er) gemt i inputmappe.'
        "InvalidOption" = 'Vælg! Tryk på Enter for at prøve igen...'
        "LangAppliedSuccess" = '[OK] Brugergrænsefladesprog blev anvendt: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Automatisk registrering af Windows-systemsprog aktiveret.'
        "LauncherBaseNotFoundTitle" = '[!] FEJL: KUNNE IKKE DOWNLOAD ELLER FINDE BASE LAUNCHER SCRIPT!'
        "LauncherIntegrated" = '[OK] Integreret understøttelse af {0} sprog i PSBBN Launcher til Windows!'
        "LauncherPrompt" = 'Vælg et eller flere sprog (f.eks. 7 eller 1, 2, 3 eller 1-5 eller A):'
        "LauncherTip1" = '- Indtast 1 tal for at generere filen med kun det sprog.'
        "LauncherTipAll" = '- Indtast ''A'' for at generere den komplette fil med alle 40 sprog.'
        "LauncherTipHeader" = '* Tip: Hver udførelse genererer en ren fil, der kun indeholder det eller de valgte sprog.'
        "LauncherTipMulti" = '- Indtast flere tal adskilt med komma (f.eks. 1, 2, 3) for at generere med disse sprog.'
        "LauncherTipRange" = '- Indtast et interval (f.eks. 1-5) for at generere med det udvalg af sprog.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Forrige skærm'
        "NavDeleteInput" = '[X] Slet fil fra input-mappe'
        "NavEnter" = '[Enter] Hovedmenu'
        "NavExit" = '[Esc] Afslut'
        "NavInstructions" = '[Enter] Hovedmenu |  [B] Forrige skærm |  [Esc] Afslut'
        "NavKeepInput" = '[V] Behold filen i input-mappe'
        "OfficialDownloadSuccess" = '[OK] Officiel fil blev downloadet ({0:N0} bytes).'
        "PkgCompressingGz" = '[*] Komprimerer til ''bnupdate.tar.gz'' via .NET GZipStream...'
        "PkgCreatingTar" = '[*] Oprettelse af ''bnupdate.tar'' og indstilling af POSIX-udførelsestilladelser (+x)...'
        "PkgErrorTar" = '[!] Kunne ikke generere bnupdate.tar.'
        "PkgGenTitle" = 'PSBBN INSTALLATIONSPAKKE GENERATION (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Teksturer (.tm2 og .png) forbliver på engelsk (kræver manuel grafisk redesign).'
        "PkgNotice2" = '2. 100 % af systemteksterne (XML, ATOK HTML og scripts) er oversat.'
        "PkgNotice3" = '3. ''bnupdate.tar.gz''-filen er beregnet til øjeblikkelig test på PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TEKNISK MEDDELELSE]:'
        "PkgPromptTar" = 'Vil du generere filen ''bnupdate.tar.gz'' for at teste på PS2? (J/N) [Standard: Y]'
        "PkgSuccess" = '[+] Pakke genereret med succes (Linux 0755-tilladelser aktiveret): {0} ({1:N0} bytes)'
        "PosixPatchedCount" = '[+] Filer rettet med POSIX 0755-udførelsestilladelse (+x): {0}'
        "PressAnyKey" = 'Tryk på en vilkårlig tast for at vende tilbage til menuen...'
        "ProgressAtokHelp" = 'Oversættelse af ATOK Hjælp'
        "ProgressUpdatingHtml" = 'Opdatering af HTML-filer'
        "ProgressUpdatingXml" = 'Opdatering af XML-filer'
        "ProgressXmlStrings" = 'Oversættelse af XML-strenge'
        "PsbbnEnglishEnsure" = 'Sørg for, at mappen ''PSBBN_English'' er til stede i ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] FEJL: BASE DIRECTORY PSBBN_ENGLISH IKKE FUNDET!'
        "ReadmeEnsure" = 'Sørg for, at filen ''README.md'' er i ''input''-mappen.'
        "ReadmeNotFoundDownloading" = '[*] README.md blev ikke fundet. Downloader fra officielt lager...'
        "ReadmeNotFoundTitle" = '[!] FEJL: README.MD FIL IKKE FUNDET!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'Teles] [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} sprog valgt ({1})'
        "SelectUILangPrompt" = 'Vælg en valgmulighed'
        "SelectUITitle" = 'SKIFT UI-SPROG'
        "SessionStarted" = 'Session startede den:'
        "SourceFile" = 'Kilde:'
        "Step1Copying" = '[*] [1/3] Kopierer komplet struktur og binære filer...'
        "Step2TranslatingXml" = '[*] [2/3] Oversættelse af {0} system-XML-filer...'
        "Step3TranslatingAtok" = '[*] [3/3] Oversættelse af {0} ATOK HTML-hjælpefiler...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Notice .pngdgraphics (.pngd) em kræver manuel redigering; de ændres   ikke af scriptet. Systemtekstfiler (XML, HTML, txt) er 100 % oversat.'
        "Translating" = 'Oversættelse'
        "UsingFallback" = '[!] Ved hjælp af lokal fallback: {0}'
        "ValidatingXml" = '[*] Validerer syntaktisk integritet af 100 % af XML-filer...'
        "XmlSyntaxError" = '[!] Syntaksfejl i {0}: {1}'
        "XmlValidationSuccess" = '[+] 100 % af XML-filer valideret med succes (0 syntaksfejl).'
    }
    "de" = @{
        "All40Success" = 'Alle 40 Sprachen (vollständig mehrsprachig)'
        "AllLanguages" = 'Alle Sprachen übersetzen (1 - 40)'
        "BackMenu" = 'Zurück zum Hauptmenü'
        "CancelOption" = 'Zurück'
        "CannotConnectGithub" = '[!] Keine Verbindung zu GitHub möglich: {0}'
        "ChangeLanguage" = 'Oberflächensprache ändern'
        "ChangelogMainNotFoundTitle" = '[!] FEHLER: CHANGELOG_MAIN_ENG.TXT KONNTE NICHT HERUNTERGELADEN ODER GEFUNDEN WERDEN!'
        "ChangelogMainTitle" = 'PSBBN Haupt-Änderungsprotokoll Übersetzer [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] FEHLER: CHANGELOG_PATCH_ENG.TXT KONNTE NICHT HERUNTERGELADEN ODER GEFUNDEN WERDEN!'
        "ChangelogPatchTitle" = 'PSBBN Patch-Änderungsprotokoll Übersetzer [By Emerson Teles]'
        "ChooseOption" = 'Wählen Sie eine Option:'
        "CompletionBanner" = '[OK] Übersetzung von {0} erfolgreich abgeschlossen - 100%'
        "DescLauncher" = 'Erstellt und aktualisiert den PSBBN Launcher for Windows mit Unterstützung für alle 40 Sprachen.'
        "DescMain" = 'Übersetzt das Haupt-Änderungsprotokoll (changelog_main_eng.txt).'
        "DescPatch" = 'Übersetzt die Patch-Hinweise und Kanal-Updates (changelog_patch_eng.txt).'
        "DescReadme" = 'Übersetzt das offizielle PSBBN README.md unter Beibehaltung von Markdown und Links.'
        "DescScript" = 'Übersetzt alle 458 UI-Texte des Linux/WSL-Installationsskripts (eng.txt).'
        "DescSystem" = 'Übersetzt alle PS2 PSBBN-Systemdateien (XML-Dialoge, Guides, Menüs, ATOK-Hilfe).'
        "DestFile" = 'Ziel:'
        "DownloadingLatestGithub" = '[i] Neueste offizielle Version von GitHub wird heruntergeladen...'
        "DownloadingOfficial" = '[*] Offizielle Datei aus dem GitHub-Repository wird heruntergeladen...'
        "EnglishOption" = 'Englisch (Standard)'
        "EngTxtEnsureFile" = 'Bitte stellen Sie sicher, dass sich die Datei ''eng.txt'' im Ordner ''input'' befindet.'
        "EngTxtErrorTitle" = '[!] FEHLER: DATEI ENG.TXT NICHT GEFUNDEN!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt nicht gefunden. Herunterladen aus dem offiziellen Repository...'
        "EnsureConnected" = 'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, oder legen Sie die Datei im input-Ordner ab.'
        "ExitOption" = 'Beenden'
        "ExpectedPath" = 'Erwarteter Pfad: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 Übersetzungspaket wird entpackt...'
        "FileNotFoundError" = '[FEHLER] Datei nicht gefunden: {0}'
        "GeneratedFile" = '[OK] Generierte Datei: {0}'
        "GenericEnsureInternetOrInput" = 'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind oder die Datei im Ordner ''input'' liegt.'
        "IndividualBlocks" = 'Einzelne Blöcke: {0}'
        "IndividualBlocksNotice" = '[OK] Einzelne Blöcke für CosmicScale: {0}'
        "InputFileDeleted" = 'behalten [OK] Datei(en) aus dem Eingabeordner gelöscht.'
        "InputFileKept" = '[OK] Datei(en) im Eingabeordner gespeichert.'
        "InvalidOption" = 'Ungültige Option! Drücken Sie Enter...'
        "LangAppliedSuccess" = '[OK] Oberflächensprache erfolgreich angewendet: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Automatische Erkennung der Windows-Systemsprache aktiviert.'
        "LauncherBaseNotFoundTitle" = '[!] FEHLER: DAS BASIS-SKRIPT DES LAUNCHERS KONNTE NICHT HERUNTERGELADEN ODER GEFUNDEN WERDEN!'
        "LauncherIntegrated" = '[OK] Integrierte Unterstützung für {0} Sprache(n) in PSBBN Launcher for Windows!'
        "LauncherPrompt" = 'Wählen Sie eine oder mehrere Sprachen (z. B. 7 oder 1, 2, 3 oder 1-5 oder A)'
        "LauncherTip1" = '- Geben Sie 1 Zahl ein, um die Datei nur mit dieser Sprache zu erstellen.'
        "LauncherTipAll" = '- Geben Sie ''A'' ein, um die vollständige Datei mit allen 40 Sprachen zu erstellen.'
        "LauncherTipHeader" = '* Tipp: Bei jeder Ausführung wird eine saubere Datei erstellt, die nur die ausgewählten Sprachen enthält.'
        "LauncherTipMulti" = '- Geben Sie mehrere durch Kommas getrennte Zahlen ein (z. B. 1, 2, 3), um mit diesen Sprachen zu erstellen.'
        "LauncherTipRange" = '- Geben Sie einen Bereich ein (z. B. 1-5), um mit diesem Sprachbereich zu erstellen.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Vorheriger Bildschirm'
        "NavDeleteInput" = '[X] Datei aus Eingabeordner löschen'
        "NavEnter" = '[Enter] Hauptmenü'
        "NavExit" = '[Esc] Beenden'
        "NavInstructions" = '[Enter] Hauptmenü  |  [B] Vorheriger Bildschirm  |  [Esc] Beenden'
        "NavKeepInput" = '[V] Datei im Eingabeordner'
        "OfficialDownloadSuccess" = '[OK] Offizielle Datei erfolgreich heruntergeladen ({0:N0} Bytes).'
        "PkgCompressingGz" = '[*] Komprimierung zu ''bnupdate.tar.gz'' über .NET GZipStream...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' erstellen und POSIX-Ausführungsberechtigungen (+x) setzen...'
        "PkgErrorTar" = '[!] bnupdate.tar konnte nicht generiert werden.'
        "PkgGenTitle" = 'PSBBN-INSTALLATIONSPAKETERSTELLUNG (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Texturen (.tm2 und .png) bleiben auf Englisch (erfordern manuelle grafische Überarbeitung).'
        "PkgNotice2" = '2. 100% der Systemtexte (XML, ATOK HTML und Skripte) sind übersetzt.'
        "PkgNotice3" = '3. Die Datei ''bnupdate.tar.gz'' ist für sofortige Tests auf der PS2 vorgesehen (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TECHNISCHER HINWEIS]:'
        "PkgPromptTar" = 'Möchten Sie die Datei ''bnupdate.tar.gz'' zum Testen auf der PS2 generieren? (J/N) [Standard: J]'
        "PkgSuccess" = '[+] Paket erfolgreich generiert (Linux 0755-Berechtigungen aktiviert): {0} ({1:N0} Bytes)'
        "PosixPatchedCount" = '[+] Dateien mit POSIX 0755-Ausführungsberechtigung (+x) angepasst: {0}'
        "PressAnyKey" = 'Drücken Sie eine beliebige Taste, um zum Menü zurückzukehren...'
        "ProgressAtokHelp" = 'ATOK-Hilfe wird übersetzt'
        "ProgressUpdatingHtml" = 'HTML-Dateien werden aktualisiert'
        "ProgressUpdatingXml" = 'XML-Dateien werden aktualisiert'
        "ProgressXmlStrings" = 'XML-Zeichenfolgen werden übersetzt'
        "PsbbnEnglishEnsure" = 'Bitte stellen Sie sicher, dass sich der Ordner ''PSBBN_English'' im Verzeichnis ''input'' befindet.'
        "PsbbnEnglishNotFoundTitle" = '[!] FEHLER: BASISVERZEICHNIS PSBBN_ENGLISH NICHT GEFUNDEN!'
        "ReadmeEnsure" = 'Bitte stellen Sie sicher, dass sich die Datei ''README.md'' im Ordner ''input'' befindet.'
        "ReadmeNotFoundDownloading" = '[*] README.md nicht gefunden. Herunterladen aus dem offiziellen Repository...'
        "ReadmeNotFoundTitle" = '[!] FEHLER: DATEI README.MD NICHT GEFUNDEN!'
        "ReadmeTitle" = 'PSBBN Readme Übersetzer [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Übersetzer [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} Sprachen ausgewählt ({1})'
        "SelectUILangPrompt" = 'Wählen Sie die Sprache der Benutzeroberfläche'
        "SelectUITitle" = 'OBERFLÄCHENSPRACHE WÄHLEN'
        "SessionStarted" = 'Sitzung gestartet am:'
        "SourceFile" = 'Quelle:'
        "Step1Copying" = '[*] [1/3] Kopieren der vollständigen Struktur und Binärdateien...'
        "Step2TranslatingXml" = '[*] [2/3] Übersetzen von {0} System-XML-Dateien...'
        "Step3TranslatingAtok" = '[*] [3/3] Übersetzen von {0} ATOK-HTML-Hilfedateien...'
        "SuiteTitle" = 'PSBBN Mehrsprachige Übersetzungs-Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Übersetzer [By Emerson Teles]'
        "TextureDisclaimer" = 'Hinweis: Texturen (.tm2 / .png) erfordern manuelle Grafikbearbeitung. Die Suite übersetzt 100 % der Systemdateitexte (XML, HTML, Menüs und Skripte).'
        "Translating" = 'Übersetze'
        "UsingFallback" = '[!] Verwende lokalen Fallback: {0}'
        "ValidatingXml" = '[*] Validierung der syntaktischen Integrität von 100% der XML-Dateien...'
        "XmlSyntaxError" = '[!] Syntaxfehler in {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% der XML-Dateien erfolgreich validiert (0 Syntaxfehler).'
    }
    "el" = @{
        "All40Success" = 'Και οι 40 γλώσσες (Πλήρης πολύγλωσση)'
        "AllLanguages" = 'Μετάφραση όλων των γλωσσών (1 - 40)'
        "BackMenu" = 'Επιστροφή στο Κύριο Μενού'
        "CancelOption" = 'Πίσω'
        "CannotConnectGithub" = '[!] Δεν είναι δυνατή η σύνδεση στο GitHub: {0}'
        "ChangeLanguage" = 'Αλλαγή γλώσσας διεπαφής χρήστη'
        "ChangelogMainNotFoundTitle" = '[!] ΣΦΑΛΜΑ: ΔΕΝ ΜΠΟΡΕΙ ΝΑ ΛΗΨΕΙ Ή ΝΑ ΕΝΤΟΠΙΣΕΙ ΤΟ CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Κύριος μεταφραστής καταγραφής αλλαγών PSBBN [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ΣΦΑΛΜΑ: ΔΕΝ ΜΠΟΡΕΙ ΝΑ ΛΗΨΕΙ Ή ΝΑ ΕΝΤΟΠΙΣΕΙ ΤΟ CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Μεταφραστής ενημερωμένης έκδοσης κώδικα αλλαγών PSBBN [By Emerson Teles]'
        "ChooseOption" = 'Επιλέξτε μια επιλογή:'
        "CompletionBanner" = '[OK] Η μετάφραση του {0} ολοκληρώθηκε με επιτυχία - 100%'
        "DescLauncher" = 'Δημιουργεί και ενημερώνει το PSBBN Launcher για Windows με υποστήριξη και για τις 40 γλώσσες.'
        "DescMain" = 'Μεταφράζει τις σημειώσεις έκδοσης του κύριου προγράμματος εγκατάστασης και το αρχείο αλλαγών (changelog_main_eng.txt).'
        "DescPatch" = 'Μεταφράζει το ιστορικό ενημερώσεων κώδικα, τις διορθώσεις και τις σημειώσεις ενημέρωσης καναλιού (changelog_patch_eng.txt).'
        "DescReadme" = 'Μεταφράζει το επίσημο PSBBN README.md διατηρώντας τη μορφοποίηση και τους συνδέσμους σήμανσης.'
        "DescScript" = 'Μεταφράζει και τις 458 συμβολοσειρές διεπαφής χρήστη για το σενάριο εγκατάστασης Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'Μεταφράζει όλα τα αρχεία συστήματος PS2 PSBBN (παράθυρα διαλόγου XML, οδηγοί, μενού, βοήθεια NetFront/ATOK).'
        "DestFile" = 'Προορισμός:'
        "DownloadingLatestGithub" = '[i] Λήψη της τελευταίας επίσημης έκδοσης από το GitHub...'
        "DownloadingOfficial" = '[*] Λήψη επίσημου αρχείου από το αποθετήριο GitHub...'
        "EnglishOption" = 'Αγγλικά (προεπιλογή)'
        "EngTxtEnsureFile" = 'Βεβαιωθείτε ότι το αρχείο "eng.txt" υπάρχει στον φάκελο "input".'
        "EngTxtErrorTitle" = '[!] ΣΦΑΛΜΑ: ΤΟ ΑΡΧΕΙΟ ENG.TXT ΔΕΝ ΒΡΕΘΗΚΕ!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt δεν βρέθηκε. Λήψη από επίσημο αποθετήριο...'
        "EnsureConnected" = 'Βεβαιωθείτε ότι είστε συνδεδεμένοι στο Διαδίκτυο ή τοποθετήστε το αρχείο στον κατάλογο εισόδου.'
        "ExitOption" = 'Εξοδος'
        "ExpectedPath" = 'Αναμενόμενη διαδρομή: {0}'
        "ExtractingPack" = '[*] Εξαγωγή πακέτου μετάφρασης PSBBN v3.5...'
        "FileNotFoundError" = '[ΣΦΑΛΜΑ] Το αρχείο δεν βρέθηκε: {0}'
        "GeneratedFile" = '[OK] Δημιουργήθηκε αρχείο: {0}'
        "GenericEnsureInternetOrInput" = 'Βεβαιωθείτε ότι είστε συνδεδεμένοι στο Διαδίκτυο ή ότι έχετε το αρχείο στο φάκελο "input".'
        "IndividualBlocks" = 'Ατομικά μπλοκ: {0}'
        "IndividualBlocksNotice" = '[OK] Μεμονωμένα μπλοκ για το CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Τα αρχεία διαγράφηκαν από τον φάκελο εισόδου.'
        "InputFileKept" = '[ΟΚ] Τα αρχεία διατηρούνται στον φάκελο εισόδου.'
        "InvalidOption" = 'Άκυρη επιλογή! Πατήστε Enter για να προσπαθήσετε ξανά...'
        "LangAppliedSuccess" = '[OK] Η γλώσσα διεπαφής εφαρμόστηκε με επιτυχία: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Ο αυτόματος εντοπισμός γλώσσας συστήματος των Windows ενεργοποιήθηκε.'
        "LauncherBaseNotFoundTitle" = '[!] ΣΦΑΛΜΑ: ΔΕΝ ΜΠΟΡΕΙ ΝΑ ΛΗΨΕΙ Ή ΝΑ ΕΝΤΟΠΙΣΕΙ ΣΕΝΑΡΙΟ BASE LAUNCHER!'
        "LauncherIntegrated" = '[OK] Ενσωματωμένη υποστήριξη για {0} γλώσσες στο PSBBN Launcher για Windows!'
        "LauncherPrompt" = 'Επιλέξτε μία ή περισσότερες γλώσσες (π.χ. 7 ή 1, 2, 3 ή 1-5 ή Α):'
        "LauncherTip1" = '- Εισαγάγετε 1 αριθμό για να δημιουργήσετε το αρχείο μόνο με αυτήν τη γλώσσα.'
        "LauncherTipAll" = '- Εισαγάγετε ''A'' για να δημιουργήσετε το πλήρες αρχείο και με τις 40 γλώσσες.'
        "LauncherTipHeader" = '* Συμβουλή: Κάθε εκτέλεση δημιουργεί ένα καθαρό αρχείο που περιέχει μόνο τις επιλεγμένες γλώσσες.'
        "LauncherTipMulti" = '- Εισαγάγετε πολλούς αριθμούς διαχωρισμένους με κόμμα (π.χ. 1, 2, 3) για δημιουργία με αυτές τις γλώσσες.'
        "LauncherTipRange" = '- Εισαγάγετε ένα εύρος (π.χ. 1-5) για δημιουργία με αυτό το εύρος γλωσσών.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Προηγούμενη οθόνη'
        "NavDeleteInput" = '[X] Διαγραφή αρχείου από τον φάκελο εισόδου'
        "NavEnter" = '[Εισαγωγή] Κύριο μενού'
        "NavExit" = '[Esc] Έξοδος'
        "NavInstructions" = '[Εισαγωγή] Κύριο μενού |  [B] Προηγούμενη οθόνη |  [Esc] Έξοδος'
        "NavKeepInput" = '[V] Διατήρηση του αρχείου στο φάκελο εισόδου'
        "OfficialDownloadSuccess" = '[OK] Το επίσημο αρχείο λήφθηκε με επιτυχία ({0:N0} byte).'
        "PkgCompressingGz" = '[*] Συμπίεση σε ''bnupdate.tar.gz'' μέσω .NET GZipStream...'
        "PkgCreatingTar" = '[*] Δημιουργία ''bnupdate.tar'' και ορισμός δικαιωμάτων εκτέλεσης POSIX (+x)...'
        "PkgErrorTar" = '[!] Δεν ήταν δυνατή η δημιουργία του bnupdate.tar.'
        "PkgGenTitle" = 'PSBBN INSTALLATION PACKAGE GENERATION (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Οι υφές (.tm2 και .png) παραμένουν στα αγγλικά (απαιτείται χειροκίνητος επανασχεδιασμός γραφικών).'
        "PkgNotice2" = '2. Το 100% των κειμένων συστήματος (XML, ATOK HTML και σενάρια) μεταφράζονται.'
        "PkgNotice3" = '3. Το αρχείο ''bnupdate.tar.gz'' προορίζεται για άμεση δοκιμή σε PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[ΤΕΧΝΙΚΗ ΣΗΜΕΙΩΣΗ]:'
        "PkgPromptTar" = 'Θέλετε να δημιουργήσετε το αρχείο ''bnupdate.tar.gz'' για δοκιμή στο PS2; (Ναι/Δ) [Προεπιλογή: Ν]'
        "PkgSuccess" = '[+] Το πακέτο δημιουργήθηκε με επιτυχία (Ενεργοποιήθηκαν τα δικαιώματα Linux 0755): {0} ({1:N0} byte)'
        "PosixPatchedCount" = '[+] Αρχεία επιδιορθωμένα με άδεια εκτέλεσης POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Πατήστε οποιοδήποτε πλήκτρο για να επιστρέψετε στο μενού...'
        "ProgressAtokHelp" = 'Μετάφραση Βοήθεια ATOK'
        "ProgressUpdatingHtml" = 'Ενημέρωση αρχείων HTML'
        "ProgressUpdatingXml" = 'Ενημέρωση αρχείων XML'
        "ProgressXmlStrings" = 'Μετάφραση συμβολοσειρών XML'
        "PsbbnEnglishEnsure" = 'Βεβαιωθείτε ότι ο φάκελος "PSBBN_English" υπάρχει στο "input".'
        "PsbbnEnglishNotFoundTitle" = '[!] ΣΦΑΛΜΑ: Ο ΒΑΣΙΚΟΣ ΚΑΤΑΛΟΓΟΣ PSBBN_ENGLISH ΔΕΝ ΒΡΕΘΗΚΕ!'
        "ReadmeEnsure" = 'Βεβαιωθείτε ότι το αρχείο ''README.md'' βρίσκεται στο φάκελο ''input''.'
        "ReadmeNotFoundDownloading" = '[*] Το README.md δεν βρέθηκε. Λήψη από επίσημο αποθετήριο...'
        "ReadmeNotFoundTitle" = '[!] ΣΦΑΛΜΑ: ΤΟ ΑΡΧΕΙΟ README.MD ΔΕΝ ΒΡΕΘΗΚΕ!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} επιλεγμένες γλώσσες ({1})'
        "SelectUILangPrompt" = 'Επιλέξτε μια επιλογή'
        "SelectUITitle" = 'ΑΛΛΑΓΉ ΓΛΏΣΣΑΣ ΔΙΕΠΑΦΉΣ ΧΡΉΣΤΗ'
        "SessionStarted" = 'Η συνεδρία ξεκίνησε στις:'
        "SourceFile" = 'Πηγή:'
        "Step1Copying" = '[*] [1/3] Αντιγραφή πλήρους δομής και δυαδικών αρχείων...'
        "Step2TranslatingXml" = '[*] [2/3] Μετάφραση {0} αρχείων XML συστήματος...'
        "Step3TranslatingAtok" = '[*] [3/3] Μετάφραση {0} ATOK HTML αρχείων βοήθειας...'
        "SuiteTitle" = 'PSBBN Πολυγλωσσική Σουίτα μετάφρασης - V1 [By Emerson Teles]'
        "SystemTitle" = 'Μεταφραστής συστήματος PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Σημείωση: Οι υφές (.tm2 / .png) περιέχουν ενσωματωμένα γραφικά και   απαιτούν μη αυτόματη επεξεργασία. δεν αλλοιώνονται από το σενάριο. Τα   αρχεία κειμένου συστήματος (XML, HTML, txt) μεταφράζονται 100%.'
        "Translating" = 'Μετάφραση'
        "UsingFallback" = '[!] Χρήση τοπικής εναλλακτικής: {0}'
        "ValidatingXml" = '[*] Επικύρωση συντακτικής ακεραιότητας του 100% των αρχείων XML...'
        "XmlSyntaxError" = '[!] Σφάλμα σύνταξης στο {0}: {1}'
        "XmlValidationSuccess" = '[+] Το 100% των αρχείων XML επικυρώθηκε με επιτυχία (0 συντακτικά σφάλματα).'
    }
    "en" = @{
        "All40Success" = 'All 40 Languages (Full Multilingual)'
        "AllLanguages" = 'Translate All Languages (1 - 40)'
        "BackMenu" = 'Back to Main Menu'
        "CancelOption" = 'Back'
        "CannotConnectGithub" = '[!] Cannot connect to GitHub: {0}'
        "ChangeLanguage" = 'Change UI Language'
        "ChangelogMainNotFoundTitle" = '[!] ERROR: COULD NOT DOWNLOAD OR LOCATE CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ERROR: COULD NOT DOWNLOAD OR LOCATE CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Select an option:'
        "CompletionBanner" = '[OK] Translation of {0} successfully finished - 100%'
        "DescLauncher" = 'Generates and updates the PSBBN Launcher for Windows with support for all 40 languages.'
        "DescMain" = 'Translates the main installer release notes and changelog (changelog_main_eng.txt).'
        "DescPatch" = 'Translates patch history, fixes, and channel update notes (changelog_patch_eng.txt).'
        "DescReadme" = 'Translates the official PSBBN README.md preserving markdown formatting and links.'
        "DescScript" = 'Translates all 458 UI strings for the Linux/WSL PSBBN installer script (eng.txt).'
        "DescSystem" = 'Translates all PS2 PSBBN system files (XML dialogs, guides, menus, NetFront/ATOK help).'
        "DestFile" = 'Destination:'
        "DownloadingLatestGithub" = '[i] Downloading latest official version from GitHub...'
        "DownloadingOfficial" = '[*] Downloading official file from GitHub repository...'
        "EnglishOption" = 'English (default)'
        "EngTxtEnsureFile" = 'Please ensure that the ''eng.txt'' file is present in the ''input'' folder.'
        "EngTxtErrorTitle" = '[!] ERROR: ENG.TXT FILE NOT FOUND!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt not found. Downloading from official repository...'
        "EnsureConnected" = 'Please ensure you are connected to the Internet or place the file in the input directory.'
        "ExitOption" = 'Exit'
        "ExpectedPath" = 'Expected path: {0}'
        "ExtractingPack" = '[*] Extracting PSBBN v3.5 translation pack...'
        "FileNotFoundError" = '[ERROR] File not found: {0}'
        "GeneratedFile" = '[OK] Generated file: {0}'
        "GenericEnsureInternetOrInput" = 'Please ensure you are connected to the Internet or have the file in the ''input'' folder.'
        "IndividualBlocks" = 'Individual Blocks: {0}'
        "IndividualBlocksNotice" = '[OK] Individual blocks for CosmicScale: {0}'
        "InputFileDeleted" = '[OK] File(s) deleted from input folder.'
        "InputFileKept" = '[OK] File(s) kept in input folder.'
        "InvalidOption" = 'Invalid option! Press Enter to try again...'
        "LangAppliedSuccess" = '[OK] UI language successfully applied: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Windows system language auto-detection enabled.'
        "LauncherBaseNotFoundTitle" = '[!] ERROR: COULD NOT DOWNLOAD OR LOCATE BASE LAUNCHER SCRIPT!'
        "LauncherIntegrated" = '[OK] Integrated support for {0} language(s) into PSBBN Launcher for Windows!'
        "LauncherPrompt" = 'Choose one or more languages (e.g. 7 or 1, 2, 3 or 1-5 or A)'
        "LauncherTip1" = '- Enter 1 number to generate the file with only that language.'
        "LauncherTipAll" = '- Enter ''A'' to generate the complete file with all 40 languages.'
        "LauncherTipHeader" = '* Tip: Each execution generates a clean file containing only the chosen language(s).'
        "LauncherTipMulti" = '- Enter multiple numbers separated by comma (e.g. 1, 2, 3) to generate with those languages.'
        "LauncherTipRange" = '- Enter a range (e.g. 1-5) to generate with that range of languages.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Previous Screen'
        "NavDeleteInput" = '[X] Delete file from input folder'
        "NavEnter" = '[Enter] Main Menu'
        "NavExit" = '[Esc] Exit'
        "NavInstructions" = '[Enter] Main Menu  |  [B] Previous Screen  |  [Esc] Exit'
        "NavKeepInput" = '[V] Keep file in input folder'
        "OfficialDownloadSuccess" = '[OK] Official file downloaded successfully ({0:N0} bytes).'
        "PkgCompressingGz" = '[*] Compressing to ''bnupdate.tar.gz'' via .NET GZipStream...'
        "PkgCreatingTar" = '[*] Creating ''bnupdate.tar'' and setting POSIX execution permissions (+x)...'
        "PkgErrorTar" = '[!] Could not generate bnupdate.tar.'
        "PkgGenTitle" = 'PSBBN INSTALLATION PACKAGE GENERATION (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Textures (.tm2 and .png) remain in English (require manual graphic redesign).'
        "PkgNotice2" = '2. 100% of system texts (XML, ATOK HTML and scripts) are translated.'
        "PkgNotice3" = '3. The ''bnupdate.tar.gz'' file is intended for immediate testing on PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TECHNICAL NOTICE]:'
        "PkgPromptTar" = 'Do you want to generate the ''bnupdate.tar.gz'' file to test on PS2? (Y/N) [Default: Y]'
        "PkgSuccess" = '[+] Package generated successfully (Linux 0755 permissions enabled): {0} ({1:N0} bytes)'
        "PosixPatchedCount" = '[+] Files patched with POSIX 0755 execution permission (+x): {0}'
        "PressAnyKey" = 'Press any key to return to menu...'
        "ProgressAtokHelp" = 'Translating ATOK Help'
        "ProgressUpdatingHtml" = 'Updating HTML files'
        "ProgressUpdatingXml" = 'Updating XML files'
        "ProgressXmlStrings" = 'Translating XML strings'
        "PsbbnEnglishEnsure" = 'Please ensure that the ''PSBBN_English'' folder is present inside ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] ERROR: BASE DIRECTORY PSBBN_ENGLISH NOT FOUND!'
        "ReadmeEnsure" = 'Please ensure that the ''README.md'' file is in the ''input'' folder.'
        "ReadmeNotFoundDownloading" = '[*] README.md not found. Downloading from official repository...'
        "ReadmeNotFoundTitle" = '[!] ERROR: README.MD FILE NOT FOUND!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} languages selected ({1})'
        "SelectUILangPrompt" = 'Select UI language'
        "SelectUITitle" = 'SELECT UI LANGUAGE'
        "SessionStarted" = 'Session started on:'
        "SourceFile" = 'Source:'
        "Step1Copying" = '[*] [1/3] Copying complete structure and binaries...'
        "Step2TranslatingXml" = '[*] [2/3] Translating {0} system XML files...'
        "Step3TranslatingAtok" = '[*] [3/3] Translating {0} ATOK HTML help files...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Notice: Textures (.tm2 / .png) require manual graphic editing (not via script). The suite translates 100% of system file texts (XML, HTML, menus and scripts).'
        "Translating" = 'Translating'
        "UsingFallback" = '[!] Using local fallback: {0}'
        "ValidatingXml" = '[*] Validating syntactic integrity of 100% of XML files...'
        "XmlSyntaxError" = '[!] Syntax error in {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% of XML files validated successfully (0 syntax errors).'
    }
    "es" = @{
        "All40Success" = 'Todos los 40 idiomas (multilingüe completo)'
        "AllLanguages" = 'Traducir Todos los Idiomas (1 - 40)'
        "BackMenu" = 'Volver al Menú Principal'
        "CancelOption" = 'Volver'
        "CannotConnectGithub" = '[!] No se pudo conectar a GitHub: {0}'
        "ChangeLanguage" = 'Cambiar idioma de la interfaz'
        "ChangelogMainNotFoundTitle" = '[!] ERROR: ¡NO SE PUDO DESCARGAR O ENCONTRAR CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Traductor PSBBN Changelog Main [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ERROR: ¡NO SE PUDO DESCARGAR O ENCONTRAR CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Traductor PSBBN Changelog Patch [By Emerson Teles]'
        "ChooseOption" = 'Seleccione una opción:'
        "CompletionBanner" = '[OK] Traducción de {0} finalizada con éxito - 100%'
        "DescLauncher" = 'Genera y actualiza PSBBN Launcher for Windows con soporte para los 40 idiomas.'
        "DescMain" = 'Traduce el registro de cambios principal (changelog_main_eng.txt).'
        "DescPatch" = 'Traduce las notas de parches y actualizaciones de canales (changelog_patch_eng.txt).'
        "DescReadme" = 'Traduce el README.md oficial conservando el formato Markdown y los enlaces.'
        "DescScript" = 'Traduce las 458 cadenas de interfaz del instalador Linux/WSL (eng.txt).'
        "DescSystem" = 'Traduce todos los archivos del sistema PSBBN (diálogos XML, guías, menús, ayuda ATOK).'
        "DestFile" = 'Destino:'
        "DownloadingLatestGithub" = '[i] Descargando la última versión oficial desde GitHub...'
        "DownloadingOfficial" = '[*] Descargando archivo oficial del repositorio de GitHub...'
        "EnglishOption" = 'Inglés (predeterminado)'
        "EngTxtEnsureFile" = 'Asegúrese de que el archivo ''eng.txt'' esté presente en la carpeta ''input''.'
        "EngTxtErrorTitle" = '[!] ERROR: ¡ARCHIVO ENG.TXT NO ENCONTRADO!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt no encontrado. Descargando del repositorio oficial...'
        "EnsureConnected" = 'Asegúrese de estar conectado a Internet o coloque el archivo en la carpeta input.'
        "ExitOption" = 'Salir'
        "ExpectedPath" = 'Ruta esperada: {0}'
        "ExtractingPack" = '[*] Extrayendo paquete de traducción PSBBN v3.5...'
        "FileNotFoundError" = '[ERROR] Archivo no encontrado: {0}'
        "GeneratedFile" = '[OK] Archivo generado: {0}'
        "GenericEnsureInternetOrInput" = 'Asegúrese de estar conectado a Internet o tener el archivo en la carpeta ''input''.'
        "IndividualBlocks" = 'Bloques individuales: {0}'
        "IndividualBlocksNotice" = '[OK] Bloques individuales para CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Archivo(s) eliminado(s) de la carpeta de entrada.'
        "InputFileKept" = '[OK] Archivo(s) guardado(s) en la carpeta de entrada.'
        "InvalidOption" = '¡Opción inválida! Presione Enter para continuar...'
        "LangAppliedSuccess" = '[OK] Idioma aplicado en la interfaz con éxito: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Detección automática del idioma del sistema Windows habilitada.'
        "LauncherBaseNotFoundTitle" = '[!] ERROR: ¡NO SE PUDO DESCARGAR O ENCONTRAR EL SCRIPT BASE DEL LAUNCHER!'
        "LauncherIntegrated" = '[OK] ¡Soporte integrado para {0} idioma(s) en PSBBN Launcher for Windows!'
        "LauncherPrompt" = 'Elija uno o más idiomas (ej: 7 o 1, 2, 3 o 1-5 o A)'
        "LauncherTip1" = '- Ingrese 1 número para generar el archivo solo con ese idioma.'
        "LauncherTipAll" = '- Ingrese ''A'' para generar el archivo completo con los 40 idiomas.'
        "LauncherTipHeader" = '* Consejo: Cada ejecución genera un archivo limpio que contiene solo los idiomas elegidos.'
        "LauncherTipMulti" = '- Ingrese varios números separados por coma (ej: 1, 2, 3) para generar con esos idiomas.'
        "LauncherTipRange" = '- Ingrese un rango (ej: 1-5) para generar con ese rango de idiomas.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Pantalla anterior'
        "NavDeleteInput" = '[X] Eliminar archivo de la carpeta de entrada'
        "NavEnter" = '[Entrar] Menú principal'
        "NavExit" = '[Esc] Salir'
        "NavInstructions" = '[Enter] Menú Principal  |  [B] Pantalla Anterior  |  [Esc] Salir'
        "NavKeepInput" = '[V] Mantener el archivo en la carpeta de entrada'
        "OfficialDownloadSuccess" = '[OK] Archivo oficial descargado con éxito ({0:N0} bytes).'
        "PkgCompressingGz" = '[*] Comprimiendo a ''bnupdate.tar.gz'' mediante .NET GZipStream...'
        "PkgCreatingTar" = '[*] Creando ''bnupdate.tar'' y ajustando permisos de ejecución POSIX (+x)...'
        "PkgErrorTar" = '[!] No se pudo generar bnupdate.tar.'
        "PkgGenTitle" = 'GENERACIÓN DEL PAQUETE DE INSTALACIÓN PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Las texturas (.tm2 y .png) permanecen en inglés (requieren rediseño gráfico manual).'
        "PkgNotice2" = '2. El 100% de los textos del sistema (XML, HTML ATOK y scripts) están traducidos.'
        "PkgNotice3" = '3. El archivo ''bnupdate.tar.gz'' está destinado a pruebas inmediatas en PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[AVISO TÉCNICO]:'
        "PkgPromptTar" = '¿Desea generar el archivo ''bnupdate.tar.gz'' para probar en PS2? (S/N) [Predeterminado: S]'
        "PkgSuccess" = '[+] Paquete generado con éxito (permisos Linux 0755 habilitados): {0} ({1:N0} bytes)'
        "PosixPatchedCount" = '[+] Archivos ajustados con permiso de ejecución POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Presione cualquier tecla para volver al menú...'
        "ProgressAtokHelp" = 'Traduciendo ayuda de ATOK'
        "ProgressUpdatingHtml" = 'Actualizando archivos HTML'
        "ProgressUpdatingXml" = 'Actualizando archivos XML'
        "ProgressXmlStrings" = 'Traduciendo cadenas XML'
        "PsbbnEnglishEnsure" = 'Asegúrese de que la carpeta ''PSBBN_English'' esté presente dentro de ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] ERROR: ¡DIRECTORIO BASE PSBBN_ENGLISH NO ENCONTRADO!'
        "ReadmeEnsure" = 'Asegúrese de que el archivo ''README.md'' esté en la carpeta ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md no encontrado. Descargando del repositorio oficial...'
        "ReadmeNotFoundTitle" = '[!] ERROR: ¡ARCHIVO README.MD NO ENCONTRADO!'
        "ReadmeTitle" = 'Traductor PSBBN Readme [By Emerson Teles]'
        "ScriptTitle" = 'Traductor PSBBN Script [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} idiomas seleccionados ({1})'
        "SelectUILangPrompt" = 'Elija el idioma de la interfaz'
        "SelectUITitle" = 'SELECCIONAR IDIOMA DE LA INTERFAZ'
        "SessionStarted" = 'Sesión iniciada el:'
        "SourceFile" = 'Origen:'
        "Step1Copying" = '[*] [1/3] Copiando estructura completa y binarios...'
        "Step2TranslatingXml" = '[*] [2/3] Traduciendo {0} archivos XML del sistema...'
        "Step3TranslatingAtok" = '[*] [3/3] Traduciendo {0} archivos HTML de ayuda de ATOK...'
        "SuiteTitle" = 'Suite Multilingüe de Traducción PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'Traductor System PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Aviso: Las texturas (.tm2 / .png) requieren edición gráfica manual (no por script). La suite traduce el 100% de los textos del sistema (XML, HTML, menús y scripts).'
        "Translating" = 'Traduciendo'
        "UsingFallback" = '[!] Usando copia local de respaldo: {0}'
        "ValidatingXml" = '[*] Validando integridad sintáctica del 100% de los archivos XML...'
        "XmlSyntaxError" = '[!] Error sintáctico en {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% de los archivos XML validados con éxito (0 errores de sintaxis).'
    }
    "fa" = @{
        "All40Success" = 'همه 40 زبان (چند زبانه کامل)'
        "AllLanguages" = 'ترجمه همه زبانها (1 - 40)'
        "BackMenu" = 'بازگشت به منوی اصلی'
        "CancelOption" = 'برگشت'
        "CannotConnectGithub" = '[!] نمی توان به GitHub متصل شد: {0}'
        "ChangeLanguage" = 'Change UI Language'
        "ChangelogMainNotFoundTitle" = '[!] خطا: نمی‌توان CHANGELOG_MAIN_ENG.TXT را دانلود یا پیدا کرد!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] خطا: نمی‌توان CHANGELOG_PATCH_ENG.TXT را دانلود یا پیدا کرد!'
        "ChangelogPatchTitle" = 'مترجم پچ تغییرات PSBBN [By Emerson Teles]'
        "ChooseOption" = 'یک گزینه را انتخاب کنید:'
        "CompletionBanner" = '[OK] ترجمه {0} با موفقیت به پایان رسید - 100%'
        "DescLauncher" = 'PSBBN Launcher برای ویندوز را با پشتیبانی از همه 40 زبان ایجاد و به روز می کند.'
        "DescMain" = 'یادداشت‌های انتشار نصب‌کننده اصلی و تغییرات را ترجمه می‌کند (changelog_main_eng.txt).'
        "DescPatch" = 'تاریخچه وصله، اصلاحات و یادداشت‌های به‌روزرسانی کانال را ترجمه می‌کند (changelog_patch_eng.txt).'
        "DescReadme" = 'ترجمه رسمی PSBBN README.md با حفظ قالب بندی علامت گذاری و پیوندها.'
        "DescScript" = 'تمام 458 رشته UI را برای اسکریپت نصب کننده Linux/WSL PSBBN (eng.txt) ترجمه می کند.'
        "DescSystem" = 'Translates all PS2 PSBBN system files (XML dialogs, guides, menus, NetFront/ATOK help).'
        "DestFile" = 'مقصد:'
        "DownloadingLatestGithub" = '[i] دانلود آخرین نسخه رسمی از GitHub...'
        "DownloadingOfficial" = '[*] در حال دانلود فایل رسمی از مخزن GitHub...'
        "EnglishOption" = 'انگلیسی (پیش‌فرض)'
        "EngTxtEnsureFile" = 'لطفاً مطمئن شوید که فایل ''eng.txt'' در پوشه ''input'' وجود دارد.'
        "EngTxtErrorTitle" = '[!] خطا: فایل ENG.TXT یافت نشد!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt یافت نشد. دانلود از مخزن رسمی...'
        "EnsureConnected" = 'لطفاً مطمئن شوید که به اینترنت متصل هستید یا فایل را در فهرست ورودی قرار دهید.'
        "ExitOption" = 'خارج شوید'
        "ExpectedPath" = 'مسیر مورد انتظار: {0}'
        "ExtractingPack" = '[*] استخراج بسته ترجمه PSBBN v3.5...'
        "FileNotFoundError" = '[خطا] فایل یافت نشد: {0}'
        "GeneratedFile" = '[OK] فایل تولید شده: {0}'
        "GenericEnsureInternetOrInput" = 'لطفاً مطمئن شوید که به اینترنت متصل هستید یا فایل را در پوشه "ورودی" دارید.'
        "IndividualBlocks" = 'بلوک های فردی: {0}'
        "IndividualBlocksNotice" = '[OK] بلوک‌های جداگانه برای CosmicScale: {0}'
        "InputFileDeleted" = '[OK] فایل(های) از پوشه ورودی حذف شد.'
        "InputFileKept" = '[OK] فایل(های) در پوشه ورودی نگهداری می شود.'
        "InvalidOption" = 'گزینه نامعتبر! برای امتحان دوباره Enter را فشار دهید...'
        "LangAppliedSuccess" = '[OK] زبان رابط کاربری با موفقیت اعمال شد: {0} ({1})'
        "LauncherAutoDetect" = '[OK] تشخیص خودکار زبان سیستم ویندوز فعال شد.'
        "LauncherBaseNotFoundTitle" = '[!] خطا: نمی‌توان اسکریپت BASE Launcher را دانلود یا پیدا کرد!'
        "LauncherIntegrated" = '[OK] پشتیبانی یکپارچه برای {0} زبان(های) در PSBBN Launcher برای ویندوز!'
        "LauncherPrompt" = 'یک یا چند زبان را انتخاب کنید (مثلاً 7 یا 1، 2، 3 یا 1-5 یا A):'
        "LauncherTip1" = '- 1 عدد را وارد کنید تا فایل فقط با آن زبان تولید شود.'
        "LauncherTipAll" = '- برای تولید فایل کامل با تمام 40 زبان، ''A'' را وارد کنید.'
        "LauncherTipHeader" = '* نکته: هر اجرا یک فایل تمیز تولید می کند که فقط شامل زبان(های) انتخاب شده است.'
        "LauncherTipMulti" = '- اعداد متعددی را وارد کنید که با کاما از هم جدا شده اند (مثلاً 1، 2، 3) برای ایجاد با آن زبان ها.'
        "LauncherTipRange" = '- یک محدوده (به عنوان مثال 1-5) را برای ایجاد با آن محدوده از زبان ها وارد کنید.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] صفحه قبلی'
        "NavDeleteInput" = '[X] حذف فایل از پوشه ورودی'
        "NavEnter" = '[Enter] منوی اصلی'
        "NavExit" = '[Esc] خروج'
        "NavInstructions" = '[ورود] منوی اصلی |  [B] صفحه قبلی |  [Esc] خروج'
        "NavKeepInput" = '[V] نگه داشتن فایل در پوشه ورودی'
        "OfficialDownloadSuccess" = '[OK] فایل رسمی با موفقیت بارگیری شد ({0:N0} بایت).'
        "PkgCompressingGz" = '[*] فشرده سازی به ''bnupdate.tar.gz'' از طریق NET GZipStream...'
        "PkgCreatingTar" = '[*] ایجاد ''bnupdate.tar'' و تنظیم مجوزهای اجرای POSIX (+x)...'
        "PkgErrorTar" = '[!] bnupdate.tar ایجاد نشد.'
        "PkgGenTitle" = 'تولید بسته نصب PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. بافت ها (tm2. و .png) به زبان انگلیسی باقی می مانند (نیاز به طراحی مجدد گرافیکی دستی).'
        "PkgNotice2" = '2. 100% متون سیستم (XML، ATOK HTML و اسکریپت ها) ترجمه می شوند.'
        "PkgNotice3" = '3. فایل ''bnupdate.tar.gz'' برای آزمایش فوری روی PS2 (HDD / Telnet / USB) در نظر گرفته شده است.'
        "PkgNoticeHeader" = '[اطلاعیه فنی]:'
        "PkgPromptTar" = 'آیا می خواهید فایل ''bnupdate.tar.gz'' را برای آزمایش در PS2 ایجاد کنید؟ (Y/N) [پیش‌فرض: Y]'
        "PkgSuccess" = '[+] بسته با موفقیت ایجاد شد (مجوزهای لینوکس 0755 فعال است): {0} ({1:N0} بایت)'
        "PosixPatchedCount" = '[+] فایل‌های وصله‌شده با مجوز اجرای POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'برای بازگشت به منو، هر کلیدی را فشار دهید...'
        "ProgressAtokHelp" = 'ترجمه راهنما ATOK'
        "ProgressUpdatingHtml" = 'به روز رسانی فایل های HTML'
        "ProgressUpdatingXml" = 'به روز رسانی فایل های XML'
        "ProgressXmlStrings" = 'ترجمه رشته های XML'
        "PsbbnEnglishEnsure" = 'لطفاً مطمئن شوید که پوشه "PSBBN_English" در داخل "ورودی" وجود دارد.'
        "PsbbnEnglishNotFoundTitle" = '[!] خطا: BASE DIRECTORY PSBBN_ENGLISH یافت نشد!'
        "ReadmeEnsure" = 'لطفاً مطمئن شوید که فایل "README.md" در پوشه "ورودی" است.'
        "ReadmeNotFoundDownloading" = '[*] README.md یافت نشد. دانلود از مخزن رسمی...'
        "ReadmeNotFoundTitle" = '[!] خطا: فایل README.MD یافت نشد!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'مترجم اسکریپت PSBBN [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} زبان انتخاب شده ({1})'
        "SelectUILangPrompt" = 'یک گزینه را انتخاب کنید'
        "SelectUITitle" = 'CHANGE UI LANGUAGE'
        "SessionStarted" = 'جلسه در تاریخ شروع شد:'
        "SourceFile" = 'منبع:'
        "Step1Copying" = '[*] [1/3] کپی ساختار کامل و باینری ها...'
        "Step2TranslatingXml" = '[*] [2/3] ترجمه فایل های XML سیستم {0}...'
        "Step3TranslatingAtok" = '[*] [3/3] ترجمه فایل های راهنمای {0} ATOK HTML...'
        "SuiteTitle" = 'مجموعه ترجمه چند زبانه PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'مترجم سیستم PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'توجه: بافت‌ها (tm2. / .png) حاوی گرافیک‌های تعبیه‌شده هستند و نیاز به   ویرایش دستی دارند. آنها توسط فیلمنامه تغییر نمی کنند. فایل های متنی   سیستم (XML، HTML، txt) 100٪ ترجمه شده اند.'
        "Translating" = 'در حال ترجمه'
        "UsingFallback" = '[!] استفاده از بازگشت محلی: {0}'
        "ValidatingXml" = '[*] اعتبار سنجی یکپارچگی نحوی 100% فایل های XML...'
        "XmlSyntaxError" = '[!] خطای نحوی در {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% فایل‌های XML با موفقیت تأیید شدند (0 خطای نحوی).'
    }
    "fi" = @{
        "All40Success" = 'Kaikki 40 kieltä (täysi monikielinen)'
        "AllLanguages" = 'Käännä kaikki kielet (1–40)'
        "BackMenu" = 'Takaisin päävalikkoon'
        "CancelOption" = 'Takaisin'
        "CannotConnectGithub" = '[!] Ei voi muodostaa yhteyttä GitHubiin: {0}'
        "ChangeLanguage" = 'Vaihda käyttöliittymän kieli'
        "ChangelogMainNotFoundTitle" = '[!] VIRHE: CHANGELOG_MAIN_ENG.TXT-tiedostoa EI VOI LADATA TAI LATAUS!'
        "ChangelogMainTitle" = 'PSBBN-muutoslokin pääkääntäjä [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] VIRHE: CHANGELOG_PATCH_ENG.TXT-tiedostoa EI VOI LADATA TAI LATAUS!'
        "ChangelogPatchTitle" = 'PSBBN muutoslokin korjauskääntäjä [By Emerson Teles]'
        "ChooseOption" = 'Valitse vaihtoehto:'
        "CompletionBanner" = '[OK] Kielen {0} käännös onnistui - 100 %'
        "DescLauncher" = 'Luo ja päivittää PSBBN Launcher for Windows -ohjelman, joka tukee kaikkia 40 kieltä.'
        "DescMain" = 'Kääntää tärkeimmät asennusohjelman julkaisutiedot ja muutoslokin (changelog_main_eng.txt).'
        "DescPatch" = 'Kääntää korjaustiedostohistorian, korjaukset ja kanavapäivityshuomautukset (changelog_patch_eng.txt).'
        "DescReadme" = 'Translates the official PSBBN README.md preserving markdown formatting and links.'
        "DescScript" = 'Kääntää kaikki 458 käyttöliittymämerkkijonoa Linux/WSL PSBBN-asennusohjelmalle (eng.txt).'
        "DescSystem" = 'Kääntää kaikki PS2 PSBBN -järjestelmätiedostot (XML-valintaikkunat, oppaat, valikot, NetFront/ATOK-ohjeet).'
        "DestFile" = 'Kohde:'
        "DownloadingLatestGithub" = '[i] Ladataan uusin virallinen versio GitHubista...'
        "DownloadingOfficial" = '[*] Ladataan virallista tiedostoa GitHub-arkistosta...'
        "EnglishOption" = 'Englanti (oletus)'
        "EngTxtEnsureFile" = 'Varmista, että "eng.txt"-tiedosto on "input"-kansiossa.'
        "EngTxtErrorTitle" = '[!] VIRHE: ENG.TXT-TIEDOSTO EI LÖYDYT!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt-tiedostoa ei löydy. Ladataan virallisesta arkistosta...'
        "EnsureConnected" = 'Varmista, että olet yhteydessä Internetiin tai sijoita tiedosto syöttöhakemistoon.'
        "ExitOption" = 'Exit'
        "ExpectedPath" = 'Odotettu polku: {0}'
        "ExtractingPack" = '[*] Puretaan PSBBN v3.5 -käännöspakettia...'
        "FileNotFoundError" = '[ERROR] Tiedostoa ei löydy: {0}'
        "GeneratedFile" = '[OK] Luotu tiedosto: {0}'
        "GenericEnsureInternetOrInput" = 'Varmista, että olet yhteydessä Internetiin tai että tiedosto on syöttökansiossa.'
        "IndividualBlocks" = 'Yksittäiset lohkot: {0}'
        "IndividualBlocksNotice" = '[OK] CosmicScalen yksittäiset lohkot: {0}'
        "InputFileDeleted" = '[OK] Tiedosto(t) poistettu syöttökansiosta.'
        "InputFileKept" = '[OK] Tiedosto(t) säilytetään syöttökansiossa.'
        "InvalidOption" = 'Virheellinen vaihtoehto! Yritä uudelleen painamalla Enter...'
        "LangAppliedSuccess" = '[OK] Käyttöliittymän kieli otettu onnistuneesti käyttöön: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Windowsin järjestelmäkielen automaattinen tunnistus käytössä.'
        "LauncherBaseNotFoundTitle" = '[!] VIRHE: PERUSKÄYNNISTYSOHJELMAA EI VOI LADATA TAI PAIKKAA!'
        "LauncherIntegrated" = '[OK] Integroitu tuki {0} kielelle Windows PSBBN Launcheriin!'
        "LauncherPrompt" = 'Valitse yksi tai useampi kieli (esim. 7 tai 1, 2, 3 tai 1-5 tai A):'
        "LauncherTip1" = '- Kirjoita 1 numero luodaksesi tiedoston vain tällä kielellä.'
        "LauncherTipAll" = '- Kirjoita ''A'' luodaksesi täydellisen tiedoston kaikilla 40 kielellä.'
        "LauncherTipHeader" = '* Vihje: Jokainen suoritus luo puhtaan tiedoston, joka sisältää vain valitut kielet.'
        "LauncherTipMulti" = '- Kirjoita useita pilkuilla erotettuja numeroita (esim. 1, 2, 3) luodaksesi kyseisillä kielillä.'
        "LauncherTipRange" = '- Syötä alue (esim. 1-5), joka luodaan tällä kielialueella.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Edellinen näyttö'
        "NavDeleteInput" = '[X] Poista tiedosto syöttökansiosta'
        "NavEnter" = '[Syötä] Päävalikko'
        "NavExit" = '[Esc] Poistu'
        "NavInstructions" = '[Syötä] Päävalikko |  [B] Edellinen näyttö |  [Esc] Poistu'
        "NavKeepInput" = '[V] Säilytä tiedosto syöttökansiossa'
        "OfficialDownloadSuccess" = '[OK] Virallinen tiedosto ladattiin onnistuneesti ({0:N0} tavua).'
        "PkgCompressingGz" = '[*] Pakkaaminen tiedostoon "bnupdate.tar.gz" .NET GZipStreamin kautta...'
        "PkgCreatingTar" = '[*] Luodaan "bnupdate.tar" ja asetetaan POSIX-suoritusoikeudet (+x)...'
        "PkgErrorTar" = '[!] Tiedostoa bnupdate.tar ei voitu luoda.'
        "PkgGenTitle" = 'PSBBN-ASENNUSPAKETTIEN LUOMINEN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Tekstuurit (.tm2 ja .png) pysyvät englanninkielisinä (vaatii manuaalisen grafiikan uudelleensuunnittelun).'
        "PkgNotice2" = '2. 100 % järjestelmäteksteistä (XML, ATOK HTML ja skriptit) käännetään.'
        "PkgNotice3" = '3. Tiedosto bnupdate.tar.gz on tarkoitettu välittömään testaukseen PS2:lla (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TEKNINEN ILMOITUS]:'
        "PkgPromptTar" = 'Haluatko luoda bnupdate.tar.gz-tiedoston testattavaksi PS2:lla? (K/E) [Oletus: K]'
        "PkgSuccess" = '[+] Paketti luotu onnistuneesti (Linux 0755 -oikeudet käytössä): {0} ({1:N0} tavua)'
        "PosixPatchedCount" = '[+] Tiedostot, jotka on korjattu POSIX 0755 -suoritusluvalla (+x): {0}'
        "PressAnyKey" = 'Palaa valikkoon painamalla mitä tahansa näppäintä...'
        "ProgressAtokHelp" = 'ATOK-ohjeen kääntäminen'
        "ProgressUpdatingHtml" = 'Päivitetään HTML-tiedostoja'
        "ProgressUpdatingXml" = 'Päivitetään XML-tiedostoja'
        "ProgressXmlStrings" = 'XML-merkkijonojen kääntäminen'
        "PsbbnEnglishEnsure" = 'Varmista, että PSBBN_English-kansio on "input" -kohdassa.'
        "PsbbnEnglishNotFoundTitle" = '[!] VIRHE: PERUSHAKEMISTOA PSBBN_ENGLISH EI LÖYDYNYT!'
        "ReadmeEnsure" = 'Varmista, että ''README.md''-tiedosto on ''input''-kansiossa.'
        "ReadmeNotFoundDownloading" = '[*] README.md:tä ei löydy. Ladataan virallisesta arkistosta...'
        "ReadmeNotFoundTitle" = '[!] VIRHE: README.MD-TIEDOSTO EI LÖYDYT!'
        "ReadmeTitle" = 'PSBBN Readme -kääntäjä [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} kieliä valittu ({1})'
        "SelectUILangPrompt" = 'Valitse vaihtoehto'
        "SelectUITitle" = 'VAIHDA KÄYTTÖLIITTYMÄN KIELI'
        "SessionStarted" = 'Istunto alkoi:'
        "SourceFile" = 'Lähde:'
        "Step1Copying" = '[*] [1/3] Kopioidaan koko rakennetta ja binääritiedostoja...'
        "Step2TranslatingXml" = '[*] [2/3] Käännetään {0} järjestelmän XML-tiedostoja...'
        "Step3TranslatingAtok" = '[*] [3/3] Käännetään {0} ATOK HTML -aputiedostoja...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'Järjestelmän PSBBN-kääntäjä [By Emerson Teles]'
        "TextureDisclaimer" = 'Huomautus: Tekstuurit (.tm2 / .png) sisältävät upotettua grafiikkaa ja   vaativat manuaalisen muokkauksen; käsikirjoitus ei muuta niitä.   Järjestelmän tekstitiedostot (XML, HTML, txt) käännetään   100-prosenttisesti.'
        "Translating" = 'Kääntäminen'
        "UsingFallback" = '[!] Paikallinen varatoiminto: {0}'
        "ValidatingXml" = '[*] Vahvistetaan XML-tiedostojen 100 %:n syntaktista eheyttä...'
        "XmlSyntaxError" = '[!] Syntaksivirhe kohteessa {0}: {1}'
        "XmlValidationSuccess" = '[+] 100 % XML-tiedostoista validoitu onnistuneesti (0 syntaksivirhettä).'
    }
    "fr" = @{
        "All40Success" = 'Toutes les 40 langues (multilingue complet)'
        "AllLanguages" = 'Traduire Toutes les Langues (1 - 40)'
        "BackMenu" = 'Retour au Menu Principal'
        "CancelOption" = 'Retour'
        "CannotConnectGithub" = '[!] Impossible de se connecter à GitHub : {0}'
        "ChangeLanguage" = 'Changer la langue de l''interface'
        "ChangelogMainNotFoundTitle" = '[!] ERREUR: IMPOSSIBLE DE TÉLÉCHARGER OU LOCALISER CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Traducteur PSBBN Changelog Main [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ERREUR: IMPOSSIBLE DE TÉLÉCHARGER OU LOCALISER CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Traducteur PSBBN Changelog Patch [By Emerson Teles]'
        "ChooseOption" = 'Choisissez une option :'
        "CompletionBanner" = '[OK] Traduction de {0} terminée avec succès - 100%'
        "DescLauncher" = 'Génère et met à jour PSBBN Launcher for Windows avec prise en charge des 40 langues.'
        "DescMain" = 'Traduit les notes de version principales du projet (changelog_main_eng.txt).'
        "DescPatch" = 'Traduit l''historique des correctifs et mises à jour (changelog_patch_eng.txt).'
        "DescReadme" = 'Traduit le README.md officiel en préservant le formatage Markdown et les liens.'
        "DescScript" = 'Traduit les 458 chaînes d''interface du script d''installation (eng.txt).'
        "DescSystem" = 'Traduit tous les fichiers système PSBBN (dialogues XML, guides, menus, aide ATOK).'
        "DestFile" = 'Destination :'
        "DownloadingLatestGithub" = '[i] Téléchargement de la dernière version officielle depuis GitHub...'
        "DownloadingOfficial" = '[*] Téléchargement du fichier officiel depuis le dépôt GitHub...'
        "EnglishOption" = 'Anglais (par défaut)'
        "EngTxtEnsureFile" = 'Veuillez vous assurer que le fichier ''eng.txt'' est présent dans le dossier ''input''.'
        "EngTxtErrorTitle" = '[!] ERREUR: FICHIER ENG.TXT INTROUVABLE!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt introuvable. Téléchargement depuis le dépôt officiel...'
        "EnsureConnected" = 'Veuillez vous assurer d''être connecté à Internet ou placez le fichier dans le dossier input.'
        "ExitOption" = 'Quitter'
        "ExpectedPath" = 'Chemin attendu : {0}'
        "ExtractingPack" = '[*] Extraction du pack de traduction PSBBN v3.5...'
        "FileNotFoundError" = '[ERREUR] Fichier introuvable : {0}'
        "GeneratedFile" = '[OK] Fichier généré : {0}'
        "GenericEnsureInternetOrInput" = 'Veuillez vous assurer d''être connecté à Internet ou d''avoir le fichier dans le dossier ''input''.'
        "IndividualBlocks" = 'Blocs individuels : {0}'
        "IndividualBlocksNotice" = '[OK] Blocs individuels pour CosmicScale : {0}'
        "InputFileDeleted" = '[OK] Fichier(s) supprimé(s) du dossier d''entrée.'
        "InputFileKept" = '[OK] Fichier(s) conservé(s) dans le dossier d''entrée.'
        "InvalidOption" = 'Option invalide ! Appuyez sur Entrée...'
        "LangAppliedSuccess" = '[OK] Langue appliquée à l''interface avec succès : {0} ({1})'
        "LauncherAutoDetect" = '[OK] Détection automatique de la langue du système Windows activée.'
        "LauncherBaseNotFoundTitle" = '[!] ERREUR: IMPOSSIBLE DE TÉLÉCHARGER OU LOCALISER LE SCRIPT DU LAUNCHER!'
        "LauncherIntegrated" = '[OK] Prise en charge intégrée de {0} langue(s) dans PSBBN Launcher for Windows !'
        "LauncherPrompt" = 'Choisissez une ou plusieurs langues (ex : 7 ou 1, 2, 3 ou 1-5 ou A)'
        "LauncherTip1" = '- Entrez 1 numéro pour générer le fichier avec cette seule langue.'
        "LauncherTipAll" = '- Entrez ''A'' pour générer le fichier complet avec les 40 langues.'
        "LauncherTipHeader" = '* Conseil : Chaque exécution génère un fichier propre contenant uniquement la ou les langues choisies.'
        "LauncherTipMulti" = '- Entrez plusieurs numéros séparés par des virgules (ex : 1, 2, 3) pour générer avec ces langues.'
        "LauncherTipRange" = '- Entrez une plage (ex : 1-5) pour générer avec cette plage de langues.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Écran précédent'
        "NavDeleteInput" = '[X] Supprimer le fichier du dossier d''entrée'
        "NavEnter" = '[Entrer] Menu principal'
        "NavExit" = '[Échap] Quitter'
        "NavInstructions" = '[Enter] Menu Principal  |  [B] Écran Précédent  |  [Esc] Quitter'
        "NavKeepInput" = '[V] Conserver le fichier dans le dossier d''entrée'
        "OfficialDownloadSuccess" = '[OK] Fichier officiel téléchargé avec succès ({0:N0} octets).'
        "PkgCompressingGz" = '[*] Compression vers ''bnupdate.tar.gz'' via .NET GZipStream...'
        "PkgCreatingTar" = '[*] Création de ''bnupdate.tar'' et définition des permissions POSIX (+x)...'
        "PkgErrorTar" = '[!] Impossible de générer bnupdate.tar.'
        "PkgGenTitle" = 'GÉNÉRATION DU PAQUET D''INSTALLATION PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Les textures (.tm2 et .png) restent en anglais (nécessitent une refonte graphique manuelle).'
        "PkgNotice2" = '2. 100% des textes système (XML, HTML ATOK et scripts) sont traduits.'
        "PkgNotice3" = '3. Le fichier ''bnupdate.tar.gz'' est destiné aux tests immédiats sur PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[AVIS TECHNIQUE]:'
        "PkgPromptTar" = 'Voulez-vous générer le fichier ''bnupdate.tar.gz'' pour le tester sur PS2? (O/N) [Défaut: O]'
        "PkgSuccess" = '[+] Paquet généré avec succès (permissions Linux 0755 activées): {0} ({1:N0} octets)'
        "PosixPatchedCount" = '[+] Fichiers ajustés avec permission d''exécution POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Appuyez sur une touche pour revenir au menu...'
        "ProgressAtokHelp" = 'Traduction de l''aide ATOK'
        "ProgressUpdatingHtml" = 'Mise à jour des fichiers HTML'
        "ProgressUpdatingXml" = 'Mise à jour des fichiers XML'
        "ProgressXmlStrings" = 'Traduction des chaînes XML'
        "PsbbnEnglishEnsure" = 'Veuillez vous assurer que le dossier ''PSBBN_English'' est présent dans ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] ERREUR: RÉPERTOIRE DE BASE PSBBN_ENGLISH INTROUVABLE!'
        "ReadmeEnsure" = 'Veuillez vous assurer que le fichier ''README.md'' est dans le dossier ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md introuvable. Téléchargement depuis le dépôt officiel...'
        "ReadmeNotFoundTitle" = '[!] ERREUR: FICHIER README.MD INTROUVABLE!'
        "ReadmeTitle" = 'Traducteur PSBBN Readme [By Emerson Teles]'
        "ScriptTitle" = 'Traducteur PSBBN Script [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} langues sélectionnées ({1})'
        "SelectUILangPrompt" = 'Choisissez la langue de l''interface'
        "SelectUITitle" = 'SÉLECTIONNER LA LANGUE DE L''INTERFACE'
        "SessionStarted" = 'Session démarrée le :'
        "SourceFile" = 'Source :'
        "Step1Copying" = '[*] [1/3] Copie de la structure complète et des binaires...'
        "Step2TranslatingXml" = '[*] [2/3] Traduction de {0} fichiers XML système...'
        "Step3TranslatingAtok" = '[*] [3/3] Traduction de {0} fichiers HTML d''aide ATOK...'
        "SuiteTitle" = 'Suite de Traduction Multilingue PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'Traducteur System PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Remarque : Les textures (.tm2 / .png) nécessitent une retouche manuelle. La suite traduit 100% des textes système (XML, HTML, menus et scripts).'
        "Translating" = 'Traduction en cours'
        "UsingFallback" = '[!] Utilisation de la copie locale de secours : {0}'
        "ValidatingXml" = '[*] Validation de l''intégrité syntaxique de 100% des fichiers XML...'
        "XmlSyntaxError" = '[!] Erreur syntaxique dans {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% des fichiers XML validés avec succès (0 erreur de syntaxe).'
    }
    "hi" = @{
        "All40Success" = 'सभी 40 भाषाएँ (पूर्ण बहुभाषी)'
        "AllLanguages" = 'सभी भाषाओं का अनुवाद करना (1 - 40)'
        "BackMenu" = 'मुख्य मेनू पर वापस जाएं'
        "CancelOption" = 'वापस'
        "CannotConnectGithub" = '[!] GitHub से कनेक्ट नहीं हो सकता: {0}'
        "ChangeLanguage" = 'यूआई भाषा बदलें'
        "ChangelogMainNotFoundTitle" = '[!] त्रुटि: CHANGELOG_MAIN_ENG.TXT को डाउनलोड या पता नहीं लगाया जा सका!'
        "ChangelogMainTitle" = 'PSBBN चेंजलॉग मुख्य अनुवादक [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] त्रुटि: CHANGELOG_PATCH_ENG.TXT को डाउनलोड या लोकेट नहीं किया जा सका!'
        "ChangelogPatchTitle" = 'PSBBN चेंजलॉग पैच ट्��ांसलेटर [By Emerson Teles]'
        "ChooseOption" = 'एक विकल्प चुनें:'
        "CompletionBanner" = '[OK] {0} का अनुवाद सफलतापूर्वक समाप्त - 100%'
        "DescLauncher" = 'सभी 40 भाषाओं के समर्थन के साथ विंडोज़ के लिए PSBBN लॉन्चर तैयार और अद्यतन करता है।'
        "DescMain" = 'मुख्य इंस्टॉलर रिलीज़ नोट्स और चेंजलॉग (changelog_main_eng.txt) का अनुवाद करता है।'
        "DescPatch" = 'पैच इतिहास, फिक्स और चैनल अपडेट नोट्स (changelog_patch_eng.txt) का अनुवाद करता है।'
        "DescReadme" = 'मार्कडाउन फ़ॉर्मेटिंग और लिंक को संरक्षित करने वाले आधिकारिक PSBBN README.md का अनुवाद करता है।'
        "DescScript" = 'के लिए सभी 458 UI स्ट्रिंग्स का अनुवाद करता है। Linux/WSL PSBBN इंस्टॉलर स्क्रिप्ट (eng.txt)।'
        "DescSystem" = 'सभी PS2 PSBBN सिस्टम फ़ाइलों (XML संवाद, गाइड, मेनू, NetFront/ATOK सहायता) का अनुवाद करता है।'
        "DestFile" = 'गंतव्य:'
        "DownloadingLatestGithub" = '[i] GitHub से नवीनतम आधिकारिक संस्करण डाउनलोड हो रहा है...'
        "DownloadingOfficial" = '[*] GitHub रिपॉजिटरी से आधिकारिक फ़ाइल डाउनलोड हो रही है...'
        "EnglishOption" = 'अंग्रेज़ी (डिफ़ॉल्ट)'
        "EngTxtEnsureFile" = 'कृपया सुनिश्चित करें कि ''eng.txt'' फ़ाइल ''इनपुट'' फ़ोल्डर में मौजूद है।'
        "EngTxtErrorTitle" = '[!] त्रुटि: ENG.TXT फ़ाइल नहीं मिली!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt नहीं मिला। आधिकारिक रिपॉजिटरी से डाउनलोड हो रहा है...'
        "EnsureConnected" = 'कृपया सुनिश्चित करें कि आप इंटरनेट से जुड़े हैं या फ़ाइल को इनपुट निर्देशिका में रखें।'
        "ExitOption" = 'बाहर निकलें'
        "ExpectedPath" = 'अपेक्षित पथ: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 अनुवाद पैक निकाला जा रहा है...'
        "FileNotFoundError" = '[त्रुटि] फ़ाइल नहीं मिली: {0}'
        "GeneratedFile" = '[ठीक] जेनरेट की गई फ़ाइल: {0}'
        "GenericEnsureInternetOrInput" = 'कृपया सुनिश्चित करें कि आप इंटरनेट से कनेक्ट हैं या फ़ाइल ''इनपुट'' फ़ोल्डर में है।'
        "IndividualBlocks" = 'व्यक्तिगत ब्लॉक: __0___'
        "IndividualBlocksNotice" = '[ठीक] कॉस्मिकस्केल के लिए अलग-अलग ब्लॉक: {0}'
        "InputFileDeleted" = '[ठीक] इनपुट फ़ोल्डर से फ़ाइलें हटा दी गईं।'
        "InputFileKept" = '[ठीक] फ़ाइलें इनपुट फ़ोल्डर में रखी गई हैं।'
        "InvalidOption" = 'अमान्य विकल्प! पुनः प्रयास करने के लिए Enter दबाएँ...'
        "LangAppliedSuccess" = '[OK] यूआई भाषा सफलतापूर्वक लागू की गई: {0} ({1})'
        "LauncherAutoDetect" = '[ओके] विंडोज सिस्टम लैंग्वेज ऑटो-डिटेक्शन सक्षम।'
        "LauncherBaseNotFoundTitle" = '[!] त्रुटि: बेस लॉन्चर स्क्रिप्ट को डाउनलोड या ढूंढा नहीं जा सका!'
        "LauncherIntegrated" = '[ठीक] विंडोज़ के लिए PSBBN लॉन्चर में {0} भाषा(भाषाओं) के लिए एकीकृत समर्थन!'
        "LauncherPrompt" = 'एक या अधिक भाषाएँ चुनें (जैसे 7 या 1, 2, 3 या 1-5 या ए):'
        "LauncherTip1" = '- केवल उस भाषा में फ़ाइल बनाने के लिए 1 नंबर दर्ज करें।'
        "LauncherTipAll" = '- सभी 40 भाषाओं के साथ पूरी फ़ाइल तैयार करने के लिए ''ए'' दर्ज करें।'
        "LauncherTipHeader" = '* युक्ति: प्रत्येक निष्पादन एक साफ़ फ़ाइल उत्पन्न करता है जिसमें केवल चुनी हुई भाषा(भाषाएँ) होती हैं।'
        "LauncherTipMulti" = '- उन भाषाओं के साथ उत्पन्न करने के लिए अल्पविराम से अलग किए गए कई नंबर दर्ज करें (जैसे 1, 2, 3)।'
        "LauncherTipRange" = '- भाषाओं की उस श्रेणी के साथ उत्पन्न करने के लिए एक श्रेणी (जैसे 1-5) दर्ज करें।'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[बी] पिछली स्क्रीन'
        "NavDeleteInput" = '[X] इनपुट फ़ोल्डर से फ़ाइल हटाएं'
        "NavEnter" = '[प्रवेश करें] मुख्य मेनू'
        "NavExit" = '[Esc] बाहर निकलें'
        "NavInstructions" = '[Enter] मुख्य मेनू |  [बी] पिछली स्क्रीन |  [Esc] बाहर निकलें'
        "NavKeepInput" = '[V] फ़ाइल को इनपुट फ़ोल्डर में रखें'
        "OfficialDownloadSuccess" = '[ठीक] आधिकारिक फ़ाइल सफलतापूर्वक डाउनलोड हो गई ({0:N0} बाइट्स)।'
        "PkgCompressingGz" = '[*] .NET GZipStream के माध्यम से ''bnupdate.tar.gz'' पर संपीड़ित किया जा रहा है...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' बनाना और POSIX निष्पादन अनुमतियाँ (+x) सेट करना...'
        "PkgErrorTar" = '[!] bnupdate.tar उत्पन्न नहीं कर सका।'
        "PkgGenTitle" = 'PSBBN इंस्टालेशन पैकेज जनरेशन (bnupdate.tar.gz)'
        "PkgNotice1" = '1. बनावट (.tm2 और .png) अंग्रेजी में रहती हैं (मैन्युअल ग्राफ़िक रीडिज़ाइन की आवश्यकता होती है)।'
        "PkgNotice2" = '2. 100% सिस्टम टेक्स्ट (XML, ATOK HTML और स्क्रिप्ट) का अनुवाद किया जाता है।'
        "PkgNotice3" = '3. ''bnupdate.tar.gz'' फ़ाइल PS2 (HDD/Telnet/USB) पर तत्काल परीक्षण के लिए है।'
        "PkgNoticeHeader" = '[तकनीकी सूचना]:'
        "PkgPromptTar" = 'क्या आप PS2 पर परीक्षण करने के लिए ''bnupdate.tar.gz'' फ़ाइल जनरेट करना चाहते हैं? (वाई/एन) [डिफ़ॉल्ट: वाई]'
        "PkgSuccess" = '[+] पैकेज सफलतापूर्वक उत्पन्न हुआ (लिनक्स 0755 अनुमतियाँ सक्षम): {0} ({1:एन0} बाइट्स)'
        "PosixPatchedCount" = '[+] POSIX 0755 निष्पादन अनुमति (+x) के साथ पैच की गई फ़ाइलें: {0}'
        "PressAnyKey" = 'मेनू पर लौटने के लिए कोई भी कुंजी दबाएँ...'
        "ProgressAtokHelp" = 'ATOK सहायता का अनुवाद'
        "ProgressUpdatingHtml" = 'HTML फ़ाइलें अद्यतन कर रहा है'
        "ProgressUpdatingXml" = 'XML फ़ाइलें अद्यतन कर रहा है'
        "ProgressXmlStrings" = 'XML स्ट्रिंग्स का अनुवाद'
        "PsbbnEnglishEnsure" = 'कृपया सुनिश्चित करें कि ''PSBBN_English'' फ़ोल्डर ''इनपुट'' के अंदर मौजूद है।'
        "PsbbnEnglishNotFoundTitle" = '[!] त्रुटि: आधार निर्देशिका PSBBN_अंग्रेजी नहीं मिली!'
        "ReadmeEnsure" = 'कृपया सुनिश्चित करें कि ''README.md'' फ़ाइल ''इनपुट'' फ़ोल्डर में है।'
        "ReadmeNotFoundDownloading" = '[*] README.md नहीं मिला। आधिकारिक रिपॉजिटरी से डाउनलोड हो रहा है...'
        "ReadmeNotFoundTitle" = '[!] त्रुटि: README.MD फ़ाइल नहीं मिली!'
        "ReadmeTitle" = 'PSBBN रीडमी ट्रांसलेटर [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN स्क्रिप्ट ट्रांसलेटर [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} भाषाएँ चयनित ({1})'
        "SelectUILangPrompt" = 'एक विकल्प चुनें'
        "SelectUITitle" = 'यूआई भाषा बदलें'
        "SessionStarted" = 'सत्र शुरू हुआ:'
        "SourceFile" = 'स्रोत:'
        "Step1Copying" = '[*] [1/3] संपूर्ण संरचना और बायनेरिज़ की प्रतिलिपि बनाना...'
        "Step2TranslatingXml" = '[*] [2/3] {0} सिस्टम XML फ़ाइलों का अनुवाद...'
        "Step3TranslatingAtok" = '[*] [3/3] {0} ATOK HTML सहायता फ़ाइलों का अनुवाद...'
        "SuiteTitle" = 'PSBBN बहुभाषी अनुवाद सूट - V1 [By Emerson Teles]'
        "SystemTitle" = 'सिस्टम PSBBN अनुवादक [By Emerson Teles]'
        "TextureDisclaimer" = 'सूचना: बनावट (.tm2 / .png) में एम्बेडेड ग्राफिक्स होते हैं और मैन्युअल   संपादन की आवश्यकता होती है; उन्हें स्क्रिप्ट द्वारा बदला नहीं जाता है।   सिस्टम टेक्स्ट फ़ाइलें (XML, HTML, txt) 100% अनुवादित हैं।'
        "Translating" = 'अनुवाद करना'
        "UsingFallback" = '[!] स्थानीय फ़ॉलबैक का उपयोग करना: {0}'
        "ValidatingXml" = '[*] 100% XML फ़ाइलों की वाक्यात्मक अखंडता को मान्य किया जा रहा है...'
        "XmlSyntaxError" = '[!] {0} में सिंटैक्स त्रुटि: {1}'
        "XmlValidationSuccess" = '[+] 100% XML फ़ाइलें सफलतापूर्वक मान्य की गईं (0 सिंटैक्स त्रुटियाँ)।'
    }
    "hr" = @{
        "All40Success" = 'Svih 40 jezika (potpuno višejezično)'
        "AllLanguages" = 'Prijevod svih jezika (1 - 40)'
        "BackMenu" = 'Natrag na glavni izbornik'
        "CancelOption" = 'Natrag'
        "CannotConnectGithub" = '[!] Ne mogu se spojiti na GitHub: {0}'
        "ChangeLanguage" = 'Promjena jezika korisničkog sučelja'
        "ChangelogMainNotFoundTitle" = '[!] POGREŠKA: NIJE MOGLO PREUZETI ILI LOCIRATI CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Glavni prevoditelj [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] POGREŠKA: NIJE MOGLO PREUZETI ILI LOCIRATI CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Odaberite opciju:'
        "CompletionBanner" = '[OK] Prijevod {0} uspješno završen - 100%'
        "DescLauncher" = 'Generira i ažurira PSBBN Launcher za Windows s podrškom za svih 40 jezika.'
        "DescMain" = 'Prevodi bilješke o izdanju glavnog programa za instalaciju i dnevnik promjena (changelog_main_eng.txt).'
        "DescPatch" = 'Prevodi povijest zakrpa, popravke i bilješke o ažuriranju kanala (changelog_patch_eng.txt).'
        "DescReadme" = 'Prevodi službeni PSBBN README.md čuvajući markdown formatiranje i veze.'
        "DescScript" = 'Prevodi svih 458 nizova korisničkog sučelja za Linux/WSL PSBBN instalacijsku skriptu (eng.txt).'
        "DescSystem" = 'Prevodi sve datoteke PS2 PSBBN sustava (XML dijalozi, vodiči, izbornici, NetFront/ATOK pomoć).'
        "DestFile" = 'Odredište:'
        "DownloadingLatestGithub" = '[i] Preuzimanje najnovije službene verzije s GitHuba...'
        "DownloadingOfficial" = '[*] Preuzimanje službene datoteke iz GitHub repozitorija...'
        "EnglishOption" = 'Engleski (zadano)'
        "EngTxtEnsureFile" = 'Provjerite nalazi li se datoteka ''eng.txt'' u mapi ''input''.'
        "EngTxtErrorTitle" = '[!] POGREŠKA: ENG.TXT DATOTEKA NIJE PRONAĐENA!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt nije pronađen. Preuzimanje sa službenog repozitorija...'
        "EnsureConnected" = 'Provjerite jeste li spojeni na internet ili stavite datoteku u ulazni direktorij.'
        "ExitOption" = 'Izlaz'
        "ExpectedPath" = 'Očekivani put: {0}'
        "ExtractingPack" = '[*] Izdvajanje paketa prijevoda PSBBN v3.5...'
        "FileNotFoundError" = '[GREŠKA] Datoteka nije pronađena: {0}'
        "GeneratedFile" = '[OK] Generirana datoteka: {0}'
        "GenericEnsureInternetOrInput" = 'Provjerite jeste li spojeni na internet ili imate datoteku u mapi "ulaz".'
        "IndividualBlocks" = 'Pojedinačni blokovi: {0}'
        "IndividualBlocksNotice" = '[OK] Pojedinačni blokovi za CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Datoteke su izbrisane iz ulazne mape.'
        "InputFileKept" = '[OK] Datoteke koje se čuvaju u ulaznoj mapi.'
        "InvalidOption" = 'Nevažeće opcija! Pritisnite Enter za ponovni pokušaj...'
        "LangAppliedSuccess" = '[OK] Jezik sučelja uspješno je primijenjen: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Automatsko otkrivanje jezika sustava Windows omogućeno.'
        "LauncherBaseNotFoundTitle" = '[!] POGREŠKA: NIJE MOGUĆE PREUZETI ILI LOCIRATI SKRIPTU POKRETANJA BASE!'
        "LauncherIntegrated" = '[OK] Integrirana podrška za {0} jezik(a) u PSBBN Launcher za Windows!'
        "LauncherPrompt" = 'Odaberite jedan ili više jezika (npr. 7 ili 1, 2, 3 ili 1-5 ili A):'
        "LauncherTip1" = '- Unesite 1 broj za generiranje datoteke samo s tim jezikom.'
        "LauncherTipAll" = '- Unesite ''A'' za generiranje cijele datoteke sa svih 40 jezika.'
        "LauncherTipHeader" = '* Savjet: Svako izvođenje generira čistu datoteku koja sadrži samo odabrani jezik(e).'
        "LauncherTipMulti" = '- Unesite više brojeva odvojenih zarezom (npr. 1, 2, 3) za generiranje s tim jezicima.'
        "LauncherTipRange" = '- Unesite raspon (npr. 1-5) za generiranje s tim rasponom jezika.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Prethodni ekran'
        "NavDeleteInput" = '[X] Brisanje datoteke iz ulazne mape'
        "NavEnter" = '[Enter] Glavni izbornik'
        "NavExit" = '[Esc] Izlaz'
        "NavInstructions" = '[Enter] Glavni izbornik |  [B] Prethodni zaslon |  [Esc] Izlaz'
        "NavKeepInput" = '[V] Zadrži datoteku u ulaznoj mapi'
        "OfficialDownloadSuccess" = '[OK] Službena datoteka uspješno preuzeta ({0:N0} bajtova).'
        "PkgCompressingGz" = '[*] Sažimanje u ''bnupdate.tar.gz'' putem .NET GZipStream...'
        "PkgCreatingTar" = '[*] Stvaranje ''bnupdate.tar'' i postavljanje dozvola za izvršavanje POSIX-a (+x)...'
        "PkgErrorTar" = '[!] Nije moguće generirati bnupdate.tar.'
        "PkgGenTitle" = 'GENERACIJA PSBBN INSTALACIJSKOG PAKETA (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Teksture (.tm2 i .png) ostaju na engleskom (zahtijeva ručni grafički redizajn).'
        "PkgNotice2" = '2. 100% tekstova sustava (XML, ATOK HTML i skripte) je prevedeno.'
        "PkgNotice3" = '3. Datoteka ''bnupdate.tar.gz'' namijenjena je trenutnom testiranju na PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TEHNIČKA OBAVIJEST]:'
        "PkgPromptTar" = 'Želite li generirati datoteku ''bnupdate.tar.gz'' za testiranje na PS2? (Y/N) [Default: Y]'
        "PkgSuccess" = '[+] Paket je uspješno generiran (omogućene su dozvole za Linux 0755): {0} ({1:N0} bajtova)'
        "PosixPatchedCount" = '[+] Datoteke zakrpane dozvolom za izvođenje POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Pritisnite bilo koju tipku za povratak na izbornik...'
        "ProgressAtokHelp" = 'Prevođenje ATOK Pomoć'
        "ProgressUpdatingHtml" = 'Ažuriranje HTML datoteka'
        "ProgressUpdatingXml" = 'Ažuriranje XML datoteka'
        "ProgressXmlStrings" = 'Prevođenje XML nizova'
        "PsbbnEnglishEnsure" = 'Provjerite nalazi li se mapa ''PSBBN_English'' unutar ''unosa''.'
        "PsbbnEnglishNotFoundTitle" = '[!] POGREŠKA: OSNOVNI IMENIK PSBBN_ENGLISH NIJE PRONAĐEN!'
        "ReadmeEnsure" = 'Provjerite nalazi li se datoteka ''README.md'' u mapi ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md nije pronađen. Preuzimanje sa službenog repozitorija...'
        "ReadmeNotFoundTitle" = '[!] POGREŠKA: README.MD DATOTEKA NIJE PRONAĐENA!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} odabranih jezika ({1})'
        "SelectUILangPrompt" = 'Odaberite opciju'
        "SelectUITitle" = 'PROMJENA JEZIKA KORISNIČKOG SUČELJA'
        "SessionStarted" = 'Sesija je započela:'
        "SourceFile" = 'Izvor:'
        "Step1Copying" = '[*] [1/3] Kopiranje kompletne strukture i binarnih datoteka...'
        "Step2TranslatingXml" = '[*] [2/3] Prevođenje {0} sistemskih XML datoteka...'
        "Step3TranslatingAtok" = '[*] [3/3] Prijevod {0} ATOK HTML datoteka pomoći...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'Prevoditelj sustava PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Obavijest: Teksture (.tm2 / .png) sadrže ugrađenu grafiku i   zahtijevaju ručno uređivanje; skripta ih ne mijenja. Sistemske   tekstualne datoteke (XML, HTML, txt) su 100% prevedene.'
        "Translating" = 'Prijevod'
        "UsingFallback" = '[!] Korištenje lokalne zamjene: {0}'
        "ValidatingXml" = '[*] Provjera sintaktičkog integriteta 100% XML datoteka...'
        "XmlSyntaxError" = '[!] Sintaktička pogreška u {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% XML datoteka je uspješno potvrđeno (0 grešaka u sintaksi).'
    }
    "hu" = @{
        "All40Success" = 'Mind a 40 nyelv (teljes többnyelvű)'
        "AllLanguages" = 'Minden nyelv fordítása (1-40)'
        "BackMenu" = 'Vissza a főmenübe'
        "CancelOption" = 'Vissza'
        "CannotConnectGithub" = '[!] Nem lehet csatlakozni a GitHubhoz: {0}'
        "ChangeLanguage" = 'A felhasználói felület nyelvének módosítása'
        "ChangelogMainNotFoundTitle" = '[!] HIBA: NEM LEHET LETÖLTENI VAGY KERESNI A CHANGELOG_MAIN_ENG.TXT fájlt!'
        "ChangelogMainTitle" = 'PSBBN Changelog fő fordító [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] HIBA: NEM LEHET LETÖLTENI VAGY MEGTALÁLNI A CHANGELOG_PATCH_ENG.TXT fájlt!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Válasszon egy lehetőséget:'
        "CompletionBanner" = '[OK] A(z) {0} fordítása sikeresen befejeződött – 100%'
        "DescLauncher" = 'Létrehozza és frissíti a PSBBN Launcher for Windows programot mind a 40 nyelv támogatásával.'
        "DescMain" = 'Lefordítja a fő telepítő kiadási megjegyzéseit és a változásnaplót (changelog_main_eng.txt).'
        "DescPatch" = 'Lefordítja a javítások előzményeit, a javításokat és a csatornafrissítési megjegyzéseket (changelog_patch_eng.txt).'
        "DescReadme" = 'Lefordítja a hivatalos PSBBN README.md fájlt, megőrzi a markdown formázást és a hivatkozásokat.'
        "DescScript" = 'Lefordítja mind a 458 UI karakterláncot a Linux/WSL PSBBN telepítőszkripthez (eng.txt).'
        "DescSystem" = 'Lefordítja az összes PS2 PSBBN rendszerfájlt (XML párbeszédpanelek, útmutatók, menük, NetFront/ATOK súgó).'
        "DestFile" = 'Rendeltetési hely:'
        "DownloadingLatestGithub" = '[i] A legújabb hivatalos verzió letöltése a GitHubról...'
        "DownloadingOfficial" = '[*] Hivatalos fájl letöltése a GitHub adattárból...'
        "EnglishOption" = 'Angol (alapértelmezett)'
        "EngTxtEnsureFile" = 'Győződjön meg arról, hogy az „eng.txt” fájl megtalálható az „input” mappában.'
        "EngTxtErrorTitle" = '[!] HIBA: ENG.TXT FÁJL NEM TALÁLHATÓ!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt nem található. Letöltés a hivatalos adattárból...'
        "EnsureConnected" = 'Győződjön meg arról, hogy csatlakozik az internethez, vagy helyezze el a fájlt a bemeneti könyvtárba.'
        "ExitOption" = 'Kijárat'
        "ExpectedPath" = 'Várt elérési út: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 fordítócsomag kibontása...'
        "FileNotFoundError" = '[HIBA] A fájl nem található: {0}'
        "GeneratedFile" = '[OK] Létrehozott fájl: {0}'
        "GenericEnsureInternetOrInput" = 'Győződjön meg arról, hogy csatlakozik az internethez, vagy hogy a fájl az „input” mappában van.'
        "IndividualBlocks" = 'Egyedi blokkok: {0}'
        "IndividualBlocksNotice" = '[OK] Egyedi blokkok a CosmicScale számára: {0}'
        "InputFileDeleted" = '[OK] Fájl(ok) törölve a bemeneti mappából.'
        "InputFileKept" = '[OK] A bemeneti mappában tárolt fájlok.'
        "InvalidOption" = 'Érvénytelen opció! Nyomja meg az Entert az újbóli próbálkozáshoz...'
        "LangAppliedSuccess" = '[OK] A felület nyelve sikeresen alkalmazva: {0} ({1})'
        "LauncherAutoDetect" = '[OK] A Windows rendszernyelv automatikus felismerése engedélyezve.'
        "LauncherBaseNotFoundTitle" = '[!] HIBA: NEM LEHET LETÖLTENI VAGY TALÁLNI AZ ALAP INDÍTÓ SZkriptjét!'
        "LauncherIntegrated" = '[OK] A PSBBN Launcher for Windows integrált támogatása {0} nyelvhez!'
        "LauncherPrompt" = 'Válasszon egy vagy több nyelvet (pl. 7 vagy 1, 2, 3 vagy 1-5 vagy A):'
        "LauncherTip1" = '- Adjon meg 1 számot a fájl létrehozásához csak az adott nyelven.'
        "LauncherTipAll" = '- Írja be az \''A\'' betűt a teljes fájl létrehozásához mind a 40 nyelven.'
        "LauncherTipHeader" = '* Tipp: Minden végrehajtás egy tiszta fájlt hoz létre, amely csak a kiválasztott nyelv(eke)t tartalmazza.'
        "LauncherTipMulti" = '- Írjon be több számot vesszővel elválasztva (pl. 1, 2, 3), hogy létrehozza ezeket a nyelveket.'
        "LauncherTipRange" = '- Adjon meg egy tartományt (pl. 1-5), amelyet az adott nyelvi tartományban szeretne létrehozni.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Előző képernyő'
        "NavDeleteInput" = '[X] Fájl törlése a bemeneti mappából'
        "NavEnter" = '[Enter] Főmenü'
        "NavExit" = '[Esc] Kilépés'
        "NavInstructions" = '[Enter] Főmenü |  [B] Előző képernyő |  [Esc] Kilépés'
        "NavKeepInput" = '[V] Tartsa a fájlt a bemeneti mappában'
        "OfficialDownloadSuccess" = '[OK] A hivatalos fájl letöltése sikeres volt ({0:N0} bájt).'
        "PkgCompressingGz" = '[*] Tömörítés a „bnupdate.tar.gz” fájlba a .NET GZipStreamen keresztül...'
        "PkgCreatingTar" = '[*] A „bnupdate.tar” létrehozása és a POSIX végrehajtási engedélyek beállítása (+x)...'
        "PkgErrorTar" = '[!] Nem sikerült létrehozni a bnupdate.tar fájlt.'
        "PkgGenTitle" = 'PSBBN TELEPÍTÉSI CSOMAG LÉTREHOZÁSA (bnupdate.tar.gz)'
        "PkgNotice1" = '1. A textúrák (.tm2 és .png) angol maradnak (kézi grafikai újratervezés szükséges).'
        "PkgNotice2" = '2. A rendszerszövegek (XML, ATOK HTML és szkriptek) 100%-a le van fordítva.'
        "PkgNotice3" = '3. A „bnupdate.tar.gz” fájl azonnali tesztelésre szolgál PS2-n (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TECHNIKAI KÖZLEMÉNY]:'
        "PkgPromptTar" = 'Szeretné létrehozni a „bnupdate.tar.gz” fájlt, hogy tesztelje a PS2-n? (I/N) [Alapértelmezett: I]'
        "PkgSuccess" = '[+] A csomag sikeresen generálva (Linux 0755 engedélyek engedélyezve): {0} ({1:N0} bájt)'
        "PosixPatchedCount" = '[+] POSIX 0755 végrehajtási engedéllyel javított fájlok (+x): {0}'
        "PressAnyKey" = 'Nyomja meg bármelyik gombot a menübe való visszatéréshez...'
        "ProgressAtokHelp" = 'ATOK Súgó fordítása'
        "ProgressUpdatingHtml" = 'HTML-fájlok frissítése'
        "ProgressUpdatingXml" = 'XML-fájlok frissítése'
        "ProgressXmlStrings" = 'XML-karakterláncok fordítása'
        "PsbbnEnglishEnsure" = 'Győződjön meg arról, hogy a ''PSBBN_English'' mappa megtalálható az ''input'' részben.'
        "PsbbnEnglishNotFoundTitle" = '[!] HIBA: AZ ALAPKÖNYVTÁR PSBBN_ENGLISH NEM TALÁLHATÓ!'
        "ReadmeEnsure" = 'Győződjön meg arról, hogy a „README.md” fájl az „input” mappában van.'
        "ReadmeNotFoundDownloading" = '[*] README.md nem található. Letöltés a hivatalos adattárból...'
        "ReadmeNotFoundTitle" = '[!] HIBA: README.MD FÁJL NEM TALÁLHATÓ!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} kiválasztott nyelv ({1})'
        "SelectUILangPrompt" = 'Válasszon egy lehetőséget'
        "SelectUITitle" = 'A FELHASZNÁLÓI FELÜLET NYELVÉNEK MÓDOSÍTÁSA'
        "SessionStarted" = 'Az ülés kezdete:'
        "SourceFile" = 'Forrás:'
        "Step1Copying" = '[*] [1/3] Teljes szerkezet és binárisok másolása...'
        "Step2TranslatingXml" = '[*] [2/3] {0} rendszer XML-fájlok fordítása...'
        "Step3TranslatingAtok" = '[*] [3/3] {0} ATOK HTML súgófájlok fordítása...'
        "SuiteTitle" = 'PSBBN többnyelvű fordítócsomag – V1 [By Emerson Teles]'
        "SystemTitle" = 'Rendszer PSBBN fordító [By Emerson Teles]'
        "TextureDisclaimer" = 'Megjegyzés: A textúrák (.tm2 / .png) beágyazott grafikát tartalmaznak,   és kézi szerkesztést igényelnek; ezeket nem változtatja meg a   forgatókönyv. A rendszer szöveges fájlok (XML, HTML, txt) 100%-ban le   vannak fordítva.'
        "Translating" = 'Fordítás'
        "UsingFallback" = '[!] Helyi tartalék használata: {0}'
        "ValidatingXml" = '[*] Az XML-fájlok 100%-ának szintaktikai integritásának ellenőrzése...'
        "XmlSyntaxError" = '[!] Szintaktikai hiba itt: {0}: {1}'
        "XmlValidationSuccess" = '[+] Az XML-fájlok 100%-a sikeresen érvényesítve (0 szintaktikai hiba).'
    }
    "id" = @{
        "All40Success" = 'Semua 40 Bahasa (Multibahasa Penuh)'
        "AllLanguages" = 'Terjemahkan Semua Bahasa (1 - 40)'
        "BackMenu" = 'Kembali ke Menu Utama'
        "CancelOption" = 'Kembali'
        "CannotConnectGithub" = '[!] Tidak dapat terhubung ke GitHub: {0}'
        "ChangeLanguage" = 'Ubah Bahasa UI'
        "ChangelogMainNotFoundTitle" = '[!] KESALAHAN: TIDAK BISA MENGUNDUH ATAU MENEMUKAN CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] KESALAHAN: TIDAK BISA MENGUNDUH ATAU MENEMUKAN CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Pilih salah satu opsi:'
        "CompletionBanner" = '[OK] Terjemahan {0} berhasil diselesaikan - 100%'
        "DescLauncher" = 'Menghasilkan dan memperbarui Peluncur PSBBN untuk Windows dengan dukungan untuk 40 bahasa.'
        "DescMain" = 'Menerjemahkan catatan rilis penginstal utama dan log perubahan (changelog_main_eng.txt).'
        "DescPatch" = 'Menerjemahkan riwayat patch, perbaikan, dan catatan pembaruan saluran (changelog_patch_eng.txt).'
        "DescReadme" = 'Menerjemahkan README.md PSBBN resmi yang mempertahankan format dan tautan penurunan harga.'
        "DescScript" = 'Menerjemahkan seluruh 458 string UI untuk skrip penginstal PSBBN Linux/WSL (eng.txt).'
        "DescSystem" = 'Menerjemahkan semua file sistem PS2 PSBBN (dialog XML, panduan, menu, bantuan NetFront/ATOK).'
        "DestFile" = 'Tujuan:'
        "DownloadingLatestGithub" = '[i] Mengunduh versi resmi terbaru dari GitHub...'
        "DownloadingOfficial" = '[*] Mengunduh file resmi dari repositori GitHub...'
        "EnglishOption" = 'Inggris (default)'
        "EngTxtEnsureFile" = 'Harap pastikan bahwa file ''eng.txt'' ada di folder ''input''.'
        "EngTxtErrorTitle" = '[!] KESALAHAN: FILE ENG.TXT TIDAK DITEMUKAN!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt tidak ditemukan. Mengunduh dari repositori resmi...'
        "EnsureConnected" = 'Pastikan Anda terhubung ke Internet atau letakkan file di direktori input.'
        "ExitOption" = 'Keluar'
        "ExpectedPath" = 'Jalur yang diharapkan: {0}'
        "ExtractingPack" = '[*] Mengekstrak paket terjemahan PSBBN v3.5...'
        "FileNotFoundError" = '[ERROR] File tidak ditemukan: {0}'
        "GeneratedFile" = '[OK] File yang dihasilkan: {0}'
        "GenericEnsureInternetOrInput" = 'Pastikan Anda terhubung ke Internet atau memiliki file di folder ''input''.'
        "IndividualBlocks" = 'Blok Individu: __0___'
        "IndividualBlocksNotice" = '[OK] Blok individual untuk CosmicScale: {0}'
        "InputFileDeleted" = '[OK] File dihapus dari folder input.'
        "InputFileKept" = '[OK] File disimpan di folder input.'
        "InvalidOption" = 'Opsi tidak valid! Tekan Enter untuk mencoba lagi...'
        "LangAppliedSuccess" = '[OK] Bahasa antarmuka berhasil diterapkan: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Deteksi otomatis bahasa sistem Windows diaktifkan.'
        "LauncherBaseNotFoundTitle" = '[!] KESALAHAN: TIDAK BISA MENGUNDUH ATAU MENEMUKAN SKRIP PELUNCUR DASAR!'
        "LauncherIntegrated" = '[OK] Dukungan terintegrasi untuk {0} bahasa ke dalam Peluncur PSBBN untuk Windows!'
        "LauncherPrompt" = 'Pilih satu atau lebih bahasa (misalnya 7 atau 1, 2, 3 atau 1-5 atau A):'
        "LauncherTip1" = '- Masukkan 1 nomor untuk menghasilkan file hanya dengan bahasa itu.'
        "LauncherTipAll" = '- Masukkan ''A'' untuk menghasilkan file lengkap dengan 40 bahasa.'
        "LauncherTipHeader" = '* Tip: Setiap eksekusi menghasilkan file bersih yang hanya berisi bahasa yang dipilih.'
        "LauncherTipMulti" = '- Masukkan beberapa angka yang dipisahkan dengan koma (misalnya 1, 2, 3) untuk menghasilkan dengan bahasa tersebut.'
        "LauncherTipRange" = '- Masukkan rentang (misalnya 1-5) untuk menghasilkan rentang bahasa tersebut.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Layar Sebelumnya'
        "NavDeleteInput" = '[X] Hapus file dari folder masukan'
        "NavEnter" = '[Masuk] Menu Utama'
        "NavExit" = '[Esc] Keluar'
        "NavInstructions" = '[Enter] Menu Utama |  [B] Layar Sebelumnya |  [Esc] Keluar'
        "NavKeepInput" = '[V] Simpan file di folder masukan'
        "OfficialDownloadSuccess" = '[OK] File resmi berhasil diunduh ({0:N0} bytes).'
        "PkgCompressingGz" = '[*] Mengompresi ke ''bnupdate.tar.gz'' melalui .NET GZipStream...'
        "PkgCreatingTar" = '[*] Membuat ''bnupdate.tar'' dan mengatur izin eksekusi POSIX (+x)...'
        "PkgErrorTar" = '[!] Tidak dapat menghasilkan bnupdate.tar.'
        "PkgGenTitle" = 'PEMBUATAN PAKET INSTALASI PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Tekstur (.tm2 dan .png) tetap dalam bahasa Inggris (memerlukan desain ulang grafis manual).'
        "PkgNotice2" = '2. 100% teks sistem (XML, ATOK HTML, dan skrip) diterjemahkan.'
        "PkgNotice3" = '3. File ''bnupdate.tar.gz'' dimaksudkan untuk pengujian langsung di PS2 (HDD/Telnet/USB).'
        "PkgNoticeHeader" = '[PEMBERITAHUAN TEKNIS]:'
        "PkgPromptTar" = 'Apakah Anda ingin membuat file ''bnupdate.tar.gz'' untuk diuji di PS2? (Y/T) [Bawaan: Y]'
        "PkgSuccess" = '[+] Paket berhasil dibuat (izin Linux 0755 diaktifkan): {0} ({1:N0} bytes)'
        "PosixPatchedCount" = '[+] File yang ditambal dengan izin eksekusi POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Tekan tombol apa saja untuk kembali ke menu...'
        "ProgressAtokHelp" = 'Menerjemahkan Bantuan ATOK'
        "ProgressUpdatingHtml" = 'Memperbarui file HTML'
        "ProgressUpdatingXml" = 'Memperbarui file XML'
        "ProgressXmlStrings" = 'Menerjemahkan string XML'
        "PsbbnEnglishEnsure" = 'Harap pastikan bahwa folder ''PSBBN_English'' ada di dalam ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] KESALAHAN: DIREKTORI DASAR PSBBN_ENGLISH TIDAK DITEMUKAN!'
        "ReadmeEnsure" = 'Harap pastikan bahwa file ''README.md'' ada di folder ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md tidak ditemukan. Mengunduh dari repositori resmi...'
        "ReadmeNotFoundTitle" = '[!] KESALAHAN: FILE README.MD TIDAK DITEMUKAN!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '__0___ bahasa dipilih ({1})'
        "SelectUILangPrompt" = 'Pilih salah satu opsi'
        "SelectUITitle" = 'UBAH BAHASA UI'
        "SessionStarted" = 'Sesi dimulai pada:'
        "SourceFile" = 'Sumber:'
        "Step1Copying" = '[*] [1/3] Menyalin struktur dan biner lengkap...'
        "Step2TranslatingXml" = '[*] [2/3] Menerjemahkan {0} file XML sistem...'
        "Step3TranslatingAtok" = '[*] [3/3] Menerjemahkan {0} file bantuan ATOK HTML...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'Sistem PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Pemberitahuan: Tekstur (.tm2 / .png) berisi grafik tertanam dan   memerlukan pengeditan manual; tidak diubah oleh skrip. File teks   sistem (XML, HTML, txt) 100% diterjemahkan.'
        "Translating" = 'Menerjemahkan'
        "UsingFallback" = '[!] Menggunakan fallback lokal: {0}'
        "ValidatingXml" = '[*] Memvalidasi integritas sintaksis 100% file XML...'
        "XmlSyntaxError" = '[!] Kesalahan sintaksis di {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% file XML berhasil divalidasi (0 kesalahan sintaksis).'
    }
    "it" = @{
        "All40Success" = 'Tutte le 40 lingue (multilingue completo)'
        "AllLanguages" = 'Traduci Tutte le Lingue (1 - 40)'
        "BackMenu" = 'Torna al Menu Principale'
        "CancelOption" = 'Indietro'
        "CannotConnectGithub" = '[!] Impossibile connettersi a GitHub: {0}'
        "ChangeLanguage" = 'Cambia lingua dell''interfaccia'
        "ChangelogMainNotFoundTitle" = '[!] ERRORE: IMPOSSIBILE SCARICARE O TROVARE CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Traduttore PSBBN Changelog Main [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ERRORE: IMPOSSIBILE SCARICARE O TROVARE CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Traduttore PSBBN Changelog Patch [By Emerson Teles]'
        "ChooseOption" = 'Seleziona un''opzione:'
        "CompletionBanner" = '[OK] Traduzione di {0} completata con successo - 100%'
        "DescLauncher" = 'Genera e aggiorna PSBBN Launcher for Windows con supporto per tutte le 40 lingue.'
        "DescMain" = 'Traduce il changelog principale dell''installer (changelog_main_eng.txt).'
        "DescPatch" = 'Traduce la cronologia delle patch e note di aggiornamento (changelog_patch_eng.txt).'
        "DescReadme" = 'Traduce il file README.md ufficiale preservando formattazione e link.'
        "DescScript" = 'Traduce le 458 stringhe di interfaccia dello script (eng.txt).'
        "DescSystem" = 'Traduce tutti i file di sistema PSBBN (dialoghi XML, guide, menu, aiuto ATOK).'
        "DestFile" = 'Destinazione:'
        "DownloadingLatestGithub" = '[i] Download dell''ultima versione ufficiale da GitHub...'
        "DownloadingOfficial" = '[*] Download del file ufficiale dal repository GitHub...'
        "EnglishOption" = 'Inglese (predefinito)'
        "EngTxtEnsureFile" = 'Assicurati che il file ''eng.txt'' sia presente nella cartella ''input''.'
        "EngTxtErrorTitle" = '[!] ERRORE: FILE ENG.TXT NON TROVATO!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt non trovato. Download dal repository ufficiale...'
        "EnsureConnected" = 'Assicurati di essere connesso a Internet o posiziona il file nella cartella input.'
        "ExitOption" = 'Esci'
        "ExpectedPath" = 'Percorso previsto: {0}'
        "ExtractingPack" = '[*] Estrazione del pacchetto di traduzione PSBBN v3.5...'
        "FileNotFoundError" = '[ERRORE] File non trovato: {0}'
        "GeneratedFile" = '[OK] File generato: {0}'
        "GenericEnsureInternetOrInput" = 'Assicurati di essere connesso a Internet o di avere il file nella cartella ''input''.'
        "IndividualBlocks" = 'Blocchi individuali: {0}'
        "IndividualBlocksNotice" = '[OK] Blocchi individuali per CosmicScale: {0}'
        "InputFileDeleted" = '[OK] File eliminati dalla cartella di input.'
        "InputFileKept" = '[OK] File mantenuti nella cartella di input.'
        "InvalidOption" = 'Opzione non valida! Premi Invio...'
        "LangAppliedSuccess" = '[OK] Lingua applicata all''interfaccia con successo: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Rilevamento automatico della lingua del sistema Windows abilitato.'
        "LauncherBaseNotFoundTitle" = '[!] ERRORE: IMPOSSIBILE SCARICARE O TROVARE LO SCRIPT DI BASE DEL LAUNCHER!'
        "LauncherIntegrated" = '[OK] Supporto integrato per {0} lingua/e in PSBBN Launcher for Windows!'
        "LauncherPrompt" = 'Scegli una o più lingue (es: 7 o 1, 2, 3 o 1-5 o A)'
        "LauncherTip1" = '- Inserisci 1 numero per generare il file solo con quella lingua.'
        "LauncherTipAll" = '- Inserisci ''A'' per generare il file completo con tutte le 40 lingue.'
        "LauncherTipHeader" = '* Suggerimento: Ogni esecuzione genera un file pulito contenente solo le lingue scelte.'
        "LauncherTipMulti" = '- Inserisci più numeri separati da virgola (es: 1, 2, 3) per generare con quelle lingue.'
        "LauncherTipRange" = '- Inserisci un intervallo (es: 1-5) per generare con quell''intervallo di lingue.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Schermata precedente'
        "NavDeleteInput" = '[X] Elimina il file dalla cartella di input'
        "NavEnter" = '[Invio] Menu principale'
        "NavExit" = '[Esc] Esci'
        "NavInstructions" = '[Enter] Menu Principale  |  [B] Schermata Precedente  |  [Esc] Esci'
        "NavKeepInput" = '[V] Conserva il file nella cartella di input'
        "OfficialDownloadSuccess" = '[OK] File ufficiale scaricato con successo ({0:N0} byte).'
        "PkgCompressingGz" = '[*] Compressione in ''bnupdate.tar.gz'' tramite .NET GZipStream...'
        "PkgCreatingTar" = '[*] Creazione di ''bnupdate.tar'' e impostazione dei permessi di esecuzione POSIX (+x)...'
        "PkgErrorTar" = '[!] Impossibile generare bnupdate.tar.'
        "PkgGenTitle" = 'GENERAZIONE DEL PACCHETTO DI INSTALLAZIONE PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Le texture (.tm2 e .png) rimangono in inglese (richiedono riprogettazione grafica manuale).'
        "PkgNotice2" = '2. Il 100% dei testi di sistema (XML, HTML ATOK e script) è tradotto.'
        "PkgNotice3" = '3. Il file ''bnupdate.tar.gz'' è destinato a test immediati su PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[AVVISO TECNICO]:'
        "PkgPromptTar" = 'Vuoi generare il file ''bnupdate.tar.gz'' per testare su PS2? (S/N) [Predefinito: S]'
        "PkgSuccess" = '[+] Pacchetto generato con successo (permessi Linux 0755 abilitati): {0} ({1:N0} byte)'
        "PosixPatchedCount" = '[+] File aggiornati con permesso di esecuzione POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Premi un tasto qualsiasi per tornare al menu...'
        "ProgressAtokHelp" = 'Traduzione guida ATOK'
        "ProgressUpdatingHtml" = 'Aggiornamento file HTML'
        "ProgressUpdatingXml" = 'Aggiornamento file XML'
        "ProgressXmlStrings" = 'Traduzione stringhe XML'
        "PsbbnEnglishEnsure" = 'Assicurati che la cartella ''PSBBN_English'' sia presente all''interno di ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] ERRORE: DIRECTORY DI BASE PSBBN_ENGLISH NON TROVATA!'
        "ReadmeEnsure" = 'Assicurati che il file ''README.md'' sia presente nella cartella ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md non trovato. Download dal repository ufficiale...'
        "ReadmeNotFoundTitle" = '[!] ERRORE: FILE README.MD NON TROVATO!'
        "ReadmeTitle" = 'Traduttore PSBBN Readme [By Emerson Teles]'
        "ScriptTitle" = 'Traduttore PSBBN Script [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} lingue selezionate ({1})'
        "SelectUILangPrompt" = 'Scegli la lingua dell''interfaccia'
        "SelectUITitle" = 'SELEZIONA LINGUA DELL''INTERFACCIA'
        "SessionStarted" = 'Sessione avviata il:'
        "SourceFile" = 'Sorgente:'
        "Step1Copying" = '[*] [1/3] Copia della struttura completa e dei binari...'
        "Step2TranslatingXml" = '[*] [2/3] Traduzione di {0} file XML di sistema...'
        "Step3TranslatingAtok" = '[*] [3/3] Traduzione di {0} file HTML di guida ATOK...'
        "SuiteTitle" = 'Suite Multilingue di Traduzione PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'Traduttore System PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Avviso: Le texture (.tm2 / .png) richiedono modifiche grafiche manuali. La suite traduce al 100% i testi di sistema (XML, HTML, menu e script).'
        "Translating" = 'Traduzione in corso'
        "UsingFallback" = '[!] Utilizzo del fallback locale: {0}'
        "ValidatingXml" = '[*] Convalida dell''integrità sintattica del 100% dei file XML...'
        "XmlSyntaxError" = '[!] Errore sintattico in {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% dei file XML convalidati con successo (0 errori di sintassi).'
    }
    "iw" = @{
        "All40Success" = 'כל 40 השפות (רב-לשוניות מלאה)'
        "AllLanguages" = 'תרגם את כל השפות (1 - 40)'
        "BackMenu" = 'חזרה לתפריט הראשי'
        "CancelOption" = 'חזרה'
        "CannotConnectGithub" = '[!] לא ניתן להתחבר ל-GitHub: {0}'
        "ChangeLanguage" = 'שנה שפת ממשק משתמש'
        "ChangelogMainNotFoundTitle" = '[!] שגיאה: לא ניתן היה להוריד או לאתר את CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'מתרגם יומן שינויים ראשי PSBBN [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] שגיאה: לא ניתן היה להוריד או לאתר את CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'מתרגם יומן שינויי טלאי PSBBN [By Emerson Teles]'
        "ChooseOption" = 'בחר אפשרות:'
        "CompletionBanner" = '[OK] תרגום של {0} הושלם בהצלחה - 100%'
        "DescLauncher" = 'מוסיף תמיכה וזיהוי אוטומטי של עד 40 שפות ב-PSBBN Launcher for Windows.'
        "DescMain" = 'מתרגם את הערות השחרור הראשיות של תוכנית ההתקנה ויומן השינויים (changelog_main_eng.txt).'
        "DescPatch" = 'מתרגם את היסטוריית הטלאים, תיקונים והערות עדכון ערוצים (changelog_patch_eng.txt).'
        "DescReadme" = 'מתרגם את קובץ ה-README.md הרשמי תוך שמירה על עיצוב markdown וקישורים.'
        "DescScript" = 'מתרגם את כל 458 מחרוזות ממשק המשתמש עבור סקריפט ההתקנה של Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'מתרגם את כל קובצי מערכת PS2 PSBBN (תיבות דו-שיח של XML, מדריכים, תפריטים, עזרה של NetFront/ATOK).'
        "DestFile" = 'יעד:'
        "DownloadingLatestGithub" = '[i] מוריד את הגרסה הרשמית האחרונה מ-GitHub...'
        "DownloadingOfficial" = '[*] מוריד קובץ רשמי ממאגר GitHub...'
        "EnglishOption" = 'אנגלית (ברירת מחדל)'
        "EngTxtEnsureFile" = 'אנא ודא שקובץ ''eng.txt'' קיים בתיקיית ''קלט''.'
        "EngTxtErrorTitle" = '[!] שגיאה: קובץ ENG.TXT לא נמצא!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt לא נמצא. מוריד מהמאגר הרשמי...'
        "EnsureConnected" = 'אנא ודא שאתה מחובר לאינטרנט או מקם את הקובץ בספריית הקלט.'
        "ExitOption" = 'יציאה'
        "ExpectedPath" = 'נתיב צפוי: {0}'
        "ExtractingPack" = '[*] מחלץ חבילת תרגום PSBBN v3.5...'
        "FileNotFoundError" = '[שגיאה] הקובץ לא נמצא: {0}'
        "GeneratedFile" = '[אישור] קובץ שנוצר: {0}'
        "GenericEnsureInternetOrInput" = 'אנא ודא שאתה מחובר לאינטרנט או שהקובץ נמצא בתיקיית ''קלט''.'
        "IndividualBlocks" = 'בלוקים בודדים: {0}'
        "IndividualBlocksNotice" = '[אישור] בלוקים בודדים עבור CosmicScale: {0}'
        "InputFileDeleted" = '[אישור] קבצים נמחקו מתיקיית הקלט.'
        "InputFileKept" = '[אישור] קבצים שמורים בתיקיית הקלט.'
        "InvalidOption" = 'אפשרות לא חוקית! הקש Enter כדי לנסות שוב...'
        "LangAppliedSuccess" = '[OK] שפת ממשק המשתמש הוחלה בהצלחה: {0} ({1})'
        "LauncherAutoDetect" = '[אישור] זיהוי אוטומטי של שפת מערכת Windows מופעל.'
        "LauncherBaseNotFoundTitle" = '[!] שגיאה: לא ניתן היה להוריד או לאתר את סקריפט ה-BASE LAUNCHER!'
        "LauncherIntegrated" = '[אישור] תמיכה משולבת עבור {0} שפות ב-PSBBN Launcher עבור Windows!'
        "LauncherPrompt" = 'בחר שפה אחת או יותר (למשל 7 או 1, 2, 3 או 1-5 או A):'
        "LauncherTip1" = '- הזן מספר אחד כדי ליצור את הקובץ עם השפה הזו בלבד.'
        "LauncherTipAll" = '- הזן ''A'' כדי ליצור את הקובץ המלא עם כל 40 השפות.'
        "LauncherTipHeader" = '* טיפ: כל ביצוע יוצר קובץ נקי המכיל רק את השפות שנבחרו.'
        "LauncherTipMulti" = '- הזן מספרים מרובים מופרדים בפסיק (למשל 1, 2, 3) כדי ליצור עם שפות אלו.'
        "LauncherTipRange" = '- הזן טווח (למשל 1-5) כדי ליצור עם טווח שפות זה.'
        "LauncherTitle" = 'מתרגם PSBBN Launcher for Windows [By Emerson Teles]'
        "NavBack" = '[ב] מסך קודם'
        "NavDeleteInput" = '[X] מחק קובץ מתיקיית הקלט'
        "NavEnter" = '[Enter] תפריט ראשי'
        "NavExit" = '[Esc] יציאה'
        "NavInstructions" = '[Enter] תפריט ראשי |  [B] מסך קודם |  [Esc] יציאה'
        "NavKeepInput" = '[V] שמור את הקובץ בתיקיית הקלט'
        "OfficialDownloadSuccess" = '[אישור] הקובץ הרשמי הורד בהצלחה ({0:N0} בתים).'
        "PkgCompressingGz" = '[*] דחיסה ל-''bnupdate.tar.gz'' דרך .NET GZipStream...'
        "PkgCreatingTar" = '[*] יצירת ''bnupdate.tar'' והגדרת הרשאות ביצוע POSIX (+x)...'
        "PkgErrorTar" = '[!] לא ניתן ליצור bnupdate.tar.'
        "PkgGenTitle" = 'חבילת התקנת PSBBN GENERATION (bnupdate.tar.gz)'
        "PkgNotice1" = '1. טקסטורות (.tm2 ו-.png) נשארות באנגלית (דורש עיצוב גרפי ידני מחדש).'
        "PkgNotice2" = '2. 100% מטקסטי המערכת (XML, ATOK HTML וסקריפטים) מתורגמים.'
        "PkgNotice3" = '3. הקובץ ''bnupdate.tar.gz'' מיועד לבדיקה מיידית ב-PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[הודעה טכנית]:'
        "PkgPromptTar" = 'האם אתה רוצה ליצור את הקובץ ''bnupdate.tar.gz'' לבדיקה ב-PS2? (Y/N) [ברירת מחדל: Y]'
        "PkgSuccess" = '[+] החבילה נוצרה בהצלחה (הרשאות לינוקס 0755 מופעלות): {0} ({1:N0} בתים)'
        "PosixPatchedCount" = '[+] קבצים שתוקנו עם הרשאת ביצוע POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'הקש על מקש כלשהו כדי לחזור לתפריט...'
        "ProgressAtokHelp" = 'תרגום ATOK עזרה'
        "ProgressUpdatingHtml" = 'עדכון קובצי HTML'
        "ProgressUpdatingXml" = 'עדכון קבצי XML'
        "ProgressXmlStrings" = 'תרגום מחרוזות XML'
        "PsbbnEnglishEnsure" = 'אנא ודא שהתיקיה ''PSBBN_English'' נמצאת בתוך ''קלט''.'
        "PsbbnEnglishNotFoundTitle" = '[!] שגיאה: ספריית הבסיס PSBBN_ENGLISH לא נמצאה!'
        "ReadmeEnsure" = 'אנא ודא שהקובץ ''README.md'' נמצא בתיקיית ''קלט''.'
        "ReadmeNotFoundDownloading" = '[*] README.md לא נמצא. מוריד מהמאגר הרשמי...'
        "ReadmeNotFoundTitle" = '[!] שגיאה: קובץ README.MD לא נמצא!'
        "ReadmeTitle" = 'מתרגם PSBBN Readme [By Emerson Teles]'
        "ScriptTitle" = 'מתרגם סקריפט PSBBN [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} שפות נבחרו ({1})'
        "SelectUILangPrompt" = 'בחר אפשרות'
        "SelectUITitle" = 'שנה שפת ממשק משתמש'
        "SessionStarted" = 'ההפעלה החלה ב:'
        "SourceFile" = 'מקור:'
        "Step1Copying" = '[*] [1/3] העתקת מבנה מלא וקבצים בינאריים...'
        "Step2TranslatingXml" = '[*] [2/3] תרגום {0} קבצי XML של מערכת...'
        "Step3TranslatingAtok" = '[*] [3/3] תרגום {0} ATOK HTML קבצי עזרה...'
        "SuiteTitle" = 'ערכת תרגום רב-לשונית PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'מתרגם מערכת PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'הערה: טקסטורות (.tm2 / .png) מכילות גרפיקה מוטמעת ודורשות   עריכה ידנית; הן אינן משתנות על ידי הסקריפט. קובצי טקסט של המערכת   (XML, HTML, txt) מתורגמים ב-100%.'
        "Translating" = 'מתרגם'
        "UsingFallback" = '[!] שימוש ב-fallback מקומי: {0}'
        "ValidatingXml" = '[*] אימות שלמות תחבירית של 100% מקבצי XML...'
        "XmlSyntaxError" = '[!] שגיאת תחביר ב{0}: {1}'
        "XmlValidationSuccess" = '[+] 100% מקבצי ה-XML אומתו בהצלחה (0 שגיאות תחביר).'
    }
    "ja" = @{
        "All40Success" = '全 40 言語 (完全多言語)'
        "AllLanguages" = '全言語を一括翻訳 (1 - 40)'
        "BackMenu" = 'メインメニューに戻る'
        "CancelOption" = '戻る'
        "CannotConnectGithub" = '[!] GitHub に接続できません: {0}'
        "ChangeLanguage" = 'UI言語を変更する'
        "ChangelogMainNotFoundTitle" = '[!] エラー: CHANGELOG_MAIN_ENG.TXT をダウンロードまたは検索できませんでした!'
        "ChangelogMainTitle" = 'PSBBN メイン更新履歴翻訳機 [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] エラー: CHANGELOG_PATCH_ENG.TXT をダウンロードまたは検索できませんでした!'
        "ChangelogPatchTitle" = 'PSBBN パッチ更新履歴翻訳機 [By Emerson Teles]'
        "ChooseOption" = 'オプションを選択してください:'
        "CompletionBanner" = '[OK] {0} の翻訳が正常に完了しました - 100%'
        "DescLauncher" = '40言語すべてをサポートするPSBBN Launcher for Windowsを生成および更新します。'
        "DescMain" = 'インストーラーの公式更新履歴(changelog_main_eng.txt)を翻訳します。'
        "DescPatch" = 'パッチ履歴とチャンネル更新メモ(changelog_patch_eng.txt)を翻訳します。'
        "DescReadme" = 'Markdownフォーマットとリンクを維持しながら公式README.mdを翻訳します。'
        "DescScript" = 'Linux/WSLインストーラスクリプトの全458行のUIテキスト(eng.txt)を翻訳します。'
        "DescSystem" = 'PSBBNシステムファイル(XMLダイアログ、ガイド、メニュー、ATOKヘルプ)を翻訳します。'
        "DestFile" = '出力先:'
        "DownloadingLatestGithub" = '[i] GitHubから最新の公式バージョンをダウンロードしています...'
        "DownloadingOfficial" = '[*] GitHub リポジトリから公式ファイルをダウンロードしています...'
        "EnglishOption" = '英語（デフォルト）'
        "EngTxtEnsureFile" = '''eng.txt'' ファイルが ''input'' フォルダにあることを確認していただきます。'
        "EngTxtErrorTitle" = '[!] エラー: ENG.TXT ファイルが見つかりません!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt が見つかりません。公式リポジトリからダウンロードしています...'
        "EnsureConnected" = 'インターネットに接続していることを確認するか、ファイルを入力ディレクトリに配置してください。'
        "ExitOption" = '終了'
        "ExpectedPath" = '予想されるパス: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 翻訳パックを展開しています...'
        "FileNotFoundError" = '[エラー] ファイルが見つかりません: {0}'
        "GeneratedFile" = '[OK] 生成されたファイル: {0}'
        "GenericEnsureInternetOrInput" = 'インターネットに接続されているか、ファイルが ''input'' フォルダにあることを確認していただきます。'
        "IndividualBlocks" = '個々のブロック: {0}'
        "IndividualBlocksNotice" = '[OK] CosmicScale の個々のブロック: {0}'
        "InputFileDeleted" = '[OK] 入力フォルダーからファイルが削除されました。'
        "InputFileKept" = '[OK] ファイルは入力フォルダーに保存されます。'
        "InvalidOption" = '無効なオプションです! Enterを押してください...'
        "LangAppliedSuccess" = '[OK] UI言語が正常に適用されました: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Windows システム言語の自動検出が有効になりました。'
        "LauncherBaseNotFoundTitle" = '[!] エラー: ランチャーのベーススクリプトをダウンロードまたは検索できませんでした!'
        "LauncherIntegrated" = '[OK] {0} 言語のサポートを Windows 用 PSBBN Launcher に統合しました。'
        "LauncherPrompt" = '1 つ以上の言語を選択します (例: 7 または 1、2、3、1-5、または A):'
        "LauncherTip1" = '- 数字を 1 つ入力すると、その言語のみでファイルが生成されます。'
        "LauncherTipAll" = '- 40 言語すべてを含む完全なファイルを生成するには、「A」と入力します。'
        "LauncherTipHeader" = '* ヒント: 実行するたびに、選択した言語のみを含むクリーンなファイルが生成されます。'
        "LauncherTipMulti" = '- それらの言語で生成するには、複数の数値をカンマで区切って入力します (例: 1、2、3)。'
        "LauncherTipRange" = '- 範囲 (例: 1 ～ 5) を入力して、その範囲の言語で生成します。'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] 前の画面'
        "NavDeleteInput" = '[X] 入力フォルダーからファイルを削除'
        "NavEnter" = '[Enter] メインメニュー'
        "NavExit" = '[Esc] 終了'
        "NavInstructions" = '[Enter] メインメニュー  |  [B] 前の画面に戻る  |  [Esc] 終了'
        "NavKeepInput" = '[V] ファイルを入力フォルダーに保存します'
        "OfficialDownloadSuccess" = '[OK] 公式ファイルが正常にダウンロードされました ({0:N0} バイト)。'
        "PkgCompressingGz" = '[*] .NET GZipStream 経由で ''bnupdate.tar.gz'' に圧縮しています...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' を作成し、POSIX実行権限 (+x) を設定しています...'
        "PkgErrorTar" = '[!] bnupdate.tar を生成できませんでした。'
        "PkgGenTitle" = 'PSBBNインストールパッケージの生成 (bnupdate.tar.gz)'
        "PkgNotice1" = '1. テクスチャ (.tm2 および .png) は英語のままです (手動のグラフィック再設計が必要です)。'
        "PkgNotice2" = '2. システムテキスト (XML、ATOK HTML、スクリプト) は100%翻訳されています。'
        "PkgNotice3" = '3. ''bnupdate.tar.gz'' ファイルはPS2 (HDD / Telnet / USB) での即時テスト用です。'
        "PkgNoticeHeader" = '[技術上の注意]:'
        "PkgPromptTar" = 'PS2でテストするために ''bnupdate.tar.gz'' ファイルを生成しますか? (Y/N) [デフォルト: Y]'
        "PkgSuccess" = '[+] パッケージが正常に生成されました (Linux 0755権限が有効): {0} ({1:N0} バイト)'
        "PosixPatchedCount" = '[+] POSIX 0755実行権限 (+x) でパッチされたファイル: {0}'
        "PressAnyKey" = 'メニューに戻るには、任意のキーを押してください...'
        "ProgressAtokHelp" = 'ATOKヘルプの翻訳中'
        "ProgressUpdatingHtml" = 'HTMLファイルの更新中'
        "ProgressUpdatingXml" = 'XMLファイルの更新中'
        "ProgressXmlStrings" = 'XML文字列の翻訳中'
        "PsbbnEnglishEnsure" = '''PSBBN_English'' フォルダが ''input'' 内にあることを確認していただきます。'
        "PsbbnEnglishNotFoundTitle" = '[!] エラー: ベースディレクトリ PSBBN_ENGLISH が見つかりません!'
        "ReadmeEnsure" = '''README.md'' ファイルが ''input'' フォルダにあることを確認していただきます。'
        "ReadmeNotFoundDownloading" = '[*] README.md が見つかりません。公式リポジトリからダウンロードしています...'
        "ReadmeNotFoundTitle" = '[!] エラー: README.MD ファイルが見つかりません!'
        "ReadmeTitle" = 'PSBBN Readme 翻訳機 [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN スクリプト翻訳機 [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} 言語が選択されました ({1})'
        "SelectUILangPrompt" = 'UI言語を選択してください'
        "SelectUITitle" = 'UI言語の選択'
        "SessionStarted" = 'セッション開始日時:'
        "SourceFile" = '入力元:'
        "Step1Copying" = '[*] [1/3] 完全な構造とバイナリをコピーしています...'
        "Step2TranslatingXml" = '[*] [2/3] {0} 個のシステムXMLファイルを翻訳しています...'
        "Step3TranslatingAtok" = '[*] [3/3] {0} 個のATOK HTMLヘルプファイルを翻訳しています...'
        "SuiteTitle" = 'PSBBN 多言語翻訳スイート - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN 翻訳機 [By Emerson Teles]'
        "TextureDisclaimer" = '注意: テクスチャ(.tm2 / .png)は手動での画像編集が必要です。 システムテキスト(XML, HTML, メニュー, スクリプト)は100%翻訳されます。'
        "Translating" = '翻訳中'
        "UsingFallback" = '[!] ローカル フォールバックの使用: {0}'
        "ValidatingXml" = '[*] 100%のXMLファイルの構文整合性を検証しています...'
        "XmlSyntaxError" = '[!] {0} の構文エラー: {1}'
        "XmlValidationSuccess" = '[+] 100%のXMLファイルが正常に検証されました (構文エラー 0)。'
    }
    "ko" = @{
        "All40Success" = '40개 언어 모두(완전 다국어)'
        "AllLanguages" = '모든 언어 번역(1 - 40)'
        "BackMenu" = '메인 메뉴로 돌아가기'
        "CancelOption" = '뒤로'
        "CannotConnectGithub" = '[!] GitHub에 연결할 수 없습니다: __0___'
        "ChangeLanguage" = 'UI 언어 변경'
        "ChangelogMainNotFoundTitle" = '[!] 오류: CHANGELOG_MAIN_ENG.TXT를 다운로드하거나 찾을 수 없습니다!'
        "ChangelogMainTitle" = 'PSBBN 변경 로그 주요 번역기 [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] 오류: CHANGELOG_PATCH_ENG.TXT를 다운로드하거나 찾을 수 없습니다!'
        "ChangelogPatchTitle" = 'PSBBN 변경 로그 패치 번역기 [By Emerson Teles]'
        "ChooseOption" = '옵션 선택:'
        "CompletionBanner" = '[OK] {0} 번역이 성공적으로 완료되었습니다 - 100%'
        "DescLauncher" = '40개 언어를 모두 지원하는 Windows용 PSBBN 실행기를 생성하고 업데이트합니다.'
        "DescMain" = '주요 설치 프로그램 릴리스 노트 및 변경 로그(changelog_main_eng.txt)를 번역합니다.'
        "DescPatch" = '패치 기록, 수정 사항 및 채널 업데이트 노트(changelog_patch_eng.txt)를 번역합니다.'
        "DescReadme" = '마크다운 형식과 링크를 유지하는 공식 PSBBN README.md를 번역합니다.'
        "DescScript" = '모든 458 UI를 번역합니다. Linux/WSL PSBBN 설치 프로그램 문자열(eng.txt).'
        "DescSystem" = '모든 PS2 PSBBN 시스템 파일(XML 대화 상자, 가이드, 메뉴, NetFront/ATOK 도움말)을 번역합니다.'
        "DestFile" = '대상:'
        "DownloadingLatestGithub" = '[i] GitHub에서 최신 공식 버전을 다운로드하는 중...'
        "DownloadingOfficial" = '[*] GitHub 저장소에서 공식 파일을 다운로드하는 중...'
        "EnglishOption" = '영어 (기본값)'
        "EngTxtEnsureFile" = '''input'' 폴더에 ''eng.txt'' 파일이 있는지 확인하세요.'
        "EngTxtErrorTitle" = '[!] 오류: ENG.TXT 파일을 찾을 수 없습니다!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt를 찾을 수 없습니다. 공식 저장소에서 다운로드 중...'
        "EnsureConnected" = '인터넷에 연결되어 있는지 확인하거나 파일을 입력 디렉터리에 저장하세요.'
        "ExitOption" = '종료'
        "ExpectedPath" = '예상 경로: __0___'
        "ExtractingPack" = '[*] PSBBN v3.5 번역 팩 추출 중...'
        "FileNotFoundError" = '[오류] 파일을 찾을 수 없습니다: __0___'
        "GeneratedFile" = '[확인] 생성된 파일: __0___'
        "GenericEnsureInternetOrInput" = '인터넷에 연결되어 있는지, ''입력'' 폴더에 파일이 있는지 확인하세요.'
        "IndividualBlocks" = '개별 블록: __0___'
        "IndividualBlocksNotice" = '[OK] CosmicScale의 개별 블록: __0___'
        "InputFileDeleted" = '[확인] 입력 폴더에서 파일이 삭제되었습니다.'
        "InputFileKept" = '[확인] 파일이 입력 폴더에 보관되었습니다.'
        "InvalidOption" = '잘못된 옵션입니다! 다시 시도하려면 Enter를 누르세요...'
        "LangAppliedSuccess" = '[OK] UI 언어가 성공적으로 적용되었습니다: {0} ({1})'
        "LauncherAutoDetect" = '[확인] Windows 시스템 언어 자동 감지가 활성화되었습니다.'
        "LauncherBaseNotFoundTitle" = '[!] 오류: 기본 실행기 스크립트를 다운로드하거나 찾을 수 없습니다!'
        "LauncherIntegrated" = '[OK] Windows용 PSBBN Launcher에 __0____ 언어 지원이 통합되었습니다!'
        "LauncherPrompt" = '하나 이상의 언어를 선택하십시오(예: 7 또는 1, 2, 3 또는 1-5 또는 A).'
        "LauncherTip1" = '- 해당 언어로만 파일을 생성하려면 숫자 1개를 입력하세요.'
        "LauncherTipAll" = '- 40개 언어가 모두 포함된 전체 파일을 생성하려면 ''A''를 입력하세요.'
        "LauncherTipHeader" = '* 팁: 실행할 때마다 선택한 언어만 포함된 깨끗한 파일이 생성됩니다.'
        "LauncherTipMulti" = '- 해당 언어로 생성하려면 여러 숫자를 쉼표로 구분하여 입력하세요(예: 1, 2, 3).'
        "LauncherTipRange" = '- 해당 언어 범위로 생성하려면 범위(예: 1-5)를 입력하세요.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] 이전 화면'
        "NavDeleteInput" = '[X] 입력 폴더에서 파일 삭제'
        "NavEnter" = '[Enter] 메인 메뉴'
        "NavExit" = '[Esc] 종료'
        "NavInstructions" = '[Enter] 기본 메뉴 |  [B] 이전 화면 |  [Esc] 종료'
        "NavKeepInput" = '[V] 파일을 입력 폴더에 보관'
        "OfficialDownloadSuccess" = '[확인] 공식 파일이 성공적으로 다운로드되었습니다({0:N0}바이트).'
        "PkgCompressingGz" = '[*] .NET GZipStream을 통해 ''bnupdate.tar.gz''로 압축 중...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' 생성 및 POSIX 실행 권한 설정(+x)...'
        "PkgErrorTar" = '[!] bnupdate.tar를 생성할 수 없습니다.'
        "PkgGenTitle" = 'PSBBN 설치 패키지 생성(bnupdate.tar.gz)'
        "PkgNotice1" = '1. 텍스처(.tm2 및 .png)는 영어로 유지됩니다(수동 그래픽 재설계 필요).'
        "PkgNotice2" = '2. 시스템 텍스트(XML, ATOK HTML 및 스크립트)가 100% 번역됩니다.'
        "PkgNotice3" = '3. ''bnupdate.tar.gz'' 파일은 PS2(HDD/Telnet/USB)에서 즉시 테스트하기 위한 것입니다.'
        "PkgNoticeHeader" = '[기술적 공지]:'
        "PkgPromptTar" = 'PS2에서 테스트하기 위해 ''bnupdate.tar.gz'' 파일을 생성하시겠습니까? (Y/N) [기본값: Y]'
        "PkgSuccess" = '[+] 패키지가 성공적으로 생성되었습니다(Linux 0755 권한 활성화됨): __0___ ({1:N0} 바이트)'
        "PosixPatchedCount" = '[+] POSIX 0755 실행 권한으로 패치된 파일(+x): __0___'
        "PressAnyKey" = '메뉴로 돌아가려면 아무 키나 누르세요...'
        "ProgressAtokHelp" = 'ATOK 도움말 번역'
        "ProgressUpdatingHtml" = 'HTML 파일 업데이트 중'
        "ProgressUpdatingXml" = 'XML 파일 업데이트 중'
        "ProgressXmlStrings" = 'XML 문자열 번역'
        "PsbbnEnglishEnsure" = '''input'' 안에 ''PSBBN_English'' 폴더가 있는지 확인하세요.'
        "PsbbnEnglishNotFoundTitle" = '[!] 오류: 기본 디렉토리 PSBBN_ENGLISH를 찾을 수 없습니다!'
        "ReadmeEnsure" = '''입력'' 폴더에 ''README.md'' 파일이 있는지 확인하세요.'
        "ReadmeNotFoundDownloading" = '[*] README.md를 찾을 수 없습니다. 공식 저장소에서 다운로드 중...'
        "ReadmeNotFoundTitle" = '[!] 오류: README.MD 파일을 찾을 수 없습니다!'
        "ReadmeTitle" = 'PSBBN Readme 번역기 [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN 스크립트 번역기 [By Emerson Teles]'
        "SelectedLanguagesCount" = '__0___ 언어 선택됨 ({1})'
        "SelectUILangPrompt" = '옵션 선택'
        "SelectUITitle" = 'UI 언어 변경'
        "SessionStarted" = '세션 시작 날짜:'
        "SourceFile" = '출처:'
        "Step1Copying" = '[*] [1/3] 전체 구조 및 바이너리 복사 중...'
        "Step2TranslatingXml" = '[*] [2/3] __0___ 시스템 XML 파일을 번역하는 중...'
        "Step3TranslatingAtok" = '[*] [3/3] __0___ ATOK HTML 도움말 파일 번역 중...'
        "SuiteTitle" = 'PSBBN 다국어 번역 제품군 - V1 [By Emerson Teles]'
        "SystemTitle" = '시스템 PSBBN 번역기 [By Emerson Teles]'
        "TextureDisclaimer" = '주의 사항: 텍스처(.tm2 / .png)에는 내장 그래픽이 포함되어 있으며 수동 편집이 필요합니다. 스크립트에 의해 변경되지   않습니다. 시스템 텍스트 파일(XML, HTML, txt)은 100% 번역됩니다.'
        "Translating" = '번역 중'
        "UsingFallback" = '[!] 로컬 폴백 사용: __0___'
        "ValidatingXml" = '[*] XML 파일의 100% 구문 무결성을 검증하는 중...'
        "XmlSyntaxError" = '[!] __0___의 구문 오류: __1___'
        "XmlValidationSuccess" = '[+] XML 파일의 100%가 성공적으로 검증되었습니다(구문 오류 0개).'
    }
    "mr" = @{
        "All40Success" = 'सर्व 40 भाषा (संपूर्ण बहुभाषी)'
        "AllLanguages" = 'सर्व भाषांचे भाषांतर करा (1 - 40)'
        "BackMenu" = 'मुख्य मेनूवर परत'
        "CancelOption" = 'मागे'
        "CannotConnectGithub" = '[!] GitHub शी कनेक्ट करू शकत नाही: {0}'
        "ChangeLanguage" = 'UI भाषा बदला'
        "ChangelogMainNotFoundTitle" = '[!] त्रुटी: CHANGELOG_MAIN_ENG.TXT डाउनलोड किंवा शोधू शकलो नाही!'
        "ChangelogMainTitle" = 'PSBBN चेंजलॉग मुख्य अनुवादक [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] त्रुटी: CHANGELOG_PATCH_ENG.TXT डाउनलोड किंवा शोधू शकलो नाही!'
        "ChangelogPatchTitle" = 'PSBBN चेंजलॉग पॅच अनुवादक [By Emerson Teles]'
        "ChooseOption" = 'एक पर्याय निवडा:'
        "CompletionBanner" = '[OK] {0} चे भाषांतर यशस्वीरित्या पूर्ण झाले - 100%'
        "DescLauncher" = 'सर्व 40 भाषांसाठी समर्थनासह Windows साठी PSBBN लाँचर व्युत्पन्न आणि अद्यतनित करते.'
        "DescMain" = 'मुख्य इंस्टॉलर रिलीझ नोट्स आणि चेंजलॉग (changelog_main_eng.txt) चे भाषांतर करते.'
        "DescPatch" = 'पॅच इतिहास, निराकरणे आणि चॅनल अपडेट नोट्स (changelog_patch_eng.txt) चे भाषांतर करते.'
        "DescReadme" = 'अधिकृत PSBBN README.md चे भाषांतर मार्कडाउन फॉरमॅटिंग आणि लिंक्स संरक्षित करते.'
        "DescScript" = 'Linux/WSL PSBBN इंस्टॉलर स्क्रिप्ट (eng.txt) साठी सर्व 458 UI स्ट्रिंगचे भाषांतर करते.'
        "DescSystem" = 'सर्व PS2 PSBBN सिस्टम फाइल्स (XML संवाद, मार्गदर्शक, मेनू, NetFront/ATOK मदत) भाषांतरित करते.'
        "DestFile" = 'गंतव्यस्थान:'
        "DownloadingLatestGithub" = '[i] GitHub वरून नवीनतम अधिकृत आवृत्ती डाउनलोड करत आहे...'
        "DownloadingOfficial" = '[*] गिटहब रेपॉजिटरीवरून अधिकृत फाइल डाउनलोड करत आहे...'
        "EnglishOption" = 'इंग्रजी (डीफॉल्ट)'
        "EngTxtEnsureFile" = 'कृपया खात्री करा की ''eng.txt'' फाइल ''इनपुट'' फोल्डरमध्ये आहे.'
        "EngTxtErrorTitle" = '[!] त्रुटी: ENG.TXT फाइल सापडली नाही!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt आढळले नाही. अधिकृत भांडारातून डाउनलोड करत आहे...'
        "EnsureConnected" = 'कृपया तुम्ही इंटरनेटशी कनेक्ट असल्याची खात्री करा किंवा फाइल इनपुट निर्देशिकेत ठेवा.'
        "ExitOption" = 'बाहेर पडा'
        "ExpectedPath" = 'अपेक्षित मार्ग: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 भाषांतर पॅक काढत आहे...'
        "FileNotFoundError" = '[त्रुटी] फाइल सापडली नाही: {0}'
        "GeneratedFile" = '[ओके] व्युत्पन्न केलेली फाइल: {0}'
        "GenericEnsureInternetOrInput" = 'कृपया तुम्ही इंटरनेटशी कनेक्ट आहात किंवा ''इनपुट'' फोल्डरमध्ये फाइल असल्याची खात्री करा.'
        "IndividualBlocks" = 'वैयक्तिक ब्लॉक्स: {0}'
        "IndividualBlocksNotice" = '[ओके] कॉस्मिकस्केलसाठी वैयक्तिक ब्लॉक्स: {0}'
        "InputFileDeleted" = '[ओके] इनपुट फोल्डरमधून फाईल हटवली'
        "InputFileKept" = '[ओके] इनपुट फोल्डरमध्ये ठेवलेल्या फाइल'
        "InvalidOption" = 'अवैध पर्याय! पुन्हा प्रयत्न करण्यासाठी Enter दाबा...'
        "LangAppliedSuccess" = '[OK] UI भाषा यशस्वीरित्या लागू केली गेली: {0} ({1})'
        "LauncherAutoDetect" = '[ओके] विंडोज सिस्टम भाषा स्वयं-शोध सक्षम.'
        "LauncherBaseNotFoundTitle" = '[!] त्रुटी: बेस लाँचर स्क्रिप्ट डाउनलोड किंवा शोधू शकलो नाही!'
        "LauncherIntegrated" = '[ओके] Windows साठी PSBBN लाँचरमध्ये {0} भाषा(भाषा) साठी एकात्मिक समर्थन!'
        "LauncherPrompt" = 'एक किंवा अधिक भाषा निवडा (उदा. 7 किंवा 1, 2, 3 किंवा 1-5 किंवा A):'
        "LauncherTip1" = '- फक्त त्या भाषेसह फाईल तयार करण्यासाठी 1 क्रमांक प्रविष्ट करा.'
        "LauncherTipAll" = '- सर्व 40 भाषांसह संपूर्ण फाइल तयार करण्यासाठी ''A'' प्रविष्ट करा.'
        "LauncherTipHeader" = '* टीप: प्रत्येक अंमलबजावणी केवळ निवडलेल्या भाषा(ल्या) असलेली एक स्वच्छ फाइल व्युत्पन्न करते.'
        "LauncherTipMulti" = '- स्वल्पविरामाने विभक्त केलेले एकाधिक संख्या प्रविष्ट करा (उदा. 1, 2, 3) त्या भाषांसह निर्माण करण्यासाठी.'
        "LauncherTipRange" = '- त्या भाषेच्या श्रेणीसह व्युत्पन्न करण्यासाठी श्रेणी (उदा. 1-5) प्रविष्ट करा.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[ब] मागील स्क्रीन'
        "NavDeleteInput" = '[X] इनपुट फोल्डरमधून फाइल हटवा'
        "NavEnter" = '[एंटर] मुख्य मेनू'
        "NavExit" = '[Esc] बाहेर पडा'
        "NavInstructions" = '[एंटर] मुख्य मेनू |  [ब] मागील स्क्रीन |  [Esc] बाहेर पडा'
        "NavKeepInput" = '[V] फाईल इनपुट फोल्डरमध्ये ठेवा'
        "OfficialDownloadSuccess" = '[ओके] अधिकृत फाइल यशस्वीरित्या डाउनलोड झाली ({0:N0} बाइट्स).'
        "PkgCompressingGz" = '[*] .NET GZipStream द्वारे ''bnupdate.tar.gz'' वर संकुचित करणे...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' तयार करणे आणि POSIX अंमलबजावणी परवानग्या सेट करणे (+x)...'
        "PkgErrorTar" = '[!] bnupdate.tar व्युत्पन्न करू शकलो नाही.'
        "PkgGenTitle" = 'PSBBN इन्स्टॉलेशन पॅकेज जनरेशन (bnupdate.tar.gz)'
        "PkgNotice1" = '1. टेक्सचर (.tm2 आणि .png) इंग्रजीतच राहतील (मॅन्युअल ग्राफिक रीडिझाइन आवश्यक आहे).'
        "PkgNotice2" = '2. 100% सिस्टम मजकूर (XML, ATOK HTML आणि स्क्रिप्ट्स) भाषांतरित केले आहेत.'
        "PkgNotice3" = '3. ''bnupdate.tar.gz'' फाइल PS2 (HDD/Telnet/USB) वर त्वरित चाचणीसाठी आहे.'
        "PkgNoticeHeader" = '[तांत्रिक सूचना]:'
        "PkgPromptTar" = 'तुम्हाला PS2 वर चाचणी करण्यासाठी ''bnupdate.tar.gz'' फाइल तयार करायची आहे का? (Y/N) [डिफॉल्ट: Y]'
        "PkgSuccess" = '[+] पॅकेज यशस्वीरित्या व्युत्पन्न झाले (Linux 0755 परवानग्या सक्षम): {0} ({1:N0} बाइट्स)'
        "PosixPatchedCount" = '[+] POSIX 0755 अंमलबजावणी परवानगी (+x) सह पॅच केलेल्या फाइल्स: {0}'
        "PressAnyKey" = 'मेनूवर परत येण्यासाठी कोणतीही कळ दाबा...'
        "ProgressAtokHelp" = 'ATOK मदत चे भाषांतर करत आहे'
        "ProgressUpdatingHtml" = 'HTML फाइल्स अपडेट करत आहे'
        "ProgressUpdatingXml" = 'XML फाइल्स अपडेट करत आहे'
        "ProgressXmlStrings" = 'XML स्ट्रिंग्सचे भाषांतर करत आहे'
        "PsbbnEnglishEnsure" = 'कृपया खात्री करा की ''PSBBN_English'' फोल्डर ''इनपुट'' मध्ये उपस्थित आहे.'
        "PsbbnEnglishNotFoundTitle" = '[!] त्रुटी: बेस डायरेक्टरी PSBBN_ENGLISH सापडले नाही!'
        "ReadmeEnsure" = 'कृपया ''README.md'' फाइल ''इनपुट'' फोल्डरमध्ये असल्याची खात्री करा.'
        "ReadmeNotFoundDownloading" = '[*] README.md आढळले नाही. अधिकृत भांडारातून डाउनलोड करत आहे...'
        "ReadmeNotFoundTitle" = '[!] त्रुटी: README.MD फाइल सापडली नाही!'
        "ReadmeTitle" = 'पीएसबीबीएन रीडमी अनुवादक [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN स्क्रिप्ट अनुवादक [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} भाषा निवडल्या ({1})'
        "SelectUILangPrompt" = 'एक पर्याय निवडा'
        "SelectUITitle" = 'UI भाषा बदला'
        "SessionStarted" = 'सत्र सुरू झाले:'
        "SourceFile" = 'स्रोत:'
        "Step1Copying" = '[*] [१/३] संपूर्ण रचना आणि बायनरी कॉपी करणे...'
        "Step2TranslatingXml" = '[*] [२/३] {0} सिस्टीम एक्सएमएल फाइल्सचे भाषांतर करत आहे...'
        "Step3TranslatingAtok" = '[*] [३/३] {0} एटीओके एचटीएमएल मदत फाइल्सचे भाषांतर करत आहे...'
        "SuiteTitle" = 'PSBBN बहुभाषिक भाषांतर सूट - V1 [By Emerson Teles]'
        "SystemTitle" = 'सिस्टम PSBBN अनुवादक [By Emerson Teles]'
        "TextureDisclaimer" = 'सूचना: टेक्सचर (.tm2 / .png) मध्ये एम्बेडेड ग्राफिक्स असतात आणि   मॅन्युअल एडिटिंग आवश्यक असते; ते लिपीद्वारे बदललेले नाहीत. सिस्टम   मजकूर फाइल्स (XML, HTML, txt) 100% अनुवादित आहेत.'
        "Translating" = 'भाषांतर करत आहे'
        "UsingFallback" = '[!] स्थानिक फॉलबॅक वापरणे: {0}'
        "ValidatingXml" = '[*] XML फायलींच्या 100% सिंटॅक्टिक अखंडतेचे प्रमाणीकरण करत आहे...'
        "XmlSyntaxError" = '[!] {0} मधील वाक्यरचना त्रुटी: {1}'
        "XmlValidationSuccess" = '[+] 100% XML फायली यशस्वीरित्या प्रमाणित झाल्या (0 वाक्यरचना त्रुटी).'
    }
    "ms" = @{
        "All40Success" = 'Semua 40 Bahasa (Berbilang Bahasa Penuh)'
        "AllLanguages" = 'Terjemah Semua Bahasa (1 - 40)'
        "BackMenu" = 'Kembali ke Menu Utama'
        "CancelOption" = 'Kembali'
        "CannotConnectGithub" = '[!] Tidak dapat menyambung ke GitHub: {0}'
        "ChangeLanguage" = 'Tukar Bahasa UI'
        "ChangelogMainNotFoundTitle" = '[!] RALAT: TIDAK DAPAT MUAT TURUN ATAU MENCARI CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Penterjemah Utama PSBBN Changelog [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] RALAT: TIDAK DAPAT MUAT TURUN ATAU MENCARI CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Penterjemah Tampung Log Perubahan PSBBN [By Emerson Teles]'
        "ChooseOption" = 'Pilih satu pilihan:'
        "CompletionBanner" = '[OK] Penterjemahan {0} berjaya diselesaikan - 100%'
        "DescLauncher" = 'Menambah sokongan dan pengesanan automatik sehingga 40 bahasa dalam PSBBN Launcher for Windows.'
        "DescMain" = 'Menterjemah nota keluaran pemasang utama dan log perubahan (changelog_main_eng.txt).'
        "DescPatch" = 'Menterjemah sejarah tampung, pembetulan dan nota kemas kini saluran (changelog_patch_eng.txt).'
        "DescReadme" = 'Menterjemah fail rasmi PSBBN README.md sambil mengekalkan pemformatan markdown dan pautan.'
        "DescScript" = 'Menterjemah semua 458 rentetan UI untuk skrip pemasang Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'Menterjemah semua fail sistem PS2 PSBBN (dialog XML, panduan, menu, bantuan NetFront/ATOK).'
        "DestFile" = 'Destinasi:'
        "DownloadingLatestGithub" = '[i] Memuat turun versi rasmi terkini daripada GitHub...'
        "DownloadingOfficial" = '[*] Memuat turun fail rasmi daripada repositori GitHub...'
        "EnglishOption" = 'Bahasa Inggeris (lalai)'
        "EngTxtEnsureFile" = 'Sila pastikan bahawa fail ''eng.txt'' ada dalam folder ''input''.'
        "EngTxtErrorTitle" = '[!] RALAT: FAIL ENG.TXT TIDAK DITEMUI!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt tidak ditemui. Memuat turun daripada repositori rasmi...'
        "EnsureConnected" = 'Sila pastikan anda disambungkan ke Internet atau letakkan fail dalam direktori input.'
        "ExitOption" = 'Keluar'
        "ExpectedPath" = 'Laluan yang dijangkakan: {0}'
        "ExtractingPack" = '[*] Mengekstrak pek terjemahan PSBBN v3.5...'
        "FileNotFoundError" = '[ERROR] Fail tidak ditemui: {0}'
        "GeneratedFile" = '[OK] Fail yang dijana: {0}'
        "GenericEnsureInternetOrInput" = 'Sila pastikan anda disambungkan ke Internet atau mempunyai fail dalam folder ''input''.'
        "IndividualBlocks" = 'Blok Individu: {0}'
        "IndividualBlocksNotice" = '[OK] Blok individu untuk CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Fail dipadamkan daripada folder input.'
        "InputFileKept" = '[OK] Fail disimpan dalam folder input.'
        "InvalidOption" = 'Pilihan tidak sah! Tekan Enter untuk cuba lagi...'
        "LangAppliedSuccess" = '[OK] Bahasa UI berjaya digunakan: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Pengesanan auto bahasa sistem Windows didayakan.'
        "LauncherBaseNotFoundTitle" = '[!] RALAT: TIDAK DAPAT MUAT TURUN ATAU MENCARI SKRIP PELANCANG ASAS!'
        "LauncherIntegrated" = '[OK] Sokongan bersepadu untuk {0} bahasa ke dalam Pelancar PSBBN untuk Windows!'
        "LauncherPrompt" = 'Pilih satu atau lebih bahasa (cth. 7 atau 1, 2, 3 atau 1-5 atau A):'
        "LauncherTip1" = '- Masukkan 1 nombor untuk menjana fail dengan bahasa itu sahaja.'
        "LauncherTipAll" = '- Masukkan ''A'' untuk menjana fail lengkap dengan kesemua 40 bahasa.'
        "LauncherTipHeader" = '* Petua: Setiap pelaksanaan menjana fail bersih yang mengandungi hanya bahasa yang dipilih.'
        "LauncherTipMulti" = '- Masukkan berbilang nombor yang dipisahkan dengan koma (cth. 1, 2, 3) untuk menjana dengan bahasa tersebut.'
        "LauncherTipRange" = '- Masukkan julat (cth. 1-5) untuk menjana dengan julat bahasa tersebut.'
        "LauncherTitle" = 'Penterjemah PSBBN Launcher for Windows [By Emerson Teles]'
        "NavBack" = '[B] Skrin Sebelumnya'
        "NavDeleteInput" = '[X] Padam fail daripada folder input'
        "NavEnter" = '[Masuk] Menu Utama'
        "NavExit" = '[Esc] Keluar'
        "NavInstructions" = '[Enter] Menu Utama |  [B] Skrin Sebelumnya |  [Esc] Keluar'
        "NavKeepInput" = '[V] Simpan fail dalam folder input'
        "OfficialDownloadSuccess" = '[OK] Fail rasmi berjaya dimuat turun ({0:N0} bait).'
        "PkgCompressingGz" = '[*] Memampatkan kepada ''bnupdate.tar.gz'' melalui .NET GZipStream...'
        "PkgCreatingTar" = '[*] Mencipta ''bnupdate.tar'' dan menetapkan kebenaran pelaksanaan POSIX (+x)...'
        "PkgErrorTar" = '[!] Tidak dapat menjana bnupdate.tar.'
        "PkgGenTitle" = 'PENJANAAN PAKEJ PEMASANGAN PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Tekstur (.tm2 dan .png) kekal dalam bahasa Inggeris (memerlukan reka bentuk semula grafik manual).'
        "PkgNotice2" = '2. 100% teks sistem (XML, ATOK HTML dan skrip) diterjemahkan.'
        "PkgNotice3" = '3. Fail ''bnupdate.tar.gz'' bertujuan untuk ujian segera pada PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[NOTIS TEKNIKAL]:'
        "PkgPromptTar" = 'Adakah anda ingin menjana fail ''bnupdate.tar.gz'' untuk diuji pada PS2? (Y/N) [Lalai: Y]'
        "PkgSuccess" = '[+] Pakej berjaya dijana (kebenaran Linux 0755 didayakan): {0} ({1:N0} bait)'
        "PosixPatchedCount" = '[+] Fail ditampal dengan kebenaran pelaksanaan POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Tekan sebarang kekunci untuk kembali ke menu...'
        "ProgressAtokHelp" = 'Menterjemah Bantuan ATOK'
        "ProgressUpdatingHtml" = 'Mengemas kini fail HTML'
        "ProgressUpdatingXml" = 'Mengemas kini fail XML'
        "ProgressXmlStrings" = 'Menterjemah rentetan XML'
        "PsbbnEnglishEnsure" = 'Sila pastikan bahawa folder ''PSBBN_English'' ada di dalam ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] RALAT: DIREKTORI ASAS PSBBN_ENGLISH TIDAK DIJUMPAI!'
        "ReadmeEnsure" = 'Sila pastikan bahawa fail ''README.md'' berada dalam folder ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md tidak ditemui. Memuat turun daripada repositori rasmi...'
        "ReadmeNotFoundTitle" = '[!] RALAT: FAIL README.MD TIDAK DITEMUI!'
        "ReadmeTitle" = 'Penterjemah PSBBN Readme [By Emerson Teles]'
        "ScriptTitle" = 'Penterjemah Skrip PSBBN [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} bahasa dipilih ({1})'
        "SelectUILangPrompt" = 'Pilih satu pilihan'
        "SelectUITitle" = 'TUKAR BAHASA UI'
        "SessionStarted" = 'Sesi bermula pada:'
        "SourceFile" = 'Sumber:'
        "Step1Copying" = '[*] [1/3] Menyalin struktur lengkap dan binari...'
        "Step2TranslatingXml" = '[*] [2/3] Menterjemah {0} fail XML sistem...'
        "Step3TranslatingAtok" = '[*] [3/3] Menterjemah {0} fail bantuan HTML ATOK...'
        "SuiteTitle" = 'Suit Terjemahan Berbilang Bahasa PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'Penterjemah Sistem PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Nota: Tekstur (.tm2 / .png) mengandungi grafik terbenam dan memerlukan   penyuntingan manual; ia tidak diubah suai oleh skrip. Fail teks   sistem (XML, HTML, txt) 100% diterjemahkan.'
        "Translating" = 'Menterjemah'
        "UsingFallback" = '[!] Menggunakan sandaran tempatan: {0}'
        "ValidatingXml" = '[*] Mengesahkan integriti sintaksis 100% fail XML...'
        "XmlSyntaxError" = '[!] Ralat sintaks dalam {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% daripada fail XML berjaya disahkan (0 ralat sintaks).'
    }
    "nl" = @{
        "All40Success" = 'Alle 40 talen (volledig meertalig)'
        "AllLanguages" = 'Alle talen vertalen (1 - 40)'
        "BackMenu" = 'Terug naar hoofdmenu'
        "CancelOption" = 'Terug'
        "CannotConnectGithub" = '[!] Kan geen verbinding maken met GitHub: {0}'
        "ChangeLanguage" = 'UI-taal wijzigen'
        "ChangelogMainNotFoundTitle" = '[!] FOUT: KAN CHANGELOG_MAIN_ENG.TXT NIET DOWNLOADEN OF LOCEREN!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] FOUT: KAN CHANGELOG_PATCH_ENG.TXT NIET DOWNLOADEN OF LOCEREN!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Selecteer een optie:'
        "CompletionBanner" = '[OK] Vertaling van {0} succesvol voltooid - 100%'
        "DescLauncher" = 'Genereert en updatet de PSBBN Launcher voor Windows met ondersteuning voor alle 40 talen.'
        "DescMain" = 'Vertaalt de belangrijkste release-opmerkingen en changelog van het installatieprogramma (changelog_main_eng.txt).'
        "DescPatch" = 'Vertaalt patchgeschiedenis, fixes en kanaalupdate-opmerkingen (changelog_patch_eng.txt).'
        "DescReadme" = 'Vertaalt de officiële PSBBN README.md met behoud van markdown-opmaak en links.'
        "DescScript" = 'Vertaalt alle 458 UI-strings voor de Linux/WSL PSBBN installer-script (eng.txt).'
        "DescSystem" = 'Vertaalt alle PS2 PSBBN-systeembestanden (XML-dialogen, handleidingen, menu''s, NetFront/ATOK-help).'
        "DestFile" = 'Bestemming:'
        "DownloadingLatestGithub" = '[i] De nieuwste officiële versie downloaden van GitHub...'
        "DownloadingOfficial" = '[*] Officieel bestand downloaden van GitHub-repository...'
        "EnglishOption" = 'Engels (standaard)'
        "EngTxtEnsureFile" = 'Zorg ervoor dat het bestand ''eng.txt'' aanwezig is in de map ''input''.'
        "EngTxtErrorTitle" = '[!] FOUT: ENG.TXT-BESTAND NIET GEVONDEN!'
        "EngTxtNotFoundDownloading" = '[*] nl.txt niet gevonden. Bezig met downloaden uit officiële repository...'
        "EnsureConnected" = 'Zorg ervoor dat u verbonden bent met internet of plaats het bestand in de invoermap.'
        "ExitOption" = 'Afsluiten'
        "ExpectedPath" = 'Verwacht pad: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5-vertaalpakket uitpakken...'
        "FileNotFoundError" = '[ERROR] Bestand niet gevonden: {0}'
        "GeneratedFile" = '[OK] Gegenereerd bestand: {0}'
        "GenericEnsureInternetOrInput" = 'Zorg ervoor dat u verbonden bent met internet of dat het bestand in de map ''input'' staat.'
        "IndividualBlocks" = 'Individuele blokken: {0}'
        "IndividualBlocksNotice" = '[OK] Individuele blokken voor CosmicScale: {0}'
        "InputFileDeleted" = 'bewaren [OK] Bestand(en) verwijderd uit de invoermap.'
        "InputFileKept" = '[OK] Bestand(en) bewaard in invoermap.'
        "InvalidOption" = 'Ongeldige optie! Druk op Enter om het opnieuw te proberen...'
        "LangAppliedSuccess" = '[OK] UI-taal succesvol toegepast: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Automatische detectie van Windows-systeemtaal ingeschakeld.'
        "LauncherBaseNotFoundTitle" = '[!] FOUT: KAN BASE LAUNCHER SCRIPT NIET DOWNLOADEN OF LOCEREN!'
        "LauncherIntegrated" = '[OK] Geïntegreerde ondersteuning voor {0} taal/talen in PSBBN Launcher voor Windows!'
        "LauncherPrompt" = 'Kies een of meerdere talen (bijvoorbeeld 7 of 1, 2, 3 of 1-5 of A):'
        "LauncherTip1" = '- Voer 1 getal in om het bestand alleen met die taal te genereren.'
        "LauncherTipAll" = '- Voer ''A'' in om het volledige bestand met alle 40 talen te genereren.'
        "LauncherTipHeader" = '* Tip: Elke uitvoering genereert een schoon bestand dat alleen de gekozen taal/talen bevat.'
        "LauncherTipMulti" = '- Voer meerdere getallen in, gescheiden door een komma (bijvoorbeeld 1, 2, 3) om met die talen te genereren.'
        "LauncherTipRange" = '- Voer een bereik in (bijvoorbeeld 1-5) dat u met dat talenbereik wilt genereren.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Vorig scherm'
        "NavDeleteInput" = '[X] Bestand verwijderen uit invoermap'
        "NavEnter" = '[Enter] Hoofdmenu'
        "NavExit" = '[Esc] Afsluiten'
        "NavInstructions" = '[Enter] Hoofdmenu |  [B] Vorig scherm |  [Esc] Afsluiten'
        "NavKeepInput" = '[V] Bestand in invoermap'
        "OfficialDownloadSuccess" = '[OK] Officieel bestand succesvol gedownload ({0:N0} bytes).'
        "PkgCompressingGz" = '[*] Comprimeren naar ''bnupdate.tar.gz'' via .NET GZipStream...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' aanmaken en POSIX-uitvoeringsrechten instellen (+x)...'
        "PkgErrorTar" = '[!] Kan bnupdate.tar niet genereren.'
        "PkgGenTitle" = 'PSBBN INSTALLATIEPAKKETGENERATIE (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Texturen (.tm2 en .png) blijven in het Engels (vereist handmatig grafisch herontwerp).'
        "PkgNotice2" = '2. 100% van de systeemteksten (XML, ATOK HTML en scripts) zijn vertaald.'
        "PkgNotice3" = '3. Het bestand ''bnupdate.tar.gz'' is bedoeld om onmiddellijk te testen op PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TECHNISCHE MEDEDELING]:'
        "PkgPromptTar" = 'Wil je het bestand ''bnupdate.tar.gz'' genereren om te testen op PS2? (J/N) [Standaard: J]'
        "PkgSuccess" = '[+] Pakket succesvol gegenereerd (Linux 0755-rechten ingeschakeld): {0} ({1:N0} bytes)'
        "PosixPatchedCount" = '[+] Bestanden gepatcht met POSIX 0755-uitvoeringstoestemming (+x): {0}'
        "PressAnyKey" = 'Druk op een willekeurige toets om terug te keren naar het menu...'
        "ProgressAtokHelp" = 'ATOK Help vertalen'
        "ProgressUpdatingHtml" = 'HTML-bestanden bijwerken'
        "ProgressUpdatingXml" = 'XML-bestanden bijwerken'
        "ProgressXmlStrings" = 'XML-tekenreeksen vertalen'
        "PsbbnEnglishEnsure" = 'Zorg ervoor dat de map ''PSBBN_English'' aanwezig is in ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] FOUT: BASISDIRECTORY PSBBN_ENGLISH NIET GEVONDEN!'
        "ReadmeEnsure" = 'Zorg ervoor dat het bestand ''README.md'' zich in de map ''input'' bevindt.'
        "ReadmeNotFoundDownloading" = '[*] README.md niet gevonden. Bezig met downloaden uit officiële repository...'
        "ReadmeNotFoundTitle" = '[!] FOUT: README.MD-BESTAND NIET GEVONDEN!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} talen geselecteerd ({1})'
        "SelectUILangPrompt" = 'Selecteer een optie'
        "SelectUITitle" = 'UI-TAAL WIJZIGEN'
        "SessionStarted" = 'Sessie gestart op:'
        "SourceFile" = 'Bron:'
        "Step1Copying" = '[*] [1/3] Volledige structuur en binaire bestanden kopiëren...'
        "Step2TranslatingXml" = '[*] [2/3] {0} systeem-XML-bestanden vertalen...'
        "Step3TranslatingAtok" = '[*] [3/3] {0} ATOK HTML-helpbestanden vertalen...'
        "SuiteTitle" = 'PSBBN Meertalige vertaalsuite - V1 [By Emerson Teles]'
        "SystemTitle" = 'Systeem PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Opmerking: Texturen (.tm2 / .png) bevatten ingebedde afbeeldingen en   vereisen handmatige bewerking; ze worden niet gewijzigd door het   script. Systeemtekstbestanden (XML, HTML, txt) zijn 100% vertaald.'
        "Translating" = 'Vertalen'
        "UsingFallback" = '[!] Lokale fallback gebruiken: {0}'
        "ValidatingXml" = '[*] Validatie van de syntactische integriteit van 100% van de XML-bestanden...'
        "XmlSyntaxError" = '[!] Syntaxisfout in {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% van de XML-bestanden is succesvol gevalideerd (0 syntaxisfouten).'
    }
    "no" = @{
        "All40Success" = 'Alle 40 språk (Full flerspråklig)'
        "AllLanguages" = 'Oversett alle språk (1 - 40)'
        "BackMenu" = 'Tilbake til hovedmenyen'
        "CancelOption" = 'Tilbake'
        "CannotConnectGithub" = '[!] Kan ikke koble til GitHub: {0}'
        "ChangeLanguage" = 'Endre UI-språk'
        "ChangelogMainNotFoundTitle" = '[!] FEIL: KUNNE IKKE LASTE NED ELLER FINNE CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Hovedoversetter [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] FEIL: KUNNE IKKE LASTE NED ELLER FINNE CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Velg et alternativ:'
        "CompletionBanner" = '[OK] Oversettelse av {0} fullført - 100 %'
        "DescLauncher" = 'Genererer og oppdaterer PSBBN Launcher for Windows med støtte for alle 40 språk.'
        "DescMain" = 'Oversetter versjonsmerknadene for hovedinstallasjonen og endringsloggen (changelog_main_eng.txt).'
        "DescPatch" = 'Oversetter oppdateringshistorikk, rettelser og kanaloppdateringsnotater (changelog_patch_eng.txt).'
        "DescReadme" = 'Oversetter den offisielle PSBBN README.md som bevarer markdown-formatering og koblinger.'
        "DescScript" = 'Oversetter alle 458 UI-strenger for Linux/WSL PSBBN-installasjonsskriptet (eng.txt).'
        "DescSystem" = 'Oversetter alle PS2 PSBBN-systemfiler (XML-dialoger, guider, menyer, NetFront/ATOK-hjelp).'
        "DestFile" = 'Destinasjon:'
        "DownloadingLatestGithub" = '[i] Laster ned siste offisielle versjon fra GitHub...'
        "DownloadingOfficial" = '[*] Laster ned offisiell fil fra GitHub-depotet...'
        "EnglishOption" = 'Engelsk (standard)'
        "EngTxtEnsureFile" = 'Sørg for at ''eng.txt''-filen finnes i ''input''-mappen.'
        "EngTxtErrorTitle" = '[!] FEIL: ENG.TXT-FIL FINNER IKKE!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt ikke funnet. Laster ned fra offisielt depot...'
        "EnsureConnected" = 'Sørg for at du er koblet til Internett eller plasser filen i inndatakatalogen.'
        "ExitOption" = 'Gå'
        "ExpectedPath" = 'Forventet bane: {0}'
        "ExtractingPack" = '[*] Trekker ut PSBBN v3.5-oversettelsespakke...'
        "FileNotFoundError" = '[FEIL] Filen ble ikke funnet: {0}'
        "GeneratedFile" = '[OK] Generert fil: {0}'
        "GenericEnsureInternetOrInput" = 'Sørg for at du er koblet til Internett eller har filen i "input"-mappen.'
        "IndividualBlocks" = 'Individuelle blokker: {0}'
        "IndividualBlocksNotice" = '[OK] Individuelle blokker for CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Fil(er) slettet fra inndatamappen.'
        "InputFileKept" = '[OK] Fil(er) lagret i inndatamappen.'
        "InvalidOption" = 'Ugyldig alternativ! Trykk på Enter for å prøve igjen...'
        "LangAppliedSuccess" = '[OK] Brukergrensesnittspråk ble tatt i bruk: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Automatisk gjenkjenning av Windows-systemspråk aktivert.'
        "LauncherBaseNotFoundTitle" = '[!] FEIL: KUNNE IKKE LASTE NED ELLER FINNE BASE LAUNCHER SCRIPT!'
        "LauncherIntegrated" = '[OK] Integrert støtte for {0} språk(er) i PSBBN Launcher for Windows!'
        "LauncherPrompt" = 'Velg ett eller flere språk (f.eks. 7 eller 1, 2, 3 eller 1-5 eller A):'
        "LauncherTip1" = '- Skriv inn 1 tall for å generere filen med kun det språket.'
        "LauncherTipAll" = '- Skriv inn ''A'' for å generere den komplette filen med alle 40 språk.'
        "LauncherTipHeader" = '* Tips: Hver kjøring genererer en ren fil som kun inneholder det eller de valgte språkene.'
        "LauncherTipMulti" = '- Skriv inn flere tall atskilt med komma (f.eks. 1, 2, 3) for å generere med disse språkene.'
        "LauncherTipRange" = '- Angi en rekkevidde (f.eks. 1–5) for å generere med det utvalget av språk.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Forrige skjerm'
        "NavDeleteInput" = '[X] Slett fil fra inndatamappen'
        "NavEnter" = '[Enter] Hovedmeny'
        "NavExit" = '[Esc] Avslutt'
        "NavInstructions" = '[Enter] Hovedmeny |  [B] Forrige skjerm |  [Esc] Avslutt'
        "NavKeepInput" = '[V] Hold filen i inndatamappen'
        "OfficialDownloadSuccess" = '[OK] Offisiell fil ble lastet ned ({0:N0} byte).'
        "PkgCompressingGz" = '[*] Komprimerer til ''bnupdate.tar.gz'' via .NET GZipStream...'
        "PkgCreatingTar" = '[*] Oppretter ''bnupdate.tar'' og setter POSIX-utførelsestillatelser (+x)...'
        "PkgErrorTar" = '[!] Kunne ikke generere bnupdate.tar.'
        "PkgGenTitle" = 'PSBBN INSTALLASJONSPAKKE GENERERING (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Teksturer (.tm2 og .png) forblir på engelsk (krever manuell grafisk redesign).'
        "PkgNotice2" = '2. 100 % av systemtekstene (XML, ATOK HTML og skript) er oversatt.'
        "PkgNotice3" = '3. ''bnupdate.tar.gz''-filen er ment for umiddelbar testing på PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TEKNISK MERKNAD]:'
        "PkgPromptTar" = 'Vil du generere ''bnupdate.tar.gz''-filen for å teste på PS2? (J/N) [Standard: Y]'
        "PkgSuccess" = '[+] Pakken ble generert (Linux 0755-tillatelser aktivert): {0} ({1:N0} byte)'
        "PosixPatchedCount" = '[+] Filer korrigert med POSIX 0755-utførelsestillatelse (+x): {0}'
        "PressAnyKey" = 'Trykk en tast for å gå tilbake til menyen...'
        "ProgressAtokHelp" = 'Oversette ATOK Hjelp'
        "ProgressUpdatingHtml" = 'Oppdatering av HTML-filer'
        "ProgressUpdatingXml" = 'Oppdatering av XML-filer'
        "ProgressXmlStrings" = 'Oversette XML-strenger'
        "PsbbnEnglishEnsure" = 'Vennligst sørg for at ''PSBBN_English''-mappen er til stede i ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] FEIL: BASE DIRECTORY PSBBN_ENGLISH IKKE FUNNET!'
        "ReadmeEnsure" = 'Sørg for at ''README.md''-filen er i ''input''-mappen.'
        "ReadmeNotFoundDownloading" = '[*] README.md ble ikke funnet. Laster ned fra offisielt depot...'
        "ReadmeNotFoundTitle" = '[!] FEIL: README.MD-FILEN FINNER IKKE!'
        "ReadmeTitle" = 'PSBBN Readme-oversetter [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN-skriptoversetter [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} språk valgt ({1})'
        "SelectUILangPrompt" = 'Velg et alternativ'
        "SelectUITitle" = 'ENDRE UI-SPRÅK'
        "SessionStarted" = 'Økten startet på:'
        "SourceFile" = 'Kilde:'
        "Step1Copying" = '[*] [1/3] Kopierer fullstendig struktur og binærfiler...'
        "Step2TranslatingXml" = '[*] [2/3] Oversetter {0} system XML-filer...'
        "Step3TranslatingAtok" = '[*] [3/3] Oversetter {0} ATOK HTML hjelpefiler...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Merk: Teksturer (.tm2 / .png) inneholder innebygd grafikk og krever   manuell redigering; they are not altered by the script. System text   files (XML, HTML, txt) are 100% translated.'
        "Translating" = 'Oversettelse'
        "UsingFallback" = '[!] Bruker lokal reserve: {0}'
        "ValidatingXml" = '[*] Validerer syntaktisk integritet for 100 % av XML-filer...'
        "XmlSyntaxError" = '[!] Syntaksfeil i {0}: {1}'
        "XmlValidationSuccess" = '[+] 100 % av XML-filene ble validert (0 syntaksfeil).'
    }
    "pl" = @{
        "All40Success" = 'Wszystkie 40 języków (w pełni wielojęzyczne)'
        "AllLanguages" = 'Przetłumacz wszystkie języki (1–40)'
        "BackMenu" = 'Powrót do menu głównego'
        "CancelOption" = 'Wróć'
        "CannotConnectGithub" = '[!] Nie można połączyć się z GitHubem: {0}'
        "ChangeLanguage" = 'Zmień język interfejsu użytkownika'
        "ChangelogMainNotFoundTitle" = '[!] BŁĄD: NIE MOŻNA POBRAĆ ANI ZLOKALIZOWAĆ CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Główny tłumacz dziennika zmian PSBBN [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] BŁĄD: NIE MOŻNA POBRAĆ ANI ZLOKALIZOWAĆ CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Tłumacz poprawek dziennika zmian PSBBN [By Emerson Teles]'
        "ChooseOption" = 'Wybierz opcję:'
        "CompletionBanner" = '[OK] Tłumaczenie {0} zakończone pomyślnie - 100%'
        "DescLauncher" = 'Generuje i aktualizuje program uruchamiający PSBBN dla systemu Windows z obsługą wszystkich 40 języków.'
        "DescMain" = 'Tłumaczy główne informacje o wersji instalatora i dziennik zmian (changelog_main_eng.txt).'
        "DescPatch" = 'Tłumaczy historię poprawek, poprawki i informacje o aktualizacjach kanałów (changelog_patch_eng.txt).'
        "DescReadme" = 'Tłumaczy oficjalny plik README PSBBN README, zachowując formatowanie i łącza do przecen.'
        "DescScript" = 'Tłumaczy wszystkie 458 ciągów interfejsu użytkownika dla Skrypt instalatora PSBBN Linux/WSL (eng.txt).'
        "DescSystem" = 'Tłumaczy wszystkie pliki systemu PSBBN PS2 (okna dialogowe XML, przewodniki, menu, pomoc NetFront/ATOK).'
        "DestFile" = 'Miejsce docelowe:'
        "DownloadingLatestGithub" = '[i] Pobieranie najnowszej oficjalnej wersji z GitHub...'
        "DownloadingOfficial" = '[*] Pobieranie oficjalnego pliku z repozytorium GitHub...'
        "EnglishOption" = 'Angielski (domyślny)'
        "EngTxtEnsureFile" = 'Upewnij się, że plik „eng.txt” znajduje się w folderze „input”.'
        "EngTxtErrorTitle" = '[!] BŁĄD: NIE ZNALEZIONO PLIKU ENG.TXT!'
        "EngTxtNotFoundDownloading" = '[*] Nie znaleziono pliku eng.txt. Pobieranie z oficjalnego repozytorium...'
        "EnsureConnected" = 'Upewnij się, że masz połączenie z Internetem lub umieść plik w katalogu wejściowym.'
        "ExitOption" = 'Wyjdź'
        "ExpectedPath" = 'Oczekiwana ścieżka: _{0}'
        "ExtractingPack" = '[*] Wyodrębnianie pakietu tłumaczeń PSBBN v3.5...'
        "FileNotFoundError" = '[BŁĄD] Nie znaleziono pliku: _{0}'
        "GeneratedFile" = '[OK] Wygenerowany plik: _{0}'
        "GenericEnsureInternetOrInput" = 'Upewnij się, że masz połączenie z Internetem lub plik znajduje się w folderze wejściowym.'
        "IndividualBlocks" = 'Poszczególne bloki: _{0}'
        "IndividualBlocksNotice" = '[OK] Poszczególne bloki dla CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Plik(i) usunięty z folderu wejściowego.'
        "InputFileKept" = '[OK] Pliki przechowywane w folderze wejściowym.'
        "InvalidOption" = 'Nieprawidłowa opcja! Naciśnij Enter, aby spróbować ponownie...'
        "LangAppliedSuccess" = '[OK] Język interfejsu został pomyślnie zastosowany: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Włączono automatyczne wykrywanie języka systemu Windows.'
        "LauncherBaseNotFoundTitle" = '[!] BŁĄD: NIE MOŻNA POBRAĆ ANI ZLOKALIZOWAĆ SKRYPT PODSTAWOWEGO URUCHOMIENIA!'
        "LauncherIntegrated" = '[OK] Zintegrowana obsługa {0} języków w programie PSBBN Launcher dla Windows!'
        "LauncherPrompt" = 'Wybierz jeden lub więcej języków (np. 7 lub 1, 2, 3 lub 1-5 lub A):'
        "LauncherTip1" = '- Wprowadź 1 liczbę, aby wygenerować plik tylko z tym językiem.'
        "LauncherTipAll" = '- Wpisz „A”, aby wygenerować kompletny plik ze wszystkimi 40 językami.'
        "LauncherTipHeader" = '* Wskazówka: każde wykonanie generuje czysty plik zawierający tylko wybrane języki.'
        "LauncherTipMulti" = '- Wprowadź wiele liczb oddzielonych przecinkami (np. 1, 2, 3), które chcesz wygenerować w tych językach.'
        "LauncherTipRange" = '- Wprowadź zakres (np. 1-5), który chcesz wygenerować dla tego zakresu języków.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Poprzedni ekran'
        "NavDeleteInput" = '[X] Usuń plik z folderu wejściowego'
        "NavEnter" = '[Enter] Menu główne'
        "NavExit" = '[Esc] Wyjdź'
        "NavInstructions" = '[Enter] Menu główne |  [B] Poprzedni ekran |  [Esc] Wyjdź'
        "NavKeepInput" = '[V] Zachowaj plik w folderze wejściowym'
        "OfficialDownloadSuccess" = '[OK] Oficjalny plik pobrany pomyślnie ({0:N0} bajtów).'
        "PkgCompressingGz" = '[*] Kompresja do „bnupdate.tar.gz” poprzez .NET GZipStream...'
        "PkgCreatingTar" = '[*] Tworzenie pliku „bnupdate.tar” i ustawianie uprawnień do wykonywania POSIX (+x)...'
        "PkgErrorTar" = '[!] Nie można wygenerować pliku bnupdate.tar.'
        "PkgGenTitle" = 'GENEROWANIE PAKIETU INSTALACYJNEGO PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Tekstury (.tm2 i .png) pozostają w języku angielskim (wymagają ręcznego przeprojektowania grafiki).'
        "PkgNotice2" = '2. Przetłumaczonych jest 100% tekstów systemowych (XML, ATOK HTML i skrypty).'
        "PkgNotice3" = '3. Plik „bnupdate.tar.gz” przeznaczony jest do natychmiastowego przetestowania na PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[UWAGA TECHNICZNA]:'
        "PkgPromptTar" = 'Czy chcesz wygenerować plik „bnupdate.tar.gz” do przetestowania na PS2? (T/N) [Domyślnie: T]'
        "PkgSuccess" = '[+] Pakiet wygenerowany pomyślnie (włączono uprawnienia Linux 0755): {0} ({1:N0} bajtów)'
        "PosixPatchedCount" = '[+] Pliki poprawione z uprawnieniami do wykonywania POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Naciśnij dowolny klawisz, aby powrócić do menu...'
        "ProgressAtokHelp" = 'Tłumaczenie pomocy ATOK'
        "ProgressUpdatingHtml" = 'Aktualizacja plików HTML'
        "ProgressUpdatingXml" = 'Aktualizacja plików XML'
        "ProgressXmlStrings" = 'Tłumaczenie ciągów XML'
        "PsbbnEnglishEnsure" = 'Upewnij się, że folder „PSBBN_English” znajduje się w „input”.'
        "PsbbnEnglishNotFoundTitle" = '[!] BŁĄD: NIE ZNALEZIONO KATALOGU PODSTAWOWEGO PSBBN_ENGLISH!'
        "ReadmeEnsure" = 'Upewnij się, że plik „README.md” znajduje się w folderze „input”.'
        "ReadmeNotFoundDownloading" = '[*] Nie znaleziono pliku README.md. Pobieranie z oficjalnego repozytorium...'
        "ReadmeNotFoundTitle" = '[!] BŁĄD: NIE ZNALEZIONO PLIKU README.MD!'
        "ReadmeTitle" = 'Translator plików Readme PSBBN [By Emerson Teles]'
        "ScriptTitle" = 'Tłumacz skryptów PSBBN [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} wybrane języki ({1})'
        "SelectUILangPrompt" = 'Wybierz opcję'
        "SelectUITitle" = 'ZMIEŃ JĘZYK INTERFEJSU UŻYTKOWNIKA'
        "SessionStarted" = 'Sesja rozpoczęła się:'
        "SourceFile" = 'Źródło:'
        "Step1Copying" = '[*] [1/3] Kopiowanie całej struktury i plików binarnych...'
        "Step2TranslatingXml" = '[*] [2/3] Tłumaczenie _{0} systemowych plików XML...'
        "Step3TranslatingAtok" = '[*] [3/3] Tłumaczenie {0} plików pomocy ATOK HTML...'
        "SuiteTitle" = 'Wielojęzyczny pakiet tłumaczeń PSBBN — wersja 1 [By Emerson Teles]'
        "SystemTitle" = 'Tłumacz systemowy PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Uwaga: Tekstury (.tm2 / .png) wymagają ręcznej edycji graficznej (poza skryptem). Pakiet tłumaczy 100% tekstów plików systemowych (XML, HTML, menu i skrypty).'
        "Translating" = 'Tłumaczenie'
        "UsingFallback" = '[!] Korzystanie z lokalnego rozwiązania zastępczego: {0}'
        "ValidatingXml" = '[*] Sprawdzanie integralności składniowej 100% plików XML...'
        "XmlSyntaxError" = '[!] Błąd składni w _{0}: {1}'
        "XmlValidationSuccess" = '[+] 100% plików XML zostało pomyślnie zweryfikowanych (0 błędów składniowych).'
    }
    "pt" = @{
        "All40Success" = 'Todos os 40 Idiomas (Multilíngue Completo)'
        "AllLanguages" = 'Traduzir Todos os Idiomas (1 - 40)'
        "BackMenu" = 'Voltar ao Menu Principal'
        "CancelOption" = 'Voltar'
        "CannotConnectGithub" = '[!] Não foi possível conectar ao GitHub: {0}'
        "ChangeLanguage" = 'Alterar Idioma da Interface'
        "ChangelogMainNotFoundTitle" = '[!] ERRO: NÃO FOI POSSÍVEL BAIXAR OU LOCALIZAR CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ERRO: NÃO FOI POSSÍVEL BAIXAR OU LOCALIZAR CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Escolha uma opção:'
        "CompletionBanner" = '[OK] Tradução do {0} finalizada com sucesso - 100%'
        "DescLauncher" = 'Gera e atualiza o PSBBN Launcher para Windows com suporte para todos os 40 idiomas.'
        "DescMain" = 'Traduz o changelog oficial das versões principais do PSBBN (changelog_main_eng.txt).'
        "DescPatch" = 'Traduz o histórico de patches e atualizações de canais (changelog_patch_eng.txt).'
        "DescReadme" = 'Traduz o README.md oficial do PSBBN preservando links e formatação Markdown.'
        "DescScript" = 'Traduz as 458 linhas de interface do script instalador Linux/WSL (eng.txt).'
        "DescSystem" = 'Traduz todos os arquivos de sistema do PSBBN (diálogos XML, guias, menus, ajuda ATOK).'
        "DestFile" = 'Destino:'
        "DownloadingLatestGithub" = '[i] Baixando versao oficial mais recente do GitHub...'
        "DownloadingOfficial" = '[*] Baixando arquivo oficial do repositório GitHub...'
        "EnglishOption" = 'Inglês (padrão)'
        "EngTxtEnsureFile" = 'Por favor, certifique-se de que o arquivo ''eng.txt'' está presente na pasta ''input''.'
        "EngTxtErrorTitle" = '[!] ERRO: ARQUIVO ENG.TXT NÃO ENCONTRADO!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt não encontrado. Baixando do repositório oficial...'
        "EnsureConnected" = 'Certifique-se de estar conectado à Internet ou coloque o arquivo na pasta input.'
        "ExitOption" = 'Sair'
        "ExpectedPath" = 'Caminho esperado: {0}'
        "ExtractingPack" = '[*] Extraindo pacote de tradução PSBBN v3.5...'
        "FileNotFoundError" = '[ERRO] Arquivo não encontrado: {0}'
        "GeneratedFile" = '[OK] Arquivo gerado: {0}'
        "GenericEnsureInternetOrInput" = 'Certifique-se de estar conectado à internet ou ter o arquivo na pasta ''input''.'
        "IndividualBlocks" = 'Blocos Individuais: {0}'
        "IndividualBlocksNotice" = '[OK] Blocos individuais para o CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Arquivo(s) da pasta input excluido(s) com sucesso.'
        "InputFileKept" = '[OK] Arquivo(s) da pasta input mantido(s).'
        "InvalidOption" = 'Opção inválida! Pressione Enter para continuar...'
        "LangAppliedSuccess" = '[OK] Idioma aplicado na interface com sucesso: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Detecção automática de idioma do sistema Windows ativada.'
        "LauncherBaseNotFoundTitle" = '[!] ERRO: NÃO FOI POSSÍVEL BAIXAR OU LOCALIZAR O SCRIPT BASE DO LAUNCHER!'
        "LauncherIntegrated" = '[OK] Suporte integrado a {0} idioma(s) no PSBBN Launcher for Windows!'
        "LauncherPrompt" = 'Escolha um ou mais idiomas (ex: 7 ou 1, 2, 3 ou 1-5 ou A)'
        "LauncherTip1" = '- Digite 1 número para gerar o arquivo apenas com aquele idioma.'
        "LauncherTipAll" = '- Digite ''A'' para gerar o arquivo completo com todos os 40 idiomas.'
        "LauncherTipHeader" = '* Dica: Cada execução gera um arquivo limpo contendo apenas o(s) idioma(s) escolhido(s).'
        "LauncherTipMulti" = '- Digite vários números por vírgula (ex: 1, 2, 3) para gerar com esses idiomas.'
        "LauncherTipRange" = '- Digite um intervalo (ex: 1-5) para gerar com essa faixa de idiomas.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Voltar para a tela anterior'
        "NavDeleteInput" = '[X] Excluir arquivo da pasta input'
        "NavEnter" = '[Enter] Menu Principal'
        "NavExit" = '[Esc] Fechar / Sair'
        "NavInstructions" = '[Enter] Menu Principal  |  [B] Voltar para a tela anterior  |  [Esc] Fechar / Sair'
        "NavKeepInput" = '[V] Manter arquivo da pasta input'
        "OfficialDownloadSuccess" = '[OK] Arquivo oficial baixado com sucesso ({0:N0} bytes).'
        "PkgCompressingGz" = '[*] Compactando para ''bnupdate.tar.gz'' via .NET GZipStream...'
        "PkgCreatingTar" = '[*] Criando ''bnupdate.tar'' e ajustando permissões de execução POSIX (+x)...'
        "PkgErrorTar" = '[!] Não foi possível gerar bnupdate.tar.'
        "PkgGenTitle" = 'GERAÇÃO DO PACOTE DE INSTALAÇÃO PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. As texturas (.tm2 e .png) permanecem em inglês (requerem redesenho gráfico manual).'
        "PkgNotice2" = '2. 100% dos textos de sistema (XML, HTML ATOK e scripts) estão traduzidos.'
        "PkgNotice3" = '3. O arquivo ''bnupdate.tar.gz'' é destinado para testes imediatos no PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[AVISO TÉCNICO]:'
        "PkgPromptTar" = 'Deseja gerar o arquivo ''bnupdate.tar.gz'' para testar no PS2? (S/N) [Padrão: S]'
        "PkgSuccess" = '[+] Pacote gerado com sucesso (permissões Linux 0755 ativadas): {0} ({1:N0} bytes)'
        "PosixPatchedCount" = '[+] Arquivos ajustados com permissão de execução POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Pressione qualquer tecla para retornar ao menu...'
        "ProgressAtokHelp" = 'Traduzindo ATOK Help'
        "ProgressUpdatingHtml" = 'Atualizando arquivos HTML'
        "ProgressUpdatingXml" = 'Atualizando arquivos XML'
        "ProgressXmlStrings" = 'Traduzindo strings XML'
        "PsbbnEnglishEnsure" = 'Por favor, certifique-se de que a pasta ''PSBBN_English'' está presente dentro de ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] ERRO: DIRETÓRIO BASE PSBBN_ENGLISH NÃO ENCONTRADO!'
        "ReadmeEnsure" = 'Por favor, certifique-se de que o arquivo ''README.md'' está na pasta ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md não encontrado. Baixando do repositório oficial...'
        "ReadmeNotFoundTitle" = '[!] ERRO: ARQUIVO README.MD NÃO ENCONTRADO!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} idiomas selecionados ({1})'
        "SelectUILangPrompt" = 'Escolha o idioma da interface'
        "SelectUITitle" = 'SELECIONAR IDIOMA DA INTERFACE'
        "SessionStarted" = 'Sessão iniciada em:'
        "SourceFile" = 'Fonte:'
        "Step1Copying" = '[*] [1/3] Copiando estrutura completa e binários...'
        "Step2TranslatingXml" = '[*] [2/3] Traduzindo {0} arquivos XML de sistema...'
        "Step3TranslatingAtok" = '[*] [3/3] Traduzindo {0} arquivos HTML de ajuda do ATOK...'
        "SuiteTitle" = 'PSBBN Suíte Multilíngue de Tradução - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Aviso: Texturas (.tm2 / .png) requerem edição gráfica manual e não via script. A suíte traduz 100% dos textos dos arquivos de sistema (XML, HTML, menus e scripts).'
        "Translating" = 'Traduzindo'
        "UsingFallback" = '[!] Usando cópia local de fallback: {0}'
        "ValidatingXml" = '[*] Validando integridade sintática de 100% dos arquivos XML...'
        "XmlSyntaxError" = '[!] Erro sintático em {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% dos arquivos XML validados com sucesso (0 erros de sintaxe).'
    }
    "pt-pt" = @{
        "All40Success" = 'Todos os 40 Idiomas (Multilíngue Completo)'
        "AllLanguages" = 'Traduzir Todos os Idiomas (1 - 40)'
        "BackMenu" = 'Voltar ao Menu Principal'
        "CancelOption" = 'Voltar'
        "CannotConnectGithub" = '[!] Não foi possível conectar ao GitHub: {0}'
        "ChangeLanguage" = 'Alterar Idioma da Interface'
        "ChangelogMainNotFoundTitle" = '[!] ERRO: NÃO FOI POSSÍVEL TRANSFERIR OU LOCALIZAR CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ERRO: NÃO FOI POSSÍVEL TRANSFERIR OU LOCALIZAR CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Escolha uma opção:'
        "CompletionBanner" = '[OK] Tradução do {0} concluída com sucesso - 100%'
        "DescLauncher" = 'Gera e atualiza o iniciador PSBBN Launcher for Windows com suporte aos 40 idiomas.'
        "DescMain" = 'Traduz o registo de alterações oficial das versões principais do PSBBN (changelog_main_eng.txt).'
        "DescPatch" = 'Traduz o histórico de correções e atualizações de canais (changelog_patch_eng.txt).'
        "DescReadme" = 'Traduz o README.md oficial do PSBBN preservando ligações e formatação Markdown.'
        "DescScript" = 'Traduz as 458 linhas de interface do script instalador Linux/WSL (eng.txt).'
        "DescSystem" = 'Traduz todos os ficheiros de sistema do PSBBN (diálogos XML, guias, menus, ajuda ATOK).'
        "DestFile" = 'Destino:'
        "DownloadingLatestGithub" = '[i] A transferir a versao oficial mais recente do GitHub...'
        "DownloadingOfficial" = '[*] Baixando arquivo oficial do repositório GitHub...'
        "EnglishOption" = 'Inglês (padrão)'
        "EngTxtEnsureFile" = 'Por favor, certifique-se de que o ficheiro ''eng.txt'' está presente na pasta ''input''.'
        "EngTxtErrorTitle" = '[!] ERRO: FICHEIRO ENG.TXT NÃO ENCONTRADO!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt não encontrado. A transferir do repositório oficial...'
        "EnsureConnected" = 'Certifique-se de estar conectado à Internet ou coloque o arquivo na pasta input.'
        "ExitOption" = 'Sair'
        "ExpectedPath" = 'Caminho esperado: {0}'
        "ExtractingPack" = '[*] A extrair o pacote de tradução PSBBN v3.5...'
        "FileNotFoundError" = '[ERRO] Arquivo não encontrado: {0}'
        "GeneratedFile" = '[OK] Arquivo gerado: {0}'
        "GenericEnsureInternetOrInput" = 'Certifique-se de estar ligado à Internet ou de ter o ficheiro na pasta ''input''.'
        "IndividualBlocks" = 'Blocos Individuais: {0}'
        "IndividualBlocksNotice" = '[OK] Blocos individuais para o CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Ficheiro(s) da pasta input eliminado(s) com sucesso.'
        "InputFileKept" = '[OK] Ficheiro(s) da pasta input mantido(s).'
        "InvalidOption" = 'Opção inválida! Prima Enter para continuar...'
        "LangAppliedSuccess" = '[OK] Idioma aplicado na interface com sucesso: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Detecção automática de idioma do sistema Windows ativada.'
        "LauncherBaseNotFoundTitle" = '[!] ERRO: NÃO FOI POSSÍVEL TRANSFERIR OU LOCALIZAR O SCRIPT BASE DO LAUNCHER!'
        "LauncherIntegrated" = '[OK] Suporte integrado a {0} idioma(s) no PSBBN Launcher for Windows!'
        "LauncherPrompt" = 'Escolha um ou mais idiomas (ex: 7 ou 1, 2, 3 ou 1-5 ou A)'
        "LauncherTip1" = '- Digite 1 número para gerar o arquivo apenas com aquele idioma.'
        "LauncherTipAll" = '- Digite ''A'' para gerar o arquivo completo com todos os 40 idiomas.'
        "LauncherTipHeader" = '* Dica: Cada execução gera um arquivo limpo contendo apenas o(s) idioma(s) escolhido(s).'
        "LauncherTipMulti" = '- Digite vários números por vírgula (ex: 1, 2, 3) para gerar com esses idiomas.'
        "LauncherTipRange" = '- Digite um intervalo (ex: 1-5) para gerar com essa faixa de idiomas.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Voltar para o ecra anterior'
        "NavDeleteInput" = '[X] Eliminar ficheiro da pasta input'
        "NavEnter" = '[Enter] Menu Principal'
        "NavExit" = '[Esc] Fechar / Sair'
        "NavInstructions" = '[Enter] Menu Principal  |  [B] Voltar ao ecrã anterior  |  [Esc] Fechar / Sair'
        "NavKeepInput" = '[V] Manter ficheiro na pasta input'
        "OfficialDownloadSuccess" = '[OK] Arquivo oficial baixado com sucesso ({0:N0} bytes).'
        "PkgCompressingGz" = '[*] A compactar para ''bnupdate.tar.gz'' via .NET GZipStream...'
        "PkgCreatingTar" = '[*] A criar ''bnupdate.tar'' e a ajustar permissões de execução POSIX (+x)...'
        "PkgErrorTar" = '[!] Não foi possível gerar bnupdate.tar.'
        "PkgGenTitle" = 'GERAÇÃO DO PACOTE DE INSTALAÇÃO PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. As texturas (.tm2 e .png) permanecem em inglês (requerem redesenho gráfico manual).'
        "PkgNotice2" = '2. 100% dos textos do sistema (XML, HTML ATOK e scripts) estão traduzidos.'
        "PkgNotice3" = '3. O ficheiro ''bnupdate.tar.gz'' é destinado a testes imediatos na PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[AVISO TÉCNICO]:'
        "PkgPromptTar" = 'Deseja gerar o ficheiro ''bnupdate.tar.gz'' para testar na PS2? (S/N) [Predefinição: S]'
        "PkgSuccess" = '[+] Pacote gerado com sucesso (permissões Linux 0755 ativadas): {0} ({1:N0} bytes)'
        "PosixPatchedCount" = '[+] Ficheiros ajustados com permissão de execução POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Pressione qualquer tecla para retornar ao menu...'
        "ProgressAtokHelp" = 'A traduzir ATOK Help'
        "ProgressUpdatingHtml" = 'A atualizar ficheiros HTML'
        "ProgressUpdatingXml" = 'A atualizar ficheiros XML'
        "ProgressXmlStrings" = 'A traduzir cadeias XML'
        "PsbbnEnglishEnsure" = 'Por favor, certifique-se de que a pasta ''PSBBN_English'' está presente dentro de ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] ERRO: DIRETÓRIO BASE PSBBN_ENGLISH NÃO ENCONTRADO!'
        "ReadmeEnsure" = 'Por favor, certifique-se de que o ficheiro ''README.md'' está na pasta ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md não encontrado. A transferir do repositório oficial...'
        "ReadmeNotFoundTitle" = '[!] ERRO: FICHEIRO README.MD NÃO ENCONTRADO!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} idiomas selecionados ({1})'
        "SelectUILangPrompt" = 'Escolha o idioma da interface'
        "SelectUITitle" = 'SELECIONAR IDIOMA DA INTERFACE'
        "SessionStarted" = 'Sessão iniciada em:'
        "SourceFile" = 'Origem:'
        "Step1Copying" = '[*] [1/3] A copiar a estrutura completa e os binários...'
        "Step2TranslatingXml" = '[*] [2/3] A traduzir {0} ficheiros XML do sistema...'
        "Step3TranslatingAtok" = '[*] [3/3] A traduzir {0} ficheiros HTML de ajuda do ATOK...'
        "SuiteTitle" = 'PSBBN Suíte Multilíngue de Tradução - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Aviso: Ficheiros de textura (.tm2 / .png) requerem edição gráfica manual (fora de script). A suíte traduz 100% dos textos dos ficheiros de sistema (XML, HTML, menus e scripts).'
        "Translating" = 'A traduzir'
        "UsingFallback" = '[!] Usando cópia local de fallback: {0}'
        "ValidatingXml" = '[*] A validar integridade sintática de 100% dos ficheiros XML...'
        "XmlSyntaxError" = '[!] Erro sintático em {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% dos ficheiros XML validados com sucesso (0 erros de sintaxe).'
    }
    "ro" = @{
        "All40Success" = 'Toate cele 40 de limbi (multilingve)'
        "AllLanguages" = 'Traduceți toate limbile (1 - 40)'
        "BackMenu" = 'Înapoi la meniul principal'
        "CancelOption" = 'Înapoi'
        "CannotConnectGithub" = '[!] Nu se poate conecta la GitHub: {0}'
        "ChangeLanguage" = 'Schimbați limba UI'
        "ChangelogMainNotFoundTitle" = '[!] EROARE: NU S-A POAT DESCARCARE SAU LOCALIZA CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Traducător principal PSBBN Changelog [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] EROARE: NU S-A POAT DESCARCARE SAU LOCARE CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Selectați o opțiune:'
        "CompletionBanner" = '[OK] Traducerea lui {0} s-a terminat cu succes - 100%'
        "DescLauncher" = 'Generează și actualizează PSBBN Launcher pentru Windows cu suport pentru toate cele 40 de limbi.'
        "DescMain" = 'Traduce notele de lansare a programului de instalare principal și jurnalul de modificări (changelog_main_eng.txt).'
        "DescPatch" = 'Traduce istoricul corecțiilor, corecțiile și notele de actualizare a canalului (changelog_patch_eng.txt).'
        "DescReadme" = 'Traduce versiunea oficială PSBBN README.md păstrând formatarea și linkurile de reducere.'
        "DescScript" = 'Traduce toate cele 458 de șiruri UI pentru scriptul de instalare Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'Traduce toate fișierele de sistem PS2 PSBBN (dialoguri XML, ghiduri, meniuri, ajutor NetFront/ATOK).'
        "DestFile" = 'Destinaţie:'
        "DownloadingLatestGithub" = '[i] Se descarcă cea mai recentă versiune oficială de pe GitHub...'
        "DownloadingOfficial" = '[*] Se descarcă fișierul oficial din depozitul GitHub...'
        "EnglishOption" = 'Engleză (implicit)'
        "EngTxtEnsureFile" = 'Asigurați-vă că fișierul „eng.txt” este prezent în folderul „input”.'
        "EngTxtErrorTitle" = '[!] EROARE: FIȘIERUL ENG.TXT NU GĂSIT!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt nu a fost găsit. Se descarcă din depozitul oficial...'
        "EnsureConnected" = 'Asigurați-vă că sunteți conectat la Internet sau plasați fișierul în directorul de intrare.'
        "ExitOption" = 'Ieșire'
        "ExpectedPath" = 'Calea așteptată: {0}'
        "ExtractingPack" = '[*] Se extrage pachetul de traducere PSBBN v3.5...'
        "FileNotFoundError" = '[EROARE] Fișierul nu a fost găsit: {0}'
        "GeneratedFile" = '[OK] Fișier generat: {0}'
        "GenericEnsureInternetOrInput" = 'Asigurați-vă că sunteți conectat la Internet sau aveți fișierul în folderul „input”.'
        "IndividualBlocks" = 'Blocuri individuale: {0}'
        "IndividualBlocksNotice" = '[OK] Blocuri individuale pentru CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Fișier(e) șterse(e) din folderul de intrare.'
        "InputFileKept" = '[OK] Fișier(e) păstrat(e) în folderul de intrare.'
        "InvalidOption" = 'Opțiune nevalidă! Apăsați Enter pentru a încerca din nou...'
        "LangAppliedSuccess" = '[OK] Limba interfeței a fost aplicată cu succes: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Detectarea automată a limbii sistemului Windows este activată.'
        "LauncherBaseNotFoundTitle" = '[!] EROARE: NU S-A POAT DESCARCARE SAU LOCARE SCRIPTUL BASE LUNCHER!'
        "LauncherIntegrated" = '[OK] Suport integrat pentru limbile {0} în PSBBN Launcher pentru Windows!'
        "LauncherPrompt" = 'Alegeți una sau mai multe limbi (de exemplu, 7 sau 1, 2, 3 sau 1-5 sau A):'
        "LauncherTip1" = '- Introduceți 1 număr pentru a genera fișierul doar cu limba respectivă.'
        "LauncherTipAll" = '- Introduceți „A” pentru a genera fișierul complet cu toate cele 40 de limbi.'
        "LauncherTipHeader" = '* Sfat: Fiecare execuție generează un fișier curat care conține doar limbile alese.'
        "LauncherTipMulti" = '- Introduceți mai multe numere separate prin virgulă (de exemplu, 1, 2, 3) pentru a le genera cu acele limbi.'
        "LauncherTipRange" = '- Introduceți un interval (de exemplu, 1-5) pentru a genera cu acel interval de limbi.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Ecranul precedent'
        "NavDeleteInput" = '[X] Ștergeți fișierul din folderul de intrare'
        "NavEnter" = '[Intra] Meniul principal'
        "NavExit" = '[Esc] Ieșire'
        "NavInstructions" = '[Enter] Meniu principal |  [B] Ecranul precedent |  [Esc] Ieșire'
        "NavKeepInput" = '[V] Păstrați fișierul în folderul de intrare'
        "OfficialDownloadSuccess" = '[OK] Fișierul oficial a fost descărcat cu succes ({0:N0} octeți).'
        "PkgCompressingGz" = '[*] Se comprimă în „bnupdate.tar.gz” prin .NET GZipStream...'
        "PkgCreatingTar" = '[*] Se creează „bnupdate.tar” și se stabilesc permisiunile de execuție POSIX (+x)...'
        "PkgErrorTar" = '[!] Nu s-a putut genera bnupdate.tar.'
        "PkgGenTitle" = 'GENERARE PACHET DE INSTALARE PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Texturile (.tm2 și .png) rămân în limba engleză (necesită reproiectarea grafică manuală).'
        "PkgNotice2" = '2. 100% din textele de sistem (XML, ATOK HTML și scripturi) sunt traduse.'
        "PkgNotice3" = '3. Fișierul „bnupdate.tar.gz” este destinat testării imediate pe PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[AVIS TEHNIC]:'
        "PkgPromptTar" = 'Doriți să generați fișierul „bnupdate.tar.gz” pentru a testa pe PS2? (D/N) [Implicit: Y]'
        "PkgSuccess" = '[+] Pachetul a fost generat cu succes (permisiunile Linux 0755 activate): {0} ({1:N0} octeți)'
        "PosixPatchedCount" = '[+] Fișiere corectate cu permisiunea de execuție POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Apăsați orice tastă pentru a reveni la meniu...'
        "ProgressAtokHelp" = 'Traducerea ATOK Help'
        "ProgressUpdatingHtml" = 'Actualizarea fișierelor HTML'
        "ProgressUpdatingXml" = 'Actualizarea fișierelor XML'
        "ProgressXmlStrings" = 'Traducerea șirurilor XML'
        "PsbbnEnglishEnsure" = 'Vă rugăm să vă asigurați că folderul „PSBBN_English” este prezent în „input”.'
        "PsbbnEnglishNotFoundTitle" = '[!] EROARE: DIRECTORUL DE BAZĂ PSBBN_ENGLISH NU GĂSIT!'
        "ReadmeEnsure" = 'Vă rugăm să vă asigurați că fișierul „README.md” se află în folderul „input”.'
        "ReadmeNotFoundDownloading" = '[*] README.md nu a fost găsit. Se descarcă din depozitul oficial...'
        "ReadmeNotFoundTitle" = '[!] EROARE: FIȘIERUL README.MD NU GĂSIT!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} limbi selectate ({1})'
        "SelectUILangPrompt" = 'Selectați o opțiune'
        "SelectUITitle" = 'SCHIMBAȚI LIMBA UI'
        "SessionStarted" = 'Sesiunea a început pe:'
        "SourceFile" = 'Sursă:'
        "Step1Copying" = '[*] [1/3] Se copiează structura completă și binarele...'
        "Step2TranslatingXml" = '[*] [2/3] Se traduc {0} fișiere XML de sistem...'
        "Step3TranslatingAtok" = '[*] [3/3] Se traduc {0} ATOK fișiere de ajutor HTML...'
        "SuiteTitle" = 'Suită de traducere multilingvă PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Notă: Texturile (.tm2 / .png) conțin elemente grafice încorporate și   necesită editare manuală; they are not altered by the script. System   text files (XML, HTML, txt) are 100% translated.'
        "Translating" = 'Traducerea'
        "UsingFallback" = '[!] Folosind alternativă locală: {0}'
        "ValidatingXml" = '[*] Se validează integritatea sintactică a 100% din fișierele XML...'
        "XmlSyntaxError" = '[!] Eroare de sintaxă în {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% din fișierele XML validate cu succes (0 erori de sintaxă).'
    }
    "ru" = @{
        "All40Success" = 'Все 40 языков (полный многоязычный набор)'
        "AllLanguages" = 'Перевести на все языки (1 - 40)'
        "BackMenu" = 'Назад в главное меню'
        "CancelOption" = 'Назад'
        "CannotConnectGithub" = '[!] Не удалось подключиться к GitHub: {0}'
        "ChangeLanguage" = 'Изменить язык интерфейса'
        "ChangelogMainNotFoundTitle" = '[!] ОШИБКА: НЕВОЗМОЖНО СКАЧАТЬ ИЛИ НАЙТИ CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Переводчик основного списка изменений PSBBN [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ОШИБКА: НЕВОЗМОЖНО СКАЧАТЬ ИЛИ НАЙТИ CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Переводчик списка исправлений PSBBN [By Emerson Teles]'
        "ChooseOption" = 'Выберите опцию:'
        "CompletionBanner" = '[OK] Перевод {0} успешно завершен - 100%'
        "DescLauncher" = 'Добавляет поддержку и автоопределение до 40 языков в PSBBN Launcher for Windows.'
        "DescMain" = 'Переводит основной список изменений проекта (changelog_main_eng.txt).'
        "DescPatch" = 'Переводит список обновлений каналов и патчей (changelog_patch_eng.txt).'
        "DescReadme" = 'Переводит официальный README.md с сохранением разметки и ссылок.'
        "DescScript" = 'Переводит все 458 строк интерфейса скрипта установщика (eng.txt).'
        "DescSystem" = 'Переводит системные файлы PSBBN (диалоги XML, гиды, меню, помощь ATOK).'
        "DestFile" = 'Назначение:'
        "DownloadingLatestGithub" = '[i] Загрузка последней официальной версии с GitHub...'
        "DownloadingOfficial" = '[*] Загрузка официального файла из репозитория GitHub...'
        "EnglishOption" = 'Английский (по умолчанию)'
        "EngTxtEnsureFile" = 'Убедитесь, что файл «eng.txt» присутствует в папке «input».'
        "EngTxtErrorTitle" = '[!] ОШИБКА: ФАЙЛ ENG.TXT НЕ НАЙДЕН!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt не найден. Скачивание из официального репозитория...'
        "EnsureConnected" = 'Убедитесь, что вы подключены к Интернету, или поместите файл в папку input.'
        "ExitOption" = 'Выход'
        "ExpectedPath" = 'Ожидаемый путь: {0}'
        "ExtractingPack" = '[*] Извлечение пакета перевода PSBBN v3.5...'
        "FileNotFoundError" = '[ОШИБКА] Файл не найден: {0}'
        "GeneratedFile" = '[OK] Созданный файл: {0}'
        "GenericEnsureInternetOrInput" = 'Убедитесь, что вы подключены к Интернету или файл находится в папке «вход».'
        "IndividualBlocks" = 'Отдельные блоки: {0}'
        "IndividualBlocksNotice" = '[OK] Отдельные блоки для CosmicScale: {0}'
        "InputFileDeleted" = '[ОК] Файл(ы) удалены из входной папки.'
        "InputFileKept" = '[OK] Файл(ы) сохранены во входной папке.'
        "InvalidOption" = 'Неверная опция! Нажмите Enter...'
        "LangAppliedSuccess" = '[OK] Язык интерфейса успешно применен: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Автоматическое определение языка системы Windows включено.'
        "LauncherBaseNotFoundTitle" = '[!] ОШИБКА: НЕ МОЖЕТ ЗАГРУЗИТЬ ИЛИ НАЙТИ БАЗОВЫЙ СКРИПТ ПУЛЬТА ЗАПУСКА!'
        "LauncherIntegrated" = '[OK] Интегрирована поддержка {0} языка(ов) в PSBBN Launcher for Windows!'
        "LauncherPrompt" = 'Выберите один или несколько языков (напр.: 7 или 1, 2, 3 или 1-5 или A)'
        "LauncherTip1" = '- Введите 1 число, чтобы создать файл только с этим языком.'
        "LauncherTipAll" = '- Введите ''A'', чтобы создать полный файл со всеми 40 языками.'
        "LauncherTipHeader" = '* Подсказка: При каждом запуске создается чистый файл, содержащий только выбранные языки.'
        "LauncherTipMulti" = '- Введите несколько номеров через запятую (напр.: 1, 2, 3) для создания с этими языками.'
        "LauncherTipRange" = '- Введите диапазон (напр.: 1-5) для создания с этим диапазоном языков.'
        "LauncherTitle" = 'Переводчик PSBBN Launcher for Windows [By Emerson Teles]'
        "NavBack" = '[B] Предыдущий экран'
        "NavDeleteInput" = '[X] Удалить файл из входной папки'
        "NavEnter" = '[Ввод] Главное меню'
        "NavExit" = '[Esc] Выход'
        "NavInstructions" = '[Enter] Главное меню  |  [B] Предыдущий экран  |  [Esc] Выход'
        "NavKeepInput" = '[V] Сохранить файл во входной папке'
        "OfficialDownloadSuccess" = '[OK] Официальный файл успешно загружен ({0:N0} байт).'
        "PkgCompressingGz" = '[*] Сжатие в bnupdate.tar.gz через .NET GZipStream...'
        "PkgCreatingTar" = '[*] Создание bnupdate.tar и установка разрешений на выполнение POSIX (+x)...'
        "PkgErrorTar" = '[!] Не удалось сгенерировать bnupdate.tar.'
        "PkgGenTitle" = 'ГЕНЕРАЦИЯ УСТАНОВОЧНОГО ПАКЕТА PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Текстуры (.tm2 и .png) остаются на английском языке (требуется ручная графическая переработка).'
        "PkgNotice2" = '2. Переведено 100% системных текстов (XML, ATOK HTML и скрипты).'
        "PkgNotice3" = '3. Файл bnupdate.tar.gz предназначен для немедленного тестирования на PS2 (HDD/Telnet/USB).'
        "PkgNoticeHeader" = '[ТЕХНИЧЕСКОЕ УВЕДОМЛЕНИЕ]:'
        "PkgPromptTar" = 'Хотите создать файл bnupdate.tar.gz для тестирования на PS2? (Да/Нет) [По умолчанию: Да]'
        "PkgSuccess" = '[+] Пакет сгенерирован успешно (разрешения Linux 0755 включены): {0} ({1:N0} байт)'
        "PosixPatchedCount" = '[+] Файлы, исправленные с разрешением на выполнение POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Нажмите любую клавишу для возврата в меню...'
        "ProgressAtokHelp" = 'Перевод справки ATOK'
        "ProgressUpdatingHtml" = 'Обновление HTML-файлов'
        "ProgressUpdatingXml" = 'Обновление XML-файлов'
        "ProgressXmlStrings" = 'Перевод строк XML'
        "PsbbnEnglishEnsure" = 'Убедитесь, что папка «PSBBN_English» присутствует внутри «input».'
        "PsbbnEnglishNotFoundTitle" = '[!] ОШИБКА: БАЗОВЫЙ СПРАВОЧНИК PSBBN_ENGLISH НЕ НАЙДЕН!'
        "ReadmeEnsure" = 'Убедитесь, что файл README.md находится в папке «input».'
        "ReadmeNotFoundDownloading" = '[*] README.md не найден. Скачивание из официального репозитория...'
        "ReadmeNotFoundTitle" = '[!] ОШИБКА: ФАЙЛ README.MD НЕ НАЙДЕН!'
        "ReadmeTitle" = 'Переводчик PSBBN Readme [By Emerson Teles]'
        "ScriptTitle" = 'Переводчик скрипта PSBBN [By Emerson Teles]'
        "SelectedLanguagesCount" = 'Выбрано языков: {0} ({1})'
        "SelectUILangPrompt" = 'Выберите язык интерфейса'
        "SelectUITitle" = 'ВЫБОР ЯЗЫКА ИНТЕРФЕЙСА'
        "SessionStarted" = 'Сеанс начат:'
        "SourceFile" = 'Источник:'
        "Step1Copying" = '[*] [1/3] Копирование полной структуры и двоичных файлов...'
        "Step2TranslatingXml" = '[*] [2/3] Перевод {0} системных XML-файлов...'
        "Step3TranslatingAtok" = '[*] [3/3] Перевод файлов справки {0} ATOK HTML...'
        "SuiteTitle" = 'Многоязычный пакет перевода PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'Переводчик системы PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Примечание: Текстуры (.tm2 / .png) требуют ручного редактирования. Пакет переводит 100% системных текстов (XML, HTML, меню и скрипты).'
        "Translating" = 'Перевод'
        "UsingFallback" = '[!] Использование локальной резервной копии: {0}'
        "ValidatingXml" = '[*] Проверка синтаксической целостности 100% XML-файлов...'
        "XmlSyntaxError" = '[!] Синтаксическая ошибка в {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% XML-файлов проверены успешно (0 синтаксических ошибок).'
    }
    "sk" = @{
        "All40Success" = 'Všetkých 40 jazykov (plná viacjazyčnosť)'
        "AllLanguages" = 'Preložiť všetky jazyky (1 – 40)'
        "BackMenu" = 'Späť do hlavného menu'
        "CancelOption" = 'Späť'
        "CannotConnectGithub" = '[!] Nedá sa pripojiť na GitHub: {0}'
        "ChangeLanguage" = 'Zmeniť jazyk používateľského rozhrania'
        "ChangelogMainNotFoundTitle" = '[!] CHYBA: NEMOŽNO STIAHNUŤ ANI NÁJSŤ CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Hlavný prekladateľ PSBBN Changelog [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] CHYBA: NEMOŽNO STIAHNUŤ ANI NÁJSŤ CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Vyberte možnosť:'
        "CompletionBanner" = '[OK] Preklad {0} úspešne dokončený – 100 %'
        "DescLauncher" = 'Generuje a aktualizuje spúšťač PSBBN pre Windows s podporou všetkých 40 jazykov.'
        "DescMain" = 'Prekladá poznámky k vydaniu hlavného inštalátora a protokol zmien (changelog_main_eng.txt).'
        "DescPatch" = 'Prekladá históriu opráv, opravy a poznámky k aktualizácii kanála (changelog_patch_eng.txt).'
        "DescReadme" = 'Prekladá oficiálny PSBBN README.md so zachovaním formátovania markdown a odkazov.'
        "DescScript" = 'Preloží všetkých 458 reťazcov používateľského rozhrania pre inštalačný skript Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'Prekladá všetky systémové súbory PS2 PSBBN (XML dialógy, návody, ponuky, pomoc NetFront/ATOK).'
        "DestFile" = 'Cieľ:'
        "DownloadingLatestGithub" = '[i] Sťahovanie najnovšej oficiálnej verzie z GitHub...'
        "DownloadingOfficial" = '[*] Sťahovanie oficiálneho súboru z úložiska GitHub...'
        "EnglishOption" = 'Angličtina (predvolené)'
        "EngTxtEnsureFile" = 'Uistite sa, že súbor ''eng.txt'' je prítomný v priečinku ''input''.'
        "EngTxtErrorTitle" = '[!] CHYBA: SÚBOR ENG.TXT NENÁJDENÝ!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt sa nenašiel. Sťahovanie z oficiálneho úložiska...'
        "EnsureConnected" = 'Uistite sa, že ste pripojení na internet alebo umiestnite súbor do vstupného adresára.'
        "ExitOption" = 'VÝCHOD'
        "ExpectedPath" = 'Očakávaná cesta: {0}'
        "ExtractingPack" = '[*] Extrahuje sa prekladový balík PSBBN v3.5...'
        "FileNotFoundError" = '[CHYBA] Súbor sa nenašiel: {0}'
        "GeneratedFile" = '[OK] Vygenerovaný súbor: {0}'
        "GenericEnsureInternetOrInput" = 'Uistite sa, že ste pripojení na internet alebo máte súbor v priečinku ''vstup''.'
        "IndividualBlocks" = 'Jednotlivé bloky: {0}'
        "IndividualBlocksNotice" = '[OK] Jednotlivé bloky pre CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Súbor(y) odstránené zo vstupného priečinka.'
        "InputFileKept" = '[OK] Súbor(y) uložené vo vstupnom priečinku.'
        "InvalidOption" = 'Neplatná možnosť! Stlačte Enter a skúste to znova...'
        "LangAppliedSuccess" = '[OK] Jazyk rozhrania bol úspešne použitý: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Automatická detekcia jazyka systému Windows je povolená.'
        "LauncherBaseNotFoundTitle" = '[!] CHYBA: NEMOŽNO STIAHNUŤ ANI NÁJSŤ ZÁKLADNÝ SPÚŠŤACÍ SKRIPT!'
        "LauncherIntegrated" = '[OK] Integrovaná podpora pre {0} jazykov do spúšťača PSBBN pre Windows!'
        "LauncherPrompt" = 'Vyberte jeden alebo viac jazykov (napr. 7 alebo 1, 2, 3 alebo 1-5 alebo A):'
        "LauncherTip1" = '- Zadajte 1 číslo na vygenerovanie súboru iba v tomto jazyku.'
        "LauncherTipAll" = '- Zadajte ''A'', aby ste vygenerovali úplný súbor so všetkými 40 jazykmi.'
        "LauncherTipHeader" = '* Tip: Každé spustenie vygeneruje čistý súbor obsahujúci iba zvolené jazyky.'
        "LauncherTipMulti" = '– Zadajte viaceré čísla oddelené čiarkou (napr. 1, 2, 3), ktoré chcete vygenerovať v týchto jazykoch.'
        "LauncherTipRange" = '– Zadajte rozsah (napr. 1 – 5), ktorý sa má vygenerovať s týmto rozsahom jazykov.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Predchádzajúca obrazovka'
        "NavDeleteInput" = '[X] Odstrániť súbor zo vstupného priečinka'
        "NavEnter" = '[Enter] Hlavné menu'
        "NavExit" = '[Esc] Ukončiť'
        "NavInstructions" = '[Enter] Hlavné menu |  [B] Predchádzajúca obrazovka |  [Esc] Ukončite'
        "NavKeepInput" = '[V] Ponechať súbor vo vstupnom priečinku'
        "OfficialDownloadSuccess" = '[OK] Oficiálny súbor bol úspešne stiahnutý ({0:N0} bajtov).'
        "PkgCompressingGz" = '[*] Komprimuje sa na ''bnupdate.tar.gz'' cez .NET GZipStream...'
        "PkgCreatingTar" = '[*] Vytvára sa ''bnupdate.tar'' a nastavuje sa povolenia na spustenie POSIX (+x)...'
        "PkgErrorTar" = '[!] Nepodarilo sa vygenerovať súbor bnupdate.tar.'
        "PkgGenTitle" = 'VYTVORENIE INŠTALAČNÉHO BALÍKU PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Textúry (.tm2 a .png) zostávajú v angličtine (vyžadujú manuálny grafický redizajn).'
        "PkgNotice2" = '2. Je preložených 100 % systémových textov (XML, ATOK HTML a skripty).'
        "PkgNotice3" = '3. Súbor ''bnupdate.tar.gz'' je určený na okamžité testovanie na PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TECHNICKÉ OZNÁMENIE]:'
        "PkgPromptTar" = 'Chcete vygenerovať súbor ''bnupdate.tar.gz'' na testovanie na PS2? (Á/N) [Predvolené: Á]'
        "PkgSuccess" = '[+] Balík bol úspešne vygenerovaný (povolenia systému Linux 0755 povolené): {0} ({1:N0} bajtov)'
        "PosixPatchedCount" = '[+] Súbory opravené s povolením na vykonanie POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Stlačením ľubovoľného tlačidla sa vrátite do ponuky...'
        "ProgressAtokHelp" = 'Preklad ATOK Pomocník'
        "ProgressUpdatingHtml" = 'Aktualizácia HTML súborov'
        "ProgressUpdatingXml" = 'Aktualizácia súborov XML'
        "ProgressXmlStrings" = 'Preklad reťazcov XML'
        "PsbbnEnglishEnsure" = 'Uistite sa, že priečinok ''PSBBN_English'' je prítomný vo vnútri ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] CHYBA: BASE DIRECTORY PSBBN_ENGLISH NENÁJDENÉ!'
        "ReadmeEnsure" = 'Uistite sa, že súbor ''README.md'' je v priečinku ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md sa nenašiel. Sťahovanie z oficiálneho úložiska...'
        "ReadmeNotFoundTitle" = '[!] CHYBA: SÚBOR README.MD NENÁJDENÝ!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} vybratých jazykov ({1})'
        "SelectUILangPrompt" = 'Vyberte možnosť'
        "SelectUITitle" = 'ZMENIŤ JAZYK POUŽÍVATEĽSKÉHO ROZHRANIA'
        "SessionStarted" = 'Relácia sa začala:'
        "SourceFile" = 'Zdroj:'
        "Step1Copying" = '[*] [1/3] Kopíruje sa úplná štruktúra a binárne súbory...'
        "Step2TranslatingXml" = '[*] [2/3] Preklad {0} systémových súborov XML...'
        "Step3TranslatingAtok" = '[*] [3/3] Prekladá sa {0} ATOK HTML súbory pomocníka...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite – V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Upozornenie: Textúry (.tm2 / .png) obsahujú vloženú grafiku a vyžadujú   ručnú úpravu; nie sú zmenené scenárom. Systémové textové súbory (XML,   HTML, txt) sú 100% preložené.'
        "Translating" = 'Preklad'
        "UsingFallback" = '[!] Použitie lokálnej záložnej: {0}'
        "ValidatingXml" = '[*] Overuje sa syntaktická integrita 100 % súborov XML...'
        "XmlSyntaxError" = '[!] Chyba syntaxe v {0}: {1}'
        "XmlValidationSuccess" = '[+] 100 % súborov XML bolo úspešne overených (0 syntaktických chýb).'
    }
    "sr" = @{
        "All40Success" = 'Свих 40 језика (потпуно вишејезично)'
        "AllLanguages" = 'Преведи све језике (1 - 40)'
        "BackMenu" = 'Назад на главни мени'
        "CancelOption" = 'Назад'
        "CannotConnectGithub" = '[!] Не могу да се повежем на ГитХуб: {0}'
        "ChangeLanguage" = 'Промените језик корисничког интерфејса'
        "ChangelogMainNotFoundTitle" = '[!] ГРЕШКА: НИЈЕ МОГЛО ПРЕУЗЕТИ ИЛИ ЛОЦИРАТИ ЦХАНГЕЛОГ_МАИН_ЕНГ.ТКСТ!'
        "ChangelogMainTitle" = 'ПСББН Цхангелог Главни преводилац [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ГРЕШКА: НИЈЕ МОГУЋЕ ПРЕУЗЕТИ НИ ЛОКАЦИЈУ ЦХАНГЕЛОГ_ПАТЦХ_ЕНГ.ТКСТ!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Изаберите опцију:'
        "CompletionBanner" = '[OK] Превод {0} успешно завршен - 100%'
        "DescLauncher" = 'Генерише и ажурира ПСББН Лаунцхер за Виндовс са подршком за свих 40 језика.'
        "DescMain" = 'Преводи главне напомене о издању инсталатера и дневник промена (цхангелог_маин_енг.ткт).'
        "DescPatch" = 'Преводи историју закрпа, исправке и белешке о ажурирању канала (цхангелог_патцх_енг.ткт).'
        "DescReadme" = 'Преводи званични ПСББН РЕАДМЕ.мд чувајући форматирање и линкове за смањење вредности.'
        "DescScript" = 'Преводи свих 458 УИ стрингова за Линук/ВСЛ ПСББН инсталациону скрипту (енг.ткт).'
        "DescSystem" = 'Преводи све ПС2 ПСББН системске датотеке (КСМЛ дијалози, водичи, менији, НетФронт/АТОК помоћ).'
        "DestFile" = 'Одредиште:'
        "DownloadingLatestGithub" = '[и] Преузимање најновије званичне верзије са ГитХуб-а...'
        "DownloadingOfficial" = '[*] Преузимање званичне датотеке из ГитХуб спремишта...'
        "EnglishOption" = 'Енглески (подразумевано)'
        "EngTxtEnsureFile" = 'Уверите се да је датотека ''енг.ткт'' присутна у фасцикли ''инпут''.'
        "EngTxtErrorTitle" = '[!] ГРЕШКА: ЕНГ.ТКСТ ДАТОТЕКА НИЈЕ ПРОНАЂЕНА!'
        "EngTxtNotFoundDownloading" = '[*] енг.ткт није пронађен. Преузимање из званичног спремишта...'
        "EnsureConnected" = 'Уверите се да сте повезани на Интернет или поставите датотеку у директоријум за унос.'
        "ExitOption" = 'Изађи'
        "ExpectedPath" = 'Очекивана путања: {0}'
        "ExtractingPack" = '[*] Распакивање ПСББН в3.5 пакета превода...'
        "FileNotFoundError" = '[ГРЕШКА] Датотека није пронађена: {0}'
        "GeneratedFile" = '[ОК] Генерисана датотека: {0}'
        "GenericEnsureInternetOrInput" = 'Уверите се да сте повезани на Интернет или да имате датотеку у фасцикли „улаз“.'
        "IndividualBlocks" = 'Појединачни блокови: {0}'
        "IndividualBlocksNotice" = '[ОК] Појединачни блокови за ЦосмицСцале: {0}'
        "InputFileDeleted" = '[ОК] Датотеке су избрисане из фасцикле за унос.'
        "InputFileKept" = '[ОК] Датотеке се чувају у фасцикли за унос.'
        "InvalidOption" = 'Неважећа опција! Притисните Ентер да покушате поново...'
        "LangAppliedSuccess" = '[OK] Језик интерфејса је успешно примењен: {0} ({1})'
        "LauncherAutoDetect" = '[ОК] Омогућено је аутоматско откривање језика система Виндовс.'
        "LauncherBaseNotFoundTitle" = '[!] ГРЕШКА: НИЈЕ МОГЛО ПРЕУЗИМАЊЕ ИЛИ ЛОЦИРАЈУ СЦРИПТ БАЗНОГ ПОКРЕТАЧА!'
        "LauncherIntegrated" = '[ОК] Интегрисана подршка за {0} језика у ПСББН Лаунцхер за Виндовс!'
        "LauncherPrompt" = 'Изаберите један или више језика (нпр. 7 или 1, 2, 3 или 1-5 или А):'
        "LauncherTip1" = '- Унесите 1 број да бисте генерисали датотеку само на том језику.'
        "LauncherTipAll" = '- Унесите ''А'' да бисте генерисали комплетну датотеку са свих 40 језика.'
        "LauncherTipHeader" = '* Савет: Свако извршење генерише чисту датотеку која садржи само изабране језике.'
        "LauncherTipMulti" = '– Унесите више бројева одвојених зарезом (нпр. 1, 2, 3) да бисте генерисали са тим језицима.'
        "LauncherTipRange" = '– Унесите опсег (нпр. 1-5) за генерисање са тим опсегом језика.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[Б] Претходни екран'
        "NavDeleteInput" = '[Кс] Избришите датотеку из фасцикле за унос'
        "NavEnter" = '[Ентер] Главни мени'
        "NavExit" = '[Есц] Излаз'
        "NavInstructions" = '[Ентер] Главни мени |  [Б] Претходни екран |  [Есц] Излаз'
        "NavKeepInput" = '[В] Задржи датотеку у фасцикли за унос'
        "OfficialDownloadSuccess" = '[ОК] Званична датотека је успешно преузета (___Н0___ бајтова).'
        "PkgCompressingGz" = '[*] Компресовање у ''бнупдате.тар.гз'' преко .НЕТ ГЗипСтреам-а...'
        "PkgCreatingTar" = '[*] Креирање ''бнупдате.тар'' и постављање дозвола за извршавање ПОСИКС (+к)...'
        "PkgErrorTar" = '[!] Није могуће генерисати бнупдате.тар.'
        "PkgGenTitle" = 'ГЕНЕРАЦИЈА ИНСТАЛАЦИЈСКОГ ПАКЕТА ПСББН (бнупдате.тар.гз)'
        "PkgNotice1" = '1. Текстуре (.тм2 и .пнг) остају на енглеском (захтевају ручни графички редизајн).'
        "PkgNotice2" = '2. 100% системских текстова (КСМЛ, АТОК ХТМЛ и скрипте) је преведено.'
        "PkgNotice3" = '3. Датотека ''бнупдате.тар.гз'' је намењена за тренутно тестирање на ПС2 (ХДД / Телнет / УСБ).'
        "PkgNoticeHeader" = '[ТЕХНИЧКО ОБАВЕШТЕЊЕ]:'
        "PkgPromptTar" = 'Да ли желите да генеришете датотеку ''бнупдате.тар.гз'' за тестирање на ПС2? (И/Н) [Дефаулт: И]'
        "PkgSuccess" = '[+] Пакет је успешно генерисан (омогућене дозволе за Линук 0755): {0} ({1:Н0} бајтова)'
        "PosixPatchedCount" = '[+] Фајлови закрпљени са дозволом за извршавање ПОСИКС 0755 (+к): {0}'
        "PressAnyKey" = 'Притисните било који тастер да се вратите у мени...'
        "ProgressAtokHelp" = 'Превођење АТОК Помоћ'
        "ProgressUpdatingHtml" = 'Ажурирање ХТМЛ датотека'
        "ProgressUpdatingXml" = 'Ажурирање КСМЛ датотека'
        "ProgressXmlStrings" = 'Превођење КСМЛ стрингова'
        "PsbbnEnglishEnsure" = 'Уверите се да је фасцикла „ПСББН_Енглисх“ присутна унутар „уноса“.'
        "PsbbnEnglishNotFoundTitle" = '[!] ГРЕШКА: ОСНОВНИ ДИРЕКТОРИЈ ПСББН_ЕНГЛИСХ НИЈЕ ПРОНАЂЕН!'
        "ReadmeEnsure" = 'Уверите се да је датотека „РЕАДМЕ.мд“ у фасцикли „улаз“.'
        "ReadmeNotFoundDownloading" = '[*] РЕАДМЕ.мд није пронађен. Преузимање из званичног спремишта...'
        "ReadmeNotFoundTitle" = '[!] ГРЕШКА: ДАТОТЕКА РЕАДМЕ.МД НИЈЕ ПРОНАЂЕНА!'
        "ReadmeTitle" = 'ПСББН Реадме Транслатор [By Emerson Teles]'
        "ScriptTitle" = 'ПСББН преводилац скрипти [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} одабраних језика ({1})'
        "SelectUILangPrompt" = 'Изаберите опцију'
        "SelectUITitle" = 'ПРОМЕНИТЕ ЈЕЗИК КОРИСНИЧКОГ ИНТЕРФЕЈСА'
        "SessionStarted" = 'Сесија је почела:'
        "SourceFile" = 'Извор:'
        "Step1Copying" = '[*] [1/3] Копирање комплетне структуре и бинарних датотека...'
        "Step2TranslatingXml" = '[*] [2/3] Превођење {0} системских КСМЛ датотека...'
        "Step3TranslatingAtok" = '[*] [3/3] Превођење {0} АТОК ХТМЛ датотека помоћи...'
        "SuiteTitle" = 'ПСББН вишејезични преводитељски пакет – В1 [By Emerson Teles]'
        "SystemTitle" = 'Системски ПСББН преводилац [By Emerson Teles]'
        "TextureDisclaimer" = 'Напомена: Текстуре (.тм2 / .пнг) садрже уграђену графику и захтевају   ручно уређивање; они нису измењени сценаријем. Системске текстуалне   датотеке (КСМЛ, ХТМЛ, ткт) су 100% преведене.'
        "Translating" = 'Превођење'
        "UsingFallback" = '[!] Коришћење локалног резервног: {0}'
        "ValidatingXml" = '[*] Провера синтаксичког интегритета 100% КСМЛ датотека...'
        "XmlSyntaxError" = '[!] Грешка у синтакси у {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% КСМЛ датотека је успешно потврђено (0 грешака у синтакси).'
    }
    "sv" = @{
        "All40Success" = 'Alla 40 språk (Fullständig flerspråkig)'
        "AllLanguages" = 'Översätt alla språk (1 - 40)'
        "BackMenu" = 'Tillbaka till huvudmenyn'
        "CancelOption" = 'Tillbaka'
        "CannotConnectGithub" = '[!] Kan inte ansluta till GitHub: {0}'
        "ChangeLanguage" = 'Ändra UI-språk'
        "ChangelogMainNotFoundTitle" = '[!] FEL: KUNDE INTE LADDA NER ELLER LITTA CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Huvudöversättare för PSBBN Changelog [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] FEL: KUNDE INTE LADDA NED ELLER LITTA CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Välj ett alternativ:'
        "CompletionBanner" = '[OK] Översättningen av {0} har slutförts - 100 %'
        "DescLauncher" = 'Genererar och uppdaterar PSBBN Launcher för Windows med stöd för alla 40 språk.'
        "DescMain" = 'Översätter versionsinformationen för huvudinstallationen och ändringsloggen (changelog_main_eng.txt).'
        "DescPatch" = 'Översätter patchhistorik, fixar och kanaluppdateringsnoteringar (changelog_patch_eng.txt).'
        "DescReadme" = 'Translates the official PSBBN README.md preserving markdown formatting and links.'
        "DescScript" = 'Translates all 458 UI strings for the Linux/WSL PSBBN installer script (eng.txt).'
        "DescSystem" = 'Översätter alla PS2 PSBBN-systemfiler (XML-dialoger, guider, menyer, NetFront/ATOK-hjälp).'
        "DestFile" = 'Destination:'
        "DownloadingLatestGithub" = '[i] Laddar ner senaste officiella versionen från GitHub...'
        "DownloadingOfficial" = '[*] Laddar ned officiell fil från GitHub-arkivet...'
        "EnglishOption" = 'Engelska (standard)'
        "EngTxtEnsureFile" = 'Se till att filen ''eng.txt'' finns i mappen ''input''.'
        "EngTxtErrorTitle" = '[!] FEL: ENG.TXT-FIL HITTER INTE!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt hittades inte. Laddar ner från det officiella arkivet...'
        "EnsureConnected" = 'Se till att du är ansluten till Internet eller placera filen i inmatningskatalogen.'
        "ExitOption" = 'Utgång'
        "ExpectedPath" = 'Förväntad sökväg: {0}'
        "ExtractingPack" = '[*] Extraherar PSBBN v3.5 översättningspaket...'
        "FileNotFoundError" = '[FEL] Filen hittades inte: {0}'
        "GeneratedFile" = '[OK] Genererad fil: {0}'
        "GenericEnsureInternetOrInput" = 'Se till att du är ansluten till Internet eller har filen i mappen "input".'
        "IndividualBlocks" = 'Individuella block: {0}'
        "IndividualBlocksNotice" = '[OK] Individuella block för CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Fil(er) raderade från inmatningsmappen.'
        "InputFileKept" = '[OK] Fil(er) sparas i inmatningsmappen.'
        "InvalidOption" = 'Ogiltigt alternativ! Tryck på Retur för att försöka igen...'
        "LangAppliedSuccess" = '[OK] Gränssnittsspråket har tillämpats: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Automatisk identifiering av Windows-systemspråk aktiverad.'
        "LauncherBaseNotFoundTitle" = '[!] FEL: KUNDE INTE LADDA NER ELLER LITTA BASE LAUNCHER SCRIPT!'
        "LauncherIntegrated" = '[OK] Integrerat stöd för {0} språk i PSBBN Launcher för Windows!'
        "LauncherPrompt" = 'Välj ett eller flera språk (t.ex. 7 eller 1, 2, 3 eller 1-5 eller A):'
        "LauncherTip1" = '- Ange 1 nummer för att skapa filen med endast det språket.'
        "LauncherTipAll" = '- Ange ''A'' för att skapa hela filen med alla 40 språken.'
        "LauncherTipHeader" = '* Tips: Varje körning genererar en ren fil som endast innehåller det eller de valda språken.'
        "LauncherTipMulti" = '- Ange flera siffror separerade med kommatecken (t.ex. 1, 2, 3) för att generera med dessa språk.'
        "LauncherTipRange" = '- Ange ett intervall (t.ex. 1-5) för att generera med det intervallet av språk.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Föregående skärm'
        "NavDeleteInput" = '[X] Ta bort fil från inmatningsmappen'
        "NavEnter" = '[Enter] Huvudmeny'
        "NavExit" = '[Esc] Avsluta'
        "NavInstructions" = '[Enter] Huvudmeny |  [B] Föregående skärm |  [Esc] Avsluta'
        "NavKeepInput" = '[V] Behåll filen i inmatningsmappen'
        "OfficialDownloadSuccess" = '[OK] Officiell fil har laddats ned ({0:N0} byte).'
        "PkgCompressingGz" = '[*] Komprimerar till ''bnupdate.tar.gz'' via .NET GZipStream...'
        "PkgCreatingTar" = '[*] Skapar ''bnupdate.tar'' och ställer in POSIX-körningsbehörigheter (+x)...'
        "PkgErrorTar" = '[!] Kunde inte generera bnupdate.tar.'
        "PkgGenTitle" = 'PSBBN INSTALLATIONSPAKET GENERATION (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Texturer (.tm2 och .png) förblir på engelska (kräver manuell grafisk omdesign).'
        "PkgNotice2" = '2. 100 % av systemtexterna (XML, ATOK HTML och skript) är översatta.'
        "PkgNotice3" = '3. Filen ''bnupdate.tar.gz'' är avsedd för omedelbar testning på PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TEKNISK MEDDELANDE]:'
        "PkgPromptTar" = 'Vill du skapa filen ''bnupdate.tar.gz'' för att testa på PS2? (J/N) [Standard: Y]'
        "PkgSuccess" = '[+] Paketet har skapats framgångsrikt (Linux 0755-behörigheter aktiverade): {0} ({1:N0} byte)'
        "PosixPatchedCount" = '[+] Filer korrigerade med POSIX 0755 exekveringsbehörighet (+x): {0}'
        "PressAnyKey" = 'Tryck på valfri tangent för att återgå till menyn...'
        "ProgressAtokHelp" = 'Översätta ATOK Hjälp'
        "ProgressUpdatingHtml" = 'Uppdatera HTML-filer'
        "ProgressUpdatingXml" = 'Uppdatera XML-filer'
        "ProgressXmlStrings" = 'Översätta XML-strängar'
        "PsbbnEnglishEnsure" = 'Se till att mappen ''PSBBN_English'' finns i ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] FEL: BASKABEL PSBBN_ENGLISH HITTADE INTE!'
        "ReadmeEnsure" = 'Se till att filen ''README.md'' finns i mappen ''input''.'
        "ReadmeNotFoundDownloading" = '[*] README.md hittades inte. Laddar ner från det officiella arkivet...'
        "ReadmeNotFoundTitle" = '[!] FEL: README.MD-FIL HITTER INTE!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} språk valda ({1})'
        "SelectUILangPrompt" = 'Välj ett alternativ'
        "SelectUITitle" = 'ÄNDRA UI-SPRÅK'
        "SessionStarted" = 'Session började på:'
        "SourceFile" = 'Källa:'
        "Step1Copying" = '[*] [1/3] Kopierar fullständig struktur och binärer...'
        "Step2TranslatingXml" = '[*] [2/3] Översätter {0} system-XML-filer...'
        "Step3TranslatingAtok" = '[*] [3/3] Översätter {0} ATOK HTML-hjälpfiler...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Observera: Texturer (.tm2 / .png) innehåller inbäddad grafik och   kräver manuell redigering; de ändras inte av manuset. Systemtextfiler   (XML, HTML, txt) är 100 % översatta.'
        "Translating" = 'Översätter'
        "UsingFallback" = '[!] Använder lokal reserv: {0}'
        "ValidatingXml" = '[*] Validerar syntaktisk integritet för 100 % av XML-filerna...'
        "XmlSyntaxError" = '[!] Syntaxfel i {0}: {1}'
        "XmlValidationSuccess" = '[+] 100 % av XML-filerna validerades framgångsrikt (0 syntaxfel).'
    }
    "ta" = @{
        "All40Success" = 'அனைத்து 40 மொழிகளும் (முழு பன்மொழி)'
        "AllLanguages" = 'அனைத்து மொழிகளையும் மொழிபெயர் (1 - 40)'
        "BackMenu" = 'முதன்மை மெனுவுக்குத் திரும்பு'
        "CancelOption" = 'பின்'
        "CannotConnectGithub" = '[!] GitHub உடன் இணைக்க முடியவில்லை: {0}'
        "ChangeLanguage" = 'UI மொழியை மாற்றவும்'
        "ChangelogMainNotFoundTitle" = '[!] பிழை: CHANGELOG_MAIN_ENG.TXTஐப் பதிவிறக்கவோ அல்லது கண்டுபிடிக்கவோ முடியவில்லை!'
        "ChangelogMainTitle" = 'PSBBN சேஞ்ச்லாக் முதன்மை மொழிபெயர்ப்பாளர் [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] பிழை: CHANGELOG_PATCH_ENG.TXTஐப் பதிவிறக்கவோ அல்லது கண்டுபிடிக்கவோ முடியவில்லை!'
        "ChangelogPatchTitle" = 'PSBBN சேஞ்ச்லாக் பேட்ச் மொழிபெயர்ப்பாளர் [By Emerson Teles]'
        "ChooseOption" = 'ஒரு விருப்பத்தைத் தேர்ந்தெடுக்கவும்:'
        "CompletionBanner" = '[OK] {0} இன் மொழிபெயர்ப்பு வெற்றிகரமாக முடிந்தது - 100%'
        "DescLauncher" = 'அனைத்து 40 மொழிகளுக்கும் ஆதரவுடன் Windows க்கான PSBBN துவக்கியை உருவாக்கி புதுப்பிக்கிறது.'
        "DescMain" = 'முக்கிய நிறுவி வெளியீட்டு க���றிப்புகள் மற்றும் சேஞ்ச்லாக் (changelog_main_eng.txt) ஆகியவற்றை மொழிபெயர்க்கிறது.'
        "DescPatch" = 'இணைப்பு வரலாறு, திருத்தங்��ள் மற்றும் சேனல் புதுப்பிப்பு குறிப்புகளை மொழிபெயர்க்கிறது (changelog_patch_eng.txt).'
        "DescReadme" = 'மார்க் டவுன��� வடிவமைப்பு மற்றும் இணைப்புகளைப் பாதுகாக்கும் அதிகாரப்பூர்வ PSBBN README.md ஐ மொழிபெயர்க்கிறது.'
        "DescScript" = 'Linux/WSL PSBBN நிறுவி ஸ்கிரிப்ட் (eng.txt) க்கான அனைத்து 458 UI சரங்களையும் மொழிபெயர்க்கிறது.'
        "DescSystem" = 'அனைத்து PS2 PSBBN சிஸ்டம் கோப்புகளையும் (XML உரையாடல்கள், வழிகாட்டிகள், மெனுக்கள், NetFront/ATOK உதவி) மொழிபெயர்க்கிறது.'
        "DestFile" = 'சேருமிடம்:'
        "DownloadingLatestGithub" = '[i] GitHub இலிருந்து சமீபத்திய அதிகாரப்பூர்வ பதிப்பைப் பதிவிறக்குகிறது...'
        "DownloadingOfficial" = '[*] GitHub களஞ்சியத்திலிருந்து அதிகாரப்பூர்வ கோப்பைப் பதிவிறக்குகிறது...'
        "EnglishOption" = 'ஆங்கிலம் (இயல்புநிலை)'
        "EngTxtEnsureFile" = '''eng.txt'' கோப்பு ''உள்ளீடு'' கோப்புறையில் இருப்பதை உறுதிசெய்யவும்.'
        "EngTxtErrorTitle" = '[!] பிழை: ENG.TXT கோப்பு கிடைக்கவில்லை!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt கிடைக்கவில்லை. அதிகாரப்பூர்வ களஞ்சியத்திலிருந்து பதிவிறக்குகிறது...'
        "EnsureConnected" = 'நீங்கள் இணையத்துடன் இணைக்கப்பட்டுள்ளீர்கள் என்பதை உறுதிப்படுத்தவும் அல்லது கோப்பை உள்ளீட்டு கோப்பகத்தில் வைக்கவும்.'
        "ExitOption" = 'வெளியேறு'
        "ExpectedPath" = 'எதிர்பார்க்கப்படும் பாதை: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 மொழிபெயர்ப்பு தொகுப்பைப் பிரித்தெடுக்கிறது...'
        "FileNotFoundError" = '[பிழை] கோப்பு கிடைக்கவில்லை: {0}'
        "GeneratedFile" = '[சரி] உருவாக்கப்பட்ட கோப்பு: {0}'
        "GenericEnsureInternetOrInput" = 'நீங்கள் இணையத்துடன் இணைக்கப்பட்டுள்ளீர்களா அல்லது ''உள்ளீடு'' கோப்புறையில் கோப்பு உள்ளதா என்பதை உறுதிப்படுத்தவும்.'
        "IndividualBlocks" = 'தனிப்பட்ட தொகுதிகள்: {0}'
        "IndividualBlocksNotice" = '[சரி] காஸ்மிக்ஸ்கேலுக்கான தனிப்பட்ட தொகுதிகள்: {0}'
        "InputFileDeleted" = '[சரி] உள்ளீட்டு கோப்புறையிலிருந்து கோப்பு(கள்) நீக்கப்பட்டன.'
        "InputFileKept" = '[சரி] உள்ளீட்டு கோப்புறையில் கோப்பு(கள்) வைக்கப்பட்டுள்ளன.'
        "InvalidOption" = 'தவறான விருப்பம்! மீண்டும் முயற்சிக்க Enter ஐ அழுத்தவும்...'
        "LangAppliedSuccess" = '[OK] இடைமுக மொழி வெற்றிகரமாகப் பயன்படுத்தப்பட்டது: {0} ({1})'
        "LauncherAutoDetect" = '[சரி] விண்டோஸ் சிஸ்டம் மொழி தானாக கண்டறிதல் இயக்கப்பட்டது.'
        "LauncherBaseNotFoundTitle" = '[!] பிழை: பேஸ் லாஞ்சர் ஸ்கிரிப்டைப் பதிவிறக்கவோ அல்லது கண்டுபிடிக்கவோ முடியவில்லை!'
        "LauncherIntegrated" = '[சரி] Windows க்கான PSBBN துவக்கியில் {0} மொழி(கள்)க்கான ஒருங்கிணைந்த ஆதரவு!'
        "LauncherPrompt" = 'ஒன்று அல்லது அதற்கு மேற்பட்ட மொழிகளைத் தேர்ந்தெடுக்கவும் (எ.கா. 7 அல்லது 1, 2, 3 அல்லது 1-5 அல்லது ஏ):'
        "LauncherTip1" = '- அந்த மொழியில் மட்டும் கோப்பை உருவாக்க 1 எண்ணை உள்ளிடவும்.'
        "LauncherTipAll" = '- அனைத்து 40 மொழிகளிலும் முழுமையான கோப்பை உருவாக்க ''A'' ஐ உள்ளிடவும்.'
        "LauncherTipHeader" = '* உதவிக்குறிப்பு: ஒவ்வொரு செயலாக்கமும் தேர்ந்தெடுக்கப்பட்ட மொழி(கள்) கொண்ட சுத்தமான கோப்பை உருவாக்குகிறது.'
        "LauncherTipMulti" = '- அந்த மொழிகளில் உருவாக்க, கமாவால் பிரிக்கப்பட்ட பல எண்களை உள்ளிடவும் (எ.கா. 1, 2, 3).'
        "LauncherTipRange" = '- அந்த மொழிகளின் வரம்பில் உருவாக்க வரம்பை உள்ளிடவும் (எ.கா. 1-5).'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] முந்தைய திரை'
        "NavDeleteInput" = '[X] உள்ளீட்டு கோப்புறையிலிருந்து கோப்பை நீக்கவும்'
        "NavEnter" = '[உள்ளிடவும்] முதன்மை மெனு'
        "NavExit" = '[Esc] வெளியேறு'
        "NavInstructions" = '[உள்ளிடவும்] முதன்மை மெனு |  [B] முந்தைய திரை |  [Esc] வெளியேறு'
        "NavKeepInput" = '[V] கோப்பை உள்ளீட்டு கோப்புறையில் வைக்கவும்'
        "OfficialDownloadSuccess" = '[சரி] அதிகாரப்பூர்வ கோப்பு பதிவிறக்கம் செய்யப்பட்டது ({0:N0} பைட்டுகள்).'
        "PkgCompressingGz" = '[*] .NET GZipStream வழியாக ''bnupdate.tar.gz'' க்கு சுருக்குகிறது...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' ஐ உருவாக்குதல் மற்றும் POSIX செயல்படுத்தல் அனுமதிகளை (+x) அமைத்தல்...'
        "PkgErrorTar" = '[!] bnupdate.tar ஐ உருவாக்க முடியவில்லை.'
        "PkgGenTitle" = 'PSBBN இன்ஸ்டாலேஷன் பேக்கேஜ் ஜெனரேஷன் (bnupdate.tar.gz)'
        "PkgNotice1" = '1. இழைமங்கள் (.tm2 மற்றும் .png) ஆங்கிலத்தில் இருக்கும் (கையேடு கிராஃபிக் மறுவடிவமைப்பு தேவை).'
        "PkgNotice2" = '2. 100% கணினி உரைகள் (XML, ATOK HTML மற்றும் ஸ்கிரிப்டுகள்) மொழிபெயர்க்கப்பட்டுள்ளன.'
        "PkgNotice3" = '3. ''bnupdate.tar.gz'' கோப்பு PS2 (HDD / Telnet / USB) இல் உடனடி சோதனைக்காக வடிவமைக்கப்பட்டுள்ளது.'
        "PkgNoticeHeader" = '[தொழில்நுட்ப அறிவிப்பு]:'
        "PkgPromptTar" = 'PS2 இல் சோதிக்க ''bnupdate.tar.gz'' கோப்பை உருவாக்க விரும்புகிறீர்களா? (Y/N) [இயல்புநிலை: Y]'
        "PkgSuccess" = '[+] தொகுப்பு வெற்றிகரமாக உருவாக்கப்பட்டது (லினக்ஸ் 0755 அனுமதிகள் இயக்கப்பட்டது): {0} ({1:N0} பைட்டுகள்)'
        "PosixPatchedCount" = '[+] POSIX 0755 இயக்க அனுமதியுடன் இணைக்கப்பட்ட கோப்புகள் (+x): {0}'
        "PressAnyKey" = 'மெனுவிற்குத் திரும்ப எந்த விசையையும் அழுத்தவும்...'
        "ProgressAtokHelp" = 'ATOK உதவியை மொழிபெயர்க்கிறது'
        "ProgressUpdatingHtml" = 'HTML கோப்புகளைப் புதுப்பிக்கிறது'
        "ProgressUpdatingXml" = 'XML கோப்புகளைப் புதுப்பிக்கிறது'
        "ProgressXmlStrings" = 'XML சரங்களை மொழிபெயர்க்கிறது'
        "PsbbnEnglishEnsure" = '''PSBBN_English'' கோப்புறை ''உள்ளீடு'' உள்ளே இருப்பதை உறுதிசெய்யவும்.'
        "PsbbnEnglishNotFoundTitle" = '[!] பிழை: பேஸ் டைரக்டரி PSBBN_English கிடைக்கவில்லை!'
        "ReadmeEnsure" = '''README.md'' கோப்பு ''உள்ளீடு'' கோப்புறையில் இருப்பதை உறுதிசெய்யவும்.'
        "ReadmeNotFoundDownloading" = '[*] README.md கிடைக்கவில்லை. அதிகாரப்பூர்வ களஞ்சியத்திலிருந்து பதிவிறக்குகிறது...'
        "ReadmeNotFoundTitle" = '[!] பிழை: README.MD கோப்பு கிடைக்கவில்லை!'
        "ReadmeTitle" = 'PSBBN Readme மொழிபெயர்ப்பாளர் [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN ஸ்கிரிப்ட் மொழிபெயர்ப்பாளர் [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} மொழிகள் தேர்ந்தெடுக்கப்பட்டன ({1})'
        "SelectUILangPrompt" = 'ஒரு விருப்பத்தைத் தேர்ந்தெடுக்கவும்'
        "SelectUITitle" = 'UI மொழியை மாற்றவும்'
        "SessionStarted" = 'அமர்வு தொடங்கியது:'
        "SourceFile" = 'ஆதாரம்:'
        "Step1Copying" = '[*] [1/3] முழுமையான கட்டமைப்பு மற்றும் பைனரிகளை நகலெடுக்கிறது...'
        "Step2TranslatingXml" = '[*] [2/3] {0} சிஸ்டம் எக்ஸ்எம்எல் கோப்புகளை மொழிபெயர்க்கிறது...'
        "Step3TranslatingAtok" = '[*] [3/3] {0} ATOK HTML உதவி கோப்புகளை மொழிபெயர்க்கிறது...'
        "SuiteTitle" = 'PSBBN பன்மொழி மொழிபெயர்ப்பு தொகுப்பு - V1 [By Emerson Teles]'
        "SystemTitle" = 'கணினி PSBBN மொழிபெயர்ப்பாளர் [By Emerson Teles]'
        "TextureDisclaimer" = 'குறிப்பு: இழைமங்கள் (.tm2 / .png) உட்பொதிக்கப்பட்ட கிராபிக்ஸ் மற்றும்   கைமுறையாகத் திருத்தம் செய்ய வேண்டும்; அவை ஸ்கிரிப்ட் மூலம்   மாற்றப்பட���ில்லை. கணினி உரை கோப்புகள் (XML, HTML, txt) 100%   மொழிபெயர்க்கப்பட்டுள்ளன.'
        "Translating" = 'மொழிபெயர்த்தல்'
        "UsingFallback" = '[!] உள்ளூர் வீழ்ச்சியைப் பயன்படுத்துதல்: {0}'
        "ValidatingXml" = '[*] XML கோப்புகளின் 100% தொடரியல் ஒருமைப்பாட்டை சரிபார்க்கிறது...'
        "XmlSyntaxError" = '[!] {0}: {1} இல் தொடரியல் பிழை'
        "XmlValidationSuccess" = '[+] XML கோப்புகளில் 100% வெற்றிகரமாக சரிபார்க்கப்பட்டது (0 தொடரியல் பிழைகள்).'
    }
    "te" = @{
        "All40Success" = 'మొత్తం 40 భాషలు (పూర్తి బహుభాషా)'
        "AllLanguages" = 'అన్ని భాషలను అనువదించు (1 - 40)'
        "BackMenu" = 'తిరిగి ప్రధాన మెనూకి'
        "CancelOption" = 'వెనుక'
        "CannotConnectGithub" = '[!] GitHubకి కనెక్ట్ చేయడం సాధ్యపడదు: {0}'
        "ChangeLanguage" = 'UI భాషను మార్చండి'
        "ChangelogMainNotFoundTitle" = '[!] లోపం: CHANGELOG_MAIN_ENG.TXTని డౌన్‌లోడ్ చేయడం లేదా గుర్తించడం సాధ్యపడలేదు!'
        "ChangelogMainTitle" = 'PSBBN చేంజ్లాగ్ ప్రధాన అనువాదకుడు [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] లోపం: CHANGELOG_PATCH_ENG.TXTని డౌన్‌లోడ్ చేయడం లేదా గుర్తించడం సాధ్యపడలేదు!'
        "ChangelogPatchTitle" = 'PSBBN చేంజ్‌లాగ్ ప్యాచ్ ట్రాన్స్‌లేటర్ [By Emerson Teles]'
        "ChooseOption" = 'ఒక ఎంపికను ఎంచుకోండి:'
        "CompletionBanner" = '[OK] {0} అనువాదం విజయవంతంగా పూర్తయింది - 100%'
        "DescLauncher" = 'మొత్తం 40 భాషలకు మద్దతుతో Windows కోసం PSBBN లాంచర్‌ను రూపొందిస్తుంది మరియు అప్‌డేట్ చేస్తుంది.'
        "DescMain" = 'ప్రధాన ఇన్‌స్టాలర్ విడుదల గమనికలు మరియు చేంజ్‌లాగ్‌ను అనువదిస్తుంది (changelog_main_eng.txt).'
        "DescPatch" = 'ప్యాచ్ చరిత్ర, పరిష్కారాలు మరియు ఛానెల్ నవీకరణ గమనికలను అనువదిస్తుంది (changelog_patch_eng.txt).'
        "DescReadme" = 'మార్క్‌డౌన్ ఫార్మాటింగ్ మరియు లింక్‌లను సంరక్షించే అధికారిక PSBBN README.mdని అనువదిస్తుంది.'
        "DescScript" = 'Linux/WSL PSBBN ఇన్‌స్టాలర్ స్క్రిప్ట్ (eng.txt) కోసం మొత్తం 458 UI స్ట్రింగ్‌లను అనువదిస్తుంది.'
        "DescSystem" = 'అన్ని PS2 PSBBN సిస్టమ్ ఫైల్‌లను అనువదిస్తుంది (XML డైలాగ్‌లు, గైడ్‌లు, మెనూలు, NetFront/ATOK సహాయం).'
        "DestFile" = 'గమ్యం:'
        "DownloadingLatestGithub" = '[i] GitHub నుండి తాజా అధికారిక సంస్కరణను డౌన్‌లోడ్ చేస్తోంది...'
        "DownloadingOfficial" = '[*] GitHub రిపోజిటరీ నుండి అధికారిక ఫైల్‌ని డౌన్‌లోడ్ చేస్తోంది...'
        "EnglishOption" = 'ఆంగ్లం (డిఫాల్ట్)'
        "EngTxtEnsureFile" = 'దయచేసి ''eng.txt'' ఫైల్ ''ఇన్‌పుట్'' ఫోల్డర్‌లో ఉందని నిర్ధారించుకోండి.'
        "EngTxtErrorTitle" = '[!] లోపం: ENG.TXT ఫైల్ కనుగొనబడలేదు!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt కనుగొనబడలేదు. అధికారిక రిపోజిటరీ నుండి డౌన్‌లోడ్ చేస్తోంది...'
        "EnsureConnected" = 'దయచేసి మీరు ఇంటర్నెట్‌కి కనెక్ట్ అయ్యారని నిర్ధారించుకోండి లేదా ఫైల్‌ను ఇన్‌పుట్ డైరెక్టరీలో ఉంచండి.'
        "ExitOption" = 'నిష్క్రమించు'
        "ExpectedPath" = 'ఆశించిన మార్గం: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 అనువాద ప్యాక్‌ని సంగ్రహిస్తోంది...'
        "FileNotFoundError" = '[లోపం] ఫైల్ కనుగొనబడలేదు: {0}'
        "GeneratedFile" = '[సరే] రూపొందించిన ఫైల్: {0}'
        "GenericEnsureInternetOrInput" = 'దయచేసి మీరు ఇంటర్నెట్‌కి కనెక్ట్ అయ్యారని లేదా ఫైల్ ''ఇన్‌పుట్'' ఫోల్డర్‌లో ఉందని నిర్ధారించుకోండి.'
        "IndividualBlocks" = 'వ్యక్తిగత బ్లాక్‌లు: {0}'
        "IndividualBlocksNotice" = '[సరే] కాస్మిక్ స్కేల్ కోసం వ్యక్తిగత బ్లాక్‌లు: {0}'
        "InputFileDeleted" = '[సరే] ఇన్‌పుట్ ఫోల్డర్ నుండి ఫైల్(లు) తొలగించబడ్డాయి.'
        "InputFileKept" = '[సరే] ఫైల్(లు) ఇన్‌పుట్ ఫోల్డర్‌లో ఉంచబడ్డాయి.'
        "InvalidOption" = 'చెల్లని ఎంపిక! మళ్లీ ప్రయత్నించడానికి ఎంటర్ నొక్కండి...'
        "LangAppliedSuccess" = '[OK] ఇంటర్‌ఫేస్ భాష విజయవంతంగా వర్తింపజేయబడింది: {0} ({1})'
        "LauncherAutoDetect" = '[సరే] Windows సిస్టమ్ లాంగ్వేజ్ ఆటో-డిటెక్షన్ ప్రారంభించబడింది.'
        "LauncherBaseNotFoundTitle" = '[!] లోపం: బేస్ లాంచర్ స్క్రిప్ట్‌ని డౌన్‌లోడ్ చేయడం లేదా గుర్తించడం సాధ్యపడలేదు!'
        "LauncherIntegrated" = '[సరే] Windows కోసం PSBBN లాంచర్‌లో {0} భాష(లు)కి సమీకృత మద్దతు!'
        "LauncherPrompt" = 'ఒకటి లేదా అంతకంటే ఎక్కువ భాషలను ఎంచుకోండి (ఉదా. 7 లేదా 1, 2, 3 లేదా 1-5 లేదా A):'
        "LauncherTip1" = '- ఆ భాషతో మాత్రమే ఫైల్‌ను రూపొందించడానికి 1 నంబర్‌ను నమోదు చేయండి.'
        "LauncherTipAll" = '- మొత్తం 40 భాషలతో పూర్తి ఫైల్‌ను రూపొందించడానికి ''A''ని నమోదు చేయండి.'
        "LauncherTipHeader" = '* చిట్కా: ప్రతి ఎగ్జిక్యూషన్ ఎంచుకున్న భాష(ల)ను మాత్రమే కలిగి ఉండే క్లీన్ ఫైల్‌ను రూపొందిస్తుంది.'
        "LauncherTipMulti" = '- ఆ భాషలతో రూపొందించడానికి కామాతో వేరు చేయబడిన బహుళ సంఖ్యలను నమోదు చేయండి (ఉదా. 1, 2, 3).'
        "LauncherTipRange" = '- ఆ శ్రేణి భాషలతో రూపొందించడానికి పరిధిని నమోదు చేయండి (ఉదా. 1-5).'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] మునుపటి స్క్రీన్'
        "NavDeleteInput" = '[X] ఇన్‌పుట్ ఫోల్డర్ నుండి ఫైల్‌ను తొలగించండి'
        "NavEnter" = '[నమోదు చేయండి] ప్రధాన మెనూ'
        "NavExit" = '[Esc] నిష్క్రమించు'
        "NavInstructions" = '[నమోదు చేయండి] ప్రధాన మెనూ |  [B] మునుపటి స్క్రీన్ |  [Esc] నిష్క్రమించు'
        "NavKeepInput" = '[V] ఫైల్‌ను ఇన్‌పుట్ ఫోల్డర్‌లో ఉంచండి'
        "OfficialDownloadSuccess" = '[సరే] అధికారిక ఫైల్ విజయవంతంగా డౌన్‌లోడ్ చేయబడింది ({0:N0} బైట్లు).'
        "PkgCompressingGz" = '[*] .NET GZipStream ద్వారా ''bnupdate.tar.gz''కి కుదించబడుతోంది...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar''ని సృష్టిస్తోంది మరియు POSIX అమలు అనుమతులను సెట్ చేస్తోంది (+x)...'
        "PkgErrorTar" = '[!] bnupdate.tarని రూపొందించడం సాధ్యపడలేదు.'
        "PkgGenTitle" = 'PSBBN ఇన్‌స్టాలేషన్ ప్యాకేజీ జనరేషన్ (bnupdate.tar.gz)'
        "PkgNotice1" = '1. అల్లికలు (.tm2 మరియు .png) ఆంగ్లంలో ఉంటాయి (మాన్యువల్ గ్రాఫిక్ రీడిజైన్ అవసరం).'
        "PkgNotice2" = '2. 100% సిస్టమ్ టెక్స్ట్‌లు (XML, ATOK HTML మరియు స్క్రిప్ట్‌లు) అనువదించబడ్డాయి.'
        "PkgNotice3" = '3. ''bnupdate.tar.gz'' ఫైల్ PS2 (HDD / Telnet / USB)లో తక్షణ పరీక్ష కోసం ఉద్దేశించబడింది.'
        "PkgNoticeHeader" = '[సాంకేతిక నోటీసు]:'
        "PkgPromptTar" = 'మీరు PS2లో పరీక్షించడానికి ''bnupdate.tar.gz'' ఫైల్‌ను రూపొందించాలనుకుంటున్నారా? (Y/N) [డిఫాల్ట్: Y]'
        "PkgSuccess" = '[+] ప్యాకేజీ విజయవంతంగా రూపొందించబడింది (Linux 0755 అనుమతులు ప్రారంభించబడ్డాయి): {0} ({1:N0} బైట్లు)'
        "PosixPatchedCount" = '[+] POSIX 0755 అమలు అనుమతితో ప్యాచ్ చేయబడిన ఫైల్‌లు (+x): {0}'
        "PressAnyKey" = 'మెనుకి తిరిగి రావడానికి ఏదైనా కీని నొక్కండి...'
        "ProgressAtokHelp" = 'ATOK సహాయాన్ని అనువదిస్తోంది'
        "ProgressUpdatingHtml" = 'HTML ఫైల్‌లను నవీకరిస్తోంది'
        "ProgressUpdatingXml" = 'XML ఫైల్‌లను నవీకరిస్తోంది'
        "ProgressXmlStrings" = 'XML స్ట్రింగ్‌లను అనువదిస్తోంది'
        "PsbbnEnglishEnsure" = 'దయచేసి ''PSBBN_English'' ఫోల్డర్ ''ఇన్‌పుట్'' లోపల ఉందని నిర్ధారించుకోండి.'
        "PsbbnEnglishNotFoundTitle" = '[!] లోపం: బేస్ డైరెక్టరీ PSBBN_English కనుగొనబడలేదు!'
        "ReadmeEnsure" = 'దయచేసి ''README.md'' ఫైల్ ''ఇన్‌పుట్'' ఫోల్డర్‌లో ఉందని నిర్ధారించుకోండి.'
        "ReadmeNotFoundDownloading" = '[*] README.md కనుగొనబడలేదు. అధికారిక రిపోజిటరీ నుండి డౌన్‌లోడ్ చేస్తోంది...'
        "ReadmeNotFoundTitle" = '[!] లోపం: README.MD ఫైల్ కనుగొనబడలేదు!'
        "ReadmeTitle" = 'PSBBN రీడ్‌మీ అనువాదకుడు [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN స్క్రిప్ట్ ట్రాన్స్‌లేటర్ [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} భాషలు ఎంచుకోబడ్డాయి ({1})'
        "SelectUILangPrompt" = 'ఒక ఎంపికను ఎంచుకోండి'
        "SelectUITitle" = 'UI భాషను మార్చండి'
        "SessionStarted" = 'సెషన్ ప్రారంభమైనది:'
        "SourceFile" = 'మూలం:'
        "Step1Copying" = '[*] [1/3] పూర్తి నిర్మాణం మరియు బైనరీలను కాపీ చేస్తోంది...'
        "Step2TranslatingXml" = '[*] [2/3] {0} సిస్టమ్ XML ఫైల్‌లను అనువదిస్తోంది...'
        "Step3TranslatingAtok" = '[*] [3/3] {0} ATOK HTML సహాయ ఫైళ్లను అనువదిస్తోంది...'
        "SuiteTitle" = 'PSBBN బహుభాషా అనువాద సూట్ - V1 [By Emerson Teles]'
        "SystemTitle" = 'సిస్టమ్ PSBBN అనువాదకుడు [By Emerson Teles]'
        "TextureDisclaimer" = 'గమనిక: అల్లికలు (.tm2 / .png) పొందుపరిచిన గ్రాఫిక్‌లను కలిగి ఉంటాయి   మరియు మాన్యువల్ సవరణ అవసరం; అవి స్క్రిప్ట్ ద్వారా మార్చబడవు. సిస్టమ్   టెక్స్ట్ ఫైల్‌లు (XML, HTML, txt) 100% అనువదించబడ్డాయి.'
        "Translating" = 'అనువదిస్తోంది'
        "UsingFallback" = '[!] స్థానిక ఫాల్‌బ్యాక్‌ని ఉపయోగించడం: {0}'
        "ValidatingXml" = '[*] XML ఫైల్‌లలో 100% వాక్యనిర్మాణ సమగ్రతను ధృవీకరిస్తోంది...'
        "XmlSyntaxError" = '[!] {0}: {1}లో సింటాక్స్ లోపం'
        "XmlValidationSuccess" = '[+] 100% XML ఫైల్‌లు విజయవంతంగా ధృవీకరించబడ్డాయి (0 సింటాక్స్ లోపాలు).'
    }
    "th" = @{
        "All40Success" = 'ทั้งหมด 40 ภาษา (หลายภาษาเต็มรูปแบบ)'
        "AllLanguages" = 'แปลทุกภาษา (1 - 40)'
        "BackMenu" = 'กลับไปที่เมนูหลัก'
        "CancelOption" = 'กลับ'
        "CannotConnectGithub" = '[!] ไม่สามารถเชื่อมต่อกับ GitHub: {0}'
        "ChangeLanguage" = 'เปลี่ยนภาษา UI'
        "ChangelogMainNotFoundTitle" = '[!] ข้อผิดพลาด: ไม่สามารถดาวน์โหลดหรือค้นหา CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ข้อผิดพลาด: ไม่สามารถดาวน์โหลดหรือค้นหา CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'เลือกตัวเลือก:'
        "CompletionBanner" = '[OK] การแปล {0} สำเร็จแล้ว - 100%'
        "DescLauncher" = 'สร้างและอัปเดต PSBBN Launcher สำหรับ Windows พร้อมรองรับทั้งหมด 40 ภาษา'
        "DescMain" = 'แปลบันทึกประจำรุ่นของตัวติดตั้งหลักและบันทึกการเปลี่ยนแปลง (changelog_main_eng.txt)'
        "DescPatch" = 'แปลประวัติแพตช์ การแก้ไข และบันทึกการอัปเดตช่อง (changelog_patch_eng.txt)'
        "DescReadme" = 'แปล PSBBN README.md อย่างเป็นทางการโดยรักษารูปแบบมาร์กดาวน์และลิงก์'
        "DescScript" = 'แปลสตริง UI ทั้งหมด 458 รายการสำหรับ สคริปต์ตัวติดตั้ง Linux/WSL PSBBN (eng.txt)'
        "DescSystem" = 'แปลไฟล์ระบบ PS2 PSBBN ทั้งหมด (กล่องโต้ตอบ XML, คำแนะนำ, เมนู, วิธีใช้ NetFront/ATOK)'
        "DestFile" = 'ปลายทาง:'
        "DownloadingLatestGithub" = '[i] กำลังดาวน์โหลดเวอร์ชันอย่างเป็นทางการล่าสุดจาก GitHub...'
        "DownloadingOfficial" = '[*] กำลังดาวน์โหลดไฟล์อย่างเป็นทางการจากที่เก็บ GitHub...'
        "EnglishOption" = 'ภาษาอังกฤษ (ค่าเริ่มต้น)'
        "EngTxtEnsureFile" = 'โปรดตรวจสอบให้แน่ใจว่ามีไฟล์ ''eng.txt'' อยู่ในโฟลเดอร์ ''input'''
        "EngTxtErrorTitle" = '[!] ข้อผิดพลาด: ไม่พบไฟล์ ENG.TXT!'
        "EngTxtNotFoundDownloading" = '[*] ไม่พบ eng.txt กำลังดาวน์โหลดจากพื้นที่เก็บข้อมูลอย่างเป็นทางการ...'
        "EnsureConnected" = 'โปรดตรวจสอบให้แน่ใจว่าคุณเชื่อมต่อกับอินเทอร์เน็ตหรือวางไฟล์ไว้ในไดเร็กทอรีอินพุต'
        "ExitOption" = 'ออก'
        "ExpectedPath" = 'เส้นทางที่คาดหวัง: {0}'
        "ExtractingPack" = '[*] กำลังแยกแพ็กการแปล PSBBN v3.5...'
        "FileNotFoundError" = '[ข้อผิดพลาด] ไม่พบไฟล์: {0}'
        "GeneratedFile" = '[ตกลง] ไฟล์ที่สร้าง: {0}'
        "GenericEnsureInternetOrInput" = 'โปรดตรวจสอบให้แน่ใจว่าคุณเชื่อมต่อกับอินเทอร์เน็ตหรือมีไฟล์อยู่ในโฟลเดอร์ ''อินพุต'''
        "IndividualBlocks" = 'บล็อกเดี่ยว: {0}'
        "IndividualBlocksNotice" = '[ตกลง] บล็อกส่วนบุคคลสำหรับ CosmicScale: {0}'
        "InputFileDeleted" = '[ตกลง] ไฟล์ที่ถูกลบออกจากโฟลเดอร์อินพุต'
        "InputFileKept" = '[ตกลง] ไฟล์ถูกเก็บไว้ในโฟลเดอร์อินพุต'
        "InvalidOption" = 'ตัวเลือกไม่ถูกต้อง! กด Enter เพื่อลองอีกครั้ง...'
        "LangAppliedSuccess" = '[OK] นำภาษาของอินเทอร์เฟซไปใช้เรียบร้อยแล้ว: {0} ({1})'
        "LauncherAutoDetect" = '[ตกลง] เปิดใช้งานการตรวจจับภาษาของระบบ Windows โดยอัตโนมัติ'
        "LauncherBaseNotFoundTitle" = '[!] ข้อผิดพลาด: ไม่สามารถดาวน์โหลดหรือค้นหาสคริปต์ตัวเรียกใช้ฐานได้!'
        "LauncherIntegrated" = '[ตกลง] การสนับสนุนแบบบูรณาการสำหรับ {0} ภาษาใน PSBBN Launcher สำหรับ Windows!'
        "LauncherPrompt" = 'เลือกหนึ่งภาษาหรือมากกว่า (เช่น 7 หรือ 1, 2, 3 หรือ 1-5 หรือ A):'
        "LauncherTip1" = '- ป้อน 1 หมายเลขเพื่อสร้างไฟล์ด้วยภาษานั้นเท่านั้น'
        "LauncherTipAll" = '- ป้อน ''A'' เพื่อสร้างไฟล์ทั้งหมดที่มีทั้งหมด 40 ภาษา'
        "LauncherTipHeader" = '* เคล็ดลับ: การดำเนินการแต่ละครั้งจะสร้างไฟล์ใหม่ที่มีเฉพาะภาษาที่เลือกเท่านั้น'
        "LauncherTipMulti" = '- ป้อนตัวเลขหลายตัวโดยคั่นด้วยเครื่องหมายจุลภาค (เช่น 1, 2, 3) เพื่อสร้างด้วยภาษาเหล่านั้น'
        "LauncherTipRange" = '- ป้อนช่วง (เช่น 1-5) เพื่อสร้างด้วยช่วงภาษานั้น'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] หน้าจอก่อนหน้า'
        "NavDeleteInput" = '[X] ลบไฟล์ออกจากโฟลเดอร์อินพุต'
        "NavEnter" = '[เข้าสู่] เมนูหลัก'
        "NavExit" = '[Esc] ออก'
        "NavInstructions" = '[Enter] เมนูหลัก |  [B] หน้าจอก่อนหน้า |  [Esc] ออก'
        "NavKeepInput" = '[V] เก็บไฟล์ไว้ในโฟลเดอร์อินพุต'
        "OfficialDownloadSuccess" = '[ตกลง] ดาวน์โหลดไฟล์อย่างเป็นทางการสำเร็จแล้ว ({0:N0} ไบต์)'
        "PkgCompressingGz" = '[*] กำลังบีบอัดเป็น ''bnupdate.tar.gz'' ผ่าน .NET GZipStream...'
        "PkgCreatingTar" = '[*] การสร้าง ''bnupdate.tar'' และการตั้งค่าสิทธิ์การดำเนินการ POSIX (+x)...'
        "PkgErrorTar" = '[!] ไม่สามารถสร้าง bnupdate.tar'
        "PkgGenTitle" = 'การสร้างแพ็คเกจการติดตั้ง PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. พื้นผิว (.tm2 และ .png) ยังคงเป็นภาษาอังกฤษ (ต้องมีการออกแบบกราฟิกใหม่ด้วยตนเอง)'
        "PkgNotice2" = '2. ข้อความระบบ 100% (XML, ATOK HTML และสคริปต์) ได้รับการแปล'
        "PkgNotice3" = '3. ไฟล์ ''bnupdate.tar.gz'' มีไว้สำหรับการทดสอบทันทีบน PS2 (HDD / Telnet / USB)'
        "PkgNoticeHeader" = '[ประกาศทางเทคนิค]:'
        "PkgPromptTar" = 'คุณต้องการสร้างไฟล์ ''bnupdate.tar.gz'' เพื่อทดสอบบน PS2 หรือไม่ (ใช่/ไม่มี) [ค่าเริ่มต้น: Y]'
        "PkgSuccess" = '[+] สร้างแพ็คเกจสำเร็จแล้ว (เปิดใช้งานการอนุญาต Linux 0755): {0} ({1:N0} ไบต์)'
        "PosixPatchedCount" = '[+] ไฟล์ที่ได้รับแพตช์ด้วยสิทธิ์ดำเนินการ POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'กดปุ่มใดก็ได้เพื่อกลับสู่เมนู...'
        "ProgressAtokHelp" = 'กำลังแปลวิธีใช้ ATOK'
        "ProgressUpdatingHtml" = 'กำลังอัปเดตไฟล์ HTML'
        "ProgressUpdatingXml" = 'กำลังอัปเดตไฟล์ XML'
        "ProgressXmlStrings" = 'การแปลสตริง XML'
        "PsbbnEnglishEnsure" = 'โปรดตรวจสอบให้แน่ใจว่ามีโฟลเดอร์ ''PSBBN_English'' อยู่ใน ''input'''
        "PsbbnEnglishNotFoundTitle" = '[!] ข้อผิดพลาด: ไม่พบไดเรกทอรีฐาน PSBBN_ENGLISH!'
        "ReadmeEnsure" = 'โปรดตรวจสอบให้แน่ใจว่าไฟล์ ''README.md'' อยู่ในโฟลเดอร์ ''input'''
        "ReadmeNotFoundDownloading" = '[*] ไม่พบ README.md กำลังดาวน์โหลดจากพื้นที่เก็บข้อมูลอย่างเป็นทางการ...'
        "ReadmeNotFoundTitle" = '[!] ข้อผิดพลาด: ไม่พบไฟล์ README.MD!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} ภาษาที่เลือก ({1})'
        "SelectUILangPrompt" = 'เลือกตัวเลือก'
        "SelectUITitle" = 'เปลี่ยนภาษา UI'
        "SessionStarted" = 'เซสชันที่เริ่มต้นเมื่อ:'
        "SourceFile" = 'แหล่งที่มา:'
        "Step1Copying" = '[*] [1/3] กำลังคัดลอกโครงสร้างและไบนารีที่สมบูรณ์...'
        "Step2TranslatingXml" = '[*] [2/3] กำลังแปลไฟล์ XML ระบบ {0}...'
        "Step3TranslatingAtok" = '[*] [3/3] กำลังแปล {0} ATOK ไฟล์วิธีใช้ HTML...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN นักแปล [By Emerson Teles]'
        "TextureDisclaimer" = 'ประกาศ: พื้นผิว (.tm2 / .png)   มีกราฟิกฝังอยู่และต้องมีการแก้ไขด้วยตนเอง   สคริปต์จะไม่มีการเปลี่ยนแปลงใดๆ ไฟล์ข้อความระบบ (XML, HTML, txt)   ได้รับการแปลแล้ว 100%'
        "Translating" = 'การแปล'
        "UsingFallback" = '[!] การใช้ทางเลือกท้องถิ่น: {0}'
        "ValidatingXml" = '[*] กำลังตรวจสอบความถูกต้องทางวากยสัมพันธ์ของไฟล์ XML 100%...'
        "XmlSyntaxError" = '[!] ข้อผิดพลาดทางไวยากรณ์ใน {0}: {1}'
        "XmlValidationSuccess" = '[+] ตรวจสอบไฟล์ XML สำเร็จ 100% (ข้อผิดพลาดทางไวยากรณ์ 0 รายการ)'
    }
    "tl" = @{
        "All40Success" = 'Lahat ng 40 Wika (Buong Multilingual)'
        "AllLanguages" = 'Isalin ang Lahat ng Wika (1 - 40)'
        "BackMenu" = 'Bumalik sa Main Menu'
        "CancelOption" = 'Bumalik'
        "CannotConnectGithub" = '[!] Hindi makakonekta sa GitHub: {0}'
        "ChangeLanguage" = 'Baguhin ang UI Language'
        "ChangelogMainNotFoundTitle" = '[!] ERROR: HINDI MA-DOWNLOAD O HANAPIN ANG CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ERROR: HINDI MA-DOWNLOAD O HANAPIN ANG CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Tagasalin ng PSBBN Changelog Patch [By Emerson Teles]'
        "ChooseOption" = 'Pumili ng opsyon:'
        "CompletionBanner" = '[OK] Ang pagsasalin ng {0} ay matagumpay na natapos - 100%'
        "DescLauncher" = 'Binubuo at ina-update ang PSBBN Launcher para sa Windows na may suporta para sa lahat ng 40 wika.'
        "DescMain" = 'Isinasalin ang pangunahing mga tala sa paglabas ng installer at changelog (changelog_main_eng.txt).'
        "DescPatch" = 'Nagsasalin ng kasaysayan ng patch, mga pag-aayos, at mga tala sa pag-update ng channel (changelog_patch_eng.txt).'
        "DescReadme" = 'Isinasalin ang opisyal na PSBBN README.md na nagpapanatili ng markdown na pag-format at mga link.'
        "DescScript" = 'Isinasalin ang lahat ng 458 UI string para sa Linux/WSL PSBBN installer script (eng.txt).'
        "DescSystem" = 'Isinasalin ang lahat ng PS2 PSBBN system file (mga XML dialog, gabay, menu, tulong sa NetFront/ATOK).'
        "DestFile" = 'Patutunguhan:'
        "DownloadingLatestGithub" = '[i] Dina-download ang pinakabagong opisyal na bersyon mula sa GitHub...'
        "DownloadingOfficial" = '[*] Dina-download ang opisyal na file mula sa GitHub repository...'
        "EnglishOption" = 'Ingles (default)'
        "EngTxtEnsureFile" = 'Pakitiyak na ang ''eng.txt'' na file ay nasa folder na ''input''.'
        "EngTxtErrorTitle" = '[!] ERROR: HINDI Natagpuan ang ENG.TXT FILE!'
        "EngTxtNotFoundDownloading" = 'Hindi nakita ang [*] eng.txt. Nagda-download mula sa opisyal na imbakan...'
        "EnsureConnected" = 'Pakitiyak na nakakonekta ka sa Internet o ilagay ang file sa direktoryo ng input.'
        "ExitOption" = 'Lumabas'
        "ExpectedPath" = 'Inaasahang landas: {0}'
        "ExtractingPack" = '[*] Kinukuha ang PSBBN v3.5 translation pack...'
        "FileNotFoundError" = '[ERROR] Hindi nakita ang file: {0}'
        "GeneratedFile" = '[OK] Binuo ng file: {0}'
        "GenericEnsureInternetOrInput" = 'Pakitiyak na nakakonekta ka sa Internet o nasa folder na ''input'' ang file.'
        "IndividualBlocks" = 'Mga Indibidwal na Block: {0}'
        "IndividualBlocksNotice" = '[OK] Mga indibidwal na block para sa CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Ang (mga) file ay tinanggal mula sa folder ng input.'
        "InputFileKept" = '[OK] (Mga) file na nakatago sa input folder.'
        "InvalidOption" = 'Di-wastong opsyon! Pindutin ang Enter upang subukang muli...'
        "LangAppliedSuccess" = '[OK] Matagumpay na nailapat ang wika ng UI: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Pinagana ang auto-detection ng wika ng system ng Windows.'
        "LauncherBaseNotFoundTitle" = '[!] ERROR: HINDI MA-DOWNLOAD O HANAPIN ANG BASE LAUNCHER SCRIPT!'
        "LauncherIntegrated" = '[OK] Pinagsamang suporta para sa {0} (mga) wika sa PSBBN Launcher para sa Windows!'
        "LauncherPrompt" = 'Pumili ng isa o higit pang mga wika (hal. 7 o 1, 2, 3 o 1-5 o A):'
        "LauncherTip1" = '- Maglagay ng 1 numero upang mabuo ang file gamit lamang ang wikang iyon.'
        "LauncherTipAll" = '- Ilagay ang ''A'' para buuin ang kumpletong file kasama ang lahat ng 40 wika.'
        "LauncherTipHeader" = '* Tip: Ang bawat execution ay bumubuo ng malinis na file na naglalaman lamang ng napiling (mga) wika.'
        "LauncherTipMulti" = '- Maglagay ng maraming numero na pinaghihiwalay ng kuwit (hal. 1, 2, 3) upang bumuo gamit ang mga wikang iyon.'
        "LauncherTipRange" = '- Maglagay ng hanay (hal. 1-5) na bubuo gamit ang hanay ng mga wikang iyon.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Nakaraang Screen'
        "NavDeleteInput" = '[X] Tanggalin ang file mula sa input folder'
        "NavEnter" = '[Enter] Pangunahing Menu'
        "NavExit" = '[Esc] Lumabas'
        "NavInstructions" = '[Enter] Pangunahing Menu |  [B] Nakaraang Screen |  [Esc] Lumabas'
        "NavKeepInput" = '[V] Panatilihin ang file sa input folder'
        "OfficialDownloadSuccess" = '[OK] Matagumpay na na-download ang opisyal na file ({0:N0} bytes).'
        "PkgCompressingGz" = '[*] Kino-compress sa ''bnupdate.tar.gz'' sa pamamagitan ng .NET GZipStream...'
        "PkgCreatingTar" = '[*] Gumagawa ng ''bnupdate.tar'' at nagtatakda ng mga pahintulot sa pagpapatupad ng POSIX (+x)...'
        "PkgErrorTar" = '[!] Hindi makabuo ng bnupdate.tar.'
        "PkgGenTitle" = 'PAGBUBUO NG PACKAGE NG PAG-INSTALL NG PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Ang mga texture (.tm2 at .png) ay nananatili sa English (nangangailangan ng manu-manong graphic na muling pagdidisenyo).'
        "PkgNotice2" = '2. 100% ng mga text ng system (XML, ATOK HTML at mga script) ay isinalin.'
        "PkgNotice3" = '3. Ang ''bnupdate.tar.gz'' na file ay inilaan para sa agarang pagsubok sa PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[TEKNIKAL NA PAUNAWA]:'
        "PkgPromptTar" = 'Gusto mo bang buuin ang ''bnupdate.tar.gz'' na file upang subukan sa PS2? (Y/N) [Default: Y]'
        "PkgSuccess" = '[+] Matagumpay na nabuo ang package (pinagana ang mga pahintulot sa Linux 0755): {0} ({1:N0} bytes)'
        "PosixPatchedCount" = '[+] Mga file na na-patch na may pahintulot sa pagpapatupad ng POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Pindutin ang anumang key upang bumalik sa menu...'
        "ProgressAtokHelp" = 'Pagsasalin ng ATOK Help'
        "ProgressUpdatingHtml" = 'Ina-update ang mga HTML file'
        "ProgressUpdatingXml" = 'Ina-update ang mga XML file'
        "ProgressXmlStrings" = 'Pagsasalin ng mga XML string'
        "PsbbnEnglishEnsure" = 'Pakitiyak na ang folder na ''PSBBN_English'' ay nasa loob ng ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] ERROR: BASE DIRECTORY PSBBN_ENGLISH NOT FOUND!'
        "ReadmeEnsure" = 'Pakitiyak na ang ''README.md'' na file ay nasa ''input'' na folder.'
        "ReadmeNotFoundDownloading" = '[*] Hindi nakita ang README.md. Nagda-download mula sa opisyal na imbakan...'
        "ReadmeNotFoundTitle" = '[!] ERROR: HINDI Natagpuan ang README.MD FILE!'
        "ReadmeTitle" = 'Tagasalin ng PSBBN Readme [By Emerson Teles]'
        "ScriptTitle" = 'Tagasalin ng PSBBN Script [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} wika ang napili ({1})'
        "SelectUILangPrompt" = 'Pumili ng opsyon'
        "SelectUITitle" = 'BAGUHIN ANG UI LANGUAGE'
        "SessionStarted" = 'Nagsimula ang session noong:'
        "SourceFile" = 'Pinagmulan:'
        "Step1Copying" = '[*] [1/3] Kinokopya ang kumpletong istraktura at binary...'
        "Step2TranslatingXml" = '[*] [2/3] Nagsasalin ng {0} system XML file...'
        "Step3TranslatingAtok" = '[*] [3/3] Nagsasalin ng {0} ATOK HTML na mga help file...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'Tagasalin ng System PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Notice: Textures (.tm2 / .png) contain embedded graphics and require   manual editing; hindi sila binabago ng script. Ang mga text file ng   system (XML, HTML, txt) ay 100% isinalin.'
        "Translating" = 'Pagsasalin'
        "UsingFallback" = '[!] Gamit ang lokal na fallback: {0}'
        "ValidatingXml" = '[*] Pinapatunayan ang syntactic na integridad ng 100% ng mga XML file...'
        "XmlSyntaxError" = '[!] Syntax error sa {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% ng mga XML file ay matagumpay na napatunayan (0 syntax error).'
    }
    "tr" = @{
        "All40Success" = '40 Dilin Tamamı (Tam Çok Dilli)'
        "AllLanguages" = 'Tüm Dilleri Çevir (1 - 40)'
        "BackMenu" = 'Ana Menüye Dön'
        "CancelOption" = 'Geri'
        "CannotConnectGithub" = '[!] GitHub''a bağlanılamıyor: {0}'
        "ChangeLanguage" = 'Kullanıcı Arayüzü Dilini Değiştir'
        "ChangelogMainNotFoundTitle" = '[!] HATA: CHANGELOG_MAIN_ENG.TXT İNDİRİLEMEDİ VEYA BULUNAMADI!'
        "ChangelogMainTitle" = 'PSBBN Değişiklik Günlüğü Ana Çevirmeni [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] HATA: CHANGELOG_PATCH_ENG.TXT İNDİRİLEMEDİ VEYA BULUNAMADI!'
        "ChangelogPatchTitle" = 'PSBBN Değişiklik Günlüğü Yama Çeviricisi [By Emerson Teles]'
        "ChooseOption" = 'Bir seçenek belirleyin:'
        "CompletionBanner" = '[OK] {0} kelimesinin çevirisi başarıyla tamamlandı - %100'
        "DescLauncher" = '40 dilin tamamını destekleyen Windows için PSBBN Başlatıcısını oluşturur ve günceller.'
        "DescMain" = 'Ana yükleyici sürüm notlarını ve değişiklik günlüğünü (changelog_main_eng.txt) çevirir.'
        "DescPatch" = 'Yama geçmişini, düzeltmeleri ve kanal güncelleme notlarını (changelog_patch_eng.txt) çevirir.'
        "DescReadme" = 'Markdown formatını ve bağlantılarını koruyarak resmi PSBBN README.md''yi çevirir.'
        "DescScript" = '458''in tümünü çevirir Linux/WSL PSBBN yükleyici komut dosyası (eng.txt) için kullanıcı arayüzü dizeleri.'
        "DescSystem" = 'Tüm PS2 PSBBN sistem dosyalarını çevirir (XML iletişim kutuları, kılavuzlar, menüler, NetFront/ATOK yardımı).'
        "DestFile" = 'Hedef:'
        "DownloadingLatestGithub" = '[i] GitHub''dan en son resmi sürüm indiriliyor...'
        "DownloadingOfficial" = '[*] Resmi dosya GitHub deposundan indiriliyor...'
        "EnglishOption" = 'İngilizce (varsayılan)'
        "EngTxtEnsureFile" = 'Lütfen ''eng.txt'' dosyasının ''input'' klasöründe bulunduğundan emin olun.'
        "EngTxtErrorTitle" = '[!] HATA: ENG.TXT DOSYASI BULUNAMADI!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt bulunamadı. Resmi depodan indiriliyor...'
        "EnsureConnected" = 'Lütfen internete bağlı olduğunuzdan emin olun veya dosyayı giriş dizinine yerleştirin.'
        "ExitOption" = 'Çıkış'
        "ExpectedPath" = 'Beklenen yol: {0}'
        "ExtractingPack" = '[*] PSBBN v3.5 çeviri paketi çıkarılıyor...'
        "FileNotFoundError" = '[HATA] Dosya bulunamadı: {0}'
        "GeneratedFile" = '[Tamam] Oluşturulan dosya: __0___'
        "GenericEnsureInternetOrInput" = 'Lütfen internete bağlı olduğunuzdan veya dosyanın ''giriş'' klasöründe olduğundan emin olun.'
        "IndividualBlocks" = 'Bireysel Bloklar: {0}'
        "IndividualBlocksNotice" = '[OK] CosmicScale için ayrı bloklar: {0}'
        "InputFileDeleted" = '[OK] Dosya(lar) giriş klasöründen silindi.'
        "InputFileKept" = '[OK] Dosya(lar) giriş klasöründe tutulur.'
        "InvalidOption" = 'Geçersiz seçenek! Tekrar denemek için Enter''a basın...'
        "LangAppliedSuccess" = '[OK] Arayüz dili başarıyla uygulandı: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Windows sistem dilinin otomatik tespiti etkinleştirildi.'
        "LauncherBaseNotFoundTitle" = '[!] HATA: TEMEL BAŞLATICI YAZISI İNDİRİLEMEDİ VEYA BULUNAMADI!'
        "LauncherIntegrated" = '[OK] Windows için PSBBN Başlatıcı''ya __0___ dil(ler) için entegre destek!'
        "LauncherPrompt" = 'Bir veya daha fazla dil seçin (ör. 7 veya 1, 2, 3 veya 1-5 veya A):'
        "LauncherTip1" = '- Dosyayı yalnızca bu dilde oluşturmak için 1 sayı girin.'
        "LauncherTipAll" = '- Dosyanın tamamını 40 dilin tamamıyla oluşturmak için ''A'' girin.'
        "LauncherTipHeader" = '* İpucu: Her yürütme, yalnızca seçilen dilleri içeren temiz bir dosya oluşturur.'
        "LauncherTipMulti" = '- Bu dillerle oluşturmak için virgülle ayrılmış birden fazla sayı girin (ör. 1, 2, 3).'
        "LauncherTipRange" = '- Bu dil aralığıyla oluşturulacak aralığı (örneğin 1-5) girin.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Önceki Ekran'
        "NavDeleteInput" = '[X] Giriş klasöründen dosyayı sil'
        "NavEnter" = '[Giriş] Ana Menü'
        "NavExit" = '[Esc] Çıkış'
        "NavInstructions" = '[Enter] Ana Menü |  [B] Önceki Ekran |  [Esc] Çıkış'
        "NavKeepInput" = '[V] Dosyayı giriş klasöründe tut'
        "OfficialDownloadSuccess" = '[OK] Resmi dosya başarıyla indirildi ({0:N0} bayt).'
        "PkgCompressingGz" = '[*] .NET GZipStream aracılığıyla ''bnupdate.tar.gz'' dosyasına sıkıştırılıyor...'
        "PkgCreatingTar" = '[*] ''bnupdate.tar'' oluşturuluyor ve POSIX yürütme izinleri (+x) ayarlanıyor...'
        "PkgErrorTar" = '[!] bnupdate.tar oluşturulamadı.'
        "PkgGenTitle" = 'PSBBN KURULUM PAKETİ OLUŞTURMA (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Dokular (.tm2 ve .png) İngilizce olarak kalır (manuel grafik tasarımı gerektirir).'
        "PkgNotice2" = '2. Sistem metinlerinin (XML, ATOK HTML ve scriptler) %100''ü çevrilir.'
        "PkgNotice3" = '3. ''bnupdate.tar.gz'' dosyası PS2''de (HDD / Telnet / USB) anında test edilmek üzere tasarlanmıştır.'
        "PkgNoticeHeader" = '[TEKNİK BİLDİRİM]:'
        "PkgPromptTar" = 'PS2''de test etmek için ''bnupdate.tar.gz'' dosyasını oluşturmak istiyor musunuz? (E/H) [Varsayılan: E]'
        "PkgSuccess" = '[+] Paket başarıyla oluşturuldu (Linux 0755 izinleri etkinleştirildi): {0} ({1:N0} bayt)'
        "PosixPatchedCount" = '[+] POSIX 0755 yürütme izniyle (+x) yamalı dosyalar: __0___'
        "PressAnyKey" = 'Menüye dönmek için herhangi bir tuşa basın...'
        "ProgressAtokHelp" = 'ATOK Yardımının Çevirisi'
        "ProgressUpdatingHtml" = 'HTML dosyalarını güncelleme'
        "ProgressUpdatingXml" = 'XML dosyalarını güncelleme'
        "ProgressXmlStrings" = 'XML dizelerini çevirme'
        "PsbbnEnglishEnsure" = 'Lütfen ''input'' içinde ''PSBBN_English'' klasörünün bulunduğundan emin olun.'
        "PsbbnEnglishNotFoundTitle" = '[!] HATA: BAZ DİZİNİ PSBBN_İNGİLİZCE BULUNAMADI!'
        "ReadmeEnsure" = 'Lütfen ''README.md'' dosyasının ''input'' klasöründe olduğundan emin olun.'
        "ReadmeNotFoundDownloading" = '[*] README.md bulunamadı. Resmi depodan indiriliyor...'
        "ReadmeNotFoundTitle" = '[!] HATA: README.MD DOSYASI BULUNAMADI!'
        "ReadmeTitle" = 'PSBBN Beni Oku Çevirmeni [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Komut Dosyası Çevirmeni [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} diller seçildi ({1})'
        "SelectUILangPrompt" = 'Bir seçenek belirleyin'
        "SelectUITitle" = 'KULLANICI ARAYÜZÜ DILINI DEĞIŞTIR'
        "SessionStarted" = 'Oturum şu tarihte başladı:'
        "SourceFile" = 'Kaynak:'
        "Step1Copying" = '[*] [1/3] Tüm yapı ve ikili dosyalar kopyalanıyor...'
        "Step2TranslatingXml" = '[*] [2/3] __0___ sistem XML dosyaları çevriliyor...'
        "Step3TranslatingAtok" = '[*] [3/3] __0___ ATOK HTML yardım dosyaları çevriliyor...'
        "SuiteTitle" = 'PSBBN Çok Dilde Çeviri Paketi - V1 [By Emerson Teles]'
        "SystemTitle" = 'Sistem PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Dikkat: Dokular (.tm2 / .png) gömülü grafikler içerir ve manuel   düzenleme gerektirir; komut dosyası tarafından değiştirilmezler.   Sistem metin dosyaları (XML, HTML, txt) %100 çevrilmiştir.'
        "Translating" = 'Çeviri'
        "UsingFallback" = '[!] Yerel geri dönüş kullanılıyor: {0}'
        "ValidatingXml" = '[*] XML dosyalarının %100''ünün sözdizimsel bütünlüğü doğrulanıyor...'
        "XmlSyntaxError" = '[!] {0}''da sözdizimi hatası: {1}'
        "XmlValidationSuccess" = '[+] XML dosyalarının %100''ü başarıyla doğrulandı (0 sözdizimi hatası).'
    }
    "uk" = @{
        "All40Success" = 'Усі 40 мов (повна багатомовність)'
        "AllLanguages" = 'Перекласти всі мови (1–40)'
        "BackMenu" = 'Назад до головного меню'
        "CancelOption" = 'Назад'
        "CannotConnectGithub" = '[!] Неможливо підключитися до GitHub: {0}'
        "ChangeLanguage" = 'Змінити мову інтерфейсу користувача'
        "ChangelogMainNotFoundTitle" = '[!] ПОМИЛКА: НЕ МОЖНА ЗАВАНТАЖИТИ АБО ЗНАХОДИТИ CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'Перекладач журналу змін PSBBN [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] ПОМИЛКА: НЕ МОЖНА ЗАВАНТАЖИТИ АБО ЗНАХОДИТИ CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'Перекладач виправлень журналу змін PSBBN [By Emerson Teles]'
        "ChooseOption" = 'Виберіть параметр:'
        "CompletionBanner" = '[OK] Переклад {0} успішно завершено – 100%'
        "DescLauncher" = 'Створює та оновлює програму запуску PSBBN для Windows із підтримкою всіх 40 мов.'
        "DescMain" = 'Перекладає примітки до основного випуску інсталятора та журнал змін (changelog_main_eng.txt).'
        "DescPatch" = 'Перекладає історію виправлень, виправлення та примітки до оновлення каналу (changelog_patch_eng.txt).'
        "DescReadme" = 'Перекладає офіційний PSBBN README.md зберігаючи форматування розмітки та посилання.'
        "DescScript" = 'Перекладає всі 458 рядків інтерфейсу користувача для сценарію інсталятора Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'Перекладає всі системні файли PSBBN PS2 (діалогові вікна XML, посібники, меню, довідка NetFront/ATOK).'
        "DestFile" = 'Призначення:'
        "DownloadingLatestGithub" = '[i] Завантаження останньої офіційної версії з GitHub...'
        "DownloadingOfficial" = '[*] Завантаження офіційного файлу з репозиторію GitHub...'
        "EnglishOption" = 'Англійська (за замовчуванням)'
        "EngTxtEnsureFile" = 'Будь ласка, переконайтеся, що файл «eng.txt» присутній у папці «input».'
        "EngTxtErrorTitle" = '[!] ПОМИЛКА: ФАЙЛ ENG.TXT НЕ ЗНАЙДЕНО!'
        "EngTxtNotFoundDownloading" = '[*] eng.txt не знайдено. Завантаження з офіційного репозиторію...'
        "EnsureConnected" = 'Переконайтеся, що ви підключені до Інтернету, або помістіть файл у вхідний каталог.'
        "ExitOption" = 'Вийти'
        "ExpectedPath" = 'Expected path: {0}'
        "ExtractingPack" = '[*] Видобування пакета перекладів PSBBN v3.5...'
        "FileNotFoundError" = '[ERROR] File not found: {0}'
        "GeneratedFile" = '[OK] Generated file: {0}'
        "GenericEnsureInternetOrInput" = 'Переконайтеся, що ви підключені до Інтернету або маєте файл у папці «вхід».'
        "IndividualBlocks" = 'Окремі блоки: {0}'
        "IndividualBlocksNotice" = '[OK] Окремі блоки для CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Файл(и) видалено з вхідної папки.'
        "InputFileKept" = '[OK] Файли зберігаються у вхідній папці.'
        "InvalidOption" = 'Недійсний варіант! Натисніть Enter, щоб повторити спробу...'
        "LangAppliedSuccess" = '[OK] Мову інтерфейсу успішно застосовано: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Увімкнено автоматичне визначення мови системи Windows.'
        "LauncherBaseNotFoundTitle" = '[!] ПОМИЛКА: НЕ МОЖНА ЗАВАНТАЖИТИ АБО ЗНАХОДИТИ БАЗОВИЙ СЦЕНАРІЙ ЗАПУСКА!'
        "LauncherIntegrated" = '[OK] Інтегрована підтримка {0} мов у програму запуску PSBBN для Windows!'
        "LauncherPrompt" = 'Виберіть одну або кілька мов (наприклад, 7 або 1, 2, 3 або 1-5 або A):'
        "LauncherTip1" = '- Введіть 1 число, щоб створити файл лише цією мовою.'
        "LauncherTipAll" = '- Введіть «A», щоб створити повний файл усіма 40 мовами.'
        "LauncherTipHeader" = '* Підказка: кожне виконання генерує чистий файл, що містить лише вибрані мови.'
        "LauncherTipMulti" = '- Введіть кілька чисел, розділених комами (наприклад, 1, 2, 3), щоб створити ці мови.'
        "LauncherTipRange" = '- Введіть діапазон (наприклад, 1-5), щоб створити з цим діапазоном мов.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Попередній екран'
        "NavDeleteInput" = '[X] Видалити файл із вхідної папки'
        "NavEnter" = '[Enter] Головне меню'
        "NavExit" = '[Esc] Вихід'
        "NavInstructions" = '[Enter] Головне меню |  [B] Попередній екран |  [Esc] Вийти'
        "NavKeepInput" = '[V] Зберігати файл у вхідній папці'
        "OfficialDownloadSuccess" = '[OK] Офіційний файл успішно завантажено ({0:N0} байт).'
        "PkgCompressingGz" = '[*] Стиснення до ''bnupdate.tar.gz'' через .NET GZipStream...'
        "PkgCreatingTar" = '[*] Створення ''bnupdate.tar'' і встановлення дозволів на виконання POSIX (+x)...'
        "PkgErrorTar" = '[!] Could not generate bnupdate.tar.'
        "PkgGenTitle" = 'ГЕНЕРУВАННЯ ІНСТАЛЯЦІЙНОГО ПАКЕТУ PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Текстури (.tm2 і .png) залишаються англійською мовою (вимагають ручного графічного редизайну).'
        "PkgNotice2" = '2. Перекладено 100% системних текстів (XML, ATOK HTML і скрипти).'
        "PkgNotice3" = '3. Файл ''bnupdate.tar.gz'' призначений для негайного тестування на PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[ТЕХНІЧНА ПРИМІТКА]:'
        "PkgPromptTar" = 'Ви хочете створити файл «bnupdate.tar.gz» для тестування на PS2? (Y/N) [За замовчуванням: Y]'
        "PkgSuccess" = '[+] Пакет створено успішно (дозволи Linux 0755 увімкнено): {0} ({1:N0} байтів)'
        "PosixPatchedCount" = '[+] Файли, виправлені за допомогою дозволу на виконання POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Press any key to return to menu...'
        "ProgressAtokHelp" = 'Переклад ATOK Допомога'
        "ProgressUpdatingHtml" = 'Оновлення файлів HTML'
        "ProgressUpdatingXml" = 'Оновлення файлів XML'
        "ProgressXmlStrings" = 'Translating XML strings'
        "PsbbnEnglishEnsure" = 'Будь ласка, переконайтеся, що папка «PSBBN_English» присутня всередині «input».'
        "PsbbnEnglishNotFoundTitle" = '[!] ПОМИЛКА: БАЗОВИЙ КАТАЛОГ PSBBN_ENGLISH НЕ ЗНАЙДЕНО!'
        "ReadmeEnsure" = 'Будь ласка, переконайтеся, що файл «README.md» знаходиться у папці «input».'
        "ReadmeNotFoundDownloading" = '[*] README.md не знайдено. Завантаження з офіційного репозиторію...'
        "ReadmeNotFoundTitle" = '[!] ПОМИЛКА: ФАЙЛ README.MD НЕ ЗНАЙДЕНО!'
        "ReadmeTitle" = 'Перекладач Readme PSBBN [By Emerson Teles]'
        "ScriptTitle" = 'Перекладач сценаріїв PSBBN [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} languages selected ({1})'
        "SelectUILangPrompt" = 'Виберіть параметр'
        "SelectUITitle" = 'ЗМІНИТИ МОВУ ІНТЕРФЕЙСУ КОРИСТУВАЧА'
        "SessionStarted" = 'Сеанс розпочато:'
        "SourceFile" = 'Джерело:'
        "Step1Copying" = '[*] [1/3] Копіювання повної структури та двійкових файлів...'
        "Step2TranslatingXml" = '[*] [2/3] Переклад {0} системних файлів XML...'
        "Step3TranslatingAtok" = '[*] [3/3] Переклад файлів довідки {0} ATOK HTML...'
        "SuiteTitle" = 'PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]'
        "SystemTitle" = 'Перекладач системного PSBBN [By Emerson Teles]'
        "TextureDisclaimer" = 'Примітка: текстури (.tm2 / .png) містять вбудовану графіку ��а   потребують редагування вручну; вони не змінюються сценарієм. Системні   текстові файли (XML, HTML, txt) перекладено на 100%.'
        "Translating" = 'Переклад'
        "UsingFallback" = '[!] Використання локального резервного варіанту: {0}'
        "ValidatingXml" = '[*] Перевірка синтаксичної цілісності 100% файлів XML...'
        "XmlSyntaxError" = '[!] Синтаксична помилка в {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% файлів XML успішно перевірено (0 синтаксичних помилок).'
    }
    "vi" = @{
        "All40Success" = 'Tất cả 40 ngôn ngữ (Đa ngôn ngữ)'
        "AllLanguages" = 'Dịch tất cả ngôn ngữ (1 - 40)'
        "BackMenu" = 'Quay lại Menu chính'
        "CancelOption" = 'Quay lại'
        "CannotConnectGithub" = '[!] Không thể kết nối với GitHub: {0}'
        "ChangeLanguage" = 'Thay đổi ngôn ngữ giao diện người dùng'
        "ChangelogMainNotFoundTitle" = '[!] LỖI: KHÔNG THỂ TẢI XUỐNG HOẶC ĐỊNH VỊ CHANGELOG_MAIN_ENG.TXT!'
        "ChangelogMainTitle" = 'PSBBN Changelog Main Translator [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] LỖI: KHÔNG THỂ TẢI XUỐNG HOẶC ĐỊNH VỊ CHANGELOG_PATCH_ENG.TXT!'
        "ChangelogPatchTitle" = 'PSBBN Changelog Patch Translator [By Emerson Teles]'
        "ChooseOption" = 'Chọn một tùy chọn:'
        "CompletionBanner" = '[OK] Bản dịch của {0} đã hoàn tất thành công - 100%'
        "DescLauncher" = 'Tạo và cập nhật Trình khởi chạy PSBBN cho Windows với sự hỗ trợ cho tất cả 40 ngôn ngữ.'
        "DescMain" = 'Dịch ghi chú phát hành và nhật ký thay đổi của trình cài đặt chính (changelog_main_eng.txt).'
        "DescPatch" = 'Dịch lịch sử bản vá, bản sửa lỗi và ghi chú cập nhật kênh (changelog_patch_eng.txt).'
        "DescReadme" = 'Dịch PSBBN README.md chính thức giữ nguyên định dạng và liên kết đánh dấu.'
        "DescScript" = 'Dịch tất cả 458 chuỗi giao diện người dùng cho tập lệnh trình cài đặt PSBBN Linux/WSL PSBBN (eng.txt).'
        "DescSystem" = 'Dịch tất cả các tệp hệ thống PS2 PSBBN (hộp thoại XML, hướng dẫn, menu, trợ giúp NetFront/ATOK).'
        "DestFile" = 'Đích:'
        "DownloadingLatestGithub" = '[i] Đang tải xuống phiên bản chính thức mới nhất từ ​​GitHub...'
        "DownloadingOfficial" = '[*] Đang tải xuống tệp chính thức từ kho GitHub...'
        "EnglishOption" = 'Tiếng Anh (mặc định)'
        "EngTxtEnsureFile" = 'Hãy đảm bảo rằng tệp ''eng.txt'' có trong thư mục ''input''.'
        "EngTxtErrorTitle" = '[!] LỖI: KHÔNG TÌM THẤY TỆP ENG.TXT!'
        "EngTxtNotFoundDownloading" = '[*] không tìm thấy eng.txt. Đang tải xuống từ kho lưu trữ chính thức...'
        "EnsureConnected" = 'Hãy đảm bảo bạn đã kết nối với Internet hoặc đặt tệp vào thư mục đầu vào.'
        "ExitOption" = 'Thoát'
        "ExpectedPath" = 'Đường đi dự kiến: {0}'
        "ExtractingPack" = '[*] Đang giải nén gói dịch PSBBN v3.5...'
        "FileNotFoundError" = '[ERROR] Không tìm thấy tệp: {0}'
        "GeneratedFile" = '[OK] Tệp đã tạo: {0}'
        "GenericEnsureInternetOrInput" = 'Hãy đảm bảo bạn đã kết nối với Internet hoặc có tệp trong thư mục ''đầu vào''.'
        "IndividualBlocks" = 'Khối riêng lẻ: {0}'
        "IndividualBlocksNotice" = '[OK] Các khối riêng lẻ cho CosmicScale: {0}'
        "InputFileDeleted" = '[OK] Đã xóa (các) tệp khỏi thư mục đầu vào.'
        "InputFileKept" = '[OK] (Các) tệp được lưu trong thư mục đầu vào.'
        "InvalidOption" = 'Tùy chọn không hợp lệ! Nhấn Enter để thử lại...'
        "LangAppliedSuccess" = '[OK] Đã áp dụng ngôn ngữ giao diện thành công: {0} ({1})'
        "LauncherAutoDetect" = '[OK] Đã bật tính năng tự động phát hiện ngôn ngữ hệ thống Windows.'
        "LauncherBaseNotFoundTitle" = '[!] LỖI: KHÔNG THỂ TẢI XUỐNG HOẶC XÁC ĐỊNH VỊ TRÍ BASE LAUNCHER Script!'
        "LauncherIntegrated" = '[OK] Tích hợp hỗ trợ cho (các) ngôn ngữ {0} vào Trình khởi chạy PSBBN cho Windows!'
        "LauncherPrompt" = 'Chọn một hoặc nhiều ngôn ngữ (ví dụ: 7 hoặc 1, 2, 3 hoặc 1-5 hoặc A):'
        "LauncherTip1" = '- Nhập 1 số để tạo file chỉ với ngôn ngữ đó.'
        "LauncherTipAll" = '- Nhập ''A'' để tạo tệp hoàn chỉnh với tất cả 40 ngôn ngữ.'
        "LauncherTipHeader" = '* Mẹo: Mỗi lần thực thi sẽ tạo ra một tệp sạch chỉ chứa (các) ngôn ngữ đã chọn.'
        "LauncherTipMulti" = '- Nhập nhiều số cách nhau bằng dấu phẩy (ví dụ: 1, 2, 3) để tạo bằng các ngôn ngữ đó.'
        "LauncherTipRange" = '- Nhập một phạm vi (ví dụ: 1-5) để tạo với phạm vi ngôn ngữ đó.'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] Màn hình trước'
        "NavDeleteInput" = '[X] Xóa tập tin khỏi thư mục đầu vào'
        "NavEnter" = '[Vào] Menu chính'
        "NavExit" = '[Esc] Thoát'
        "NavInstructions" = '[Enter] Main Menu |  [B] Màn hình trước |  [Esc] Thoát'
        "NavKeepInput" = '[V] Giữ tập tin trong thư mục đầu vào'
        "OfficialDownloadSuccess" = '[OK] Đã tải xuống tệp chính thức thành công ({0:N0} byte).'
        "PkgCompressingGz" = '[*] Nén vào ''bnupdate.tar.gz'' qua .NET GZipStream...'
        "PkgCreatingTar" = '[*] Tạo ''bnupdate.tar'' và thiết lập quyền thực thi POSIX (+x)...'
        "PkgErrorTar" = '[!] Không thể tạo bnupdate.tar.'
        "PkgGenTitle" = 'TẠO GÓI CÀI ĐẶT PSBBN (bnupdate.tar.gz)'
        "PkgNotice1" = '1. Hoạ tiết (.tm2 và .png) vẫn bằng tiếng Anh (yêu cầu thiết kế lại đồ họa theo cách thủ công).'
        "PkgNotice2" = '2. 100% văn bản hệ thống (XML, ATOK HTML và tập lệnh) được dịch.'
        "PkgNotice3" = '3. Tệp ''bnupdate.tar.gz'' được dùng để thử nghiệm ngay trên PS2 (HDD / Telnet / USB).'
        "PkgNoticeHeader" = '[THÔNG BÁO KỸ THUẬT]:'
        "PkgPromptTar" = 'Bạn có muốn tạo tệp ''bnupdate.tar.gz'' để kiểm tra trên PS2 không? (Có/N) [Mặc định: Y]'
        "PkgSuccess" = '[+] Đã tạo gói thành công (đã bật quyền Linux 0755): {0} ({1:N0} byte)'
        "PosixPatchedCount" = '[+] Các tệp được vá bằng quyền thực thi POSIX 0755 (+x): {0}'
        "PressAnyKey" = 'Nhấn phím bất kỳ để trở về menu...'
        "ProgressAtokHelp" = 'Dịch ATOK Trợ giúp'
        "ProgressUpdatingHtml" = 'Cập nhật tệp HTML'
        "ProgressUpdatingXml" = 'Cập nhật tệp XML'
        "ProgressXmlStrings" = 'Dịch chuỗi XML'
        "PsbbnEnglishEnsure" = 'Hãy đảm bảo rằng thư mục ''PSBBN_English'' có trong ''input''.'
        "PsbbnEnglishNotFoundTitle" = '[!] LỖI: KHÔNG TÌM THẤY THƯ MỤC CƠ SỞ PSBBN_ENGLISH!'
        "ReadmeEnsure" = 'Hãy đảm bảo rằng tệp ''README.md'' nằm trong thư mục ''input''.'
        "ReadmeNotFoundDownloading" = '[*] Không tìm thấy README.md. Đang tải xuống từ kho lưu trữ chính thức...'
        "ReadmeNotFoundTitle" = '[!] LỖI: KHÔNG TÌM THẤY TỆP README.MD!'
        "ReadmeTitle" = 'PSBBN Readme Translator [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN Script Translator [By Emerson Teles]'
        "SelectedLanguagesCount" = '{0} ngôn ngữ được chọn ({1})'
        "SelectUILangPrompt" = 'Chọn một tùy chọn'
        "SelectUITitle" = 'THAY ĐỔI NGÔN NGỮ GIAO DIỆN NGƯỜI DÙNG'
        "SessionStarted" = 'Phiên bắt đầu vào:'
        "SourceFile" = 'Nguồn:'
        "Step1Copying" = '[*] [1/3] Sao chép cấu trúc hoàn chỉnh và nhị phân...'
        "Step2TranslatingXml" = '[*] [2/3] Dịch {0} tệp XML hệ thống...'
        "Step3TranslatingAtok" = '[*] [3/3] Dịch {0} Tệp trợ giúp HTML ATOK...'
        "SuiteTitle" = 'Bộ dịch đa ngôn ngữ PSBBN - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = 'Lưu ý: Hoạ tiết (.tm2 / .png) chứa đồ họa nhúng và yêu cầu chỉnh sửa   thủ công; chúng không bị thay đổi bởi tập lệnh. Các tệp văn bản hệ   thống (XML, HTML, txt) được dịch 100%.'
        "Translating" = 'Dịch'
        "UsingFallback" = '[!] Sử dụng dự phòng cục bộ: {0}'
        "ValidatingXml" = '[*] Xác thực tính toàn vẹn cú pháp của 100% tệp XML...'
        "XmlSyntaxError" = '[!] Lỗi cú pháp trong {0}: {1}'
        "XmlValidationSuccess" = '[+] 100% tệp XML được xác thực thành công (0 lỗi cú pháp).'
    }
    "zh-cn" = @{
        "All40Success" = '所有 40 种语言（完整多语言）'
        "AllLanguages" = '翻译所有语言 (1 - 40)'
        "BackMenu" = '返回主菜单'
        "CancelOption" = '返回'
        "CannotConnectGithub" = '[!] 无法连接到 GitHub：{0}'
        "ChangeLanguage" = '更改界面语言'
        "ChangelogMainNotFoundTitle" = '[!] 错误：无法下载或找到 CHANGELOG_MAIN_ENG.TXT！'
        "ChangelogMainTitle" = 'PSBBN 变更日志主译者 [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] 错误：无法下载或找到 CHANGELOG_PATCH_ENG.TXT！'
        "ChangelogPatchTitle" = 'PSBBN 变更日志补丁转换器 [By Emerson Teles]'
        "ChooseOption" = '请选择一个选项：'
        "CompletionBanner" = '[OK] {0} 的翻译已成功完成 - 100%'
        "DescLauncher" = '生成并更新适用于 Windows 的 PSBBN 启动器，支持所有 40 种语言。'
        "DescMain" = 'Translates the main installer release notes and changelog (changelog_main_eng.txt).'
        "DescPatch" = '翻译补丁历史记录、修复和频道更新说明 (changelog_patch_eng.txt)。'
        "DescReadme" = '翻译官方 PSBBN README.md 并保留 Markdown 格式和链接。'
        "DescScript" = '翻译 Linux/WSL PSBBN 安装程序脚本 (eng.txt) 的所有 458 个 UI 字符串。'
        "DescSystem" = '翻译所有 PS2 PSBBN 系统文件（XML 对话框、指南、菜单、NetFront/ATOK 帮助）。'
        "DestFile" = '目标：'
        "DownloadingLatestGithub" = '[i] 正在从 GitHub 下载最新的官方版本...'
        "DownloadingOfficial" = '[*] 正在从 GitHub 存储库下载官方文件...'
        "EnglishOption" = '英语（默认）'
        "EngTxtEnsureFile" = '请确保“input”文件夹中存在“eng.txt”文件。'
        "EngTxtErrorTitle" = '[!] 错误：ENG.TXT 文件未找到！'
        "EngTxtNotFoundDownloading" = '[*] eng.txt 未找到。正在从官方存储库下载...'
        "EnsureConnected" = '请确保您已连接到互联网或将文件放置在输入目录中。'
        "ExitOption" = '退出'
        "ExpectedPath" = '预期路径：{0}'
        "ExtractingPack" = '[*] 正在提取 PSBBN v3.5 翻译包...'
        "FileNotFoundError" = '[错误] 找不到文件：{0}'
        "GeneratedFile" = '[确定] 生成的文件：{0}'
        "GenericEnsureInternetOrInput" = '请确保您已连接到互联网或该文件位于“输入”文件夹中。'
        "IndividualBlocks" = '单个块：{0}'
        "IndividualBlocksNotice" = '[确定] CosmicScale 的各个块：{0}'
        "InputFileDeleted" = '[确定] 从输入文件夹中删除文件。'
        "InputFileKept" = '[确定] 文件保存在输入文件夹中。'
        "InvalidOption" = '无效选项！按 Enter 重试...'
        "LangAppliedSuccess" = '[OK] 界面语言已成功应用: {0} ({1})'
        "LauncherAutoDetect" = '[确定] Windows 系统语言自动检测已启用。'
        "LauncherBaseNotFoundTitle" = '[!] 错误：无法下载或定位基础启动器脚本！'
        "LauncherIntegrated" = '[确定] 将对 {0} 语言的支持集成到 Windows 版 PSBBN 启动器中！'
        "LauncherPrompt" = '选择一种或多种语言（例如 7 或 1、2、3 或 1-5 或 A）：'
        "LauncherTip1" = '- 输入 1 个数字以生成仅使用该语言的文件。'
        "LauncherTipAll" = '- 输入“A”生成包含所有 40 种语言的完整文件。'
        "LauncherTipHeader" = '* 提示：每次执行都会生成一个仅包含所选语言的干净文件。'
        "LauncherTipMulti" = '- 输入多个以逗号分隔的数字（例如 1、2、3）以使用这些语言生成。'
        "LauncherTipRange" = '- 输入一个范围（例如 1-5）以使用该范围的语言生成。'
        "LauncherTitle" = 'PSBBN Launcher for Windows Translator [By Emerson Teles]'
        "NavBack" = '[B] 上一屏幕'
        "NavDeleteInput" = '[X] 从输入文件夹中删除文件'
        "NavEnter" = '[输入] 主菜单'
        "NavExit" = '[Esc] 退出'
        "NavInstructions" = '[Enter] Main Menu  |  [B] Previous Screen  |  [Esc] Exit'
        "NavKeepInput" = '[V] 将文件保留在输入文件夹中'
        "OfficialDownloadSuccess" = '[确定] 官方文件下载成功（{0:N0} 字节）。'
        "PkgCompressingGz" = '[*] 通过 .NET GZipStream 压缩为“bnupdate.tar.gz”...'
        "PkgCreatingTar" = '[*] 创建“bnupdate.tar”并设置 POSIX 执行权限 (+x)...'
        "PkgErrorTar" = '[!] 无法生成 bnupdate.tar。'
        "PkgGenTitle" = 'PSBBN 安装包生成 (bnupdate.tar.gz)'
        "PkgNotice1" = '1. 纹理（.tm2 和 .png）仍为英文（需要手动重新设计图形）。'
        "PkgNotice2" = '2. 100% 的系统文本（XML、ATOK HTML 和脚本）已翻译。'
        "PkgNotice3" = '3.“bnupdate.tar.gz”文件用于在 PS2（HDD/Telnet/USB）上立即进行测试。'
        "PkgNoticeHeader" = '[技术公告]：'
        "PkgPromptTar" = '您想生成“bnupdate.tar.gz”文件以在 PS2 上进行测试吗？ （是/否）[默认：是]'
        "PkgSuccess" = '[+] 包生成成功（已启用 Linux 0755 权限）： {0} ({1:N0} 字节)'
        "PosixPatchedCount" = '[+] 使用 POSIX 0755 执行权限 (+x) 修补的文件： {0}'
        "PressAnyKey" = '按任意键返回菜单...'
        "ProgressAtokHelp" = '翻译 ATOK 帮助'
        "ProgressUpdatingHtml" = '更新 HTML 文件'
        "ProgressUpdatingXml" = '更新 XML 文件'
        "ProgressXmlStrings" = '翻译 XML 字符串'
        "PsbbnEnglishEnsure" = '请确保“输入”中存在“PSBBN_English”文件夹。'
        "PsbbnEnglishNotFoundTitle" = '[!] 错误：未找到基本目录 PSBBN_ENGLISH！'
        "ReadmeEnsure" = '请确保“README.md”文件位于“input”文件夹中。'
        "ReadmeNotFoundDownloading" = '[*] 未找到 README.md。正在从官方存储库下载...'
        "ReadmeNotFoundTitle" = '[!] 错误：未找到 README.MD 文件！'
        "ReadmeTitle" = 'PSBBN 自述文件翻译器 [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN 脚本翻译器 [By Emerson Teles]'
        "SelectedLanguagesCount" = '已选择 {0} 种语言 ({1})'
        "SelectUILangPrompt" = '请选择一个选项'
        "SelectUITitle" = '更改界面语言'
        "SessionStarted" = '会议开始于：'
        "SourceFile" = '来源：'
        "Step1Copying" = '[*] [1/3] 复制完整的结构和二进制文件...'
        "Step2TranslatingXml" = '[*] [2/3] 正在翻译 {0} 系统 XML 文件...'
        "Step3TranslatingAtok" = '[*] [3/3] 翻译 {0} ATOK HTML 帮助文件...'
        "SuiteTitle" = 'PSBBN 多语言翻译套件 - V1 [By Emerson Teles]'
        "SystemTitle" = 'System PSBBN Translator [By Emerson Teles]'
        "TextureDisclaimer" = '注意：纹理（.tm2 / .png）需要手动图像编辑，不受脚本处理。 本套件100%翻译系统文件文本（XML、HTML、菜单和脚本）。'
        "Translating" = '正在翻译'
        "UsingFallback" = '[!] 使用本地后备：{0}'
        "ValidatingXml" = '[*] 验证 100% XML 文件的语法完整性...'
        "XmlSyntaxError" = '[!] {0} 中的语法错误： {1}'
        "XmlValidationSuccess" = '[+] 100% 的 XML 文件已成功验证（0 个语法错误）。'
    }
    "zh-tw" = @{
        "All40Success" = '所有 40 種語言（完整多語言）'
        "AllLanguages" = '翻譯所有語言 (1 - 40)'
        "BackMenu" = '返回主選單'
        "CancelOption" = '返回'
        "CannotConnectGithub" = '[!] 無法連線到 GitHub：{0}'
        "ChangeLanguage" = '更改介面語言'
        "ChangelogMainNotFoundTitle" = '[!] 錯誤：無法下載或找到 CHANGELOG_MAIN_ENG.TXT！'
        "ChangelogMainTitle" = 'PSBBN 變更日誌主翻譯器 [By Emerson Teles]'
        "ChangelogPatchNotFoundTitle" = '[!] 錯誤：無法下載或找到 CHANGELOG_PATCH_ENG.TXT！'
        "ChangelogPatchTitle" = 'PSBBN 變更日誌補丁翻譯器 [By Emerson Teles]'
        "ChooseOption" = '請選擇一個選項:'
        "CompletionBanner" = '[OK] {0} 的翻譯已成功完成 - 100%'
        "DescLauncher" = '為 PSBBN Launcher for Windows 新增多達 40 種語言支援與自動偵測。'
        "DescMain" = '翻譯主安裝程式發行說明和變更記錄 (changelog_main_eng.txt)。'
        "DescPatch" = '翻譯補丁歷史記錄、修復和頻道更新說明 (changelog_patch_eng.txt)。'
        "DescReadme" = '翻譯保留 Markdown 格式和連結的官方 PSBBN README.md。'
        "DescScript" = '翻譯 Linux/WSL PSBBN 安裝腳本的所有 458 個 UI 字串 (eng.txt)。'
        "DescSystem" = '翻譯所有 PS2 PSBBN 系統檔案（XML 對話方塊、指南、選單、NetFront/ATOK 說明）。'
        "DestFile" = '目的地:'
        "DownloadingLatestGithub" = '[i] 正在從 GitHub 下載最新的官方版本...'
        "DownloadingOfficial" = '[*] 正在從 GitHub 儲存庫下載官方檔案...'
        "EnglishOption" = '英語（預設）'
        "EngTxtEnsureFile" = '請確保「input」資料夾中存在「eng.txt」檔案。'
        "EngTxtErrorTitle" = '[!] 錯誤：ENG.TXT 檔案未找到！'
        "EngTxtNotFoundDownloading" = '[*] eng.txt 未找到。正在從官方儲存庫下載...'
        "EnsureConnected" = '請確保您已連接到互聯網或將檔案放置在輸入目錄中。'
        "ExitOption" = '退出'
        "ExpectedPath" = '預期路徑：{0}'
        "ExtractingPack" = '[*] 正在提取 PSBBN v3.5 翻譯套件...'
        "FileNotFoundError" = '[錯誤] 找不到檔案：{0}'
        "GeneratedFile" = '[確定] 產生的檔案：{0}'
        "GenericEnsureInternetOrInput" = '請確保您已連接到網際網路或該檔案位於「輸入」資料夾中。'
        "IndividualBlocks" = '單一區塊：{0}'
        "IndividualBlocksNotice" = '[確定] CosmicScale 的各個區塊：{0}'
        "InputFileDeleted" = '[確定] 從輸入資料夾中刪除檔案。'
        "InputFileKept" = '[確定] 檔案保存在輸入資料夾中。'
        "InvalidOption" = '無效選項！按 Enter 重試...'
        "LangAppliedSuccess" = '[OK] 介面語言已成功套用: {0} ({1})'
        "LauncherAutoDetect" = '[確定] Windows 系統語言自動偵測已啟用。'
        "LauncherBaseNotFoundTitle" = '[!] 錯誤：無法下載或定位基礎啟動器腳本！'
        "LauncherIntegrated" = '[___ 啟動語言公告'
        "LauncherPrompt" = '選擇一種或多種語言（例如 7 或 1、2、3 或 1-5 或 A）：'
        "LauncherTip1" = '- 輸入 1 個數字以產生僅使用該語言的檔案。'
        "LauncherTipAll" = '- 輸入「A」產生包含所有 40 種語言的完整檔案。'
        "LauncherTipHeader" = '* 提示：每次執行都會產生一個僅包含所選語言的乾淨檔案。'
        "LauncherTipMulti" = '- 輸入多個以逗號分隔的數字（例如 1、2、3）以使用這些語言產生。'
        "LauncherTipRange" = '- 輸入範圍（例如 1-5）以使用該範圍的語言產生。'
        "LauncherTitle" = 'PSBBN Launcher for Windows 翻譯器 [By Emerson Teles]'
        "NavBack" = '[B] 上一畫面'
        "NavDeleteInput" = '[X] 從輸入資料夾中刪除檔案'
        "NavEnter" = '[輸入] 主選單'
        "NavExit" = '[Esc] 退出'
        "NavInstructions" = '[Enter] 主選單 |  [B] 上一畫面 |  [Esc] 退出'
        "NavKeepInput" = '[V] 將檔案保留在輸入資料夾中'
        "OfficialDownloadSuccess" = '[確定] 官方文件下載成功（{0:N0} 位元組）。'
        "PkgCompressingGz" = '[*] 透過 .NET GZipStream 壓縮為「bnupdate.tar.gz」...'
        "PkgCreatingTar" = '[*] 建立「bnupdate.tar」並設定 POSIX 執行權限 (+x)...'
        "PkgErrorTar" = '[!] 無法產生 bnupdate.tar。'
        "PkgGenTitle" = 'PSBBN INSTALLATION PACKAGE GENERATION (bnupdate.tar.gz)'
        "PkgNotice1" = '1. 紋理（.tm2 和 .png）仍為英文（需要手動重新設計圖形）。'
        "PkgNotice2" = '2. 100% 的系統文字（XML、ATOK HTML 和腳本）已翻譯。'
        "PkgNotice3" = '3.「bnupdate.tar.gz」檔案用於在 PS2（HDD/Telnet/USB）上立即進行測試。'
        "PkgNoticeHeader" = '[1/3] 複製完整的結構和二進位檔案...|| 技術公告]：'
        "PkgPromptTar" = '您想產生“bnupdate.tar.gz”檔案以在 PS2 上進行測試嗎？ （是/否）[預設：是]'
        "PkgSuccess" = '[+] 套件產生成功（已啟用 Linux 0755 權限）： {0} ({1:N0} 位元組)'
        "PosixPatchedCount" = '[+] 使用 POSIX 0755 執行權限 (+x) 修補的檔案： {0}'
        "PressAnyKey" = '按任意鍵返回選單...'
        "ProgressAtokHelp" = '翻譯 ATOK 幫助'
        "ProgressUpdatingHtml" = '更新 HTML 檔案'
        "ProgressUpdatingXml" = '更新 XML 檔案'
        "ProgressXmlStrings" = '翻譯 XML 字串'
        "PsbbnEnglishEnsure" = '請確保「輸入」中存在「PSBBN_English」資料夾。'
        "PsbbnEnglishNotFoundTitle" = '[!] 錯誤：未找到基本目錄 PSBBN_ENGLISH！'
        "ReadmeEnsure" = '請確保“README.md”檔案位於“input”資料夾中。'
        "ReadmeNotFoundDownloading" = '[*] 未找到 README.md。正在從官方儲存庫下載...'
        "ReadmeNotFoundTitle" = '[!] 錯誤：未找到 README.MD 檔案！'
        "ReadmeTitle" = 'PSBBN 自述文件翻譯器 [By Emerson Teles]'
        "ScriptTitle" = 'PSBBN 腳本翻譯器 [By Emerson Teles]'
        "SelectedLanguagesCount" = '已選擇 {0} 種語言 ({1})'
        "SelectUILangPrompt" = '請選擇一個選項'
        "SelectUITitle" = '更改介面語言'
        "SessionStarted" = '工作階段開始於:'
        "SourceFile" = '來源:'
        "Step1Copying" = '[*] [1/3] 複製完整的結構和二進位檔案...| 技術公告]：'
        "Step2TranslatingXml" = '[*] [2/3] 正在翻譯 {0} 系統 XML 檔案...'
        "Step3TranslatingAtok" = '[*] [3/3] 正在翻譯 {0} ATOK HTML 說明文件...'
        "SuiteTitle" = 'PSBBN 多語言翻譯套件 - V1 [By Emerson Teles]'
        "SystemTitle" = '系統 PSBBN 翻譯器 [By Emerson Teles]'
        "TextureDisclaimer" = '注意：紋理 (.tm2 / .png) 需要手動圖像編輯，不受腳本處理。 本套件100%翻譯系統文字檔案 (XML, HTML, 功能表和腳本)。'
        "Translating" = '正在翻譯'
        "UsingFallback" = '[!] 使用本地後備：{0}'
        "ValidatingXml" = '[*] 驗證 100% XML 檔案的語法完整性...'
        "XmlSyntaxError" = '[!] {0} 中的文法錯誤：{1}'
        "XmlValidationSuccess" = '[+] 100% 的 XML 檔案已成功驗證（0 個語法錯誤）。'
    }
}


function Get-SessionStartTime {
    $currentLang = if ($Global:SelectedUILangCode) {
        $Global:SelectedUILangCode.ToLower()
    } else {
        [System.Globalization.CultureInfo]::CurrentUICulture.Name.ToLower()
    }
    $conn = if ($currentLang -like "pt*") {
        (" " + [char]0xE0 + "s ")
    } else {
        " - "
    }
    if (-not $Global:ScriptSessionStartTime) {
        $Global:ScriptSessionStartTime = Get-Date
    }
    return $Global:ScriptSessionStartTime.ToString("dd/MM/yyyy") + $conn + $Global:ScriptSessionStartTime.ToString("HH:mm:ss")
}

function Get-ScriptUI {
    $lang = if ($Global:SelectedUILangCode) {
        $Global:SelectedUILangCode.ToLower()
    } else {
        [System.Globalization.CultureInfo]::CurrentUICulture.Name.ToLower()
    }

    $activeDict = $null
    # 1. Exact match (e.g. "pt-pt", "zh-cn", "zh-tw")
    if ($Global:UI_Translations40 -and $Global:UI_Translations40.ContainsKey($lang)) {
        $activeDict = $Global:UI_Translations40[$lang]
    } elseif ($Global:UI_Translations40) {
        # 2. Base language match (e.g. "pt-br" -> "pt", "en-us" -> "en")
        $baseLang = ($lang -split "-")[0]
        if ($Global:UI_Translations40.ContainsKey($baseLang)) {
            $activeDict = $Global:UI_Translations40[$baseLang]
        }
    }

    # Merge activeDict on top of English baseline so no key is ever missing or empty
    $baseDict = if ($Global:UI_Translations40 -and $Global:UI_Translations40.ContainsKey("en")) { $Global:UI_Translations40["en"] } else { @{} }
    $merged = @{}
    foreach ($k in $baseDict.Keys) { $merged[$k] = $baseDict[$k] }
    if ($activeDict) {
        foreach ($k in $activeDict.Keys) {
            if (-not [string]::IsNullOrWhiteSpace($activeDict[$k])) {
                $merged[$k] = $activeDict[$k]
            }
        }
    }
    return $merged
}


# ------------------------------------------------------------------------------
# Manual UI Language Selector (Grid of 40 Languages)
# ------------------------------------------------------------------------------
function Select-ScriptUILanguage {
    Clear-Host
    $ui = Get-ScriptUI
    $titleStr = if ($ui.SelectUITitle) { $ui.SelectUITitle } else { "SELECIONAR IDIOMA DA INTERFACE" }
    Show-HeaderBanner $titleStr
    Write-Host ""
    $enOpt = if ($ui.EnglishOption) { $ui.EnglishOption } else { "English (default)" }
    Write-Host ("  [00] {0}" -f $enOpt) -ForegroundColor Cyan
    Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor DarkGray

    for ($i = 0; $i -lt 20; $i++) {
        $l1 = $Languages40[$i]
        $l2 = $Languages40[$i + 20]
        $id1 = $l1.id.PadLeft(2, '0')
        $id2 = $l2.id.PadLeft(2, '0')
        
        $col1 = ("  [{0}] {1,-26}" -f $id1, $l1.name)
        $col2 = ("[{0}] {1,-26}" -f $id2, $l2.name)
        Write-Host -NoNewline $col1 -ForegroundColor White
        Write-Host $col2 -ForegroundColor White
    }

    $cancelText = if ($ui.CancelOption) { $ui.CancelOption } else { "Voltar" }
    Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ("  [0]  {0}" -f $cancelText) -ForegroundColor Yellow
    Write-Host "========================================================================================" -ForegroundColor Cyan
    Write-Host ""
    $promptText = if ($ui.SelectUILangPrompt) { $ui.SelectUILangPrompt } else { "Escolha o idioma da interface" }
    $choice = Read-Host ("  {0} (00, 01 - 40)" -f $promptText)
    $choice = $choice.Trim()
    if ($choice -eq "0" -or [string]::IsNullOrWhiteSpace($choice)) { return "back" }

    $selectedLangName = $null
    $selectedLangNative = $null

    if ($choice -eq "00" -or $choice.ToLower() -eq "en" -or $choice.ToLower() -eq "english") {
        $Global:SelectedUILangCode = "en"
        $selectedLangName = "English"
        $selectedLangNative = "English"
    } else {
        foreach ($l in $Languages40) {
            if ($choice -eq $l.id -or $choice -eq $l.id.PadLeft(2, '0') -or $choice.ToLower() -eq $l.code.ToLower() -or $choice.ToLower() -eq $l.code3.ToLower()) {
                $Global:SelectedUILangCode = $l.code.ToLower()
                $selectedLangName = $l.name
                $selectedLangNative = $l.native
                break
            }
        }
    }

    if ($selectedLangName) {
        $newUi = Get-ScriptUI
        try { $Host.UI.RawUI.WindowTitle = $newUi.SuiteTitle } catch { }
        Write-Host ""
        Write-Host "  ========================================================================================" -ForegroundColor Green
        $successFmt = if ($newUi.LangAppliedSuccess) { $newUi.LangAppliedSuccess } else { "[OK] Idioma aplicado na interface com sucesso: {0} ({1})" }
        Write-Host ("  " + ($successFmt -f $selectedLangName, $selectedLangNative)) -ForegroundColor Green
        Write-Host "  ========================================================================================" -ForegroundColor Green
        Write-Host ""
        $nav = Wait-EndNavigation -showInputOptions $false
        return $nav
    }

    Write-Host ""
    Write-Host ("  " + $ui.InvalidOption) -ForegroundColor Red
    Start-Sleep -Seconds 1
    return "back"
}

# ------------------------------------------------------------------------------
# Windows Console Helper: Enable QuickEdit Mode (allows text selection and copying with mouse)
# ------------------------------------------------------------------------------
function Enable-ConsoleQuickEdit {
    try {
        $code = @"
using System;
using System.Runtime.InteropServices;
public static class Win32Console {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
    public static void EnableQuickEdit() {
        IntPtr hStdin = GetStdHandle(-10);
        uint mode;
        if (GetConsoleMode(hStdin, out mode)) {
            mode |= 0x0040; mode |= 0x0080;
            SetConsoleMode(hStdin, mode);
        }
    }
}
"@
        Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
        [Win32Console]::EnableQuickEdit()
    } catch { }
}

# ------------------------------------------------------------------------------
# Navigation Key Waiter: [Enter] -> Return "menu", [B] -> Return "back", [Esc] -> Exit
# ------------------------------------------------------------------------------
# Navigation End Banner & Input Management Key Waiter
# ------------------------------------------------------------------------------
function Show-EndNavigationBanner([bool]$showInputOptions = $true) {
    $ui = Get-ScriptUI

    $tEnter = if ($ui.NavEnter) { $ui.NavEnter } else { "[Enter] Menu Principal" }
    $tBack  = if ($ui.NavBack) { $ui.NavBack } else { "[B] Voltar para a tela anterior" }
    $tExit  = if ($ui.NavExit) { $ui.NavExit } else { "[Esc] Fechar / Sair" }
    $tDel   = if ($ui.NavDeleteInput) { $ui.NavDeleteInput } else { "[X] Excluir arquivo da pasta input" }
    $tKeep  = if ($ui.NavKeepInput) { $ui.NavKeepInput } else { "[V] Manter arquivo da pasta input" }

    Write-Host "  " -NoNewline
    Write-Host $tEnter -ForegroundColor Cyan -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host $tBack -ForegroundColor Yellow -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host $tExit -ForegroundColor Gray

    if ($showInputOptions) {
        Write-Host "  " -NoNewline
        Write-Host $tDel -ForegroundColor Red -NoNewline
        Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
        Write-Host $tKeep -ForegroundColor Green
    }
    Write-Host ""
}

function Wait-EndNavigation {
    param(
        [string]$inputDir = $null,
        [string[]]$inputFiles = @(),
        [bool]$showInputOptions = ((-not [string]::IsNullOrWhiteSpace($inputDir)) -or ($inputFiles -and $inputFiles.Count -gt 0))
    )
    $ui = Get-ScriptUI

    Show-EndNavigationBanner -showInputOptions $showInputOptions

    $canReadKey = $false
    try {
        if (-not [Console]::IsInputRedirected) {
            $canReadKey = $true
        }
    } catch { }

    if (-not $canReadKey) {
        $resp = Read-Host
        if ($resp -eq "b" -or $resp -eq "B") { return "back" }
        if ($resp -eq "x" -or $resp -eq "X") {
            if ($inputFiles -and $inputFiles.Count -gt 0) {
                foreach ($f in $inputFiles) {
                    if (Test-Path $f) { Remove-Item -Path $f -Recurse -Force -ErrorAction SilentlyContinue }
                }
            }
            if ($inputDir -and (Test-Path $inputDir)) {
                Get-ChildItem -Path $inputDir | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }
            return "menu"
        }
        return "menu"
    }

    # Flush any lingering keystrokes from previous Read-Host or inputs
    try {
        while ([Console]::KeyAvailable) {
            [void][Console]::ReadKey($true)
        }
    } catch { }

    while ($true) {
        try {
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if ($key.Key -eq [ConsoleKey]::Enter) {
                    return "menu"
                }
                if ($key.Key -eq [ConsoleKey]::B) {
                    return "back"
                }
                if ($key.Key -eq [ConsoleKey]::Escape) {
                    exit 0
                }
                if ($key.Key -eq [ConsoleKey]::X -and $showInputOptions) {
                    if ($inputFiles -and $inputFiles.Count -gt 0) {
                        foreach ($f in $inputFiles) {
                            if (Test-Path $f) {
                                Remove-Item -Path $f -Recurse -Force -ErrorAction SilentlyContinue
                            }
                        }
                    }
                    if ($inputDir -and (Test-Path $inputDir)) {
                        Get-ChildItem -Path $inputDir | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    $delMsg = if ($ui.InputFileDeleted) { $ui.InputFileDeleted } else { "[OK] Arquivo(s) da pasta input excluido(s) com sucesso." }
                    Write-Host ("  " + $delMsg) -ForegroundColor Yellow
                    Start-Sleep -Milliseconds 800
                    return "menu"
                }
                if ($key.Key -eq [ConsoleKey]::V -and $showInputOptions) {
                    $keepMsg = if ($ui.InputFileKept) { $ui.InputFileKept } else { "[OK] Arquivo(s) da pasta input mantido(s)." }
                    Write-Host ("  " + $keepMsg) -ForegroundColor Green
                    Start-Sleep -Milliseconds 800
                    return "menu"
                }
            }
        } catch {
            return "menu"
        }
        Start-Sleep -Milliseconds 50
    }
}

function Show-HeaderBanner($title) {
    $cleanTitle = $title -replace '(?i)\s*\[\s*By\s+Emerson\s+Teles\s*\]', ''
    $cleanTitle = $cleanTitle.Trim().ToUpper()
    $credit = "[ By Emerson Teles ]"
    $totalLen = $cleanTitle.Length + 1 + $credit.Length
    $pad = [Math]::Max(2, [int][Math]::Floor((88 - $totalLen) / 2))
    $spaces = " " * $pad

    Write-Host "========================================================================================" -ForegroundColor Cyan
    Write-Host -NoNewline ($spaces + $cleanTitle + " ") -ForegroundColor Yellow
    Write-Host $credit -ForegroundColor Green
    Write-Host "========================================================================================" -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# Single-line Progress Indicator
# ------------------------------------------------------------------------------
function Show-InlineProgress($label, $current, $total) {
    if ($total -le 0) { $total = 1 }
    $percent = [Math]::Min(100.0, [Math]::Max(0.0, ($current / $total) * 100.0))
    $barWidth = 20
    $filled = [int][Math]::Round(($percent / 100.0) * $barWidth)
    if ($filled -gt $barWidth) { $filled = $barWidth }
    $empty = $barWidth - $filled
    $bar = ("█" * $filled) + ("░" * $empty)
    Write-Host -NoNewline ("`r    -> {0}: [ {1,4} / {2,4} ] ( {3,5:F1}% ) [{4}]" -f $label, $current, $total, $percent, $bar)
}

# ------------------------------------------------------------------------------
# Validation Gatekeeper: Rejects HTML, Error 500, and Server Error Responses
# ------------------------------------------------------------------------------
function Is-ValidTranslation([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return $false }
    if ($s -match '(?i)(<html|<!DOCTYPE|<title>|Error 500|af-error-page|<script|<style|That.+?error|<body|<main)') {
        return $false
    }
    return $true
}

# ------------------------------------------------------------------------------
# Multi-Tier Robust Google Translation Engine (Batch + Multi-Endpoint Fallback)
# ------------------------------------------------------------------------------
function Invoke-BatchTranslation($texts, $targetGoogleCode) {
    if ($texts.Count -eq 0) { return @() }
    
    $joined = $texts -join " ~|~ "
    $encoded = [System.Net.WebUtility]::UrlEncode($joined)

    # 1. Primary: Mobile Google Translate endpoint
    try {
        $mobileUrl = "https://translate.google.com/m?sl=auto&tl=$targetGoogleCode&q=$encoded"
        $req = [System.Net.HttpWebRequest]::Create($mobileUrl)
        $req.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
        $req.Timeout = 12000
        $res = $req.GetResponse()
        $stream = $res.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
        $html = $reader.ReadToEnd()
        $reader.Close(); $stream.Close(); $res.Close()

        $match = [regex]::Match($html, 'class="result-container">([\s\S]*?)</div>')
        if ($match.Success) {
            $rawResult = [System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value.Trim())
            $parts = $rawResult -split "\s*~\|~\s*"
            if ($parts.Count -eq $texts.Count) {
                $allValid = $true
                foreach ($p in $parts) {
                    if (-not (Is-ValidTranslation $p)) { $allValid = $false; break }
                }
                if ($allValid) {
                    return $parts
                }
            }
        }
    } catch { }

    # 2. Secondary: Robust element-by-element fallback with polite sleep
    $results = New-Object System.Collections.Generic.List[string]
    foreach ($item in $texts) {
        $single = Invoke-SingleTranslation $item $targetGoogleCode
        $results.Add($single)
        Start-Sleep -Milliseconds 40
    }
    return $results.ToArray()
}

function Invoke-SingleTranslation($text, $targetGoogleCode) {
    if ([string]::IsNullOrWhiteSpace($text)) { return $text }
    $encoded = [System.Net.WebUtility]::UrlEncode($text)

    # Tier 1: clients5 / dict-chrome-ex (Clean JSON)
    try {
        $url1 = "https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=auto&tl=$targetGoogleCode&q=$encoded"
        $req1 = [System.Net.HttpWebRequest]::Create($url1)
        $req1.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
        $req1.Timeout = 8000
        $res1 = $req1.GetResponse()
        $r1 = New-Object System.IO.StreamReader($res1.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $raw1 = $r1.ReadToEnd()
        $r1.Close(); $res1.Close()
        $parsed1 = ConvertFrom-Json $raw1
        $resStr1 = ""
        if ($parsed1 -is [System.Array]) {
            $sb1 = New-Object System.Text.StringBuilder
            foreach ($item1 in $parsed1) {
                if ($item1 -is [System.Array] -and $item1.Count -gt 0) {
                    [void]$sb1.Append([string]$item1[0])
                } elseif ($item1 -is [string]) {
                    [void]$sb1.Append($item1)
                }
            }
            $resStr1 = $sb1.ToString()
        } else {
            $resStr1 = [string]$parsed1
        }
        if (Is-ValidTranslation $resStr1) {
            return $resStr1
        }
    } catch { }

    # Tier 2: translate.google.com/m
    try {
        $url2 = "https://translate.google.com/m?sl=auto&tl=$targetGoogleCode&q=$encoded"
        $req2 = [System.Net.HttpWebRequest]::Create($url2)
        $req2.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
        $req2.Timeout = 8000
        $res2 = $req2.GetResponse()
        $r2 = New-Object System.IO.StreamReader($res2.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $html2 = $r2.ReadToEnd()
        $r2.Close(); $res2.Close()
        $match2 = [regex]::Match($html2, 'class="result-container">([\s\S]*?)</div>')
        if ($match2.Success) {
            $dec2 = [System.Net.WebUtility]::HtmlDecode($match2.Groups[1].Value.Trim())
            if (Is-ValidTranslation $dec2) {
                return $dec2
            }
        }
    } catch { }

    # Tier 3: translate_a/single (gtx)
    try {
        $url3 = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetGoogleCode&dt=t&q=$encoded"
        $req3 = [System.Net.HttpWebRequest]::Create($url3)
        $req3.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        $req3.Timeout = 8000
        $res3 = $req3.GetResponse()
        $r3 = New-Object System.IO.StreamReader($res3.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $raw3 = $r3.ReadToEnd()
        $r3.Close(); $res3.Close()
        $parsed3 = ConvertFrom-Json $raw3
        $sb = New-Object System.Text.StringBuilder
        foreach ($chunk in $parsed3[0]) {
            if ($chunk -and $chunk[0]) { [void]$sb.Append($chunk[0]) }
        }
        $resStr3 = $sb.ToString()
        if (Is-ValidTranslation $resStr3) {
            return $resStr3
        }
    } catch { }

    # Safety Fallback: Return original clean text, NEVER return HTML!
    return $text
}

function Invoke-GoogleTranslate($text, $targetGoogleCode) {
    return (Invoke-SingleTranslation $text $targetGoogleCode)
}

# ------------------------------------------------------------------------------
# Post-Translation Sanitize & Polish (Protects "PSBBN Definitive Project", Buttons, Channels & HOSDMenu)
# ------------------------------------------------------------------------------
function Apply-TermReplacements($text, $targetLangObj, [bool]$isChangelog = $false) {
    if ([string]::IsNullOrWhiteSpace($text)) { return $text }

    $res = $text

    # 1. Protect & Restore PSBBN Definitive Project strictly in English across all 40 languages
    $res = $res -replace 'XYZ\s*PSBBNDEFPROJ\s*XYZ', 'PSBBN Definitive Project'
    $res = $res -replace '(?i)\b(Projeto Definitivo PSBBN|Projecto Definitivo PSBBN|Projet D[eé]finitif PSBBN|Definitives PSBBN-Projekt|Definitiv PSBBN-Projekt|Proyecto Definitivo PSBBN|Progetto Definitivo PSBBN|Definitive PSBBN Project)\b', 'PSBBN Definitive Project'
    $res = $res -replace '(?i)\b(\u041E\u043A\u043E\u043D\u0447\u0430\u0442\u0435\u043B\u044C\u043D\u044B\u0439\s+\u043F\u0440\u043E\u0435\u043A\u0442\s+PSBBN)\b', 'PSBBN Definitive Project'

    # PlayStation Now! / PlayStation Now protection (NEVER translate)
    $res = $res -replace 'XYZ\s*PSNOWEXCL\s*XYZ', 'PlayStation Now!'
    $res = $res -replace 'XYZ\s*PSNOW\s*XYZ', 'PlayStation Now'
    $res = $res -replace '(?i)\bPlayStation\s+(?:Agora!?|Maintenant!?|Jetzt!?|Ora!?)\b', 'PlayStation Now'

    # feega / FEEGA protection (Sony proprietary service name, NEVER translate)
    $res = $res -replace 'XYZ\s*FEEGATOKEN\s*XYZ', 'feega'
    $res = $res -replace 'XYZ\s*FEEGAUPPER\s*XYZ', 'FEEGA'

    # PSBBN Definitive Patch restoration
    $res = $res -replace 'XYZ\s*PSBBNDEFPATCH\s*XYZ', 'PSBBN Definitive Patch'
    $res = $res -replace '(?i)\b(?:Patch Definitivo PSBBN|Patch Definitivo do PSBBN)\b', 'PSBBN Definitive Patch'

    # OSDMenu Configurator restoration (NEVER translate to "configurador OSDMenu")
    $res = $res -replace 'XYZ\s*OSDMENUCONFIG\s*XYZ', 'OSDMenu Configurator'
    $res = $res -replace '(?i)\b(?:Configurad(?:or|ore)\s+OSDMenu|configurador\s+OSDMenu|OSDMenu\s+Configurad(?:or|ore)|OSDMenu-Konfigurator|Configurateur\s+OSDMenu)\b', 'OSDMenu Configurator'

    # OSDMenu MBR restoration (NEVER translate to "MenuOSD MBR" or "MenuOSDMBR")
    $res = $res -replace 'XYZ\s*OSDMENUMBR\s*XYZ', 'OSDMenu MBR'
    $res = $res -replace '(?i)\b(?:MenuOSD\s*MBR|MenuOSDMBR)\b', 'OSDMenu MBR'
    $res = $res -replace '(?i)\bMenuOSD\b', 'OSDMenu'

    # Navigator Menu & Navigator term restoration (Proprietary term, NEVER translate "Navigator" to "Navegador")
    $res = $res -replace 'XYZ\s*NAVIGATORTOKEN\s*XYZ', 'Navigator'
    $navMenuTarget = if ($targetLangObj.code -in @("pt", "pt-pt", "es", "fr", "it")) { "Menu Navigator" } elseif ($targetLangObj.code -eq "de") { "Navigator-Menü" } else { "Navigator Menu" }
    $res = $res -replace 'XYZ\s*NAVIGATORMENU\s*XYZ', $navMenuTarget
    if ($targetLangObj.code -in @("pt", "pt-pt")) {
        # Enable / Disable terminology -> Ativar / Desativar
        $res = $res -replace '(?i)\bHabilite\b', 'Ative'
        $res = $res -replace '(?i)\bhabilite\b', 'ative'
        $res = $res -replace '(?i)\bHabilitar\b', 'Ativar'
        $res = $res -replace '(?i)\bhabilitar\b', 'ativar'
        $res = $res -replace '(?i)\bHabilitad([oa]s?)\b', 'Ativad$1'
        $res = $res -replace '(?i)\bhabilitad([oa]s?)\b', 'ativad$1'
        $res = $res -replace '(?i)\bDesabilite\b', 'Desative'
        $res = $res -replace '(?i)\bdesabilite\b', 'desative'
        $res = $res -replace '(?i)\bDesabilitar\b', 'Desativar'
        $res = $res -replace '(?i)\bdesabilitar\b', 'desativar'
        $res = $res -replace '(?i)\bDesabilitad([oa]s?)\b', 'Desativad$1'
        $res = $res -replace '(?i)\bdesabilitad([oa]s?)\b', 'desativad$1'
        $res = $res -replace '(?i)\b(?:Navigator\s+Menu|Menu\s+Navegador|Navegador\s+Menu)\b', 'Menu Navigator'
    }

    # PSBBN Launcher for Windows restoration
    $res = $res -replace 'XYZ\s*PSBBNLAUNCHWIN\s*XYZ', 'PSBBN Launcher for Windows'
    if ($targetLangObj.code -in @("pt", "pt-pt")) {
        # Enable / Disable terminology -> Ativar / Desativar
        $res = $res -replace '(?i)\bHabilite\b', 'Ative'
        $res = $res -replace '(?i)\bhabilite\b', 'ative'
        $res = $res -replace '(?i)\bHabilitar\b', 'Ativar'
        $res = $res -replace '(?i)\bhabilitar\b', 'ativar'
        $res = $res -replace '(?i)\bHabilitad([oa]s?)\b', 'Ativad$1'
        $res = $res -replace '(?i)\bhabilitad([oa]s?)\b', 'ativad$1'
        $res = $res -replace '(?i)\bDesabilite\b', 'Desative'
        $res = $res -replace '(?i)\bdesabilite\b', 'desative'
        $res = $res -replace '(?i)\bDesabilitar\b', 'Desativar'
        $res = $res -replace '(?i)\bdesabilitar\b', 'desativar'
        $res = $res -replace '(?i)\bDesabilitad([oa]s?)\b', 'Desativad$1'
        $res = $res -replace '(?i)\bdesabilitad([oa]s?)\b', 'desativad$1'
        $res = $res -replace '(?i)\bPSBBN\s+Launcher\s+para\s+Windows\b', 'PSBBN Launcher for Windows'
    }

    # README Term Protection (Proprietary name, NEVER translate "README" to "LEIAME", "Leia-me", "Lisez-moi", etc.)
    $res = $res -replace 'XYZ\s*READMETOKEN\s*XYZ', 'README'
    $res = $res -replace '(?i)\b(?:LEIAME|Leia-me|Leia\s+me)\b', 'README'

    # Art Packs and Databases Protection (Issue 603 - NEVER translate tool / pack / db names)
    $res = $res -replace 'XYZ\s*PSBBNARTDB\s*XYZ', 'PSBBN Art Database'
    $res = $res -replace '(?i)\b(?:banco\s+de\s+dados\s+de\s+artes?\s+(?:do\s+)?PSBBN|banco\s+de\s+artes?\s+(?:do\s+)?PSBBN|banco\s+de\s+dados\s+de\s+arte\s+do\s+PSBBN)\b', 'PSBBN Art Database'

    $res = $res -replace 'XYZ\s*HDDOSDICNDB\s*XYZ', 'HDD-OSD Icon Database'
    $res = $res -replace '(?i)\b(?:banco\s+de\s+dados\s+de\s+[íi]cones\s+(?:do\s+)?HDD-OSD|banco\s+de\s+[íi]cones\s+(?:do\s+)?HDD-OSD)\b', 'HDD-OSD Icon Database'

    $res = $res -replace 'XYZ\s*OPLBAPPSPACK\s*XYZ', 'OPL B-APPS Cover Pack'
    $res = $res -replace 'XYZ\s*OPLDISCSPACK\s*XYZ', 'OPL Discs & Boxes Pack'
    $res = $res -replace 'XYZ\s*OPLMGRARTDB\s*XYZ', 'OPL Manager Art Database'
    $res = $res -replace '(?i)\b(?:banco\s+de\s+dados\s+de\s+artes?\s+(?:do\s+)?OPL\s+Manager|banco\s+de\s+artes\s+do\s+OPL\s+Manager)\b', 'OPL Manager Art Database'

    $res = $res -replace 'XYZ\s*ARTPACKS\s*XYZ', 'Art Packs'
    $res = $res -replace '(?i)\bPacotes?\s+de\s+artes?\b', 'Art Packs'

    # Official Systems Protection
    $res = $res -replace 'XYZ_SAS_WITH_ACRONYM_XYZ', 'Save Application System (SAS)'
    $res = $res -replace 'XYZ_SAS_TOKEN_XYZ', 'Save Application System'
    $res = $res -replace '(?i)\b(?:Sistema\s+de\s+Aplicativos?\s+Salvos?|Sistema\s+de\s+Aplicações?\s+Salvas?)\s*\((?:SAS|SAS-compliant)\)', 'Save Application System (SAS)'

    $res = $res -replace 'XYZ_IGR_WITH_ACRONYM_XYZ', 'In-Game Reset (IGR)'
    $res = $res -replace 'XYZ_IGR_TOKEN_XYZ', 'In-Game Reset'
    $res = $res -replace '(?i)\b(?:redefinição\s+no\s+jogo|in-game\s+reset|reinicialização\s+no\s+jogo)\s*\(IGR\)', 'In-Game Reset (IGR)'

    # Homebrews & Tools Protection
    $res = $res -replace 'XYZ_OPL_WITH_ACRONYM_XYZ', 'Open PS2 Loader (OPL)'
    $res = $res -replace 'XYZ_OPEN_PS2_LOADER_XYZ', 'Open PS2 Loader'
    $res = $res -replace 'XYZ_OPL_ACRONYM_XYZ', 'OPL'
    $res = $res -replace '(?i)\bOpen\s+PS2\s+Loader\s*\(OPL\)', 'Open PS2 Loader (OPL)'
    $res = $res -replace '(?i)\b(?:Abra\s+(?:o\s+)?carregador\s+(?:do\s+|PS2)?|Buksan\s+ang\s+PS2\s+Loader|Ouvrir\s+le\s+chargeur\s+PS2|Abrir\s+el\s+cargador\s+PS2)\b', 'Open PS2 Loader'

    $res = $res -replace 'XYZ_WLE_R3Z_XYZ', 'wLaunchELF-R3Z'
    $res = $res -replace 'XYZ_WLE_XYZ', 'wLaunchELF'
    $res = $res -replace 'XYZ_R3CONFIG_XYZ', 'R3CONFIGURATOR'
    $res = $res -replace 'XYZ_POPSLOADER_XYZ', 'POPSLoader'
    $res = $res -replace 'XYZ_POPSTARTER_XYZ', 'POPStarter'
    $res = $res -replace 'XYZ_NHDDL_XYZ', 'NHDDL'
    $res = $res -replace 'XYZ_APA_JAIL_XYZ', 'APA-Jail'
    $res = $res -replace 'XYZ_PIXEL_FX_XYZ', 'Pixel FX Retro GEM'
    $res = $res -replace 'XYZ_MEMCARD_PRO_XYZ', 'MemCard Pro'
    $res = $res -replace 'XYZ_SD2PSX_XYZ', 'SD2PSX'
    $res = $res -replace 'XYZ_MECHAPWN_XYZ', 'MechaPwn'
    $res = $res -replace 'XYZ_FREEHDBOOT_XYZ', 'FreeHDBoot'
    $res = $res -replace 'XYZ_FREEMCBOOT_XYZ', 'Free McBoot'
    $res = $res -replace 'XYZ_FHDB_XYZ', 'FHDB'
    $res = $res -replace 'XYZ_FMCB_XYZ', 'FMCB'
    $res = $res -replace 'XYZ_HDDOSD_XYZ', 'HDD-OSD'
    $res = $res -replace 'XYZ_HOSDMENU_XYZ', 'HOSDMenu'
    $res = $res -replace 'XYZ_PS2LINUX_XYZ', 'PS2 Linux'
    $res = $res -replace 'XYZ_PSBBUNIT_XYZ', 'PlayStation BB Unit'
    $res = $res -replace 'XYZ_PSBROADBANDNAV_XYZ', 'PlayStation Broadband Navigator'
    $res = $res -replace 'XYZ_BBNAVIGATOR_XYZ', 'BB Navigator'

    # Physical PS2 Hardware Labels
    $res = $res -replace 'XYZ_MAINPOWER_XYZ', 'MAIN POWER'
    $res = $res -replace 'XYZ_ONSTANDBYRESET_XYZ', 'ON/STANDBY/RESET'
    $res = $res -replace 'XYZ_EXPANSIONBAY_XYZ', 'EXPANSION BAY'

    # Virtual Memory Cards
    $vmcTarget = if ($targetLangObj.code -in @("pt", "pt-pt")) { "Memory Cards Virtuais" } elseif ($targetLangObj.code -eq "es") { "Tarjetas de Memoria Virtuales" } elseif ($targetLangObj.code -eq "fr") { "Cartes MÃ©moire Virtuelles" } else { "Virtual Memory Cards" }
    $res = $res -replace 'XYZ_VMCS_PLURAL_XYZ', $vmcTarget
    $vmcSingle = if ($targetLangObj.code -in @("pt", "pt-pt")) { "Memory Card Virtual" } elseif ($targetLangObj.code -eq "es") { "Tarjeta de Memoria Virtual" } elseif ($targetLangObj.code -eq "fr") { "Carte MÃ©moire Virtuelle" } else { "Virtual Memory Card" }
    $res = $res -replace 'XYZ_VMC_SINGLE_XYZ', $vmcSingle
    $vmcGroups = if ($targetLangObj.code -in @("pt", "pt-pt", "es")) { "Grupos VMC" } else { "VMC Groups" }
    $res = $res -replace 'XYZ_VMCS_ACRONYM_XYZ', 'VMCs'
    $res = $res -replace 'XYZ_VMC_ACRONYM_XYZ', 'VMC'

    # SMB Network Protocol - NEVER translate to "Pequenas e Médias Empresas" or "PME"
    $res = $res -replace 'XYZ\s*SMBTOKEN\s*XYZ', 'SMB'
    $res = $res -replace 'XYZ_SMBTOKEN_XYZ', 'SMB'
    $res = $res -replace '(?i)\b(?:Pequenas\s+e\s+M[ée]dias\s+Empresas|PME)\b', 'SMB'
    $res = $res -replace '(?i)\bcompartilhamento\s+de\s+rede\s+de\s+SMB\b', 'compartilhamento de rede SMB'
    $res = $res -replace '(?i)\bcompartilhamento\s+de\s+rede\s+SMB\b', 'compartilhamento de rede SMB'
    $res = $res -replace '(?i)\bLançamento\s+de\s+Jogos\s+PS1\s+via\s+SMB\b', 'Execução de Jogos PS1 via SMB'
    $res = $res -replace '(?i)\bLançamento\s+de\s+Jogos\s+PS1\s+de\s+SMB\b', 'Execução de Jogos PS1 via SMB'

    # ATA BDM Assault Driver Restoration
    $res = $res -replace 'XYZ\s*ATABDMASSAULT\s*XYZ', 'ATA BDM Assault'
    $res = $res -replace 'XYZ_ATABDMASSAULT_XYZ', 'ATA BDM Assault'
    $res = $res -replace '(?i)\b(?:Ataque\s+ATA\s+BDM|Ataque\s+BDM\s+ATA|Ataque\s+BDM)\b', 'ATA BDM Assault'
    $res = $res -replace '(?i)\bdrivers?\s+(?:do\s+)?ATA\s+BDM\s+Assault\b', 'drivers ATA BDM Assault'
    $res = $res -replace '(?i)\bdrivers?\s+(?:do\s+)?Ataque\s+ATA\s+BDM\b', 'drivers ATA BDM Assault'
    $res = $res -replace '(?i)\bInstalando\s+o\s+Ataque\s+ATA\s+BDM\b', 'Instalação dos Drivers ATA BDM Assault'
    $res = $res -replace '(?i)\bInstalando\s+ATA\s+BDM\s+Assault\b', 'Instalação dos Drivers ATA BDM Assault'

    # Changelog Channel Tokens Restoration (Preserved in English for changelogs)
    $res = $res -replace 'XYZ\s*GAMECHANNEL\s*XYZ', 'Game Channel'
    $res = $res -replace 'XYZ\s*INTERNETCHANNEL\s*XYZ', 'Internet Channel'
    $res = $res -replace 'XYZ\s*MOVIECHANNEL\s*XYZ', 'Movie Channel'
    $res = $res -replace 'XYZ\s*MUSICCHANNEL\s*XYZ', 'Music Channel'
    $res = $res -replace 'XYZ\s*PHOTOCHANNEL\s*XYZ', 'Photo Channel'
    $res = $res -replace 'XYZ\s*BANDAICHANNEL\s*XYZ', 'BANDAI CHANNEL'
    $res = $res -replace 'XYZ\s*KONAMICHANNEL\s*XYZ', 'KONAMI CHANNEL'
    $res = $res -replace 'XYZ\s*CAPCOMCHANNEL\s*XYZ', 'CAPCOM CHANNEL'
    $res = $res -replace 'XYZ\s*NAMCOCHANNEL\s*XYZ', 'NAMCO CHANNEL'
    $res = $res -replace 'XYZ\s*HUDSONCHANNEL\s*XYZ', 'HUDSON CHANNEL'
    $res = $res -replace 'XYZ\s*EACHANNEL\s*XYZ', 'EA CHANNEL'

    # 2. PlayStation Button Actions & Nuance (Enter -> Confirmar, Back -> Voltar in PT, etc.)
    if ($targetLangObj.psConfirm) {
        $c = $targetLangObj.psConfirm
        $res = $res -replace '(?i)\b(?:Enter|Entrar)\b(?!\s+(?:Entertainment|na|no|em|sala|quarto))', $c
        $res = $res -replace '\benter\b', $c.ToLower()
        $res = $res -replace '\bENTER\b', $c.ToUpper()
    }
    if ($targetLangObj.psBack) {
        $b = $targetLangObj.psBack
        $res = $res -replace '(?i)\bBack\b', $b
        $res = $res -replace '\bback\b', $b.ToLower()
        $res = $res -replace '\bBACK\b', $b.ToUpper()
    }

    # 3. PlayStation Controller Buttons (Shapes & Directions)
    # UNTOUCHABLES: Select, Start, L1, L2, L3, R1, R2, R3 MUST NEVER be translated.
    if ($targetLangObj.psCircle) {
        $circ = $targetLangObj.psCircle
        $res = $res -replace '\bCircle\b', $circ
        $res = $res -replace '\bcircle\b', $circ.ToLower()
        $res = $res -replace '\bCIRCLE\b', $circ.ToUpper()
    }
    if ($targetLangObj.psCross) {
        $cr = $targetLangObj.psCross
        $res = $res -replace '\bCross\b', $cr
        $res = $res -replace '\bcross\b', $cr.ToLower()
        $res = $res -replace '\bCROSS\b', $cr.ToUpper()
    }
    if ($targetLangObj.psSquare) {
        $sq = $targetLangObj.psSquare
        $res = $res -replace '\bSquare\b', $sq
        $res = $res -replace '\bsquare\b', $sq.ToLower()
        $res = $res -replace '\bSQUARE\b', $sq.ToUpper()
    }
    if ($targetLangObj.psTriangle) {
        $tr = $targetLangObj.psTriangle
        $res = $res -replace '\bTriangle\b', $tr
        $res = $res -replace '\btriangle\b', $tr.ToLower()
        $res = $res -replace '\bTRIANGLE\b', $tr.ToUpper()
    }

    # 4. Standard UI & Menu terms (Universal for all 40 languages)
    if ($targetLangObj.installGames) {
        $res = $res -replace '(?i)[â€œ"''\u201C\u201D]Install\s+Games\s+and\s+Apps[â€"''\u201C\u201D]', ("`"{0}`"" -f $targetLangObj.installGames)
        $res = $res -replace '(?i)\bInstall\s+Games\s+and\s+Apps\b', $targetLangObj.installGames
    }
    if ($targetLangObj.optExtras) {
        $res = $res -replace '(?i)[â€œ"''\u201C\u201D]Optional\s+Extras[â€"''\u201C\u201D]', ("`"{0}`"" -f $targetLangObj.optExtras)
        $res = $res -replace '(?i)\bOptional\s+Extras(?:\s+menu)?\b', $targetLangObj.optExtras
    }
    if ($targetLangObj.gameSelector) {
        $res = $res -replace '(?i)[â€œ"''\u201C\u201D]Game\s+Selector[â€"''\u201C\u201D]', ("`"{0}`"" -f $targetLangObj.gameSelector)
        $res = $res -replace '(?i)\bGame\s+Selector\b', $targetLangObj.gameSelector
    }
    if ($targetLangObj.gameCollection) {
        $res = $res -replace '(?i)[â€œ"''\u201C\u201D](?:Game\s+Collection|Jogo\s+Collection)[â€"''\u201C\u201D]', ("`"{0}`"" -f $targetLangObj.gameCollection)
        $res = $res -replace '(?i)\b(?:Game\s+Collection|Jogo\s+Collection)\b', $targetLangObj.gameCollection
    }
    if ($targetLangObj.mc) {
        $res = $res -replace '(?i)[â€œ"''\u201C\u201D]Memory\s+Card[â€"''\u201C\u201D]', ("`"{0}`"" -f $targetLangObj.mc)
        $res = $res -replace '(?i)\bMemory\s+Card\b', $targetLangObj.mc
    }

    if ($isChangelog) {
        if ($targetLangObj.code -in @("pt", "pt-pt")) {
        # Enable / Disable terminology -> Ativar / Desativar
        $res = $res -replace '(?i)\bHabilite\b', 'Ative'
        $res = $res -replace '(?i)\bhabilite\b', 'ative'
        $res = $res -replace '(?i)\bHabilitar\b', 'Ativar'
        $res = $res -replace '(?i)\bhabilitar\b', 'ativar'
        $res = $res -replace '(?i)\bHabilitad([oa]s?)\b', 'Ativad$1'
        $res = $res -replace '(?i)\bhabilitad([oa]s?)\b', 'ativad$1'
        $res = $res -replace '(?i)\bDesabilite\b', 'Desative'
        $res = $res -replace '(?i)\bdesabilite\b', 'desative'
        $res = $res -replace '(?i)\bDesabilitar\b', 'Desativar'
        $res = $res -replace '(?i)\bdesabilitar\b', 'desativar'
        $res = $res -replace '(?i)\bDesabilitad([oa]s?)\b', 'Desativad$1'
        $res = $res -replace '(?i)\bdesabilitad([oa]s?)\b', 'desativad$1'
            $res = $res -replace '(?i)\b(?:Optional\s+Extras\s+menu|Extras\s+Menu|menu\s+Extras\s+Opcionais)\b', 'menu Extras opcionais'
            $res = $res -replace '(?i)selecione\s+[â€œ"''\u201C\u201D]?(?:Install\s+Games\s+and\s+Apps|Instalar\s+Jogos\s+e\s+Aplicativos)[â€"''\u201C\u201D]?', 'selecione â€œInstalar jogos e aplicativosâ€'
            $res = $res -replace '(?i)\b(?:Install\s+Games\s+and\s+Apps|Instalar\s+Jogos\s+e\s+Aplicativos)\b', 'Instalar jogos e aplicativos'
            $res = $res -replace '(?i)\b(?:do\s+|no\s+)?(?:Main\s+Menu|Menu\s+Principal)\b', 'no menu principal'
            $res = $res -replace '(?i)\bInstale\s+Jogos\b', 'Instalar jogos'
        }
    } else {
        if ($targetLangObj.code -in @("pt", "pt-pt")) {
        # Enable / Disable terminology -> Ativar / Desativar
        $res = $res -replace '(?i)\bHabilite\b', 'Ative'
        $res = $res -replace '(?i)\bhabilite\b', 'ative'
        $res = $res -replace '(?i)\bHabilitar\b', 'Ativar'
        $res = $res -replace '(?i)\bhabilitar\b', 'ativar'
        $res = $res -replace '(?i)\bHabilitad([oa]s?)\b', 'Ativad$1'
        $res = $res -replace '(?i)\bhabilitad([oa]s?)\b', 'ativad$1'
        $res = $res -replace '(?i)\bDesabilite\b', 'Desative'
        $res = $res -replace '(?i)\bdesabilite\b', 'desative'
        $res = $res -replace '(?i)\bDesabilitar\b', 'Desativar'
        $res = $res -replace '(?i)\bdesabilitar\b', 'desativar'
        $res = $res -replace '(?i)\bDesabilitad([oa]s?)\b', 'Desativad$1'
        $res = $res -replace '(?i)\bdesabilitad([oa]s?)\b', 'desativad$1'
            $res = $res -replace '(?i)\b(?:Optional\s+Extras|Extras\s+opcionais)\b', 'Extras Opcionais'
            $res = $res -replace '(?i)\b(?:Game\s+and\s+App\s+Installer|Instalador\s+de\s+jogos\s+e\s+aplicativos)\b', 'Instalador de Jogos e Aplicativos'
            $res = $res -replace '(?i)\b(?:Game\s+Installer|Instalador\s+de\s+jogos|Instalador\s+do\s+jogo)\b', 'Instalador de Jogos'
            $res = $res -replace '(?i)\b(?:Virtual\s+Memory\s+Cards|CartÃµes?\s+de\s+memÃ³ria\s+virtua(?:l|is))\b', 'Memory Cards Virtuais'
            $res = $res -replace '(?i)\b(?:VMC\s+Groups|Grupos\s+de\s+VMC)\b', 'Grupos VMC'
            $res = $res -replace '(?i)\b(?:Main\s+Menu|Menu\s+principal)\b', 'Menu Principal'
            $res = $res -replace '(?i)\bInstale\s+Jogos\s+e\s+Aplicativos\b', 'Instalar Jogos e Aplicativos'
            $res = $res -replace '(?i)\bInstale\s+Jogos\b', 'Instalar Jogos'
            $res = $res -replace '(?i)\bInstale\s+Fotos\b', 'Instalar Fotos'
            $res = $res -replace '(?i)\bInstale\s+Filmes\b', 'Instalar Filmes'
            $res = $res -replace '(?i)\bInstale\s+MÃºsica\b', 'Instalar MÃºsica'
            $res = $res -replace '(?i)\bInstale\s+mÃ­dia\b', 'Instalar MÃ­dia'
        }
    }
    # Portuguese PlayStation button refinements & specific UI terminology
    if ($targetLangObj.code -in @("pt", "pt-pt")) {
        # Enable / Disable terminology -> Ativar / Desativar
        $res = $res -replace '(?i)\bHabilite\b', 'Ative'
        $res = $res -replace '(?i)\bhabilite\b', 'ative'
        $res = $res -replace '(?i)\bHabilitar\b', 'Ativar'
        $res = $res -replace '(?i)\bhabilitar\b', 'ativar'
        $res = $res -replace '(?i)\bHabilitad([oa]s?)\b', 'Ativad$1'
        $res = $res -replace '(?i)\bhabilitad([oa]s?)\b', 'ativad$1'
        $res = $res -replace '(?i)\bDesabilite\b', 'Desative'
        $res = $res -replace '(?i)\bdesabilite\b', 'desative'
        $res = $res -replace '(?i)\bDesabilitar\b', 'Desativar'
        $res = $res -replace '(?i)\bdesabilitar\b', 'desativar'
        $res = $res -replace '(?i)\bDesabilitad([oa]s?)\b', 'Desativad$1'
        $res = $res -replace '(?i)\bdesabilitad([oa]s?)\b', 'desativad$1'
        $res = $res -replace '(?i)\b(?:botões\s+)?X\s+e\s+Círculo\b', 'botões Cruz e Círculo'
        $res = $res -replace '(?i)\bX\s*=\s*(?:Confirmar|confirmar)\b', 'Cruz = Confirmar'
        $res = $res -replace '(?i)\bConfirmar,\s*X\b', 'Confirmar, Cruz'
        $res = $res -replace '(?i)\bReatribuir\s+botões\s+(?:de\s+)?(?:X|cruz)\s+e\s+círculo\b', 'Reatribuir botões Cruz e Círculo'
        $res = $res -replace '(?i)#reassign-(?:cross|x|cruz)-and-(?:circle|círculo)-buttons', '#reatribuir-botões-cruz-e-círculo'
        $res = $res -replace '(?i)#reatribuir-botões-(?:x|cruz)-e-círculo', '#reatribuir-botões-cruz-e-círculo'
        $res = $res -replace '(?i)\[Configuração do botão\]', '[configuração dos botões]'
        $res = $res -replace '(?i)A\s+configuração\s+\[configuração dos botões\]', 'A [configuração dos botões]'
        $res = $res -replace '(?i)\|\s*INICIAR\s*\|', '| START |'
        $res = $res -replace '(?i)\bBotas\s+(\[[^\]]+\])', 'Inicializa $1'

        # HOSDMenu Browser vs General Browser vs Navigator
        $res = $res -replace '(?i)\[(?:Browser|Navegador)\]\(#hosdmenu\)', '[Rotina de pesquisa](#hosdmenu)'
        $res = $res -replace '(?i)e\s+no\s+\[Rotina de pesquisa\]\(#hosdmenu\)', 'e na [Rotina de pesquisa](#hosdmenu)'
        $res = $res -replace '(?i)\b(?:Menu\s+Navegador|Navegador\s+Menu)\b', 'Menu Navigator'
        $res = $res -replace '(?i)\bNavegador\b(?=\s+Menu)', 'Navigator'

        # Specific Title Casing & Module Terminology for Portuguese
        $res = $res -replace '(?i)\b(?:Movie\s+and\s+Photo\s+Installers?|Filme\s+e\s+Instalador\s+de\s+Fotos|Instalador(?:es)?\s+de\s+filmes\s+e\s+fotos)\b', 'Instaladores de Filmes e Fotos'
        $res = $res -replace '(?i)\b(?:Movie\s+Installer|Instalador\s+de\s+filmes)\b', 'Instalador de Filmes'
        $res = $res -replace '(?i)\b(?:Photo\s+Installer|Instalador\s+de\s+fotos)\b', 'Instalador de Fotos'
        $res = $res -replace '(?i)\b(?:Music\s+Installer|Instalador\s+de\s+m[úu]sicas?)\b', 'Instalador de Músicas'
        $res = $res -replace '(?i)\b(?:Game\s+and\s+App\s+Installer|Instalador\s+de\s+jogos\s+e\s+aplicativos)\b', 'Instalador de Jogos e Aplicativos'
        $res = $res -replace '(?i)\b(?:PS2\s+Linux\s+Installer|Instalador\s+do\s+PS2\s+Linux|Instalador\s+PS2\s+Linux)\b', 'Instalador do PS2 Linux'
        $res = $res -replace '(?i)\b(?:PSBBN\s+Installer|Instalador\s+PSBBN)\b', 'Instalador PSBBN'
        $res = $res -replace '(?i)\b(?:Bug\s+Fixes\s+and\s+Improvements|Correções?\s+de\s+bugs?\s+e\s+melhorias?)\b', 'Correções de Bugs e Melhorias'
        $res = $res -replace '(?i)\b(?:Bug\s+Fixes|Correções?\s+de\s+bugs?)\b', 'Correções de Bugs'
        $res = $res -replace '(?i)\b(?:New\s+Features|Novos\s+recursos)\b', 'Novos Recursos'
        $res = $res -replace '(?i)\b(?:Other\s+Changes|Outras\s+alterações)\b', 'Outras Alterações'
        $res = $res -replace '(?i)\b(?:More\s+Languages|Mais\s+idiomas)\b', 'Mais Idiomas'
        $res = $res -replace '(?i)\b(?:Enhancements|Aprimoramentos)\b', 'Aprimoramentos'
        $res = $res -replace '(?i)\b(?:Install\s+Media\s+Menu|Menu\s+Instalar\s+mídia|Menu\s+de\s+instalação\s+de\s+mídia)\b', 'Menu Instalar Mídia'
        $res = $res -replace '(?i)\b(?:Install\s+Media|Instalar\s+mídia)\b', 'Instalar Mídia'
        $res = $res -replace '(?i)\b(?:Full\s+release\s+notes|Notas\s+de\s+lançamento\s+completas)\b', 'Notas de Lançamento Completas'

        # Natural grammatical article flow for PSBBN in Portuguese
        $res = $res -replace '(?i)\bpara\s+PSBBN\b', 'para o PSBBN'
        $res = $res -replace '(?i)\bcom\s+PSBBN\b', 'com o PSBBN'
        $res = $res -replace '(?i)\bno\s+PSBBN\b', 'no PSBBN'
        $res = $res -replace '(?i)\bdo\s+PSBBN\b', 'do PSBBN'
        $res = $res -replace '(?i)\bao\s+PSBBN\b', 'ao PSBBN'
        $res = $res -replace '(?i)\bpelo\s+PSBBN\b', 'pelo PSBBN'
        $res = $res -replace '(?i)\bem\s+PSBBN\b', 'no PSBBN'
        $res = $res -replace '(?i)\bde\s+PSBBN\b', 'do PSBBN'
        $res = $res -replace '(?i)\bpara\s+o\s+o\s+PSBBN\b', 'para o PSBBN'
    }

    # 5. Channel Translations (Only for Readme, System PSBBN, and Script PSBBN; NOT for changelogs!)
    if (-not $isChangelog) {
        if ($targetLangObj.movieCh) {
            $res = $res -replace '(?i)\bMovie Channel\b', $targetLangObj.movieCh
            $res = $res -replace '(?i)\bmovie channel\b', $targetLangObj.movieCh.ToLower()
        }
        if ($targetLangObj.musicCh) {
            $res = $res -replace '(?i)\bMusic Channel\b', $targetLangObj.musicCh
            $res = $res -replace '(?i)\bmusic channel\b', $targetLangObj.musicCh.ToLower()
        }
        if ($targetLangObj.photoCh) {
            $res = $res -replace '(?i)\bPhoto Channel\b', $targetLangObj.photoCh
            $res = $res -replace '(?i)\bphoto channel\b', $targetLangObj.photoCh.ToLower()
        }
        if ($targetLangObj.internetCh) {
            $res = $res -replace '(?i)\bInternet Channel\b', $targetLangObj.internetCh
            $res = $res -replace '(?i)\binternet channel\b', $targetLangObj.internetCh.ToLower()
        }
        if ($targetLangObj.gameCh) {
            $res = $res -replace '(?i)\bGame Channel\b', $targetLangObj.gameCh
            $res = $res -replace '(?i)\bgame channel\b', $targetLangObj.gameCh.ToLower()
        }
        if ($targetLangObj.gameChPlural) {
            $res = $res -replace '(?i)\bGame Channels\b', $targetLangObj.gameChPlural
            $res = $res -replace '(?i)\bgame channels\b', $targetLangObj.gameChPlural.ToLower()
        }
        if ($targetLangObj.onlineCh) {
            $res = $res -replace '(?i)\bOnline Channels\b', $targetLangObj.onlineCh
            $res = $res -replace '(?i)\bonline channels\b', $targetLangObj.onlineCh.ToLower()
        }

        # Publisher / Brand Channels (CAPCOM, KONAMI, NAMCO, BANDAI, HUDSON, EA)
        $chWord = if ($targetLangObj.channelWord) { $targetLangObj.channelWord } else { "Canal" }
        $chWordUpper = $chWord.ToUpper()
        $chWordTitle = (Get-Culture).TextInfo.ToTitleCase($chWord.ToLower())

        $isPrefixLang = ($targetLangObj.code -in @("pt", "pt-pt", "es", "fr", "it", "ro", "ru", "uk", "bg", "sr"))

        $publishers = @("CAPCOM", "KONAMI", "NAMCO", "BANDAI", "HUDSON", "EA", "SONY", "SCEI", "SEGA")
        foreach ($pub in $publishers) {
            $pubTitle = (Get-Culture).TextInfo.ToTitleCase($pub.ToLower())
            if ($isPrefixLang) {
                # ALL CAPS: CAPCOM CHANNEL -> CANAL CAPCOM
                $res = $res -replace ("(?i)\b$pub\s+CHANNEL\b"), "$chWordUpper $pub"
                # Title Case: Capcom Channel -> Canal Capcom
                $res = $res -replace ("(?i)\b$pub\s+Channel\b"), "$chWordTitle $pubTitle"
                $res = $res -replace ("(?i)\b$pubTitle\s+Channel\b"), "$chWordTitle $pubTitle"
            } else {
                # Suffix format for others (e.g. Japanese, German, etc.)
                $res = $res -replace ("(?i)\b$pub\s+CHANNEL\b"), "$pub $chWordUpper"
                $res = $res -replace ("(?i)\b$pub\s+Channel\b"), "$pubTitle $chWordTitle"
                $res = $res -replace ("(?i)\b$pubTitle\s+Channel\b"), "$pubTitle $chWordTitle"
            }
        }
    }

    # 6. HOSDMenu / HDD-OSD / PS2 Browser Nuance
    # Official Sony PS2 Portuguese (Portugal & Brazil): "Rotina de pesquisa"
    if ($targetLangObj.hosdBrowser) {
        $hb = $targetLangObj.hosdBrowser

        # Explicit markdown links to #hosdmenu:
        # [Browser](#hosdmenu) / [Navegador](#hosdmenu) -> [Rotina de pesquisa](#hosdmenu)
        $res = $res -replace '(?i)\[(?:Browser|Navegador|navegador)\]\(#hosdmenu\)', "[$hb](#hosdmenu)"

        if ($targetLangObj.code -in @("pt", "pt-pt")) {
        # Enable / Disable terminology -> Ativar / Desativar
        $res = $res -replace '(?i)\bHabilite\b', 'Ative'
        $res = $res -replace '(?i)\bhabilite\b', 'ative'
        $res = $res -replace '(?i)\bHabilitar\b', 'Ativar'
        $res = $res -replace '(?i)\bhabilitar\b', 'ativar'
        $res = $res -replace '(?i)\bHabilitad([oa]s?)\b', 'Ativad$1'
        $res = $res -replace '(?i)\bhabilitad([oa]s?)\b', 'ativad$1'
        $res = $res -replace '(?i)\bDesabilite\b', 'Desative'
        $res = $res -replace '(?i)\bdesabilite\b', 'desative'
        $res = $res -replace '(?i)\bDesabilitar\b', 'Desativar'
        $res = $res -replace '(?i)\bdesabilitar\b', 'desativar'
        $res = $res -replace '(?i)\bDesabilitad([oa]s?)\b', 'Desativad$1'
        $res = $res -replace '(?i)\bdesabilitad([oa]s?)\b', 'desativad$1'
            $res = $res -replace '(?i)\[HOSDMenu\s+(?:Browser|Navegador|navegador)\]\(#hosdmenu\)', "[Rotina de pesquisa do HOSDMenu](#hosdmenu)"
            $res = $res -replace '(?i)\[HOSDMenu\]\(#hosdmenu\)\s+(?:Browser|Navegador|navegador)\b', "[HOSDMenu](#hosdmenu) Rotina de pesquisa"
            $res = $res -replace '(?i)\bHDD-OSD\s*\(\s*(?:Browser|Navegador|navegador)\s+2\.0\s*\)', "HDD-OSD (Rotina de pesquisa 2.0)"
            $res = $res -replace '(?i)\[(?:Browser|Navegador|navegador)\s+2\.0\]\(#hosdmenu\)', "[Rotina de pesquisa 2.0](#hosdmenu)"
            $res = $res -replace '(?i)\b(?:Browser|Navegador|navegador)\s+2\.0\b', "Rotina de pesquisa 2.0"
            $res = $res -replace '(?i)\b(?:in|no|na)\s+(?:the\s+)?\*\*(?:Browser|Navegador|navegador)\*\*', "na **Rotina de pesquisa**"
            $res = $res -replace '(?i)\b(?:for|para\s+o)\s+(?:the\s+)?(?:Browser|Navegador|navegador)\b(?=.*(?:\.\.\.|\.|$))', "para a Rotina de pesquisa"
            $res = $res -replace '(?i)\b(?:and|e\s+no|e\s+na)\s+(?:the\s+)?(?:Browser|Navegador|navegador)\b(?=.*(?:#hosdmenu|HOSDMenu|jogos|games|ordem))', "e na Rotina de pesquisa"
            $res = $res -replace '(?i)\b(?:or|ou\s+no|ou\s+na)\s+(?:the\s+)?(?:Browser|Navegador|navegador)\b(?=.*(?:#hosdmenu|HOSDMenu|jogos|games))', "ou na Rotina de pesquisa"
        } else {
            $res = $res -replace '(?i)\[HOSDMenu\s+(?:Browser|Navegador|navegador)\]\(#hosdmenu\)', "[HOSDMenu $hb](#hosdmenu)"
            $res = $res -replace '(?i)\[HOSDMenu\]\(#hosdmenu\)\s+(?:Browser|Navegador|navegador)\b', "[HOSDMenu](#hosdmenu) $hb"
            $res = $res -replace '(?i)\bHDD-OSD\s*\(\s*(?:Browser|Navegador|navegador)\s+2\.0\s*\)', "HDD-OSD ($hb 2.0)"
            $res = $res -replace '(?i)\[(?:Browser|Navegador|navegador)\s+2\.0\]\(#hosdmenu\)', "[$hb 2.0](#hosdmenu)"
            $res = $res -replace '(?i)\b(?:Browser|Navegador|navegador)\s+2\.0\b', "$hb 2.0"
        }
    }

    return $res
}

# ------------------------------------------------------------------------------
# Title Casing Formatter (Preserves Acronyms, Brands, Connective Words, Anchors)
# ------------------------------------------------------------------------------
function Format-TitleCase([string]$str, [string]$langCode = "pt") {
    if ([string]::IsNullOrWhiteSpace($str)) { return $str }
    $stopWords = @(
        'de', 'do', 'da', 'dos', 'das', 'em', 'no', 'na', 'nos', 'nas', 'e', 'ou', 'um', 'uma', 'uns', 'umas', 'para', 'por', 'com', 'sem', 'a', 'o', 'os', 'as', 'ao', 'aos', 'à', 'às',
        'del', 'la', 'las', 'el', 'los', 'y', 'unos', 'unas',
        'di', 'dello', 'della', 'dei', 'degli', 'delle', 'al', 'allo', 'alla', 'ai', 'agli', 'alle', 'dal', 'nel', 'su', 'per', 'tra', 'fra', 'il', 'lo', 'gli', 'le',
        'du', 'des', 'au', 'aux', 'et', 'les', 'pour', 'par', 'avec', 'sans', 'sur', 'sous',
        'an', 'the', 'and', 'but', 'nor', 'at', 'from', 'by', 'of'
    )
    # Don't touch markdown anchors like (#slug) or urls like (https://...)
    $pattern = '(\(#[a-zA-Z0-9\-_]+\)|\(https?://[^\s)]+\)|[^\s\-_:/()\[\]{}]+)'
    return [regex]::Replace($str, $pattern, {
        param($m)
        $w = $m.Groups[1].Value
        # If it is an anchor or url, leave untouched!
        if ($w.StartsWith('(#') -or $w.StartsWith('(http')) {
            return $w
        }
        $offset = $m.Index
        # Preserve acronyms, brands, or words with multiple uppercase letters or numbers
        if ($w -cmatch '[A-Z].*[A-Z]' -or $w -cmatch '^[A-Z0-9_]+$' -or $w -match '\d') {
            return $w
        }
        $lower = $w.ToLower()
        if ($offset -gt 0 -and $stopWords -contains $lower) {
            return $lower
        }
        return ($lower.Substring(0, 1).ToUpper() + $lower.Substring(1))
    })
}

# ------------------------------------------------------------------------------
# GitHub Markdown Anchor Slug Generator
# ------------------------------------------------------------------------------
function Get-GithubSlug([string]$text) {
    if ([string]::IsNullOrWhiteSpace($text)) { return "" }
    $s = $text.Trim().ToLower()
    $s = $s -replace '<[^>]+>', ''
    $s = $s -replace '\[([^\]]+)\]\([^)]+\)', '$1'
    $s = $s -replace '[`*~_]', ''
    $s = $s -replace '[^\p{L}\p{N}\s-]', ''
    $s = $s -replace '\s+', '-'
    $s = $s -replace '-+', '-'
    return $s.Trim('-')
}

function Fit-ScriptLineLength([string]$text, [int]$maxLen = 104) {
    if ([string]::IsNullOrWhiteSpace($text) -or $text.Length -le $maxLen) {
        return $text
    }

    $t = $text.Trim()

    # Step 1: Intelligent Synonyms & Standard Abbreviations
    $t = $t -replace '(?i)\bconfigurations?\b', 'config'
    $t = $t -replace '(?i)\bconfiguraç(?:ão|ões)\b', 'config.'
    $t = $t -replace '(?i)\bconfiguraci(?:ón|ones)\b', 'config.'
    $t = $t -replace '(?i)\bapplications?\b', 'app'
    $t = $t -replace '(?i)\baplicativ(?:o|os)\b', 'app'
    $t = $t -replace '(?i)\baplicaç(?:ão|ões)\b', 'app'
    $t = $t -replace '(?i)\baplicaci(?:ón|ones)\b', 'app'
    $t = $t -replace '(?i)\binformations?\b', 'info'
    $t = $t -replace '(?i)\binformaç(?:ão|ões)\b', 'info'
    $t = $t -replace '(?i)\binformaci(?:ón|ones)\b', 'info'
    $t = $t -replace '(?i)\bdirector(?:y|ies)\b', 'folder'
    $t = $t -replace '(?i)\bdiret[oó]ri(?:o|os)\b', 'pasta'
    $t = $t -replace '(?i)\bdirectori(?:o|os)\b', 'carpeta'
    $t = $t -replace '(?i)\bdispositiv(?:o|os)\b', 'disp.'
    $t = $t -replace '(?i)\bdispositifs?\b', 'disp.'
    $t = $t -replace '(?i)\badministrad(?:or|ores)\b', 'admin'
    $t = $t -replace '(?i)\bautomátic(?:o|a|os|as|amente)\b', 'auto'
    $t = $t -replace '(?i)\bverificaç(?:ão|ões)\b', 'verif.'
    $t = $t -replace '(?i)\bpartiç(?:ão|ões)\b', 'part.'
    $t = $t -replace '(?i)\bpartici(?:ón|ones)\b', 'part.'
    $t = $t -replace '(?i)\bpartitions?\b', 'part.'
    $t = $t -replace '(?i)\binstalaç(?:ão|ões)\b', 'instal.'
    $t = $t -replace '(?i)\binstalaci(?:ón|ones)\b', 'instal.'
    $t = $t -replace '(?i)\binstallations?\b', 'install'
    $t = $t -replace '(?i)\bdisponív(?:el|eis)\b', 'disp.'
    $t = $t -replace '(?i)\bdisponibl(?:e|es)\b', 'disp.'
    
    # Cyrillic abbreviations
    $t = $t -replace '(?i)\bконфигураци[яи]\b', 'конфиг.'
    $t = $t -replace '(?i)\bинформаци[яи]\b', 'инфо'
    $t = $t -replace '(?i)\bприложени[яе]\b', 'прилож.'
    $t = $t -replace '(?i)\bдиректори[яи]\b', 'папка'
    $t = $t -replace '(?i)\bустановк[аи]\b', 'устан.'
    $t = $t -replace '(?i)\bраздел[ыа]?\b', 'разд.'
    $t = $t -replace '(?i)\bавтоматически\b', 'авто'

    # German abbreviations
    $t = $t -replace '(?i)\bkonfiguration(?:en)?\b', 'Konfig.'
    $t = $t -replace '(?i)\binformationen?\b', 'Info'
    $t = $t -replace '(?i)\banwendungen?\b', 'Apps'
    $t = $t -replace '(?i)\bverzeichniss?e?\b', 'Ordner'
    $t = $t -replace '(?i)\binstallation(?:en)?\b', 'Install.'
    $t = $t -replace '(?i)\bpartition(?:en)?\b', 'Part.'
    $t = $t -replace '(?i)\bautomatisch\b', 'auto'

    if ($t.Length -le $maxLen) { return $t }

    # Target length allowing room for "..."
    $safeLen = $maxLen - 3
    $candidate = $t.Substring(0, $safeLen)

    # Step 2: Sentence / clause boundary search between ($safeLen - 25) and $safeLen
    $punctIdx = -1
    $puncts = @('. ', '; ', ' - ', ', ')
    foreach ($p in $puncts) {
        $idx = $candidate.LastIndexOf($p)
        if ($idx -gt ($safeLen - 25) -and $idx -gt $punctIdx) {
            $punctIdx = $idx
        }
    }
    if ($punctIdx -gt 0) {
        $sentence = $candidate.Substring(0, $punctIdx).Trim()
        if (-not ($sentence.EndsWith('.') -or $sentence.EndsWith('!') -or $sentence.EndsWith('?'))) {
            $sentence += "."
        }
        if ($sentence.Length -le $maxLen) { return $sentence }
    }

    # Step 3: Clean word boundary search
    $spaceIdx = $candidate.LastIndexOf(' ')
    if ($spaceIdx -gt ($safeLen - 20)) {
        $trimmed = $candidate.Substring(0, $spaceIdx).Trim()
        $trimmed = $trimmed -replace '(?i)\s+(?:de|para|em|por|com|e|ou|the|a|an|and|or|in|on|to|for|with|y|en|con|et|dans|pour|und|oder|mit|für|и|в|на|с|для)$', ''
        if (-not ($trimmed.EndsWith('.') -or $trimmed.EndsWith('!') -or $trimmed.EndsWith('?'))) {
            $trimmed += "..."
        }
        if ($trimmed.Length -le $maxLen) { return $trimmed }
    }

    # Step 4: Strict fallback truncate
    return ($t.Substring(0, $safeLen) + "...")
}

function Invoke-ModuleScriptPsbbn($targetLangObj, $noWait = $false) {
    $ui = Get-ScriptUI
    try { $Host.UI.RawUI.WindowTitle = $ui.ScriptTitle } catch { }

    $baseDir = Join-Path $ScriptDir "Script PSBBN"
    $inputDir = Join-Path $baseDir "input"
    $outputDir = Join-Path $baseDir "output"
    foreach ($d in @($inputDir, $outputDir)) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }

    $sourceFile = Join-Path $inputDir "eng.txt"
    $onlineUrl = "https://raw.githubusercontent.com/CosmicScale/PSBBN-Definitive-Project/main/scripts/assets/lang/eng.txt"

    # Sempre baixa a versao mais recente oficial do GitHub (substituindo o arquivo)
    Write-Host ""
    Write-Host ("  " + $ui.DownloadingLatestGithub) -ForegroundColor Cyan
    Write-Host "      Link: $onlineUrl" -ForegroundColor DarkGray
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $wc.DownloadFile($onlineUrl, $sourceFile)
        Write-Host ("  " + ($ui.OfficialDownloadSuccess -f (Get-Item $sourceFile).Length)) -ForegroundColor Green
    } catch {
        Write-Host ("  " + ($ui.CannotConnectGithub -f $_.Exception.Message)) -ForegroundColor Yellow
        Write-Host ("  " + ($ui.UsingFallback -f $sourceFile)) -ForegroundColor DarkYellow
    }

    # Fallback local se estiver offline
    if (-not (Test-Path $sourceFile)) {
        $localCandidates = @(
            (Join-Path $ScriptDir "_Docs\_PSBBN Language update\eng.txt"),
            (Join-Path $ScriptDir "_PSBBN Language update\eng.txt"),
            (Join-Path (Split-Path -Parent $ScriptDir) "_Docs\_PSBBN Language update\eng.txt"),
            (Join-Path (Split-Path -Parent $ScriptDir) "_PSBBN Language update\eng.txt")
        )
        foreach ($cand in $localCandidates) {
            if (Test-Path $cand) {
                try { Copy-Item -Path $cand -Destination $sourceFile -Force | Out-Null; break } catch { }
            }
        }
    }
    if (-not (Test-Path $sourceFile)) {
        Write-Host ""
        Write-Host "  ========================================================================================" -ForegroundColor Red
        Write-Host ("  " + $ui.EngTxtErrorTitle) -ForegroundColor Red
        Write-Host "  ========================================================================================" -ForegroundColor Red
        Write-Host ("  " + ($ui.ExpectedPath -f $sourceFile)) -ForegroundColor Yellow
        Write-Host "    -> $sourceFile" -ForegroundColor White
        Write-Host ""
        Write-Host ("  " + $ui.EngTxtEnsureFile) -ForegroundColor DarkYellow
        Write-Host "  ========================================================================================" -ForegroundColor Red
        Write-Host ""
        Write-Host ("  " + $ui.PressAnyKey) -ForegroundColor Cyan
        [void][Console]::ReadKey($true)
        return "back"
    }

    $outFileName = ("{0}.txt" -f $targetLangObj.code3.ToLower())
    $destFile = Join-Path $outputDir $outFileName
    $cache = @{}

    Write-Host ""
    Show-HeaderBanner "PSBBN SCRIPT TRANSLATOR"
    Write-Host ("  {0} {1} ({2})" -f $ui.Translating, $targetLangObj.name, $targetLangObj.native) -ForegroundColor White
    Write-Host ("  {0} {1}" -f $ui.SourceFile, $sourceFile) -ForegroundColor DarkGray
    Write-Host ("  {0} {1}" -f $ui.DestFile, $destFile) -ForegroundColor DarkGray
    Write-Host ""

    $lines = [System.IO.File]::ReadAllLines($sourceFile, [System.Text.Encoding]::UTF8)
    $translatedLines = New-Object System.Collections.Generic.List[string]
    $total = $lines.Count
    $current = 0

    $batchKeys = New-Object System.Collections.Generic.List[string]
    $batchValues = New-Object System.Collections.Generic.List[string]

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $current++
        Show-InlineProgress $ui.Translating $current $total

        $cleanLine = $line.TrimStart([char]0xFEFF)
        if ($cleanLine -match '^#\s*(Maximum line length.*)$') {
            $cachedHeader = if ($cache.ContainsKey('#comment_header')) { [string]$cache['#comment_header'] } else { "" }
            if ($targetLangObj.code -in @('pt', 'pt-pt')) {
                $cLine = "# Comprimento máximo da linha 106 caracteres"
                $cache['#comment_header'] = $cLine
                $translatedLines.Add($cLine)
            } elseif (-not [string]::IsNullOrWhiteSpace($cachedHeader) -and $cachedHeader.Trim() -ne "#" -and $cachedHeader.Trim() -ne "# ") {
                $translatedLines.Add($cachedHeader)
            } else {
                $cTrans = Invoke-SingleTranslation $matches[1] $targetLangObj.google
                if ([string]::IsNullOrWhiteSpace($cTrans) -or -not (Is-ValidTranslation $cTrans)) {
                    $cTrans = $matches[1]
                }
                $cLine = "# " + $cTrans.Trim()
                $cache['#comment_header'] = $cLine
                $translatedLines.Add($cLine)
            }
            continue
        }

        if ([string]::IsNullOrWhiteSpace($cleanLine) -or $cleanLine.StartsWith("#")) {
            $translatedLines.Add($line)
            continue
        }

        $idx = $line.IndexOf('=')
        if ($idx -lt 0) {
            $translatedLines.Add($line)
            continue
        }

        $key = $line.Substring(0, $idx)
        $val = $line.Substring($idx + 1)

        if ($cache.ContainsKey($key) -and (Is-ValidTranslation $cache[$key])) {
            $polished = Apply-TermReplacements $cache[$key] $targetLangObj $false
            $fitted = Fit-ScriptLineLength $polished 104
            $translatedLines.Add("$key=$fitted")
        } else {
            # Protect PSBBN Definitive Project
            $tokenizedVal = $val -replace 'PSBBN Definitive Project', 'XYZPSBBNDEFPROJXYZ'

            $batchKeys.Add($key)
            $batchValues.Add($tokenizedVal)

            if ($batchKeys.Count -ge 15 -or $i -eq ($lines.Count - 1)) {
                [string[]]$batchRes = @(Invoke-BatchTranslation $batchValues.ToArray() $targetLangObj.google)
                for ($k = 0; $k -lt $batchKeys.Count; $k++) {
                    $bKey = $batchKeys[$k]
                    $bOrig = $batchValues[$k]
                    $bTrans = if ($k -lt $batchRes.Count -and $batchRes[$k] -and (Is-ValidTranslation [string]$batchRes[$k])) { [string]$batchRes[$k] } else { $bOrig }
                    if ($bTrans.Length -eq 1 -and $bOrig.Length -gt 2) {
                        $bTrans = $bOrig
                    }
                    $bPolished = Apply-TermReplacements $bTrans $targetLangObj $false
                    $bFitted = Fit-ScriptLineLength $bPolished 104

                    if (Is-ValidTranslation $bFitted) {
                        $cache[$bKey] = $bFitted
                    }
                    $translatedLines.Add("$bKey=$bFitted")
                }
                $batchKeys.Clear()
                $batchValues.Clear()
            }
        }
    }

    Write-Host ""
    [System.IO.File]::WriteAllLines($destFile, $translatedLines.ToArray(), [System.Text.Encoding]::UTF8)

    

    Write-Host ""
    Write-Host "  ========================================================================================" -ForegroundColor Green
    Write-Host ("  " + ($ui.CompletionBanner -f "script PSBBN")) -ForegroundColor Green
    Write-Host "  ========================================================================================" -ForegroundColor Green
    Write-Host ""
    if (-not $noWait) { return (Wait-EndNavigation -inputFiles @($sourceFile)) }
    return "menu"
}

# ------------------------------------------------------------------------------
# Standalone Interactive Hub Loop
# ------------------------------------------------------------------------------

if ($Lang) {
    if ($Lang -eq "all" -or $Lang -eq "A" -or $Lang -eq "a") {
        foreach ($langObj in $Languages40) {
            Invoke-ModuleScriptPsbbn $langObj -noWait $true
        }
        exit 0
    } else {
        $rawParts = $Lang -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        $expandedParts = New-Object System.Collections.Generic.List[string]
        foreach ($rp in $rawParts) {
            if ($rp -match '^(\d{1,2})\s*-\s*(\d{1,2})$') {
                $start = [int]$matches[1]
                $end = [int]$matches[2]
                if ($start -le $end) {
                    for ($n = $start; $n -le $end; $n++) { $expandedParts.Add([string]$n) }
                } else {
                    for ($n = $start; $n -ge $end; $n--) { $expandedParts.Add([string]$n) }
                }
            } else {
                $expandedParts.Add($rp)
            }
        }
        $selectedList = New-Object System.Collections.Generic.List[object]
        foreach ($p in $expandedParts) {
            foreach ($l in $Languages40) {
                if ($p -eq $l.id -or $p -eq $l.id.PadLeft(2, '0') -or $p.ToLower() -eq $l.code.ToLower() -or $p.ToLower() -eq $l.code3.ToLower()) {
                    if (-not $selectedList.Contains($l)) {
                        $selectedList.Add($l)
                    }
                    break
                }
            }
        }
        if ($selectedList.Count -gt 0) {
            foreach ($item in $selectedList) {
                Invoke-ModuleScriptPsbbn $item -noWait $true
            }
            exit 0
        }
    }
}

function Show-StandaloneMenu {
    while ($true) {
        $ui = Get-ScriptUI
        $title = $ui.ScriptTitle
        $desc = $ui.DescScript
        try { $Host.UI.RawUI.WindowTitle = $title } catch { }
        Clear-Host
        Show-HeaderBanner $title
        Write-Host ("  {0} {1}" -f $ui.SessionStarted, (Get-SessionStartTime)) -ForegroundColor DarkGray
        Write-Host ("  {0}" -f $desc) -ForegroundColor White
        Write-Host ("  {0} {1}" -f $ui.SourceFile, "Script PSBBN\input\eng.txt") -ForegroundColor DarkGray
        Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor DarkGray

        for ($i = 0; $i -lt 20; $i++) {
            $l1 = $Languages40[$i]
            $l2 = $Languages40[$i + 20]
            $id1 = $l1.id.PadLeft(2, '0')
            $id2 = $l2.id.PadLeft(2, '0')
            $col1 = ("  [{0}] {1,-26}" -f $id1, $l1.name)
            $col2 = ("[{0}] {1,-26}" -f $id2, $l2.name)
            Write-Host -NoNewline $col1 -ForegroundColor White
            Write-Host $col2 -ForegroundColor White
        }

        Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host ("  [A] {0}" -f $ui.AllLanguages) -ForegroundColor Green
        Write-Host ("  [L] {0}" -f $ui.ChangeLanguage) -ForegroundColor Magenta
        Write-Host ("  [0] {0}" -f $ui.ExitOption) -ForegroundColor Red
        Write-Host "========================================================================================" -ForegroundColor Cyan
        Write-Host ""
        $choice = Read-Host ("  " + $ui.ChooseOption)
        $choice = $choice.Trim()

        if ($choice -eq "0") { exit 0 }
        if ($choice -eq "L" -or $choice -eq "l") {
            Select-ScriptUILanguage
            continue
        }
        if ($choice -eq "A" -or $choice -eq "a") {
            foreach ($langObj in $Languages40) {
                Invoke-ModuleScriptPsbbn $langObj -noWait $true
            }
            Write-Host ""
            Write-Host "  ========================================================================================" -ForegroundColor Green
            Write-Host ("  " + ($ui.CompletionBanner -f $title)) -ForegroundColor Green
            Write-Host "  ========================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host ("  " + $ui.NavInstructions) -ForegroundColor Cyan
            $nav = Wait-EndNavigation
            continue
        }

        $rawParts = $choice -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        $expandedParts = New-Object System.Collections.Generic.List[string]
        foreach ($rp in $rawParts) {
            if ($rp -match '^(\d{1,2})\s*-\s*(\d{1,2})$') {
                $start = [int]$matches[1]
                $end = [int]$matches[2]
                if ($start -le $end) {
                    for ($n = $start; $n -le $end; $n++) { $expandedParts.Add([string]$n) }
                } else {
                    for ($n = $start; $n -ge $end; $n--) { $expandedParts.Add([string]$n) }
                }
            } else {
                $expandedParts.Add($rp)
            }
        }
        $selectedList = New-Object System.Collections.Generic.List[object]
        foreach ($p in $expandedParts) {
            foreach ($l in $Languages40) {
                if ($p -eq $l.id -or $p -eq $l.id.PadLeft(2, '0') -or $p.ToLower() -eq $l.code.ToLower() -or $p.ToLower() -eq $l.code3.ToLower()) {
                    if (-not $selectedList.Contains($l)) {
                        $selectedList.Add($l)
                    }
                    break
                }
            }
        }

        if ($selectedList.Count -gt 0) {
            $multi = ($selectedList.Count -gt 1)
            for ($idx = 0; $idx -lt $selectedList.Count; $idx++) {
                $item = $selectedList[$idx]
                $isLast = ($idx -eq ($selectedList.Count - 1))
                $noWaitFlag = if ($multi) { -not $isLast } else { $false }
                Invoke-ModuleScriptPsbbn $item -noWait $noWaitFlag
            }
            continue
        } else {
            Write-Host ""
            Write-Host ("  " + $ui.InvalidOption) -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

Show-StandaloneMenu