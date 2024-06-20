import 'package:flutter/material.dart';
import 'team.dart';
import 'team_database.dart';

class TeamDetailView extends StatefulWidget {
  final Team? team;

  TeamDetailView({this.team});

  @override
  _TeamDetailViewState createState() => _TeamDetailViewState();
}

class _TeamDetailViewState extends State<TeamDetailView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _foundingYearController = TextEditingController();
  DateTime? _lastChampDate;

  @override
  void initState() {
    super.initState();
    if (widget.team != null) {
      _nameController.text = widget.team!.name;
      _foundingYearController.text = widget.team!.foundingYear.toString();
      _lastChampDate = widget.team!.lastChampDate;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastChampDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _lastChampDate) {
      setState(() {
        _lastChampDate = picked;
      });
    }
  }

  Future<void> _saveTeam() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final foundingYear = int.parse(_foundingYearController.text);

      final team = Team(
        id: widget.team?.id,
        name: name,
        foundingYear: foundingYear,
        lastChampDate: _lastChampDate,
      );

      final db = TeamDatabase.instance;
      if (widget.team == null) {
        await db.create(team.toMap());
      } else {
        await db.update(team.id!, team.toMap());
      }

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team == null ? 'New Team' : 'Edit Team'),
        actions: [
          if (widget.team != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final db = TeamDatabase.instance;
                await db.delete(widget.team!.id!);
                Navigator.of(context).pop(true);
              },
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTeam,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre del equipo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre del equipo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _foundingYearController,
                decoration: InputDecoration(labelText: 'Año de Fundación'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Porfavor, ingresa el año de fundación';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  _lastChampDate == null
                      ? 'Fecha no Seleccionada'
                      : 'Last Championship Date: ${TeamDatabase.dateTimeToString(_lastChampDate)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
