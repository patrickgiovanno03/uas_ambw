import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:popover/popover.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List notes = [];
final hiveNote = Hive.box('hiveNote');
final hivePassword = Hive.box('hivePassword');
int password = hivePassword.get('password') ?? 0;
bool logged = false;
String passwordInput1 = "";
String passwordInput2 = "";
int indexNote = 0;
int _selectedIndex = 0;

class _HomePageState extends State<HomePage> {
  Future<void> pindahKeForm(BuildContext context, {note = 0, isNew = 0}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailScreen(note: note, isNew: isNew)),
    );
    readData();
  }

  String data = "";

  void getData() {
    notes.clear();
    hiveNote.keys.forEach((element) {
      notes.add(hiveNote.get(element));
    });
    indexNote = notes.length;
  }

  void readData() {
    setState(() {
      notes.clear();
      hiveNote.keys.forEach((element) {
        notes.add(hiveNote.get(element));
      });
    });
  }

  void deleteData(indexDelete) {
    for (int i = indexDelete; i < notes.length - 1; i++) {
      hiveNote.put(i, notes[i + 1]);
    }
    hiveNote.delete(notes.length - 1);
    readData();
  }

  void deleteAllData() {
    hiveNote.clear();
    readData();
  }

  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    getData();
    if (password == 0) {
      // kalau belum ada password
      return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title:
                Text('Set PIN', style: TextStyle(fontWeight: FontWeight.bold)),
            // backgroundColor: const Color(0xff37e0d9),
            // foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  left: (MediaQuery.of(context).size.width < 750)
                      ? 16
                      : (MediaQuery.of(context).size.width < 1300)
                          ? 200
                          : 500,
                  right: (MediaQuery.of(context).size.width < 750)
                      ? 16
                      : (MediaQuery.of(context).size.width < 1300)
                          ? 200
                          : 500,
                  top: (MediaQuery.of(context).size.height < 800) ? 100 : 200,
                  bottom: 16),
              child: Column(
                children: [
                  Text('Type PIN', style: TextStyle(fontSize: 30)),
                  Padding(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 50, left: 10, right: 10),
                      child: PinCodeTextField(
                        keyboardType: TextInputType.number,
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 6,
                        obscureText: true,
                        obscuringCharacter: '*',
                        obscuringWidget:
                            Text("*", style: TextStyle(fontSize: 40)),
                        blinkWhenObscuring: true,
                        animationType: AnimationType.fade,
                        validator: (v) {
                          passwordInput1 = v!;
                        },
                      )),
                  Text('Re-type PIN', style: TextStyle(fontSize: 30)),
                  Padding(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 50, left: 10, right: 10),
                      child: PinCodeTextField(
                        keyboardType: TextInputType.number,
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 6,
                        obscureText: true,
                        obscuringCharacter: '*',
                        obscuringWidget:
                            Text("*", style: TextStyle(fontSize: 40)),
                        blinkWhenObscuring: true,
                        animationType: AnimationType.fade,
                        validator: (v) {
                          passwordInput2 = v!;
                          if (passwordInput1 != passwordInput2) {
                            return "PIN tidak sama";
                          } else {}
                        },
                      )),
                  SizedBox(
                    width: 200, // <-- Your width
                    height: 80, // <-- Your height
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.amber),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: () {
                        if (passwordInput1 == passwordInput2) {
                          hivePassword.put(
                              'password', int.parse(passwordInput1.toString()));
                          setState(() {
                            password = int.parse(passwordInput1.toString());
                            logged = true;
                          });
                        }
                      },
                      child: const Text('Save',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ));
    } else {
      // kalau sudah ada password
      if (logged) {
        // kalau sudah login
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            // index = 0 artinya page notes, index = 1 artinya page change pin
            title: Text((_selectedIndex == 0 ? 'Notes' : 'Change PIN'),
                style: TextStyle(fontWeight: FontWeight.bold)),
            // backgroundColor: const Color(0xff37e0d9),
            // foregroundColor: Colors.white,
            backgroundColor: Colors.yellow[600],
            actions: [
              if (_selectedIndex == 0)
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: IconButton(
                    icon: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.delete),
                        Text("All"),
                      ],
                    ),
                    onPressed: () {
                      deleteAllData();
                    },
                  ),
                )
            ],
          ),
          body: Container(
              child: (_selectedIndex == 0)
                  ? ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notes[index]['title'],
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 40, 40, 40),
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      notes[index]['content'].length > 35
                                          ? '${notes[index]['content'].replaceAll('\n', '...').substring(0, 35)}...'
                                          : notes[index]['content']
                                              .replaceAll('\n', '...'),
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 40, 40, 40))),
                                ],
                              ),
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                    icon: Button(
                                        created: notes[index]['created'] != null
                                            ? notes[index]['created'].toString()
                                            : "-",
                                        updated: notes[index]['updated'] != null
                                            ? notes[index]['updated'].toString()
                                            : "-"),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      deleteData(index);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                pindahKeForm(context, note: index);
                              },
                            ),
                            Divider(),
                          ],
                        );
                      },
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: (MediaQuery.of(context).size.width < 750)
                                ? 16
                                : (MediaQuery.of(context).size.width < 1300)
                                    ? 200
                                    : 500,
                            right: (MediaQuery.of(context).size.width < 750)
                                ? 16
                                : (MediaQuery.of(context).size.width < 1300)
                                    ? 200
                                    : 500,
                            top: (MediaQuery.of(context).size.height < 800)
                                ? 50
                                : 100,
                            bottom: 16),
                        child: Column(
                          children: [
                            Text('Type PIN', style: TextStyle(fontSize: 30)),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 50, left: 10, right: 10),
                                child: PinCodeTextField(
                                  keyboardType: TextInputType.number,
                                  appContext: context,
                                  pastedTextStyle: TextStyle(
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  length: 6,
                                  obscureText: true,
                                  obscuringCharacter: '*',
                                  obscuringWidget:
                                      Text("*", style: TextStyle(fontSize: 40)),
                                  blinkWhenObscuring: true,
                                  animationType: AnimationType.fade,
                                  validator: (v) {
                                    passwordInput1 = v!;
                                  },
                                )),
                            Text('Re-type PIN', style: TextStyle(fontSize: 30)),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 50, left: 10, right: 10),
                                child: PinCodeTextField(
                                  keyboardType: TextInputType.number,
                                  appContext: context,
                                  pastedTextStyle: TextStyle(
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  length: 6,
                                  obscureText: true,
                                  obscuringCharacter: '*',
                                  obscuringWidget:
                                      Text("*", style: TextStyle(fontSize: 40)),
                                  blinkWhenObscuring: true,
                                  animationType: AnimationType.fade,
                                  validator: (v) {
                                    passwordInput2 = v!;
                                    if (passwordInput1 != passwordInput2) {
                                      return "PIN tidak sama";
                                    } else {}
                                  },
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: SizedBox(
                                      width: 150, // <-- Your width
                                      height: 60, // <-- Your height
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (passwordInput1 ==
                                              passwordInput2) {
                                            hivePassword.put(
                                                'password',
                                                int.parse(
                                                    passwordInput1.toString()));
                                            setState(() {
                                              password = int.parse(
                                                  passwordInput1.toString());
                                              logged = true;
                                              _selectedIndex = 0;
                                            });
                                          }
                                        },
                                        child: const Text('Save',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.amber),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black),
                                        ),
                                      ),
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: SizedBox(
                                      width: 150, // <-- Your width
                                      height: 60, // <-- Your height
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedIndex = 0;
                                            passwordInput1 = "";
                                            logged = false;
                                          });
                                        },
                                        child: const Text('Logout',
                                            style: TextStyle(fontSize: 25)),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black87),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: SizedBox(
                                  width: 300, // <-- Your width
                                  height: 50, // <-- Your height
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedIndex = 0;
                                        logged = false;
                                        hivePassword.delete('password');
                                        password = 0;
                                      });
                                    },
                                    child: const Text('Delete PIN',
                                        style: TextStyle(fontSize: 20)),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    )),
          floatingActionButton: SizedBox(
            width: 80,
            height: 80,
            child: FloatingActionButton(
              onPressed: () {
                pindahKeForm(context, isNew: 1);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              // backgroundColor: const Color(0xff37e0d9),
              // foregroundColor: Colors.white,
              foregroundColor: Colors.black,
              backgroundColor: Colors.yellow[600],
              child: Icon(Icons.add, size: 40.0),
              elevation: 4.0,
            ),
          ),
          bottomNavigationBar: SizedBox(
            child: BottomAppBar(
              color: Colors.black87,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      iconSize: 40.0,
                      icon: Icon(Icons.sticky_note_2_rounded,
                          color: _selectedIndex == 0
                              ? Colors.yellow[600]
                              : Colors.yellow[100]),
                      onPressed: () {
                        onTabTapped(0);
                      },
                    ),
                  ),
                  Expanded(child: new Text('')),
                  Expanded(
                    child: IconButton(
                      iconSize: 40.0,
                      icon: Icon(Icons.account_box_rounded,
                          color: _selectedIndex == 1
                              ? Colors.yellow[600]
                              : Colors.yellow[100]),
                      onPressed: () {
                        onTabTapped(1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      } else {
        return Scaffold(
            appBar: AppBar(
              title:
                  Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
              // backgroundColor: const Color(0xff37e0d9),
              // foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: (MediaQuery.of(context).size.width < 750)
                        ? 16
                        : (MediaQuery.of(context).size.width < 1300)
                            ? 200
                            : 500,
                    right: (MediaQuery.of(context).size.width < 750)
                        ? 16
                        : (MediaQuery.of(context).size.width < 1300)
                            ? 200
                            : 500,
                    top: (MediaQuery.of(context).size.height < 800) ? 150 : 250,
                    bottom: 16),
                child: Column(
                  children: [
                    Text('Type PIN', style: TextStyle(fontSize: 30)),
                    Padding(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 30, left: 10, right: 10),
                        child: PinCodeTextField(
                          keyboardType: TextInputType.number,
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: true,
                          obscuringCharacter: '*',
                          // pinTheme: PinTheme,
                          obscuringWidget:
                              Text("*", style: TextStyle(fontSize: 40)),
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            passwordInput1 = v!;
                            if (v!.length == 6 && v! != password.toString()) {
                              return "PIN salah";
                            }
                          },
                        )),
                    SizedBox(
                      width: 200, // <-- Your width
                      height: 80, // <-- Your height
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (passwordInput1 == password.toString() && password != 0 && password != "") {
                              logged = true;
                            }
                          });
                        },
                        child: const Text('Login',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.amber),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
      }
    }
  }
}

