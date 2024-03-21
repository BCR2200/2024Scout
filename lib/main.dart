import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

const DELIMITER = "\t";
int clampc(int t, int max) => (t > max) ? max : t;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2200 Scouting (Flutter)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Statistics'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

abstract class JStat {
  void reset();
  String? get();
  Widget? widget(BuildContext context);
  void setUpdate(void Function(void Function()) fn) {}
  void update() {}
}
class StringInput extends JStat {
  TextEditingController txt = TextEditingController();
  String name;
  StringInput(this.name);

  late void Function(void Function()) refresh;
  @override
  void setUpdate(void Function(void Function()) fn) {
    refresh = fn;
  }

  @override
  void reset() {
    txt.text = "";
  }

  @override
  void update() {}

  @override
  String? get() => txt.text;

  @override
  Widget widget(BuildContext context) {
    Widget field =
    TextField(
      controller: txt,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      
      children: [
        Expanded(
          flex: 1,
          child: Text(
            name,
            textAlign: TextAlign.center
          ),
        ),
        
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(child: field),
            ],
          ),
        ),
      ],
    );
  }
}
class Numeric extends JStat {
  BigInt? num;
  BigInt? max;
  bool enforce = true;
  // If true, this will increment on reset instead of clearing.
  bool isMatchNumber;
  TextEditingController txt = TextEditingController();

  String name;
  Numeric(this.name, {this.max, this.isMatchNumber = false});

  late void Function(void Function()) refresh;
  @override
  void setUpdate(void Function(void Function()) fn) {
    refresh = fn;
  }

  @override
  void reset() {
    if (isMatchNumber) {
      num = (num ?? BigInt.zero) + BigInt.one;
      txt.text = num?.toString() ?? "";
    } else {
      num = null;
      txt.text = "";
    }
  }

  @override
  void update() {
    txt.text = num?.toString() ?? "";
  }

  @override
  String? get() => num?.toString() ?? "0";

  @override
  Widget widget(BuildContext context) {
    Widget field =
    TextField(
      onChanged: (value) {
          var val = BigInt.tryParse(value);
          if (val != null && max != null && val > max!) {
            num = max;
          } else {
            num = val;
          }
        print(num);
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: txt,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      
      children: [
        Expanded(
          flex: 1,
          child: Text(
            name,
            textAlign: TextAlign.center
          ),
        ),
        
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(child: TextButton(
                onPressed: () {
                  if (num == null) {
                    num = BigInt.zero;
                  } else if (num! >= BigInt.one) {
                    num = num! - BigInt.one;
                  }
                  txt.text = num?.toString() ?? "";
                },
                child: Text("-", style: Theme.of(context).textTheme.headlineLarge),
              ),),
              Expanded(child: field),
              Expanded(child: TextButton(
                onPressed: () {
                  if (num == null) {
                    num = BigInt.one;
                  } else if (max == null || num! < max!) {
                    num = num! + BigInt.one;
                  }
                  txt.text = num?.toString() ?? "";
                },
                child: Text("+", style: Theme.of(context).textTheme.headlineLarge,),
              ),),
            ],
          ),
        ),
      ],
    );
  }
}
class Boolean extends JStat {
  bool enabled = false;

  String name;
  Boolean(this.name);

  late void Function(void Function()) refresh;
  @override void setUpdate(void Function(void Function()) fn) {
    refresh = fn;
  }

  @override void reset() {
    enabled = false;
  }

  @override
  String? get() => enabled ? "1" : "0";

  @override
  Widget widget(BuildContext context) {
    var cb = Checkbox(
      value: enabled,
      onChanged: (value) {
        refresh(() {enabled = (value ?? false);});
      },
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      
      children: [
        Expanded(
          child: Text(
            name,
            textAlign: TextAlign.center
          ),
        ),
        
        Expanded(child: cb,),
      ],
    );
  }
}
class Team extends JStat {
  String? team = "Red";

  String name;
  Team(this.name);

  late void Function(void Function()) refresh;
  void Function(bool)? onChange;

  @override
  void setUpdate(void Function(void Function()) fn) {
    refresh = fn;
  }

