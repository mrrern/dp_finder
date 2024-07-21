import 'package:dp_finder/export.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';



class AuthorCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final int duration;

  const AuthorCard({Key? key, required this.result, required this.duration})
      : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Hubo un error $url';
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  bool _checkPublicDomain(String deathDate, int duration) {
    final deathYear = int.parse(deathDate.substring(0, 4));
    final currentYear = DateTime.now().year;
    return currentYear - deathYear > duration;
  }

  @override
  Widget build(BuildContext context) {
    final isPublicDomain = _checkPublicDomain(result['deathDate'], duration);
    return Card(
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(result['label']),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Descripción: ${result['description']}'),
                    Text(
                        'Fecha de fallecimiento: ${_formatDate(result['deathDate'])}'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final wikiUrl =
                            'https://www.wikidata.org/wiki/${Uri.encodeComponent(result['item'].split('/').last)}';
                        _launchURL(wikiUrl);
                      },
                      child: Text('Ver en Wikidata'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final wikiPage = result['label'].replaceAll(' ', '_');
                        final wikipediaUrl =
                            'https://en.wikipedia.org/wiki/$wikiPage';
                        _launchURL(wikipediaUrl);
                      },
                      child: Text('Ver en Wikipedia'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cerrar'),
                  ),
                ],
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            result['image'] != null
                ? CachedNetworkImage(
                    imageUrl:
                        'https://commons.wikimedia.org/wiki/Special:FilePath/${Uri.encodeComponent(result['image'])}',
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.book),
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.book, size: 150),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                result['label'],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '${result['description']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Fecha de fallecimiento: ${_formatDate(result['deathDate'])}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Container(
              color: _checkPublicDomain(result['deathDate'], duration) ? Colors.green : Colors.red,
              padding: const EdgeInsets.all(4.0),
              child: Text(
              isPublicDomain ? 'Dominio Público' : 'Protegido',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