class DetailScreen extends StatelessWidget {
  DetailScreen({super.key, this.note = 0, this.isNew = 0});

  final int note;
  final int isNew;

  var titleField = TextEditingController();
  var contentField = TextEditingController();

  void saveData() {
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    if (isNew == 0) {
      // kalau update
      var x = {
        'title': titleField.text,
        'content': contentField.text,
        'created': hiveNote.get(note)['created'],
        'updated': formatter.format(DateTime.now()).toString()
      };
      hiveNote.put(note, x);
    } else {
      // kalau create
      var x = {
        'title': titleField.text,
        'content': contentField.text,
        'created': formatter.format(DateTime.now()).toString(),
        'updated': formatter.format(DateTime.now()).toString()
      };
      hiveNote.put(indexNote, x);
      indexNote++;
    }
  }

  @override
  Widget build(BuildContext context) {
    titleField =
        TextEditingController(text: isNew == 0 ? notes[note]['title'] : '');
    contentField =
        TextEditingController(text: isNew == 0 ? notes[note]['content'] : '');
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: titleField,
          maxLines: 1,
          decoration:
              new InputDecoration.collapsed(hintText: 'Insert title here'),
        ),
        backgroundColor: Colors.yellow[600],
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(isNew == 0 ? Icons.save : Icons.add),
                  Text(isNew == 0 ? "Save" : "Add"),
                ],
              ),
              onPressed: () {
                saveData();
                Navigator.pop(context, 0);
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: contentField,
          keyboardType: TextInputType.multiline,
          minLines: 20,
          maxLines: null,
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'Insert note here'),
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({Key? key, this.created = "-", this.updated = "-"})
      : super(key: key);

  final String created;
  final String updated;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: const Icon(Icons.info, color: Colors.black45, size: 20),
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) =>
                ListItems(created: created, updated: updated),
            onPop: () => print('Popover was popped!'),
            direction: PopoverDirection.bottom,
            backgroundColor: Colors.white,
            width: 200,
            height: 195,
            arrowHeight: 15,
            arrowWidth: 30,
          );
        },
      ),
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({Key? key, this.created = "-", this.updated = "-"})
      : super(key: key);

  final String created;
  final String updated;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
              child: Text("About",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
            Divider(color: Colors.black12),
            Padding(
              padding:
                  EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Created at", style: TextStyle(color: Colors.black45)),
                  Text(created),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                  ),
                  Text("Last updated at",
                      style: TextStyle(color: Colors.black45)),
                  Text(updated),
                ],
              ),
            )
          ],
        ));
  }
}