  @override
  void reset() {
    //team = "Red";
  }

  @override
  String? get() => team;

  @override
  Widget widget(BuildContext context) {
    var radio = <Widget>[
      Row(
        children: [
          const Expanded(child: Text("Red"),),
          Expanded(child: Radio<String>(
            value: "Red",
            groupValue: team,
            onChanged: (value) {
              var change = onChange;
              if (change != null) change(true);
              refresh(() { team = value; });
            },
          ),),
        ],
      ),
      Row(
        children: [
          const Expanded(child: Text("Blue"),),
          Expanded(child: Radio<String>(
            value: "Blue",
            groupValue: team,
            onChanged: (value) {
              var change = onChange;
              if (change != null) change(false);
              refresh(() { team = value; });
            },
          ),),
        ],
      ),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      
      children: [
        Expanded(
          child: Text(
            name,
            textAlign: TextAlign.center
          ),
        ),
        
        Expanded(child: Column(children: radio,),),
      ],
    );
  }
}
class MultipleFlag extends JStat {
  String name;
  List<String> variants;
  int? ticked = 0;
  bool group = false;
  MultipleFlag(this.name, this.variants);

  late void Function(void Function()) refresh;
  @override
  void setUpdate(void Function(void Function()) fn) {
    refresh = fn;
  }

  @override
  void reset() {
    ticked = 0;
  }

  @override
  String? get() {
    if (variants.isNotEmpty) {
      var out = [];
      for (var i = 0; i < (ticked ?? 0); i++) {
        out.add("0");
      }
      out.add("1");
      for (var i = 0; i < variants.length - (ticked ?? 0) - 1; i++) {
        out.add("0");
      }
      return out.join(DELIMITER);
    } else {
      return "";
    }
  }

  @override
  Widget widget(BuildContext context) {
    var radio = <Widget>[];
    for (var i = 0; i < variants.length; i++) {
      radio.add(
        Row(
          children: [
            Expanded(child: Text(variants[i]),),
            Expanded(child: Radio<int?>(
              value: i,
              groupValue: ticked,
              onChanged: (value) {
                refresh(() { ticked = value; });
              },
            ),),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      
      children: [
        Expanded(
          child: Text(
            name,
            textAlign: TextAlign.center
          ),
        ),
        
        Expanded(child: Column(children: radio,),),
      ],
    );
  }
}
class MultipleCount extends JStat {
  String name;
  List<String> variants;
  int? ticked = 0;
  bool group = false;
  MultipleCount(this.name, this.variants);

  late void Function(void Function()) refresh;
  @override
  void setUpdate(void Function(void Function()) fn) {
    refresh = fn;
  }

  @override
  void reset() {
    ticked = 0;
  }

  @override
  String? get() => (ticked ?? 0 + 1).toString();

  @override
  Widget widget(BuildContext context) {
    var radio = <Widget>[];
    for (var i = 0; i < variants.length; i++) {
      radio.add(
        Row(
          children: [
            Expanded(child: Text(variants[i]),),
            Expanded(child: Radio<int?>(
              value: i,
              groupValue: ticked,
              onChanged: (value) {
                refresh(() { ticked = value; });
              },
            ),),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      
      children: [
        Expanded(
          child: Text(
            name,
            textAlign: TextAlign.center
          ),
        ),
        
        Expanded(child: Column(children: radio,),),
      ],
    );
  }
}

class ColorBox extends JStat {
  List<JStat> stats;
  Color color;
  double padding;
  double borderRadius;
  ColorBox(this.stats, this.color, {this.borderRadius = 10.0, this.padding = 5.0});
  @override
  String? get() {
    return stats.map((e) => e.get())
      .where((element) => element != null)
      .join(DELIMITER);
  }

  @override
  void reset() {
    for (var stat in stats) {
      stat.reset();
    }
  }

  @override
  void setUpdate(void Function(void Function()) fn) {
    for (var stat in stats) {
      stat.setUpdate(fn);
    }
  }

  @override
  void update() {
    for (var stat in stats) {
      stat.update();
    }
  }

  @override
  Widget widget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius)
        ),
        margin: EdgeInsets.all(padding),
        child: Column(
          children: stats
            .map((s) => s.widget(context))
            .where((element) => element != null)
            .map((e) => e!)
            .toList(),
        ),
      ),
    );
  }
}
class Heading extends JStat {
  String text;
  Heading(this.text);

