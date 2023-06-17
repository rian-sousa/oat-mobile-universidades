import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App com Navegação',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/details': (context) => UniScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OAT - UNIDESC'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Seja bem-vindo(a) ao meu App!',
              style: TextStyle(fontSize: 28),
            ),
            const RotatedBox(
              quarterTurns: 0, // 90 degrees rotation (vertical)
              child: Text(
                'Essa é a primeira vez que faço um app :D \n\n Esse ap está sendo alimentado por uma API \n que lista todas as universidade de um país. \n\n\n\n   Por: \nRian Sousa Florentino das Chagas \nJoão Vitor Ferreira Dantas',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center, // Optional: Adjust the font size
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Ver universidades'),
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UniScreen extends StatefulWidget {
  @override
  _UniScreenState createState() => _UniScreenState();
}

class _UniScreenState extends State<UniScreen> {
  final List<String> paises = [
    'Brasil',
    'Estados Unidos',
    'China',
    'Alemanha',
    'Índia'
    // Adicione outros países aqui
  ];

  dynamic pais;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidades'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '\n Escolha um país',
              style: TextStyle(fontSize: 24),
            ),
            DropdownButton<String>(
              hint: const Text('Selecione um país'),
              value: pais,
              items: paises.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (String? paisSelecionado) async {
                setState(() {
                  pais = paisSelecionado;
                });
                universities = await callUni(paisSelecionado);
                setState(() {});
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: universities.length,
                itemBuilder: (BuildContext context, int index) {
                  University university = universities[index];
                  return ListTile(
                    title: Text(university.name),
                    subtitle: Text('País: ${university.country}'),
                    onTap: () async {
                      String webPage = university.webPages[0];
                      var uri = Uri.parse(webPage);
                      if (await canLaunchUrl(uri)) {
                        launchUrl(uri);
                        print('Item clicado');
                      } else {
                        print('Item clicado');
                        print('Não foi possível abrir a página');
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

List<University> universities = [];

Future<List<University>> callUni(pais) async {
  var uriBase = 'http://universities.hipolabs.com/search';
  var uriFinal;
  var local;
  var localReq;

  switch (pais) {
    case 'Brasil':
      uriFinal = Uri.parse('$uriBase?country=Brazil');
      break;
    case 'Estados Unidos':
      uriFinal = Uri.parse('$uriBase?country=United+States');
      break;
    case 'China':
      uriFinal = Uri.parse('$uriBase?country=China');
      break;
    case 'Alemanha':
      uriFinal = Uri.parse('$uriBase?country=Germany');
      break;
    case 'Índia':
      uriFinal = Uri.parse('$uriBase?country=India');
      break;
  }

  var resposta =
      await http.get(uriFinal, headers: {'Content-Type': 'application/json'});

  if (resposta.statusCode == 200) {
    print('A requisição foi enviada com sucesso');
    print('DEBUG URL: $uriFinal');
    List<dynamic> data = jsonDecode(resposta.body);
    return universities =
        data.map((item) => University.fromJson(item)).toList();
  } else {
    print('Erro na requisição. Código de Status: ${resposta.statusCode}');
    return [];
  }
}

class University {
  final String country;
  final String alphaTwoCode;
  final String name;
  final String? stateProvince;
  final List<String> domains;
  final List<String> webPages;

  University({
    required this.country,
    required this.alphaTwoCode,
    required this.name,
    this.stateProvince,
    required this.domains,
    required this.webPages,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      country: json['country'],
      alphaTwoCode: json['alpha_two_code'],
      name: json['name'],
      stateProvince: json['state-province'],
      domains: List<String>.from(json['domains']),
      webPages: List<String>.from(json['web_pages']),
    );
  }
}
