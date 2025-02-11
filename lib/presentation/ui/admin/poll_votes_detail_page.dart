import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PollVotesDetailPage extends StatefulWidget {
  final String pollId;
  final List<String> options; // Lista de opciones de la encuesta
  final List<int> votes; // Lista de votos por opción
  final bool isDarkMode;
  final String title;
  final String winner;

  const PollVotesDetailPage({
    required this.pollId,
    required this.options,
    required this.votes,
    required this.isDarkMode,
    required this.title,
    required this.winner,
    Key? key,
  }) : super(key: key);

  @override
  _PollVotesDetailPageState createState() => _PollVotesDetailPageState();
}

class _PollVotesDetailPageState extends State<PollVotesDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.options.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de los Votos"),
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blue,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          //indicatorPadding: EdgeInsets.zero,
          tabs: widget.options.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            int optionVotes = widget.votes[index];

            return Tab(
              text: "$option ($optionVotes)", // Opción + votos
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.options.asMap().entries.map((entry) {
          int index = entry.key;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('polls')
                .doc(widget.pollId)
                .collection('userVotes')
                .where('voteIndex', isEqualTo: index)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("Aún no hay votos para esta opción."),
                );
              }

              final userVotes = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ListView.builder(
                  itemCount: userVotes.length,
                  itemBuilder: (context, index) {
                    final voteData =
                        userVotes[index].data() as Map<String, dynamic>;

                    String unitName =
                        voteData['unitName'] ?? "Unidad desconocida";
                    Timestamp? timestamp = voteData['timestamp'];

                    String formattedTime = timestamp != null
                        ? DateFormat('dd-MM-yyyy hh:mm a')
                            .format(timestamp.toDate())
                        : "Sin fecha";

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: const BorderSide(width: 0.2),
                        ),
                        child: ListTile(
                          title: Text(
                            unitName,
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.lightBlue
                                  : const Color.fromARGB(255, 29, 56, 207),
                            ),
                          ),
                          subtitle: Text("Fecha: $formattedTime"),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