  @override
  String? get() => null;

  @override
  void reset() {}

  @override
  Widget widget(BuildContext context) => Center(child: Text(text, textScaleFactor: 2.0));
}
class Calculated extends JStat {
  String? Function() calcFn;
  Calculated(this.calcFn);
  @override
  String? get() => calcFn();
  @override
  void reset() {}
  @override
  Widget? widget(BuildContext context) => null;
}

class Notemap extends JStat {
  List<bool> enableds = [];
  int count;
  int start;
  var checkboxes = <Widget>[];
  bool flip = true;

  String name;
  Notemap(this.name, this.count, this.start);

  late void Function(void Function()) refresh;
  @override
  void setUpdate(void Function(void Function()) fn) {
    refresh = fn;
  }

  void setFlip(bool flip) {
    if (this.flip ^ flip) {
      for (var i = 0; i < checkboxes.length; i++) {
        var temp = checkboxes[i];
        int endIndex = checkboxes.length - i - 1;
        checkboxes[i] = checkboxes[endIndex];
        checkboxes[endIndex] = temp;
      }
    }
    this.flip = flip;
  }

  @override
  void reset() {
    for (var i = 0; i < count; i++) {
      enableds[i] = false;
    }
  }

  @override
  String? get() => enableds
    .map((e) => e ? "1" : "0")
    .join(DELIMITER);

  @override
  Widget widget(BuildContext context) {
    while (enableds.length < count) {
      enableds.add(false);
    }
    checkboxes = <Widget>[];
    for (var i = 0; i < count; i++) {
      var cb = Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0)
          ),
          margin: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Checkbox(
                value: enableds[i],
                onChanged: (value) {
                  refresh(() {enableds[i] = (value ?? false);});
                },
              ),
              Text((i + start).toString()),
            ],
          ),
        ),
      );
      checkboxes.add(cb);
    }
    if (flip) checkboxes = checkboxes.reversed.toList();

    return Column(children: [
      Text(name),
        Row(
        mainAxisSize: MainAxisSize.min,
        children: checkboxes
      ),
    ],);
  }
}

class QRView extends StatelessWidget {
  final String data;
  final String teamNumber;
  const QRView(this.data, this.teamNumber, {super.key});

