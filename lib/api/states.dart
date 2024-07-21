

// Definimos el estado del autor
enum AuthorState { initial, loading, loaded, error }

enum Country {
  venezuela,
  argentina,
  brazil,
  chile,
  mexico,
  // Agregar más países según sea necesario
}

Map<Country, int> copyrightDurations = {
  Country.venezuela: 60,
  Country.argentina: 70,
  Country.brazil: 70,
  Country.chile: 70,
  Country.mexico: 100,
  // Agregar más países con sus respectivas duraciones
};


String getCountryName(Country country) {
    switch (country) {
      case Country.venezuela:
        return 'Venezuela';
      case Country.argentina:
        return 'Argentina';
      case Country.brazil:
        return 'Brazil';
      case Country.chile:
        return 'Chile';
      case Country.mexico:
        return 'Mexico';
      default:
        return 'Venezuela';
    }
  }