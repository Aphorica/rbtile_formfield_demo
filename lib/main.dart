import 'dart:async';
import 'package:flutter/material.dart';
import 'package:form_fields/form_fields.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'RadioTile in FormField Test',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new FormFieldDemo());
  }
}

// Declare some types for radio button selection.
//
enum Sex { male, female, none }
enum EyeColor { brown, hazel, green, blue, unknown }
enum Education { elementary, high_school, college, postgrad }

// This class contains the model
//
class PersonData {
  String name = '';
  Sex sex = Sex.none;
  EyeColor eyeColor = EyeColor.unknown;
  Education education = Education.elementary;

  void copyFrom(PersonData srcData) {
    name = srcData.name;
    sex = srcData.sex;
    eyeColor = srcData.eyeColor;
    education = srcData.education;
  }

  PersonData copy() {
    PersonData newPerson = new PersonData();
    newPerson.name = name;
    newPerson.sex = sex;
    newPerson.eyeColor = eyeColor;
    newPerson.education = education;

    return newPerson;
  }
}

class FormFieldDemo extends StatefulWidget {
  const FormFieldDemo({Key key}) : super(key: key);

  @override
  FormFieldDemoState createState() => new FormFieldDemoState();
}

class FormFieldDemoState extends State<FormFieldDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  ScrollController formScrollController = new ScrollController();


  static final PersonData defaultPerson = new PersonData();
  PersonData person;

  // Create the persister class
  //
  FormFieldStatePersister fieldStatePersister = new FormFieldStatePersister();

  TextEditingController nameEditController;

  bool _autovalidate = false;
  bool _formWasEdited = false;

  // constructor
  FormFieldDemoState() : person = defaultPerson.copy(),
      nameEditController = new TextEditingController()
  {
    // Add persisters in the constructor for our various formfields.  Note that
    // TextEditingController derive from ValueNotifier, so they can be mixed in.
    //
    fieldStatePersister.addPersister('Name', '', new TextEditingController(), _update);
    fieldStatePersister.addPersister('Sex', Sex.none, new ValueNotifier<Sex>(person.sex), _update);
    fieldStatePersister.addPersister('EyeColor', EyeColor.unknown,
                                     new ValueNotifier<EyeColor>(person.eyeColor), _update);
    fieldStatePersister.addPersister('Education', Education.elementary,
                                     new ValueNotifier<Education>(person.education), _update);
  }

 void _update() {
    setState((){});
  }

  // Instantiate the Formfields.  Note we provide persisters for each.
  //
  @override
  Widget build(BuildContext context) {
    EdgeInsets radioBtnPadding = new EdgeInsets.only(bottom: 10.0);

    TextFormField nameField = new TextFormField(
        controller: fieldStatePersister['Name'],
        decoration: const InputDecoration(
          icon: const Icon(Icons.person),
          hintText: 'First or first and last name',
          labelText: 'Name *',
        ),
        onSaved: (String value) {
          person.name = value;
        },
        validator: _validateName);

    Widget mfChoiceField = new RadioTileChoiceFormField<Sex>(
      persister: fieldStatePersister['Sex'],
      backgroundPadding: radioBtnPadding,
      label: 'Sex',
      onSaved: (Sex value) {
        person.sex = value;
      },
      validator: (Sex value) => value != Sex.none?
                                     null : 'Sex must be selected',
      choiceDescriptors: <ChoiceDescriptorItem>[
        new ChoiceDescriptorItem<Sex>(label: 'Male',
                                      value: Sex.male,
                                      align: CrossAxisAlignment.start),
        new ChoiceDescriptorItem<Sex>(label: 'Female',
                                      value: Sex.female,
                                      align: CrossAxisAlignment.end)
      ],
    );


    Widget eyeColorChoiceField = new RadioTileChoiceFormField<EyeColor>(
      persister: fieldStatePersister['EyeColor'],
      backgroundPadding: radioBtnPadding,
      label: 'Eye Color',
      onSaved: (EyeColor value) {
        person.eyeColor = value;
        },
      validator: (EyeColor value) => value != EyeColor.unknown?
                                     null : 'Eye Color must be selected',
      itemsPerRow: 2,
      choiceDescriptors: <ChoiceDescriptorItem>[
        new ChoiceDescriptorItem<EyeColor>(label: 'Brown',
                                           value: EyeColor.brown,
                                           align: CrossAxisAlignment.start),
        new ChoiceDescriptorItem<EyeColor>(label: 'Blue',
                                           value: EyeColor.blue,
                                           align: CrossAxisAlignment.end),
        new ChoiceDescriptorItem<EyeColor>(label: 'Hazel',
                                           value: EyeColor.hazel,
                                           align: CrossAxisAlignment.start),
        new ChoiceDescriptorItem<EyeColor>(label: 'Green',
                                           value: EyeColor.green,
                                           align: CrossAxisAlignment.end)
      ],
    );

    Widget educationChoiceField = new RadioTileChoiceFormField<Education>(
      persister: fieldStatePersister['Education'],
      backgroundPadding: radioBtnPadding,
      label: 'Education',
      onSaved: (Education value) {
        person.education = value;
      },
      layoutDir: ChoiceLayoutDir.column,
      choiceDescriptors: <ChoiceDescriptorItem>[
        new ChoiceDescriptorItem<Education>(label: 'Elementary',
                                            value: Education.elementary,
                                            align: CrossAxisAlignment.start),
        new ChoiceDescriptorItem<Education>(label: 'High School',
                                            value: Education.high_school,
                                            align: CrossAxisAlignment.start),
        new ChoiceDescriptorItem<Education>(label: 'College',
                                            value: Education.college,
                                            align: CrossAxisAlignment.start),
        new ChoiceDescriptorItem<Education>(label: 'Post Graduate',
                                            value: Education.postgrad,
                                            align: CrossAxisAlignment.start),
      ]
    );

    Container submitRow = new Container(
      alignment: FractionalOffset.center,
      padding: const EdgeInsets.only(
        top: 10.0, left: 20.0, right: 20.0, bottom: 20.0 ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
              new RaisedButton(
                child: const Text('RESET'),
                onPressed: _reset
                ),
              new Container(width: 10.0),
              new RaisedButton(
                child: const Text('SUBMIT'),
                onPressed: _handleSubmitted,
                )
            ]
      )
    );

    ListView formListView = new ListView(
        controller: formScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[ nameField,
                            mfChoiceField,
                            eyeColorChoiceField,
                            educationChoiceField]);

    Form form = new Form(
        key: _formKey,
        autovalidate: _autovalidate,
        onWillPop: _warnUserAboutInvalidData,
        child: formListView);

    Column mainColumn = new Column(
      children: <Widget>[
        new Flexible(flex:10, child: form),
        new Flexible(flex:1, child: submitRow)
      ]
    );

    Scaffold scaffold = new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: const Text('Radio Buttons')),
        body: mainColumn);

    return scaffold;
  }

 ////////////////////////////////////////////////
  //  end FormField impl
  //  begin support functions
  ////////////////////////////////////////////////

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate()) return true;

    return await showDialog<bool>(
          context: context,
          child: new AlertDialog(
            title: const Text('This form has errors'),
            content: const Text('Really leave this form?'),
            actions: <Widget>[
              new FlatButton(
                child: const Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              new FlatButton(
                child: const Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ) ??
        false;
  }

  void _reset() {
    person.copyFrom(defaultPerson);
    fieldStatePersister.resetToInitialValues();
    _update();
    new Future.delayed(new Duration(milliseconds:50)).then((dynamic a) {
      _formKey.currentState.reset();
    });
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      String sexStr = person.sex.toString().split('.')[1],
             eyeColorStr = person.eyeColor.toString().split('.')[1],
             educationStr = person.education.toString().split('.')[1]
                            .replaceAll('_', ' ');
      showInSnackBar('${person.name} is a ${sexStr},\n'
                     '  eye color is ${eyeColorStr},\n'
                     '  education level is ${educationStr}');
    }
  }

  String _validateName(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return 'Name is required.';
    final RegExp nameExp = new RegExp(r'^[A-za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
