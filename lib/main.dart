// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'canvas.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'fileManager.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graph builder',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 16, 62, 153)),
          useMaterial3: true,
          scaffoldBackgroundColor: Color.fromARGB(255, 16, 62, 153)),
      home: const MyHomePage(title: 'Graph Builder Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _add = false;
  bool _connect = false;
  Offset saved_position = Offset(0, 0);
  Color _color = Colors.blue;
  String _position = "";
  String _addText = "Add new node";
  String _conectText = "";
  int indextoMove = -1;
  bool insideMove = false;
  Offset forNodesWhenMovingOutside = Offset(0, 0);
  String facebookAccount = "";
  Offset for_menu = Offset(0, 0);
  Offset for_menu2 = Offset(0, 0);
  ValueNotifier<int> redraw = ValueNotifier<int>(0);

  GraphPainter _painter = GraphPainter.without();
  late List<List<int>> connected_components;
  String _conectedComponentsText = "";
  void facebook() {
    print("FACEBOOK");
    for (var node in nodes) {
      double r = node.radius;
      if ((for_menu.dx - node.offset.dx) * (for_menu.dx - node.offset.dx) +
              (for_menu.dy - node.offset.dy) * (for_menu.dy - node.offset.dy) <=
          r * r) {
        FacebookAuth.instance.login(permissions: [
          "public_profile",
          "user_photos",
          "email"
        ]).then((value) async {
          FacebookAuth.instance.getUserData().then((data) async {
            String urlImg = "";
            int width = 0;
            int height = 0;

            setState(() {
              nodes[nodes.indexOf(node)].name = data["name"];
              urlImg = data["picture"]["data"]["url"];
              width = data["picture"]["data"]["width"];
              height = data["picture"]["data"]["height"];
              print(urlImg);
            });

            Response res = await http.get(Uri.tryParse(urlImg)!);
            image.Image img = image.decodeImage(res.bodyBytes)!;

            nodes[nodes.indexOf(node)].originalImage = img;

            image.Image imgI = image.copyResize(
              img,
              width: 2 * node.radius.toInt(),
              height: 2 * node.radius.toInt(),
            );

            Uint8List uList = image.encodePng(imgI);
            ui.decodeImageFromList(uList, (result) {
              nodes[nodes.indexOf(node)].picture = result;
              setState(() {});
              redraw.value++;
            });
          });
        });

        /*
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                scrollable: true,
                title: const Text(
                    "Give facebook username get random image from that facebok page"),
                content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        child: Column(
                      children: [
                        TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'New Name'),
                            onChanged: (val) {
                              facebookAccount = val;
                            })
                      ],
                    ))),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("submit"))
                ],
              );
            }).then((value) => setState(() => {
              _conectText = "Image changed from facebook",
              http
                  .get(Uri.parse("http://192.168.100.13:7772/$facebookAccount"))
                  .then((value) => print("decoded" + value.body))
            }));*/
      }
    }
  }

  void rename() {
    print("enterd in rename");
    for (var node in nodes) {
      double r = node.radius;
      if ((for_menu.dx - node.offset.dx) * (for_menu.dx - node.offset.dx) +
              (for_menu.dy - node.offset.dy) * (for_menu.dy - node.offset.dy) <=
          r * r) {
        print("found node to rename");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                scrollable: true,
                title: const Text("Rename node"),
                content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        child: Column(
                      children: [
                        TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'New Name'),
                            onChanged: (val) {
                              node.name = val;
                            })
                      ],
                    ))),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("submit"))
                ],
              );
            }).then((value) => setState(() => _conectText = "Named changed"));

        break;
      }
    }
  }

  void delete() {
    String nameN = "";
    print("enterd here");
    for (var node in nodes) {
      double r = node.radius;
      if ((for_menu.dx - node.offset.dx) * (for_menu.dx - node.offset.dx) +
              (for_menu.dy - node.offset.dy) * (for_menu.dy - node.offset.dy) <=
          r * r) {
        print("found node");
        int index = nodes.indexOf(node);
        nameN = node.name;
        for (var vecin in node.neighbours) {
          int indexVecin =
              nodes.indexWhere((element) => element.index == vecin);
          if (indexVecin >= 0) {
            nodes[indexVecin]
                .neighbours
                .removeWhere((element) => element == node.index);
          }
        }
        nodes.removeAt(index);
        setState(() {
          _conectText = nameN + " was removed";
        });
        break;
      }
    }
  }

  void changeColor() {
    print("enterd in color picker");
    for (var node in nodes) {
      double r = node.radius;
      if ((for_menu.dx - node.offset.dx) * (for_menu.dx - node.offset.dx) +
              (for_menu.dy - node.offset.dy) * (for_menu.dy - node.offset.dy) <=
          r * r) {
        print("found node to change color");
        showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    scrollable: true,
                    title: const Text("Pick a color for node"),
                    content: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: ColorPicker(
                            pickerColor: node.color,
                            onColorChanged: (col) => {node.color = col})),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("submit"))
                    ],
                  );
                })
            .then((value) =>
                setState(() => _conectText = "color changed on " + node.name));

        break;
      }
    }
  }

  changePicture() {
    for (var node in nodes) {
      double r = node.radius;
      if ((for_menu.dx - node.offset.dx) * (for_menu.dx - node.offset.dx) +
              (for_menu.dy - node.offset.dy) * (for_menu.dy - node.offset.dy) <=
          r * r) {
        print("found node to change image");
        // ignore: use_build_context_synchronously
        showDialog(
                context: context,
                builder: (BuildContext context) {
                  Uint8List imgb64;
                  image.Image imgI;
                  Uint8List uList;
                  return AlertDialog(
                    scrollable: true,
                    title: const Text("Pick an image for node"),
                    content: SizedBox(
                        height: 50,
                        width: 50,
                        child: FloatingActionButton(
                            onPressed: () => {
                                  ipicker
                                      .pickImage(source: ImageSource.gallery)
                                      .then((file) async => {
                                            if (file != null)
                                              {
                                                imgb64 =
                                                    await file.readAsBytes(),
                                                imgI = image.decodeImage(imgb64)
                                                    as image.Image,
                                                uList = image.encodePng(imgI),
                                                node.originalImage = imgI,
                                                imgI = image.copyResize(
                                                  imgI,
                                                  width:
                                                      2 * node.radius.toInt(),
                                                  height:
                                                      2 * node.radius.toInt(),
                                                ),
                                                uList = image.encodePng(imgI),
                                                ui.decodeImageFromList(uList,
                                                    (result) {
                                                  node.picture = result;
                                                }),
                                                print("Path${file.path}")
                                              }
                                          }),
                                },
                            child: const Icon(Icons.camera_alt))),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("submit"))
                    ],
                  );
                })
            .then((value) =>
                setState(() => _conectText = "image changed on ${node.name}"));

        break;
      }
    }
  }

  void dfs() async {
    String rootName = "";
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text("Root for dfs"),
            content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    child: Column(
                  children: [
                    TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Root Name'),
                        onChanged: (val) {
                          rootName = val;
                        })
                  ],
                ))),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("submit"))
            ],
          );
        });

    DataNode root = nodes.firstWhere((element) => element.name == rootName);
    Queue<int> stack = Queue();
    List<int> parents = List.filled(nodes.length, -1);
    List<int> visited = <int>[];
    bool visitedAll = false;
    while (!visitedAll) {
      stack.add(root.index);

      while (stack.isNotEmpty) {
        DataNode popOut =
            nodes[nodes.indexWhere((element) => element.index == stack.last)];
        if (!visited.contains(popOut.index)) {
          visited.add(popOut.index);
        }
        stack.removeLast();

        for (var neighbour in popOut.neighbours) {
          if (!visited.contains(neighbour)) {
            stack.add(neighbour);
            parents[nodes.indexWhere((element) => element.index == neighbour)] =
                popOut.index;
          }
        }
      }
      bool unvisitedFound = false;
      for (var node in nodes) {
        if (!visited.contains(node.index)) {
          root = node;
          unvisitedFound = true;
          break;
        }
      }
      if (!unvisitedFound) {
        visitedAll = true;
      }
    }
    _conectedComponentsText = "";
    for (var index in visited) {
      _conectedComponentsText +=
          nodes.firstWhere((element) => element.index == index).name;
      if (index != visited.last) {
        _conectedComponentsText += "->";
      }
    }
  }

  void bfs() async {
    String rootName = "";
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text("Root for bfs"),
            content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    child: Column(
                  children: [
                    TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Root Name'),
                        onChanged: (val) {
                          rootName = val;
                        })
                  ],
                ))),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("submit"))
            ],
          );
        });
    print("Root:$rootName");
    DataNode root = nodes.firstWhere((element) => element.name == rootName);
    Queue<int> queue = Queue();
    List<int> visited = <int>[];
    List<int> parents = List.filled(nodes.length, -1);
    bool visitedAll = false;
    while (!visitedAll) {
      print("in bucla");
      queue.add(root.index);
      while (queue.isNotEmpty) {
        DataNode popOut =
            nodes[nodes.indexWhere((element) => element.index == queue.first)];
        if (!visited.contains(popOut.index)) {
          visited.add(popOut.index);
        }
        queue.removeFirst();

        for (var neighbour in popOut.neighbours) {
          if (!visited.contains(neighbour)) {
            queue.add(neighbour);
            parents[nodes.indexWhere((element) => element.index == neighbour)] =
                popOut.index;
          }
        }
      }
      bool unvisitedFound = false;
      for (var node in nodes) {
        if (!visited.contains(node.index)) {
          root = node;
          unvisitedFound = true;
          break;
        }
      }
      if (!unvisitedFound) {
        visitedAll = true;
      }
    }
    _conectedComponentsText = "";
    for (var index in visited) {
      _conectedComponentsText +=
          nodes.firstWhere((element) => element.index == index).name;
      if (index != visited.last) {
        _conectedComponentsText += "->";
      }
    }
  }

  void upload() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    print("uploading");

    if (result != null) {
      print("found something in upload");

      PlatformFile file = result.files.first;
      if (file.path != null) {
        print("that something has path ${file.path}");
        File myfile = File(file.path as String);

        var data = jsonDecode(await myfile.readAsString());
        var nodesJ = data["nodes"];
        print(nodesJ);
        nodes = [];
        int maxI = -1;
        for (var nodeJ in nodesJ) {
          Offset off = Offset(nodeJ["x"], nodeJ["y"]);

          double radius = nodeJ["radius"];

          Color colorp = Color.fromRGBO(
              nodeJ["color"][0], nodeJ["color"][1], nodeJ["color"][2], 1);
          DataNode node = DataNode(off, colorp);
          node.index = nodeJ["index"];
          maxI = max(maxI, node.index);
          node.radius = radius;

          if (nodeJ["name"] != null) node.name = nodeJ["name"];
          node.neighbours = <int>[];
          for (var ng in nodeJ["neighbours"]) {
            node.neighbours.add(ng);
          }

          if (nodeJ["image"] != null) {
            if (base64Decode(nodeJ["image"]).isNotEmpty) {
              print("image was decoded succesfully from base64");
              print(base64Decode(nodeJ["image"]));
            }

            node.originalImage =
                image.decodeImage(base64.decode(nodeJ["image"]));

            if (node.originalImage != null) {
              print("there is an original image");

              image.Image img = image.copyResize(
                  node.originalImage as image.Image,
                  width: 2 * node.radius.toInt(),
                  height: 2 * node.radius.toInt());

              Uint8List uList = image.encodePng(img);
              ui.decodeImageFromList(uList, (result) {
                node.picture = result;
                nodes.add(node);
                redraw.value++;
              });
            } else {
              nodes.add(node);
              redraw.value++;
            }
          } else {
            nodes.add(node);
            redraw.value++;
          }
        }
        indexNodes = maxI;
        redraw.value++;
      }
    }
  }

  void download() async {
    String fileName = "";
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text("Save file name "),
            content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    child: Column(
                  children: [
                    TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Save on file Name'),
                        onChanged: (val) {
                          fileName = val;
                        })
                  ],
                ))),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("submit"))
            ],
          );
        });

    String bytes = "";

    bytes = "{\"nodes\":[";
    int j = 0;
    for (var node in nodes) {
      bytes += "{";
      bytes += "\"index\":${node.index},\n";
      bytes += "\"name\":\"${node.name}\",\n";
      bytes +=
          "\"color\":[${node.color.red},${node.color.green},${node.color.blue}],\n";
      bytes += "\"radius\":${node.radius},\n";
      bytes += "\"x\":${node.offset.dx},\n";
      bytes += "\"y\":${node.offset.dy},\n";
      bytes += "\"neighbours\":[";
      int i = 0;
      for (var ng in node.neighbours) {
        bytes += "$ng";
        if (i < node.neighbours.length - 1) bytes += ",";
        i++;
      }
      bytes += "]";
      if (node.originalImage != null) {
        bytes += ",";
        bytes += "\"image\":\"";

        String encodedImage =
            base64.encode(image.encodeJpg(node.originalImage!));

        bytes += "$encodedImage\",\n";
        bytes += "\"imagex\":${node.originalImage!.width},";
        bytes += "\"imagey\":${node.originalImage!.height}";
      }
      bytes += "}\n";
      if (j < nodes.length - 1) bytes += ",";
      j++;
    }
    bytes += "]}";

    print("Json:$bytes");

    FileStorage.writeCounter(bytes, fileName);
  }

  Widget deleteEdge() {
    for (var node in nodes) {
      double r = node.radius;
      if ((for_menu.dx - node.offset.dx) * (for_menu.dx - node.offset.dx) +
              (for_menu.dy - node.offset.dy) * (for_menu.dy - node.offset.dy) <=
          r * r) {
        List<PopupMenuItem> items = <PopupMenuItem>[];

        for (var ng in node.neighbours) {
          DataNode ngnode = nodes.firstWhere((element) => element.index == ng);
          items
              .add(PopupMenuItem(value: ngnode.name, child: Text(ngnode.name)));
        }

        return PopupMenuButton(
          initialValue: "null",
          child: Text("Delete  edge"),
          itemBuilder: (context) => items,
          onSelected: (selected) {
            print("Selected for deleteing:$selected");
            DataNode foundNode =
                nodes.firstWhere((element) => element.name.contains(selected));
            print("Selected found deleteing:${foundNode.index}");
            //remove refrences of node from spcecified neighbour

            nodes[nodes.indexOf(foundNode)]
                .neighbours
                .removeWhere((element) => node.index == element);

            //remove refrences of specified neighbour from node
            nodes[nodes.indexOf(node)]
                .neighbours
                .removeWhere((element) => element == foundNode.index);

            redraw.value++;
          },
        );
      }
    }
    return Text("Not available");
  }

  void changeSize() {
    for (var node in nodes) {
      double r = node.radius;
      if ((for_menu.dx - node.offset.dx) * (for_menu.dx - node.offset.dx) +
              (for_menu.dy - node.offset.dy) * (for_menu.dy - node.offset.dy) <=
          r * r) {
        print("found node to rename");

        image.Image imgI;
        Uint8List uList;

        showDialog(
            context: context,
            builder: (BuildContext context) {
              String radValue = "";
              return AlertDialog(
                scrollable: true,
                title: const Text("Rename node"),
                content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        child: Column(
                      children: [
                        TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'New radius'),
                            onChanged: (value) => radValue = value)
                      ],
                    ))),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, radValue);
                      },
                      child: const Text("submit"))
                ],
              );
            }).then((value) => setState(() => {
              print("Value:" + value),
              node.radius = double.parse(value.toString()),
              imgI = image.copyResize(
                node.originalImage as image.Image,
                width: 2 * node.radius.toInt(),
                height: 2 * node.radius.toInt(),
              ),
              uList = image.encodePng(imgI),
              ui.decodeImageFromList(uList, (result) {
                node.picture = result;
                redraw.value++;
              }),
              _conectText = "Size changed"
            }));

        break;
      }
    }
  }

  void find_connected() {
    setState(() {
      List<int> notVisited = <int>[];
      Queue<int> stack = Queue();

      connected_components = <List<int>>[];
      // ignore:  unused_local_variable
      for (var node in nodes) {
        notVisited.add(1);
      }

      while (notVisited.indexWhere((element) => element == 1) >= 0) {
        connected_components.add(<int>[]);
        int IndexStart = notVisited.indexWhere((element) => element == 1);
        DataNode start = nodes[IndexStart];

        stack.add(start.index);

        while (stack.isNotEmpty) {
          DataNode node =
              nodes[nodes.indexWhere((element) => element.index == stack.last)];

          if (!connected_components.last.contains(node.index))
            connected_components.last.add(node.index);
          notVisited[
              nodes.indexWhere((element) => element.index == stack.last)] = 0;
          stack.removeLast();

          for (int ng in node.neighbours) {
            int indexInNotVisited =
                nodes.indexWhere((element) => element.index == ng);
            if (notVisited[indexInNotVisited] == 1) {
              stack.add(ng);
            }
          }
        }
      }
      _conectedComponentsText = "";
      int i = 0;
      for (var component in connected_components) {
        i++;
        Color savedColor = Colors.green;
        _conectedComponentsText += "Comp. ${i}:";
        if (component.length >= 1) {
          savedColor = nodes[nodes
                  .indexWhere((element2) => element2.index == component[0])]
              .color;
        }
        for (var element in component) {
          _conectedComponentsText +=
              "${nodes[nodes.indexWhere((element2) => element2.index == element)].name}";

          nodes[nodes.indexWhere((element2) => element2.index == element)]
              .color = savedColor;

          if (element != component.last) {
            _conectedComponentsText += "->";
          }
        }
        _conectedComponentsText += "\n";
      }
      redraw.value++;
    });
  }

  ImagePicker ipicker = ImagePicker();
  void _addNode() {
    setState(() {
      if (_add) {
        _addText = "Add new node";
      } else {
        _addText = "Stop adding";
      }

      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _add = !_add;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.primary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.

          title: Text(widget.title,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: _add ? Colors.red : Colors.green,
                    onPrimary: Colors.white),
                onPressed: () {
                  _addNode();
                },
                child: Text(_addText))
          ],
          leading: PopupMenuButton(
              child: const Icon(Icons.menu),
              itemBuilder: ((context) => [
                    const PopupMenuItem(
                        value: "fcc", child: Text("Find connected components")),
                    const PopupMenuItem(value: "dfs", child: Text("DFS")),
                    const PopupMenuItem(value: "bfs", child: Text("BFS")),
                    const PopupMenuItem(
                        value: "fsp", child: Text("Find shortest path")),
                    const PopupMenuItem(
                        value: "upload",
                        child: Row(children: [
                          Icon(Icons.upload),
                          Text("Uploade data with nodes info")
                        ])),
                    const PopupMenuItem(
                        value: "download",
                        child: Row(children: [
                          Icon(Icons.download_rounded),
                          Text("Download data with nodes info")
                        ]))
                  ]),
              onSelected: (selected) {
                switch (selected) {
                  case "fcc":
                    find_connected();
                    break;
                  case "dfs":
                    dfs();
                  case "bfs":
                    bfs();
                  case "fsp":
                    bfs();
                  case "upload":
                    upload();
                  case "download":
                    download();
                }
              })),

      body: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.  });
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    indextoMove = -1;
                    insideMove = false;
                    for (var node in nodes) {
                      double r = node.radius;
                      if ((details.localPosition.dx - node.offset.dx) *
                                  (details.localPosition.dx - node.offset.dx) +
                              (details.localPosition.dy - node.offset.dy) *
                                  (details.localPosition.dy - node.offset.dy) <=
                          r * r) {
                        indextoMove = node.index;
                        insideMove = true;
                        node.offset = details.localPosition;
                        _position =
                            "Pan x:${details.localPosition.dx}+ y:${details.localPosition.dy}";
                      }
                    }
                  });
                },
                onPanUpdate: (details) {
                  if (insideMove) {
                    int index = nodes
                        .indexWhere((element) => element.index == indextoMove);
                    nodes[index].offset += details.delta;
                  } else {
                    for (var node in nodes) {
                      node.offset -= details.delta;
                    }
                  }

                  redraw.value++;
                },
                onLongPressEnd: (details) async {
                  HapticFeedback.vibrate();
                  String? selected = await showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                          for_menu2.dx, for_menu2.dy, 0, 0),
                      items: [
                        PopupMenuItem(value: "rename", child: Text("Rename")),
                        PopupMenuItem(
                            value: "delete edge", child: deleteEdge()),
                        const PopupMenuItem(
                            value: "delete", child: Text("Delete node")),
                        const PopupMenuItem(
                            value: "picture",
                            child: Text("Add or change picture")),
                        const PopupMenuItem(
                            value: "facebook",
                            child: Text(
                                "Give facebook  username and get an image from your facebook")),
                        const PopupMenuItem(
                            value: "color", child: Text("Change color")),
                        const PopupMenuItem(
                            value: "radius", child: Text("Change size")),
                      ]);
                  if (selected != null) {
                    if (selected.contains("facebook")) {
                      facebook();
                    }

                    if (selected == 'delete') {
                      delete();
                    }
                    if (selected.contains("rename")) {
                      rename();
                    }
                    if (selected.contains("color")) {
                      changeColor();
                    }
                    if (selected.contains("picture")) {
                      print("enterd in image picker");
                      changePicture();
                    }

                    if (selected.contains("radius")) {
                      print("enterd in resize");
                      changeSize();
                    }
                  }
                },
                onDoubleTapDown: (details) {
                  print("double tab percived");
                  if (_connect) {
                    print("end connection");
                  } else {
                    print("start connection");
                  }

                  var breakS = 0;
                  setState(() {
                    if (!_connect) {
                      saved_position = details.localPosition;
                      _conectText = "Connecting";
                    } else {
                      var newPosition = details.localPosition;

                      for (var node in nodes) {
                        double r = node.radius;
                        if ((saved_position.dx - node.offset.dx) *
                                    (saved_position.dx - node.offset.dx) +
                                (saved_position.dy - node.offset.dy) *
                                    (saved_position.dy - node.offset.dy) <
                            r * r) {
                          for (var node2 in nodes) {
                            r = node2.radius;
                            if ((newPosition.dx - node2.offset.dx) *
                                        (newPosition.dx - node2.offset.dx) +
                                    (newPosition.dy - node2.offset.dy) *
                                        (newPosition.dy - node2.offset.dy) <
                                r * r) {
                              if (node != node2 &&
                                  !node.neighbours.contains(node2.index) &&
                                  !node.neighbours.contains(node2.index)) {
                                node.neighbours.add(node2.index);
                                node2.neighbours.add(node.index);
                                _painter = GraphPainter(-1, -1, redraw);
                                breakS = 1;
                                break;
                              }
                            }
                          }
                        }

                        if (breakS == 1) break;
                      }
                      _conectText = "";
                    }

                    _connect = !_connect;
                  });
                },
                onTapDown: (details) {
                  setState(() {
                    if (_add) {
                      _painter = GraphPainter(details.localPosition.dx,
                          details.localPosition.dy, redraw);
                      _position =
                          "x:${details.localPosition.dx}+ y:${details.localPosition.dy}";

                      // _color = _color == Colors.blue ? Colors.red : Colors.blue;
                    } else {
                      for_menu = details.localPosition;
                      for_menu2 = details.globalPosition;
                    }
                  });
                },
                child: Container(
                    color: _color,
                    height: min(500.0, MediaQuery.of(context).size.height),
                    width: MediaQuery.of(context).size.width,
                    child: CustomPaint(painter: _painter))),
            Text(_position,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            Text(_conectText, style: TextStyle(color: Colors.lightGreen)),
            Text(_conectedComponentsText,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),

            // This trailing comma makes auto-formatting nicer for build methods.
          ],
        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
