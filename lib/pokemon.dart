class Pokemon {
  String name;
  String img;
  List<String> type;
  int height;
  int weight;
  /*Por padrao sera adicionados os seguintes status, na respectiva ordem:
  [attack,defense,hp,speed]
  */
  List<int> stats;

  Pokemon({
    this.name,
    this.img,
    this.type,
    this.height,
    this.weight,
    this.stats,
  });

  Pokemon.fromJson(Map<String,dynamic> mapaDeInformacoesEspecificas,String urlImagem) {
    this.name = this.primeiraLetraMaiuscula(mapaDeInformacoesEspecificas['name']);
    this.img = urlImagem;
    this.type = this.filtragemDeTipos(mapaDeInformacoesEspecificas);
    this.height = mapaDeInformacoesEspecificas['height'];
    this.weight = mapaDeInformacoesEspecificas['weight'];
    this.stats = this.filtragemDeStatus(mapaDeInformacoesEspecificas);
  }

  //Metodo responsavel por filtrar os tipos somente de tipo, da lista de caracteristicas gerais
  //Posicao de cada status no vetor de status da API: posicao 0 = Speed | posicao 3 = defense | posicao 4 =  ataque | posicao 5 = hp
  List<int> filtragemDeStatus(Map<String, dynamic> jsonSpecifCaratheristhics) {
    List<int> listraFiltrada = List<int>();
    List<dynamic> listaNaoFiltrada = jsonSpecifCaratheristhics['stats'];
    listraFiltrada.add(listaNaoFiltrada[4]['base_stat']);
    listraFiltrada.add(listaNaoFiltrada[3]['base_stat']);
    listraFiltrada.add(listaNaoFiltrada[5]['base_stat']);
    listraFiltrada.add(listaNaoFiltrada[0]['base_stat']);

    return listraFiltrada;
  }

  //Metodo responsavel por filtrar os dados somente de tipo, da lista de caracteristicas gerais
  List<String> filtragemDeTipos(
      Map<String, dynamic> jsonSpecifCaratheristhics) {
    List<String> listraFiltrada = List<String>();
    List<dynamic> listaNaoFiltrada = jsonSpecifCaratheristhics['types'];
    for (int i = 0; i < listaNaoFiltrada.length; i++) {
      listraFiltrada.add(listaNaoFiltrada[i]['type']['name']);
    }

    return listraFiltrada;
  }

  String primeiraLetraMaiuscula(String string) {
    string = string[0].toUpperCase() + string.substring(1);
    return string;
  }
}
