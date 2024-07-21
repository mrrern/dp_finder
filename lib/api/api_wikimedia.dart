import 'package:http/http.dart' as http;
import 'dart:convert';

class WikidataService {
  static const int _batchSize = 20;

  Future<List<Map<String, dynamic>>> fetchAuthorData(int offset) async {
    final query = '''
    SELECT DISTINCT ?item ?itemLabel ?itemDescription ?death WHERE {
      ?item wdt:P31 wd:Q5;  # find humans
            wdt:P19/wdt:P17* wd:Q717;  # born in Venezuela
            wdt:P570 ?death.
      FILTER (?death < "1960-01-01T00:00:00Z"^^xsd:dateTime)
      SERVICE wikibase:label { bd:serviceParam wikibase:language "es,en,[AUTO_LANGUAGE]". }
    }
    LIMIT $_batchSize OFFSET $offset
    ''';

    final url =
        'https://query.wikidata.org/sparql?query=${Uri.encodeComponent(query)}&format=json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results']['bindings'];

      return results.map<Map<String, dynamic>>((result) {
        final item = result['item']['value'];
        final label = result['itemLabel']['value'];
        final description = result['itemDescription'] != null
            ? result['itemDescription']['value']
            : '';
        final deathDate = result['death']['value'];

        return {
          'item': item,
          'label': label,
          'description': description,
          'deathDate': deathDate,
          
        };
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }


}
