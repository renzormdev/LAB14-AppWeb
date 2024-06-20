import 'package:flutter/material.dart';
import 'team_database.dart';
import 'team.dart';
import 'team_detail_view.dart';

class TeamListView extends StatefulWidget {
  @override
  _TeamListViewState createState() => _TeamListViewState();
}

class _TeamListViewState extends State<TeamListView> {
  List<Team> teams = [];

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    final db = TeamDatabase.instance;
    final teamMaps = await db.readAll();
    setState(() {
      teams = teamMaps.map((map) => Team.fromMap(map)).toList();
    });
  }

  Future<void> deleteTeam(int id) async {
    final db = TeamDatabase.instance;
    await db.delete(id);
    fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Equipos')),
      body: teams.isEmpty
          ? Center(child: Text('Equipos no encontrados'))
          : ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text('Fundación: ${team.foundingYear}'),
                        SizedBox(height: 4.0),
                        Text('Ultima fecha de Campeonato: ${_formatDate(team.lastChampDate)}'),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeamDetailView(team: team),
                                  ),
                                ).then((value) => fetchTeams());
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                bool? confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmar eliminación'),
                                      content: Text('¿Estas seguro que quieres eliminar el equipo ${team.name}?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Eliminar'),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirmDelete == true) {
                                  await deleteTeam(team.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TeamDetailView()),
          ).then((value) => fetchTeams());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Desconocido';
    return '${date.day}/${date.month}/${date.year}';
  }
}
