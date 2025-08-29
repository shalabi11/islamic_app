import 'package:flutter/material.dart';
import 'package:islamic_app/features/quran/views/widget/audio_player_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/verse_model.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? highlightVerseNumber;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.highlightVerseNumber,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    if (widget.highlightVerseNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse();
      });
    }
  }

  void _scrollToVerse() {
    final verseIndex = widget.highlightVerseNumber! - 1;
    // إضافة تعديل للبسملة (إذا كانت السورة ليست التوبة أو الفاتحة)
    final adjustedIndex = (widget.surah.number != 1 && widget.surah.number != 9)
        ? verseIndex + 1
        : verseIndex;
    itemScrollController.scrollTo(
      index: adjustedIndex,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كانت السورة تبدأ بالبسملة
    final bool hasBismillah =
        widget.surah.number != 1 && widget.surah.number != 9;

    return Scaffold(
      bottomNavigationBar: AudioPlayerWidget(surah: widget.surah),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              widget.surah.nameAr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            floating: true,
            pinned: true,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          SliverFillRemaining(
            child: ScrollablePositionedList.builder(
              itemCount: widget.surah.verses.length + (hasBismillah ? 1 : 0),
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemBuilder: (context, index) {
                // إذا كانت السورة لها بسملة، اعرضها في أول عنصر
                if (hasBismillah && index == 0) {
                  return const BismillahHeader();
                }

                // حساب index الآية الصحيح
                final verseIndex = hasBismillah ? index - 1 : index;
                final Verse verse = widget.surah.verses[verseIndex];

                final bool isHighlighted =
                    (verse.number == widget.highlightVerseNumber);

                return VerseTile(verse: verse, isHighlighted: isHighlighted);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- ويدجت البسملة (أضفناها مجدداً) ---
class BismillahHeader extends StatelessWidget {
  const BismillahHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Text(
        "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }
}

// --- ويدجت عرض الآية (كاملة ومع اللون الجديد) ---
class VerseTile extends StatelessWidget {
  const VerseTile({super.key, required this.verse, this.isHighlighted = false});

  final Verse verse;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      // ✅ التعديل هنا: استخدام لون أكثر وضوحاً
      color: isHighlighted ? Colors.amber.shade100 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // إضافة حدود ملونة للآية المحددة لزيادة الوضوح
        side: isHighlighted
            ? BorderSide(color: Colors.amber.shade400, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: verse.textAr,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 25,
                  color: Colors.black87,
                  height: 2.0,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    verse.number.toString(),
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
