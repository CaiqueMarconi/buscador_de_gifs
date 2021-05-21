import 'dart:convert';

import 'package:buscador_de_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=wwMReHjx1FKRYF6fRhuhfx4YuCyqqCff&limit=25&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=wwMReHjx1FKRYF6fRhuhfx4YuCyqqCff&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt");

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18 // cor da fonte q aparecera quando o user digitar
                  ),
              textAlign: TextAlign.center, //
              onSubmitted: (text) {
                // para pesquisar um gif
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              }, // para começar a escrever dentro do formfield do meio
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  // switch no estado da conexão
                  case ConnectionState.waiting: // caso ele esteja esperando
                  case ConnectionState.none: // caso ele esteja carregando nd
                    return Container(
                      // vai demonstrar um circulo rodando ao meio, pra n ficar vazio sem nd
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        // vai colocar uma animação branca pro indicator
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container(); // se encontrar um erro para buscar os dados vai retornar um container seria possivel criar algo ali dentro do container mais n sera feito agr;
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search.isEmpty) {
      // se estiver sem pesquisa ou se o user pesquisar nulo vai aparecer os melhores gifs
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                // para quando as imagens aparecerem aparecer de forma mais suave
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]
                    ["url"],
                height: 300,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GifPage(snapshot.data["data"]
                            [index])) // passa pra uma nova tela
                    );
              },
              onLongPress: () {
                // segurar para compartilhar
                Share.share(
                  snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                );
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        });
  }
}
