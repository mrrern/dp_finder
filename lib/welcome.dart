import 'package:dp_finder/export.dart';

class AuthorsPage extends StatefulWidget {
  const AuthorsPage({super.key});

  @override
  _AuthorsPageState createState() => _AuthorsPageState();
}

class _AuthorsPageState extends State<AuthorsPage> {
  final WikidataService _wikidataService = WikidataService();
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _filteredResults = [];
  bool _isLoading = false;
  int _offset = 0;
  Country selectedCountry = Country.venezuela;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMoreData();
    _searchController.addListener(_filterResults);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterResults);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final newResults = await _wikidataService.fetchAuthorData(_offset);
      setState(() {
        _results.addAll(newResults);
        _filteredResults =
            _results; // Inicialmente, todos los resultados están filtrados
        _offset += newResults.length;
      });
    } catch (e) {
      // Manejar errores
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectCountry(Country country) {
    setState(() {
      selectedCountry = country;
      _results.clear();
      _filteredResults.clear();
      _offset = 0; // Reiniciar el offset para la nueva consulta
      _loadMoreData(); // Volver a cargar los datos para el país seleccionado
    });
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredResults = _results.where((result) {
        final label = result['label'].toLowerCase();
        return label.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = copyrightDurations[selectedCountry] ?? 70;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: MediaQuery.of(context).size.height * 0.081,
          width: MediaQuery.of(context).size.width * 0.07,
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.fill,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<Country>(
            onSelected: _selectCountry,
            itemBuilder: (BuildContext context) {
              return Country.values.map((Country country) {
                return PopupMenuItem<Country>(
                  value: country,
                  child: Text(getCountryName(country)),
                );
              }).toList();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar autores...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _loadMoreData();
                  return true;
                }
                return false;
              },
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Tres columnas para laptops
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 0.75, // Ajustar para formato de laptop
                ),
                itemCount: _filteredResults.length + 1,
                itemBuilder: (context, index) {
                  if (index == _filteredResults.length) {
                    return _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }
                  final result = _filteredResults[index];
                  return AuthorCard(result: result, duration: duration);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return ListView(
                children: Country.values.map((Country country) {
                  return ListTile(
                    title: Text(country.toString().split('.').last),
                    onTap: () {
                      _selectCountry(country);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
            },
          );
        },
        child: const Icon(Icons.language),
      ),
    );
  }
}