  @override
  Widget build(BuildContext context) {
    print(data);
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code")),
      body: Column(
        children: [
          Text(
            teamNumber,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(data),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Center(
                child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  gapless: true
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomUpGrid extends JStat {
  List<JStat> stats;
  int verticalCount;
  BottomUpGrid(this.stats, this.verticalCount);

  @override
  String? get() {
    return stats
      .map((e) => e.get())
      .where((element) => element != null)
      .join(DELIMITER);
  }

  @override
  void reset() {
    for (var stat in stats) {
      stat.reset();
    }
  }

  @override
  void setUpdate(void Function(void Function()) fn) {
    for (var stat in stats) {
      stat.setUpdate(fn);
    }
  }

  @override
  void update() {
    for (var stat in stats) {
      stat.update();
    }
  }

  @override
  Widget widget(BuildContext context) {
    var chunks = [];
    for (var i = 0; i < stats.length; i += verticalCount) {
      chunks.add(stats.sublist(i, clampc(i + verticalCount, stats.length)));
    }
    List<Widget> columns = [];
    for (List<JStat> statColumn in chunks) {
      List<Widget> columnWidgets = [];
      for (var jstat in statColumn) {
        var widget = jstat.widget(context);
        if (widget != null) {
          columnWidgets.insert(0, widget);
        }
      }
      columns.add(Expanded(child: Column(children: columnWidgets)));
    }
    return Row(children: columns,);
  }
}

class Hidden extends JStat {
  JStat stat;
  Hidden(this.stat);
  @override
  String? get() {
    return stat.get();
  }

  @override
  void reset() {
    stat.reset();
  }

  @override
  void setUpdate(void Function(void Function()) fn) {
    stat.setUpdate(fn);
  }

  @override
  void update() {
    stat.update();
  }

  @override Widget? widget(BuildContext context) => null;
}
class OnlyShow extends JStat {
  JStat stat;
  OnlyShow(this.stat);
  @override
  String? get() => null;

  @override
  void reset() {
    stat.reset();
  }

  @override
  void setUpdate(void Function(void Function()) fn) {
    stat.setUpdate(fn);
  }

  @override
  void update() {
    stat.update();
  }

  @override Widget? widget(BuildContext context) => stat.widget(context);
}

const COLORBOX_OPACITY = 0.25;
class _MyHomePageState extends State<MyHomePage> {
  late Numeric teamNum;
  late List<JStat> statistics;
  bool initialized = false;

  void update(void Function() fn) {
    setState(fn);
    for (var stat in statistics) {
      stat.update();
    }
  }

  void loadChargedUp() {
    var teleopPieces = <JStat>[
      ColorBox([Numeric("L1 Cone")], Colors.yellow.withAlpha(48)),
      ColorBox([Numeric("L2 Cone")], Colors.yellow.withAlpha(88)),
      ColorBox([Numeric("L3 Cone")], Colors.yellow.withAlpha(128)),
      ColorBox([Numeric("L1 Cube")], Colors.purple.withAlpha(48)),
      ColorBox([Numeric("L2 Cube")], Colors.purple.withAlpha(88)),
      ColorBox([Numeric("L3 Cube")], Colors.purple.withAlpha(128)),
    ];
    statistics = <JStat>[
      ColorBox(
        [
          Heading("Metastats"),
          Numeric("Team Number", max: BigInt.from(9999)),
          Numeric("Match Number", isMatchNumber: true),
        ],
        Colors.yellow.withAlpha(64)
      ),
      ColorBox(
        [
          Heading("Auto"),
          Boolean("Mobility"),
          BottomUpGrid([
            ColorBox([Numeric("L1 Cone")], Colors.yellow.withAlpha(48)),
            ColorBox([Numeric("L2 Cone")], Colors.yellow.withAlpha(88)),
            ColorBox([Numeric("L3 Cone")], Colors.yellow.withAlpha(128)),
            ColorBox([Numeric("L1 Cube")], Colors.purple.withAlpha(48)),
            ColorBox([Numeric("L2 Cube")], Colors.purple.withAlpha(88)),
            ColorBox([Numeric("L3 Cube")], Colors.purple.withAlpha(128)),
          ], 3),
          MultipleFlag("Auto End", [
            "Dock",
            "Dock & Engage",
          ]),
        ],
        Colors.red.withAlpha(64)
      ),
      ColorBox(
        [
          Heading("Teleop"),
          BottomUpGrid(teleopPieces, 3),
          MultipleFlag("Teleop End", [
            "Park",
            "Dock",
            "Dock & Engage",
          ]),
        ],
        Colors.green.withAlpha(64)
      ),
      ColorBox(
        [
          Heading("Overall"),
          Boolean("Defence Played"),
          Numeric("Driver Skill"),
          Numeric("Fouls"),
          Numeric("Tech Fouls"),

          MultipleCount("Loading Station Choice", [
            "Single (Ramp)",
            "Double (Platforms)",
          ]),
        ],
        Colors.blue.withAlpha(64),
      ),
    ];
  }

  void loadCrescendo() {
    // Bindings for NoCalc/Hidden variables.
    var middleNotes = Notemap("Middle Note Pickups", 5, 4);
    var teamsideNotes = Notemap("Teamside Note Pickups", 3, 1);
    var team = Team("Team");

    team.onChange = (isRed) {
      setState(() {
        middleNotes.setFlip(isRed);
        teamsideNotes.setFlip(isRed);
      });
    };

    var teleopSpeaker = Numeric("Speaker Scores");
    var teleopAmp = Numeric("Amp Scores");
    var teleopAmpSpeaker = Numeric("Amplified Speaker Scores");

    var autoSpeaker = Numeric("Speaker Scores");
    var autoAmp = Numeric("Amp Scores");

    var mobility = Boolean("Mobility");

    var park = Boolean("Park");
    var climb = Boolean("Climb");
    var trap = Numeric("Trap Scores");

    teamNum = Numeric("Team Number");
    statistics = <JStat>[
      ColorBox(
        [
          Heading("Metadata"),
          teamNum,
          Numeric("Match Number", isMatchNumber: true),
          OnlyShow(team),
        ],
        Colors.yellow.withOpacity(COLORBOX_OPACITY),
      ),

      ColorBox(
        [
          Heading("Autonomous"),
          mobility,
          autoSpeaker,
          autoAmp,
          OnlyShow(middleNotes),
          OnlyShow(teamsideNotes),
        ],
        Colors.red.withOpacity(COLORBOX_OPACITY),
      ),

      ColorBox(
        [
          Heading("Teleop"),
          teleopSpeaker,
          teleopAmp,
          ColorBox(
            [teleopAmpSpeaker,],
            const Color(0xffddeeff)
          ),
        ],
        Colors.green.withOpacity(COLORBOX_OPACITY),
      ),

      ColorBox(
        [
          Heading("Endgame"),
          park,
          climb,
          trap,
        ],
        Colors.blue.withOpacity(COLORBOX_OPACITY),
      ),

      ColorBox(
        [
          Heading("Match"),
          Boolean("Defense Played"),
          Numeric("Driver Skill", max: BigInt.from(10)),
          Numeric("Fouls"),
          Numeric("Tech Fouls"),
          Boolean("Died"),
          StringInput("Notes"),
        ],
        Colors.purple.withOpacity(COLORBOX_OPACITY),
      ),
      // Teleop cycles
      Calculated(() => (
        (teleopSpeaker.num ?? BigInt.zero) +
        (teleopAmp.num ?? BigInt.zero) +
        (teleopAmpSpeaker.num ?? BigInt.zero)
      ).toString()),
      // Total points
      Calculated(() => (
        (mobility.enabled ? BigInt.two : BigInt.zero) +
        (autoSpeaker.num ?? BigInt.zero) * BigInt.from(5) +
        (autoAmp.num ?? BigInt.zero) * BigInt.two +

        (teleopSpeaker.num ?? BigInt.zero) * BigInt.two +
        (teleopAmp.num ?? BigInt.zero) +
        (teleopAmpSpeaker.num ?? BigInt.zero) * BigInt.from(5) +

        (climb.enabled ? BigInt.from(3) : BigInt.zero) +
        (trap.num ?? BigInt.zero) * BigInt.from(5) +
        (park.enabled ? BigInt.one : BigInt.zero)
      ).toString()),
      Hidden(team),
      Hidden(teamsideNotes),
      Hidden(middleNotes),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      loadCrescendo();
      initialized = true;
    }
    List<Widget> stats = <Widget>[];
    //loadChargedUp();
    for (var stat in statistics) {
      stat.setUpdate(update);
      var widget = stat.widget(context);
      if (widget != null) {
        stats.add(widget);
      }
    }
    stats.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.green),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => QRView(
                  statistics
                    .map((e) => e.get())
                    .where((element) => element != null)
                    .join(DELIMITER),
                  teamNum.get() ?? "!No team number!"
                ),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 30.0, bottom: 30.0,),
            child: Text("View QR", textScaleFactor: 2.0, style: TextStyle(color: Colors.white,),),
          ),
        ),
      ),
    );
    var destroyEverything = TextButton(onPressed: () {
      setState(() {});
      for (var stat in statistics) {
        stat.reset();
      }
      Navigator.of(context, rootNavigator: true).pop();
    }, child: const Text("Confirm", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,),),);
    var dontDestroyEverything = TextButton(onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    }, child: const Text("Cancel"));
    var resetAlert = AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text(
        "This will reset all statistics to their default state and increment the match number."
        "Do you want to continue?"
      ),
      actions: [
        destroyEverything,
        dontDestroyEverything,
      ],
    );
    stats.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
          onPressed: () {
            showDialog(context: context, builder: (ctx) => resetAlert);
          },
          child: const Text("Next Match", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: stats,
      )
    );
  }
}
