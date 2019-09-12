import 'package:flutter/material.dart';
import 'package:flutter_image/network.dart';
import 'package:poke_app_completing/pokemon.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonDetailScreen extends StatefulWidget {
  final String urlInfEspecificas;
  final String urlImagem;

  PokemonDetailScreen({
    this.urlInfEspecificas,
    this.urlImagem,
  });

  @override
  PokemonDetailScreenState createState() {
    return PokemonDetailScreenState(
        urlInfEspecificas: this.urlInfEspecificas, urlImagem: this.urlImagem);
  }
}

class PokemonDetailScreenState extends State<PokemonDetailScreen> {
  String urlInfEspecificas;
  String urlImagem;
  Map<String, dynamic> listJsonFormatInfEspecificas;
  Pokemon pokemon;

  PokemonDetailScreenState({
    this.urlInfEspecificas,
    this.urlImagem,
  });

  @override
  void initState() {
    super.initState();
    this.retornandoInformacoesEspecificas();
  }

  Future<String> validandoImagem() async {
    var res = await http.get(this.urlImagem);
    if (res.statusCode == 404) {
      this.urlImagem =
          "https://www.termoparts.com.br/wp-content/uploads/2017/10/no-image.jpg";
    } 
    if (this.mounted) {
      setState(() {});
    }
    return "Sucess";
  }

  Future<String> retornandoInformacoesEspecificas() async {
    //ResBody = utilizada para obtencao do nome do pokemon e link para as outras informacoes
    var res = await http.get(Uri.encodeFull(this.urlInfEspecificas),
        headers: {"Accepet": "application/json"});
    Map<String, dynamic> resBody = json.decode(res.body);
    this.listJsonFormatInfEspecificas = resBody;
    await this.validandoImagem();
    this.pokemon =
        Pokemon.fromJson(listJsonFormatInfEspecificas, this.urlImagem);
    setState(() {});
    return "Sucesso";
  }

  @override
  Widget build(BuildContext context) {
    return this.pokemon == null
        ? Container(
            color: Colors.cyan,
            child: Center(
              child:  CircularProgressIndicator(backgroundColor: Colors.red,),
              )
          )
        : Scaffold(
            backgroundColor: Colors.cyan,
            appBar: AppBar(
              backgroundColor: Colors.cyan,
              elevation: 0.0,
              title: Text(
                this.pokemon.name,
                style: TextStyle(),
              ),
            ),
            body: Stack(
              children: <Widget>[
                Positioned(
                  //MediaQuery para retornarmos exatamente o tamanho da tela onde esta sendo rodado o app
                  height: MediaQuery.of(context).size.height / 1.5,
                  width: MediaQuery.of(context).size.width - 20,
                  left: 10.0,
                  top: MediaQuery.of(context).size.height * 0.1,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          height: 75.0,
                        ),
                        Text("Altura:  ${pokemon.height}"),
                        Text("Peso:  ${pokemon.weight}"),
                        Text(
                          "Tipos",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: pokemon.type
                              .map((f) => FilterChip(
                                    label: Text(f),
                                    onSelected: (bool) {},
                                    elevation: 2.0,
                                    backgroundColor: Colors.amber,
                                  ))
                              .toList(),
                        ),
                        Text(
                          "Status Base",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("Atk"),
                            Text("Def"),
                            Text("Hp"),
                            Text("Spd"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: pokemon.stats
                              .map((f) => FilterChip(
                                    label: Text(f.toString()),
                                    onSelected: (bool) {},
                                    elevation: 2.0,
                                    backgroundColor: Colors.deepOrange,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                      child: Container(
                        height: 150.0,
                        width: 150.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImageWithRetry(pokemon.img))),
                      ),
                )
              ],
            ),
          );
  }
}
