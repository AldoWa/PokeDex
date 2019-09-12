import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_image/network.dart';
import 'package:poke_app_completing/pokemonDetailScreen.dart';

void main() {
  runApp(MaterialApp(
    title: "Poke App",
    debugShowCheckedModeBanner: false,
    home: PokemonData(),
  ));
}

//Tela Inicial que contém a GridView Dos Pokemons
class PokemonData extends StatefulWidget {
  @override
  PokemonDataState createState() => PokemonDataState();
}

//State da tela Inicial que contém a GridView Dos Pokemons
class PokemonDataState extends State<PokemonData>
    with PortraitStatefulModeMixin {
  final TextEditingController filter = new TextEditingController();
  Icon iconeAtual = new Icon(Icons.search);
  Widget appbarTitulo = new Text("Poke App");

  final String urlPokeApi =
      "https://pokeapi.co/api/v2/pokemon/?offset=0&limit=964";
  final String urlImage =
      "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/";
  List<dynamic> informacoesGerais;
  List<dynamic> informacoesGeraisFiltred;
  String searchText = "";
  List<String> urlImagens;
  List<String> urlImagensFiltred;

  PokemonDataState() {
    this.filter.addListener(() {
      if (this.filter.text.isEmpty) {
        setState(() {
          this.searchText = "";
        });
      } else {
        setState(() {
          this.searchText = this.filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.retornandoInformacoesGeral();
  }

  Future<String> retornandoInformacoesGeral() async {
    //ResBody = utilizada para obtencao do nome do pokemon e link para as outras informacoes
    var res = await http.get(Uri.encodeFull(urlPokeApi),
        headers: {"Accepet": "application/json"});
    Map<String, dynamic> resBody = json.decode(res.body);
    informacoesGerais = resBody['results'];
    informacoesGeraisFiltred = informacoesGerais;
    if (this.mounted) {
      setState(() {});
    }
    return "Sucesso";
  }

  //Metodo responsavel por extrair o id do pokemon a partir da url passada como parametro e gerar a url completa com o link da imagem
  String formaUrlImagem(String url) {
    String pokemonIndex = url.split('/')[url.split('/').length - 2];
    String linkImagem = this.urlImage + pokemonIndex + ".png";
    return linkImagem;
  }

  List<Widget> gerandoGridView(List<dynamic> informacoesGerais) {
    List<Widget> listaWidget =
        List<Widget>.generate(informacoesGerais.length, (int indice) {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PokemonDetailScreen(
                  urlInfEspecificas: informacoesGerais[indice]['url'],
                  urlImagem:
                      this.formaUrlImagem(informacoesGerais[indice]['url']));
            }));
          },
          child: Card(
            elevation: 10.0,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image(
                  image: NetworkImageWithRetry(
                      this.formaUrlImagem(informacoesGerais[indice]['url'])),
                ),
                Text(
                  (informacoesGerais[indice]['name']),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                      color: Colors.black),
                  textDirection: TextDirection.ltr,
                )
              ],
            ),
          ),
        ),
      );
    });
    return listaWidget;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return informacoesGerais == null
        ? Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/backgroundImage.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: this.appbarTitulo,
              backgroundColor: Colors.cyan,
              actions: <Widget>[
                IconButton(
                  icon: this.iconeAtual,
                  onPressed: () {
                    this.searchPressed();
                  },
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/backgroundImage.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: this.buildGridView(),
            ));
  }

  void searchPressed() {
    setState(() {
      if (this.iconeAtual.icon == Icons.search) {
        this.iconeAtual = new Icon(Icons.close);
        this.appbarTitulo = new TextField(
          controller: this.filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this.iconeAtual = new Icon(Icons.search);
        this.appbarTitulo = new Text("Poke App");
        this.searchText = "";
        this.filter.clear();
      }
    });
  }

  Widget buildGridView() {
    String actualName;
    this.informacoesGeraisFiltred = this.informacoesGerais;
    if (this.searchText.isNotEmpty) {
      this.informacoesGeraisFiltred = List<dynamic>();
      for (int i = 0; i < this.informacoesGerais.length; i++) {
        actualName = this.informacoesGerais[i]['name'];
        if (actualName.startsWith(this.searchText.toLowerCase())) {
          this.informacoesGeraisFiltred.add(this.informacoesGerais[i]);
        }
      }
    }
    return GridView.count(
      crossAxisCount: 2,
      children: this.gerandoGridView(this.informacoesGeraisFiltred),
    );
  }
}

//Elemento de cada Bloco da GridView
class GridViewElement extends StatefulWidget {
  final GridViewElementState state;
  GridViewElement({
    this.state,
  });

  @override
  GridViewElementState createState() {
    return this.state;
  }
}

class GridViewElementState extends State<GridViewElement> {
  final String stringAnalise;
  String imagemBackground;

  GridViewElementState({this.stringAnalise});

  @override
  void initState() {
    super.initState();
    this.garantindoImagem();
  }

  Future<String> garantindoImagem() async {
    await this.retornandoUrl();
    return "Sucess";
  }

  Future<String> retornandoUrl() async {
    var res = await http.get(this.stringAnalise);
    if (res.statusCode == 404) {
      this.imagemBackground =
          "https://www.termoparts.com.br/wp-content/uploads/2017/10/no-image.jpg";
    } else {
      this.imagemBackground = this.stringAnalise;
    }
    if (this.mounted) {
      setState(() {});
    }
    return "Sucess";
  }

  @override
  Widget build(BuildContext context) {
    return this.imagemBackground == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            height: 100.0,
            width: 100.0,
            child: Image.network(this.imagemBackground),
          );
  }
}

//Mixim para bloquear rotacao da tela
mixin PortraitStatefulModeMixin<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();
    return null;
  }
}

void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
